import 'package:pel_portal/models/connection.dart';
import 'package:test/test.dart';

void main() {
  group("Connection", () {
    test("Test Connection()", () {
      Connection connection = Connection();
      expect(connection.userID, equals(""));
      expect(connection.key, equals(""));
      expect(connection.name, equals(""));
      expect(connection.connection, equals(""));
    });
    test("Test Connection.fromJson()", () {
      Connection connection = Connection.fromJson({
      "user_id": "userID",
      "key": "key",
      "name": "name",
      "connection": "connection",
      "created_at": "0001-01-01T00:00:00.000Z"
      });
      expect(connection.userID, equals("userID"));
      expect(connection.key, equals("key"));
      expect(connection.name, equals("name"));
      expect(connection.connection, equals("connection"));
      expect(connection.createdAt, equals(DateTime.parse("0001-01-01T00:00:00.000Z")));
    });
    test("Test Connection.toJson()", () {
      Connection connection = Connection();
      connection.userID = "userID";
      connection.key = "key";
      connection.name = "name";
      connection.connection = "connection";
      connection.createdAt = DateTime.parse("0001-01-01T00:00:00.000Z");
      expect(connection.toJson(), equals({
        "user_id": "userID",
        "key": "key",
        "name": "name",
        "connection": "connection",
        "created_at": "0001-01-01T00:00:00.000Z"
      }));
    });
  });
}

/*
{
      "user_id": userID,
      "key": key,
      "name": name,
      "connection": connection,
      "created_at": 0001-01-01T00:00:00.000Z
}
 */