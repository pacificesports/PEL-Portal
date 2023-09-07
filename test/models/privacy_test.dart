import 'package:pel_portal/models/privacy.dart';
import 'package:test/test.dart';

void main() {
  group("Privacy", () {
    test("Test Privacy()", () {
      Privacy privacy = Privacy();
      expect(privacy.userID, equals(""));
      expect(privacy.showEmail, equals(true));
      expect(privacy.showPhoneNumber, equals(false));
      expect(privacy.showPronouns, equals(false));
      expect(privacy.pushNotificationsEnabled, equals(false));
      expect(privacy.pushNotificationToken, equals(""));
      expect(privacy.matchRemindersEnabled, equals(false));
    });
    test("Test Privacy.fromJson()", () {
      Privacy privacy = Privacy.fromJson({
        "user_id": "user_id",
        "show_email": true,
        "show_phone_number": true,
        "show_pronouns": true,
        "push_notifications_enabled": true,
        "push_notification_token": "push_notification_token",
        "match_reminders_enabled": true,
        "updated_at": "2023-08-26T04:56:04.32787-07:00",
        "created_at": "0000-12-31T16:07:02-07:52"
      });
      expect(privacy.userID, equals("user_id"));
      expect(privacy.showEmail, equals(true));
      expect(privacy.showPhoneNumber, equals(true));
      expect(privacy.showPronouns, equals(true));
      expect(privacy.pushNotificationsEnabled, equals(true));
      expect(privacy.pushNotificationToken, equals("push_notification_token"));
      expect(privacy.matchRemindersEnabled, equals(true));
    });
  });
  test("Test Privacy.toJson()", () {
    Privacy privacy = Privacy();
    privacy.updatedAt = DateTime.parse("0001-01-01T00:00:00.000Z");
    privacy.createdAt = DateTime.parse("0001-01-01T00:00:00.000Z");
    expect(privacy.toJson(), equals({
      "user_id": "",
      "show_email": true,
      "show_phone_number": false,
      "show_pronouns": false,
      "push_notifications_enabled": false,
      "push_notification_token": "",
      "match_reminders_enabled": false,
      "updated_at": "0001-01-01T00:00:00.000Z",
      "created_at": "0001-01-01T00:00:00.000Z"
    }));
  });
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