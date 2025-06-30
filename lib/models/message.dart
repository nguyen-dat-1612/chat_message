class Message {
  final String id;
  final String type;
  final String username;
  final String text;
  final DateTime time;
  final bool isPending;
  final String? imageBase64;

  Message({
    required this.id,
    required this.type,
    required this.username,
    required this.text,
    required this.time,
    this.isPending = false,
    this.imageBase64,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    try {
      return Message(
        id: json['id']?.toString() ?? '', // Xử lý khi id là null hoặc không phải String
        type: json['type']?.toString() ?? 'chat', // Giá trị mặc định nếu type null
        username: json['username']?.toString() ?? 'Unknown', // Xử lý username null
        text: json['text']?.toString() ?? '', // Đảm bảo text luôn là String
        time: DateTime.tryParse(json['time']?.toString() ?? '') ?? DateTime.now(), // Xử lý parse lỗi
        isPending: json['isPending'] as bool? ?? false, // Xử lý bool null
        imageBase64: json['image']?.toString(), // Giữ nguyên nếu có thể null
      );
    } catch (e) {
      // Xử lý lỗi parse và trả về message lỗi
      return Message(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        type: 'error',
        username: 'System',
        text: 'Failed to parse message: ${e.toString()}',
        time: DateTime.now(),
        isPending: false,
        imageBase64: null,
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'username': username,
      'text': text,
      'time': time.toIso8601String(),
      'isPending': isPending,
      if (imageBase64 != null) 'image': imageBase64,
    };
  }

  Message copyWith({
    String? id,
    String? type,
    String? username,
    String? text,
    DateTime? time,
    bool? isPending,
    String? imageBase64,
  }) {
    return Message(
      id: id ?? this.id,
      type: type ?? this.type,
      username: username ?? this.username,
      text: text ?? this.text,
      time: time ?? this.time,
      isPending: isPending ?? this.isPending,
      imageBase64: imageBase64 ?? this.imageBase64,
    );
  }
}