import 'settings.dart';
import 'contact.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String displayName;
  final String avatarUrl;
  final String status;
  final DateTime lastSeen;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Settings settings;
  final List<Contact> contacts;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.displayName,
    required this.avatarUrl,
    required this.status,
    required this.lastSeen,
    required this.createdAt,
    required this.updatedAt,
    required this.settings,
    required this.contacts,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'],
      username: json['username'],
      email: json['email'],
      displayName: json['displayName'],
      avatarUrl: json['avatarUrl'],
      status: json['status'],
      lastSeen: DateTime.parse(json['lastSeen']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      settings: Settings.fromJson(json['settings']),
      contacts: (json['contacts'] as List<dynamic>?)
          ?.map((e) => Contact.fromJson(e))
          .toList() ??
          [],
    );
  }
}
