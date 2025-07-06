
class UserStatus {
  final String username;
  final String status;

  UserStatus({
    required this.username,
    required this.status,
  });
  factory UserStatus.fromJson(Map<String, dynamic> json) {
    return UserStatus(
      username: json['username'],
      status: json['status'],
    );
  }
}