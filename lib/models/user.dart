
import 'package:pel_portal/models/connection.dart';
import 'package:pel_portal/models/privacy.dart';
import 'package:pel_portal/models/user_school.dart';
import 'package:pel_portal/models/verification.dart';

class User {
  String id = "";
  String firstName = "";
  String lastName = "";
  String preferredName = "";
  String pronouns = "";
  String email = "";
  String profilePictureURL = "";
  String bio = "";
  String gender = "Male";
  List<String> roles = [];
  Privacy privacy = Privacy();
  UserSchool school = UserSchool();
  Verification verification = Verification();
  List<Connection> connections = [];
  DateTime updatedAt = DateTime.now().toUtc();
  DateTime createdAt = DateTime.now().toUtc();

  User();

  User.fromJson(Map<String, dynamic> json) {
    id = json["id"] ?? "";
    firstName = json["first_name"] ?? "";
    lastName = json["last_name"] ?? "";
    preferredName = json["preferred_name"] ?? "";
    pronouns = json["pronouns"] ?? "";
    email = json["email"] ?? "";
    profilePictureURL = json["profile_picture_url"] ?? "";
    bio = json["bio"] ?? "";
    gender = json["gender"] ?? "";
    for (int i = 0; i < json["roles"].length; i++) {
      roles.add(json["roles"][i]);
    }
    privacy = Privacy.fromJson(json["privacy"] ?? {});
    school = UserSchool.fromJson(json["school"] ?? {});
    verification = Verification.fromJson(json["verification"] ?? {});
    for (int i = 0; i < json["connections"].length; i++) {
      connections.add(Connection.fromJson(json["connections"][i]));
    }
    updatedAt = DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now().toUtc();
    createdAt = DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now().toUtc();
  }

  Connection getConnection(String key) {
    for (int i = 0; i < connections.length; i++) {
      if (connections[i].key == key) {
        return connections[i];
      }
    }
    return Connection();
  }

  bool canSeeAdmin() {
    return isAdmin() || canVerify() || canCreateTournament();
  }

  bool isAdmin() {
    return roles.contains("ADMIN");
  }

  bool canVerify() {
    return roles.contains("ADMIN") || roles.contains("VERIFICATION_WRITE");
  }

  bool canCreateTournament() {
    return roles.contains("ADMIN") || roles.contains("TOURNAMENT_WRITE");
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "first_name": firstName,
      "last_name": lastName,
      "preferred_name": preferredName,
      "pronouns": pronouns,
      "email": email,
      "profile_picture_url": profilePictureURL,
      "bio": bio,
      "gender": gender,
      "roles": roles,
      "privacy": privacy,
      "school": school,
      "verification": verification,
      "connections": connections,
      "updated_at": updatedAt.toIso8601String(),
      "created_at": createdAt.toIso8601String()
    };
  }

  @override
  String toString() {
    return "[$id] $firstName $lastName";
  }
}

/*
{
  "id": "348220961155448833",
  "first_name": "bharat",
  "last_name": "kathi",
  "preferred_name": "",
  "pronouns": "",
  "email": "",
  "profile_picture_url": "",
  "bio": "",
  "gender": "",
  "roles": [],
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
    "school": null,
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
  "connections": [],
  "updated_at": "0001-01-01T00:00:00Z",
  "created_at": "0001-01-01T00:00:00Z"
}
*/