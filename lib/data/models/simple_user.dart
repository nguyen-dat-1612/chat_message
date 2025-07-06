class SimpleUser {
  final String id;
  final String username;
  final String displayName;
  final String avatarUrl;
  final String status;
  final DateTime lastSeen;

  SimpleUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.avatarUrl,
    required this.status,
    required this.lastSeen,
  });

  factory SimpleUser.fromJson(Map<String, dynamic> json) {
    return SimpleUser(
      id: json['_id'] ?? json['id'],
      username: json['username'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      status: 'offline',
      lastSeen: DateTime.parse(json['lastSeen']),
    );
  }

  SimpleUser copyWith({
    String? status,
  }) {
    return SimpleUser(
      id: id,
      username: username,
      displayName: displayName,
      avatarUrl: avatarUrl,
      lastSeen: lastSeen,
      status: status ?? this.status,
    );
  }
}
