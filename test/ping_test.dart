import 'package:test/test.dart';

void main() {
  test("Ping", () {
    String ping = "Hello";
    ping += " World";

    expect(ping, equals("Hello World"));
  });
}