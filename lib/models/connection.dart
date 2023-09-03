
class Connection {
  String userID = "";
  String key = "";
  String name = "";
  String connection = "";
  DateTime createdAt = DateTime.now().toUtc();

  Connection();

  Connection.fromJson(Map<String, dynamic> json) {
    userID = json["user_id"] ?? "";
    key = json["key"] ?? "";
    name = json["name"] ?? "";
    connection = json["connection"] ?? "";
    createdAt = DateTime.tryParse(json["created_at"]) ?? DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": userID,
      "key": key,
      "name": name,
      "connection": connection,
      "created_at": createdAt.toIso8601String()
    };
  }
}
