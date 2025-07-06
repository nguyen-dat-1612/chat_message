class NotificationSettings {
  final bool message;
  final bool group;

  NotificationSettings({
    required this.message,
    required this.group,
  });

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      message: json['message'],
      group: json['group'],
    );
  }
}
