class School {
  String id = "";
  String name = "";
  String description = "";
  String website = "";
  String iconURL = "";
  String bannerURL = "";
  String type = "";
  String address = "";
  bool verified = false;
  List<String> tags = [];
  List<String> emails = [];
  DateTime updatedAt = DateTime.now().toUtc();
  DateTime createdAt = DateTime.now().toUtc();

  School();

  School.fromJson(Map<String, dynamic> json) {
    id = json["id"] ?? "";
    name = json["name"] ?? "";
    description = json["description"] ?? "";
    website = json["website"] ?? "";
    iconURL = json["icon_url"] ?? "";
    bannerURL = json["banner_url"] ?? "";
    type = json["type"] ?? "";
    address = json["address"] ?? "";
    verified = json["verified"] ?? false;
    for (var tag in json["tags"] ?? []) {
      tags.add(tag["tag"] ?? "");
    }
    for (var email in json["emails"] ?? []) {
      emails.add(email["email"] ?? "");
    }
    updatedAt = DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now().toUtc();
    createdAt = DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "website": website,
      "icon_url": iconURL,
      "banner_url": bannerURL,
      "type": type,
      "address": address,
      "verified": verified,
      "updated_at": updatedAt.toIso8601String(),
      "created_at": createdAt.toIso8601String()
    };
  }
}

/*
{
    "id": "ucsb",
    "name": "University of California, Santa Barbara",
    "description": "The University of California, Santa Barbara, is a public land-grant research university in Santa Barbara, California, United States. It is part of the University of California university system.",
    "website": "https://uscb.edu",
    "icon_url": "https://firebasestorage.googleapis.com/v0/b/pacific-esports.appspot.com/o/schools%2Fucsb.jpg?alt=media\u0026token=009b776e-bcee-41a6-8cc1-c805caea85ce",
    "banner_url": "https://firebasestorage.googleapis.com/v0/b/pacific-esports.appspot.com/o/schools%2Fucsb-banner.jpeg?alt=media\u0026token=bd36d86e-bc69-48be-a734-41b3b4848123",
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