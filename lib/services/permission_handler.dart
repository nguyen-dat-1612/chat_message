import 'package:permission_handler/permission_handler.dart';

Future<bool> requestCameraAndMicPermissions() async {
  final cameraStatus = await Permission.camera.request();
  final micStatus = await Permission.microphone.request();

  return cameraStatus.isGranted && micStatus.isGranted;
}