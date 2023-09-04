class Verification {
  String userID = "";
  String type = "";
  String fileURL = "";
  String status = "";
  String comments = "";
  bool isVerified = false;
  bool isEmailVerified = false;
  DateTime updatedAt = DateTime.now().toUtc();
  DateTime createdAt = DateTime.now().toUtc();

  Verification();

  Verification.fromJson(Map<String, dynamic> json) {
    userID = json["user_id"] ?? "";
    type = json["type"] ?? "";
    fileURL = json["file_url"] ?? "";
    status = json["status"] ?? "";
    comments = json["comments"] ?? "";
    isVerified = json["is_verified"] ?? false;
    isEmailVerified = json["is_email_verified"] ?? false;
    updatedAt = DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now().toUtc();
    createdAt = DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userID,
      "type": type,
      "file_url": fileURL,
      "status": status,
      "comments": comments,
      "is_verified": isVerified,
      "is_email_verified": isEmailVerified,
      "updated_at": updatedAt.toIso8601String(),
      "created_at": createdAt.toIso8601String()
    };
  }
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