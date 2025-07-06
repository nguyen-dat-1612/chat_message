import 'notification_settings.dart';

class Settings {
  final String theme;
  final NotificationSettings notification;

  Settings({
    required this.theme,
    required this.notification,
  });

  factory Settings.fromJson(Map<String, dynamic> json) {
    return Settings(
      theme: json['theme'],
      notification: NotificationSettings.fromJson(json['notification']),
    );
  }
}