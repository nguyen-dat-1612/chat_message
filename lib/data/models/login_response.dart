import 'package:chat_message_websocket/data/models/user.dart';

class LoginResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  LoginResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      user: User.fromJson(json['home']),
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
