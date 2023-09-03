class Privacy {
  String userID = "";
  bool showEmail = true;
  bool showPhoneNumber = false;
  bool showPronouns = false;
  bool pushNotificationsEnabled = false;
  String pushNotificationToken = "";
  bool matchRemindersEnabled = false;
  DateTime updatedAt = DateTime.now().toUtc();
  DateTime createdAt = DateTime.now().toUtc();

  Privacy();

  Privacy.fromJson(Map<String, dynamic> json) {
    userID = json["user_id"] ?? "";
    showEmail = json["show_email"] ?? false;
    showPhoneNumber = json["show_phone_number"] ?? false;
    showPronouns = json["show_pronouns"] ?? false;
    pushNotificationsEnabled = json["push_notifications_enabled"] ?? false;
    pushNotificationToken = json["push_notification_token"] ?? "";
    matchRemindersEnabled = json["match_reminders_enabled"] ?? false;
    updatedAt = DateTime.tryParse(json["updated_at"]) ?? DateTime.now().toUtc();
    createdAt = DateTime.tryParse(json["created_at"]) ?? DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userID,
      "show_email": showEmail,
      "show_phone_number": showPhoneNumber,
      "show_pronouns": showPronouns,
      "push_notifications_enabled": pushNotificationsEnabled,
      "push_notification_token": pushNotificationToken,
      "match_reminders_enabled": matchRemindersEnabled,
      "updated_at": updatedAt.toIso8601String(),
      "created_at": createdAt.toIso8601String()
    };
  }
}

/*
{
  "user_id": "",
  "show_email": false,
  "show_phone_number": false,
  "show_pronouns": false,
  "push_notifications_enabled": false,
  "push_notification_token": "",
  "match_reminders_enabled": false,
  "updated_at": "0001-01-01T00:00:00Z",
  "created_at": "0001-01-01T00:00:00Z"
}
 */