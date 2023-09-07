import 'package:flutter_test/flutter_test.dart';
import 'package:pel_portal/models/connection.dart';
import 'package:pel_portal/models/user.dart';

void main() {
  group("User", () {
    test("Test User()", () {
      User user = User();
      expect(user.id, equals(""));
    });
    test("Test User.fromJson()", () {
      User user = User.fromJson({
        "id": "348220961155448833",
        "first_name": "bharat",
        "last_name": "kathi",
        "preferred_name": "",
        "pronouns": "",
        "email": "",
        "profile_picture_url": "",
        "bio": "",
        "gender": "",
        "roles": ["TEST_ROLE"],
        "privacy": {
          "user_id": "",
          "show_email": false,
          "show_phone_number": false,
          "show_pronouns": false,
          "push_notifications_enabled": false,
          "push_notification_token": "",
          "match_reminders_enabled": false,
          "updated_at": "0001-01-01T00:00:00Z",
          "created_at": "0001-01-01T00:00:00Z"
        },
        "school": {
          "user_id": "",
          "school_id": "",
          "school": {
            "updated_at": "0001-01-01T00:00:00.000Z",
            "created_at": "0001-01-01T00:00:00.000Z"
          },
          "graduation_year": 0,
          "updated_at": "0001-01-01T00:00:00Z",
          "created_at": "0001-01-01T00:00:00Z"
        },
        "verification": {
          "user_id": "",
          "type": "",
          "file_url": "",
          "status": "",
          "comments": "",
          "is_verified": false,
          "is_email_verified": false,
          "updated_at": "0001-01-01T00:00:00Z",
          "created_at": "0001-01-01T00:00:00Z"
        },
        "connections": [{
          "user_id": "userID",
          "key": "key",
          "name": "name",
          "connection": "connection",
          "created_at": "0001-01-01T00:00:00Z"
        }],
        "updated_at": "0001-01-01T00:00:00Z",
        "created_at": "0001-01-01T00:00:00Z"
      });
      expect(user.id, equals("348220961155448833"));
      expect(user.firstName, equals("bharat"));
      expect(user.lastName, equals("kathi"));
    });
    test("Test User.toJson()", () {
      User user = User();
      user.updatedAt = DateTime.parse("0001-01-01T00:00:00Z");
      user.createdAt = DateTime.parse("0001-01-01T00:00:00Z");
      expect(user.toJson()["id"], equals(""));
    });
    test("Test User.getConnection()", () {
      User user = User();
      user.connections = [
        Connection.fromJson({
          "user_id": "userID",
          "key": "key",
          "name": "name",
          "connection": "connection",
          "created_at": "0001-01-01T00:00:00Z"
        })
      ];
      expect(user.getConnection("key").connection, equals(user.connections[0].connection));
      expect(user.getConnection("key_not_found").connection, equals(""));
    });
    test("Test User.toString()", () {
      User user = User();
      user.id = "348220961155448833";
      user.firstName = "bharat";
      user.lastName = "kathi";
      assert(user.toString() == "[348220961155448833] bharat kathi");
    });
  });
}