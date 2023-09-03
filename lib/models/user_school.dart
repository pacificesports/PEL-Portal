import 'package:pel_portal/models/school.dart';

class UserSchool {
  String userID = "";
  String schoolID = "";
  School school = School();
  int graduationYear = 0;
  DateTime updatedAt = DateTime.now().toUtc();
  DateTime createdAt = DateTime.now().toUtc();

  UserSchool();

  UserSchool.fromJson(Map<String, dynamic> json) {
    userID = json["user_id"] ?? "";
    schoolID = json["school_id"] ?? "";
    school = School.fromJson(json["school"] ?? {});
    graduationYear = json["graduation_year"] ?? 0;
    updatedAt = DateTime.tryParse(json["updated_at"]) ?? DateTime.now().toUtc();
    createdAt = DateTime.tryParse(json["created_at"]) ?? DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userID,
      "school_id": schoolID,
      "school": school.toJson(),
      "graduation_year": graduationYear,
      "updated_at": updatedAt.toIso8601String(),
      "created_at": createdAt.toIso8601String()
    };
  }
}

/*
{
    "user_id": "348220961155448833",
    "school_id": "ucsb",
    "school": {},
    "graduation_year": 2025,
    "updated_at": "0001-01-01T00:00:00Z",
    "created_at": "0001-01-01T00:00:00Z"
  }
 */