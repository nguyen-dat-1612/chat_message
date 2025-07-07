import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../services/websocket_service.dart';
import '../../core/utils/logger.dart';

class VideoCallScreen extends StatefulWidget {
  final String currentUsername;
  final String partnerUsername;
  final bool isCaller;

  const VideoCallScreen({
    super.key,
    required this.currentUsername,
    required this.partnerUsername,
    required this.isCaller,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final _localRenderer = RTCVideoRenderer();
  final _remoteRenderer = RTCVideoRenderer();
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;

  bool _isConnecting = false;
  bool _isCallActive = false;
  bool _hasRemoteStream = false;

  final List<RTCIceCandidate> _localIceQueue = [];
  final List<RTCIceCandidate> _remoteIceQueue = [];
  bool _localDescriptionSet = false;
  bool _remoteDescriptionSet = false;
  bool _canSendIce = false;
  bool _canProcessIce = false;

  @override
  void initState() {
    super.initState();

    _prepareConnection().then((_) {
      _setupWebSocketCallbacks();

      if (!widget.isCaller) {
        context.read<WebSocketService>().sendCallAccept(
          to: widget.partnerUsername,
        );
        logger.i('[CALL] Đã gửi call_accept đến ${widget.partnerUsername}');
      }
    });
  }

  void _setupWebSocketCallbacks() {
    final socket = context.read<WebSocketService>();

    socket.onSdp = (from, data) async {
      if (from != widget.partnerUsername || _peerConnection == null)  {
        logger.e('[SDP] Nhận tin nhắn không hợp lệ từ $from hoặc là __peerConnection chưa sẵn sàng');
        return;
      };

      try {
        final remoteSdp = RTCSessionDescription(data['sdp'], data['type']);
        await _peerConnection!.setRemoteDescription(remoteSdp);
        _remoteDescriptionSet = true;
        logger.d('[SDP] Đã set remote SDP (${data['type']}) từ $from');

        _checkReadyToProcessIce();

        if (data['type'] == 'offer') {
          final answer = await _peerConnection!.createAnswer();
          await _peerConnection!.setLocalDescription(answer);
          _localDescriptionSet = true;
          socket.sendSDP(widget.partnerUsername, answer);
          logger.d('[SDP] Đã tạo và gửi SDP answer đến ${widget.partnerUsername}');
          _checkReadyToSendIce();
        }
      } catch (e) {
        logger.e('[SDP] Lỗi xử lý SDP', error: e);
      }
    };

    socket.onIce = (from, data) async {
      if (from != widget.partnerUsername || _peerConnection == null) return;

      try {
        final candidate = RTCIceCandidate(data['candidate'], data['sdpMid'], data['sdpMLineIndex']);
        if (_canProcessIce) {
          await _peerConnection!.addCandidate(candidate);
          logger.d('[ICE] Đã add ICE candidate từ $from');
        } else {
          _remoteIceQueue.add(candidate);
          logger.d('[ICE] Đã thêm vào hàng đợi ICE từ $from');
        }
      } catch (e) {
        logger.e('[ICE] Lỗi xử lý ICE', error: e);
      }
    };

    socket.onHangup = (from) {
      if (from == widget.partnerUsername) {
        logger.i('[CALL] Nhận tín hiệu kết thúc từ $from');
        _cleanup();
        Navigator.pop(context);
      }
    };
  }

  void _checkReadyToProcessIce() {
    if (_localDescriptionSet && _remoteDescriptionSet && !_canProcessIce) {
      _canProcessIce = true;
      logger.d('[ICE] Sẵn sàng xử lý ICE từ xa');
      for (var candidate in _remoteIceQueue) {
        _peerConnection!.addCandidate(candidate);
      }
      _remoteIceQueue.clear();
    }
  }

  void _checkReadyToSendIce() {
    if (_localDescriptionSet && _remoteDescriptionSet && !_canSendIce) {
      _canSendIce = true;
      final socket = context.read<WebSocketService>();
      for (var candidate in _localIceQueue) {
        socket.sendICE(widget.partnerUsername, candidate);
      }
      logger.d('[ICE] Đã gửi toàn bộ ICE cục bộ');
      _localIceQueue.clear();
    }
  }

  Future<void> _prepareConnection() async {
    logger.i('[CALL] Khởi tạo kết nối WebRTC');
    try {
      setState(() => _isConnecting = true);
      await _localRenderer.initialize();
      await _remoteRenderer.initialize();

      _localStream = await navigator.mediaDevices.getUserMedia({
        'audio': true,
        'video': {'facingMode': 'home'},
      });
      _localRenderer.srcObject = _localStream;

      final config = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
          {
            'urls': 'turn:openrelay.metered.ca:80',
            'username': 'openrelayproject',
            'credential': 'openrelayproject'
          }
        ],
      };

      _peerConnection = await createPeerConnection(config);

      _peerConnection!.onIceCandidate = (candidate) {
        if (candidate.candidate != null) {
          if (_canSendIce) {
            context.read<WebSocketService>().sendICE(widget.partnerUsername, candidate);
          } else {
            _localIceQueue.add(candidate);
          }
        }
      };

      _peerConnection!.onTrack = (event) {
        if (event.streams.isNotEmpty) {
          setState(() {
            _remoteRenderer.srcObject = event.streams.first;
            _hasRemoteStream = true;
            _isCallActive = true;
            _isConnecting = false;
          });
        }
      };

      _peerConnection!.onConnectionState = (state) {
        if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
          setState(() {
            _isCallActive = true;
            _isConnecting = false;
          });
          logger.i('[CALL] Đã kết nối thành công');
        }
      };

      for (var track in _localStream!.getTracks()) {
        _peerConnection!.addTrack(track, _localStream!);
      }

      context.read<WebSocketService>().onCallAccepted = (from) async {
        logger.i('[CALL] Nhận call_accept từ $from');

        // 🛠️ Bây giờ mới tạo và gửi SDP OFFER
        final offer = await _peerConnection!.createOffer();
        await _peerConnection!.setLocalDescription(offer);
        _localDescriptionSet = true;
        context.read<WebSocketService>().sendSDP(widget.partnerUsername, offer);
        logger.i('[CALL] Đã gửi SDP offer đến $from');

        _checkReadyToSendIce();

        Future.delayed(const Duration(seconds: 10), () {
          if (!_remoteDescriptionSet) {
            logger.w('[CALL] Không nhận được SDP answer sau 10s');
            _cleanup();
            if (mounted) Navigator.pop(context);
          }
        });
      };

    } catch (e) {
      logger.e('[CALL] Lỗi khởi tạo cuộc gọi', error: e);
      setState(() => _isConnecting = false);
    }
    logger.i('[CALL] Khởi tạo kết nối thành công WebRTC');
  }

  void _cleanup() {
    logger.i('[CALL] Dọn dẹp kết nối');
    _peerConnection?.close();
    _localStream?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();

    final socket = context.read<WebSocketService>();
    socket.onSdp = null;
    socket.onIce = null;
    socket.onHangup = null;
  }

  @override
  void dispose() {
    _cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (_hasRemoteStream)
            RTCVideoView(_remoteRenderer)
          else
            Center(
              child: Text(
                'Đang chờ ${widget.partnerUsername}...',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),

          Positioned(
            right: 20,
            bottom: 100,
            width: 120,
            height: 160,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: RTCVideoView(_localRenderer, mirror: true),
              ),
            ),
          ),

          if (_isConnecting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text('Đang kết nối...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            ),

          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.red,
                  child: const Icon(Icons.call_end, color: Colors.white),
                  onPressed: () {
                    context.read<WebSocketService>().sendHangup(widget.partnerUsername);
                    _cleanup();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}