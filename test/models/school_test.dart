import 'package:pel_portal/models/school.dart';
import 'package:test/test.dart';

void main() {
  group("School", () {
    test("Test School()", () {
      School school = School();
      expect(school.id, equals(""));
      expect(school.name, equals(""));
      expect(school.description, equals(""));
      expect(school.website, equals(""));
      expect(school.type, equals(""));
      expect(school.address, equals(""));
      expect(school.verified, equals(false));
      expect(school.tags, equals([]));
    });
    test("Test School.fromJson()", () {
      School school = School.fromJson({
        "id": "ucsb",
        "name": "University of California, Santa Barbara",
        "description": "description",
        "website": "https://uscb.edu",
        "icon_url": "icon_url",
        "banner_url": "banner_url",
        "type": "COLLEGE",
        "address": "Santa Barbara, CA",
        "verified": false,
        "tags": [
          {
            "school_id": "ucsb",
            "tag": "ucsb",
            "created_at": "2023-08-26T04:56:58.196051-07:00"
          },
          {
            "school_id": "ucsb",
            "tag": "another-tag",
            "created_at": "2023-08-26T04:56:58.196051-07:00"
          }
        ],
        "emails": [
          {
            "school_id": "ucsb",
            "email": "@ucsb.edu",
            "created_at": "2023-08-28T13:52:02.307784-07:00"
          }
        ],
        "updated_at": "2023-08-26T04:56:04.32787-07:00",
        "created_at": "0000-12-31T16:07:02-07:52"
      });
      expect(school.id, equals("ucsb"));
      expect(school.name, equals("University of California, Santa Barbara"));
      expect(school.description, equals("description"));
      expect(school.website, equals("https://uscb.edu"));
      expect(school.iconURL, equals("icon_url"));
      expect(school.bannerURL, equals("banner_url"));
      expect(school.type, equals("COLLEGE"));
      expect(school.address, equals("Santa Barbara, CA"));
      expect(school.verified, equals(false));
      expect(school.tags, containsAll(["ucsb", "another-tag"]));
      expect(school.emails, containsAll(["@ucsb.edu"]));
    });
    test("Test School.toJson()", () {
      School school = School();
      school.id = "ucsb";
      school.name = "University of California, Santa Barbara";
      school.description = "description";
      school.website = "https://uscb.edu";
      school.iconURL = "icon_url";
      school.bannerURL = "banner_url";
      school.type = "COLLEGE";
      school.address = "Santa Barbara, CA";
      school.verified = false;
      var json = school.toJson();
      expect(json["id"], equals("ucsb"));
      expect(json["name"], equals("University of California, Santa Barbara"));
      expect(json["description"], equals("description"));
      expect(json["website"], equals("https://uscb.edu"));
      expect(json["icon_url"], equals("icon_url"));
      expect(json["banner_url"], equals("banner_url"));
      expect(json["type"], equals("COLLEGE"));
      expect(json["address"], equals("Santa Barbara, CA"));
      expect(json["verified"], equals(false));
    });
  });
}

/*
{
    "id": "ucsb",
    "name": "University of California, Santa Barbara",
    "description": "description",
    "website": "https://uscb.edu",
    "icon_url": "icon_url",
    "banner_url": "banner_url",
    "type": "COLLEGE",
    "address": "Santa Barbara, CA",
    "verified": false,
    "tags": [
      {
        "school_id": "ucsb",
        "tag": "ucsb",
        "created_at": "2023-08-26T04:56:58.196051-07:00"
      }
    ],
    "emails": [
      {
        "school_id": "ucsb",
        "email": "@ucsb.edu",
        "created_at": "2023-08-28T13:52:02.307784-07:00"
      }
    ],
    "updated_at": "2023-08-26T04:56:04.32787-07:00",
    "created_at": "0000-12-31T16:07:02-07:52"
  }
 */