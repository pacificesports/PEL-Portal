import 'package:flutter_test/flutter_test.dart';
import 'package:pel_portal/models/verification.dart';

void main() {
  group("Verification", () {
    test("Test Verification()", () {
      Verification verification = Verification();
      expect(verification.userID, equals(""));
      expect(verification.type, equals(""));
      expect(verification.fileURL, equals(""));
      expect(verification.status, equals(""));
      expect(verification.comments, equals(""));
      expect(verification.isVerified, equals(false));
      expect(verification.isEmailVerified, equals(false));
    });
    test("Test Verification.fromJson()", () {
      Verification verification = Verification.fromJson({
        "user_id": "userID",
        "type": "type",
        "file_url": "fileURL",
        "status": "status",
        "comments": "comments",
        "is_verified": true,
        "is_email_verified": true,
        "updated_at": "0001-01-01T00:00:00.000Z",
        "created_at": "0001-01-01T00:00:00.000Z"
      });
      expect(verification.userID, equals("userID"));
      expect(verification.type, equals("type"));
      expect(verification.fileURL, equals("fileURL"));
      expect(verification.status, equals("status"));
      expect(verification.comments, equals("comments"));
      expect(verification.isVerified, equals(true));
      expect(verification.isEmailVerified, equals(true));
    });
    test("Test Verification.toJson()", () {
      Verification verification = Verification();
      verification.updatedAt = DateTime.parse("0001-01-01T00:00:00.000Z");
      verification.createdAt = DateTime.parse("0001-01-01T00:00:00.000Z");
      expect(verification.toJson(), equals({
        "user_id": "",
        "type": "",
        "file_url": "",
        "status": "",
        "comments": "",
        "is_verified": false,
        "is_email_verified": false,
        "updated_at": "0001-01-01T00:00:00.000Z",
        "created_at": "0001-01-01T00:00:00.000Z"
      }));
    });
  });
}

/*
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
 */