import 'package:flutter_test/flutter_test.dart';
import 'package:pel_portal/models/version.dart';

void main() {
  group("Version", () {
    test("Test Version()", () {
      Version version = Version("1.2.3+4");
      expect(version.major, equals(1));
      expect(version.minor, equals(2));
      expect(version.patch, equals(3));
      expect(version.build, equals(4));
    });
    test("Test Version.toString()", () {
      Version version = Version("1.2.3+4");
      expect(version.toString(), equals("1.2.3"));
    });
    test("Test Version.getVersionCode()", () {
      Version version = Version("1.2.3+4");
      expect(version.getVersionCode(), equals(1002003));
    });
    test("Test Version.getBuild()", () {
      Version version = Version("1.2.3+4");
      expect(version.getBuild(), equals(4));
    });
  });
}