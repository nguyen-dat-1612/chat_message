
class AuthModel {
  final String username;
  final String token;

  AuthModel({required this.username, required this.token});

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      username: json['username'],
      token: json['token'],
    );
  }
}