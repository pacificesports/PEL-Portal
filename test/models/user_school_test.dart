import 'package:flutter_test/flutter_test.dart';
import 'package:pel_portal/models/user_school.dart';

void main() {
  group("UserSchool", () {
    test("Test UserSchool()", () {
      UserSchool userSchool = UserSchool();
      expect(userSchool.userID, equals(""));
      expect(userSchool.schoolID, equals(""));
      expect(userSchool.graduationYear, equals(0));
    });
    test("Test UserSchool.fromJson()", () {
      UserSchool userSchool = UserSchool.fromJson({
        "user_id": "userID",
        "school_id": "schoolID",
        "school": {
          "updated_at": "0001-01-01T00:00:00.000Z",
          "created_at": "0001-01-01T00:00:00.000Z"
        },
        "graduation_year": 2025,
        "updated_at": "0001-01-01T00:00:00.000Z",
        "created_at": "0001-01-01T00:00:00.000Z"
      });
      expect(userSchool.userID, equals("userID"));
      expect(userSchool.schoolID, equals("schoolID"));
      expect(userSchool.graduationYear, equals(2025));
    });
    test("Test UserSchool.toJson()", () {
      UserSchool userSchool = UserSchool();
      userSchool.updatedAt = DateTime.parse("0001-01-01T00:00:00.000Z");
      userSchool.createdAt = DateTime.parse("0001-01-01T00:00:00.000Z");
      expect(userSchool.toJson()["user_id"], equals(""));
    });
  });
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