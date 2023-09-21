import 'package:pel_portal/models/user.dart';

const defaultIconURL = "https://firebasestorage.googleapis.com/v0/b/pacific-esports.appspot.com/o/schools%2Fdefault.png?alt=media&token=1b1c77b9-df1c-4308-9019-d9b7fef32ea8";
const defaultBannerURL = "https://firebasestorage.googleapis.com/v0/b/pacific-esports.appspot.com/o/schools%2Fdefault-banner.png?alt=media&token=fb2dbcfb-fac6-4364-b36b-18015f86b644";

class Organization {
  String id = "";
  String name = "";
  String tag = "";
  String bio = "";
  String website = "";
  String iconURL = defaultIconURL;
  String bannerURL = defaultBannerURL;
  String socialTwitterURL = "";
  String socialInstagramURL = "";
  String socialTikTokURL = "";
  bool verified = false;
  DateTime updatedAt = DateTime.now().toUtc();
  DateTime createdAt = DateTime.now().toUtc();

  List<OrganizationUser> users = [];


  Organization();

  Organization.fromJson(Map<String, dynamic> json) {
    id = json["id"] ?? "";
    name = json["name"] ?? "";
    tag = json["tag"] ?? "";
    bio = json["bio"] ?? "";
    website = json["website"] ?? "";
    iconURL = json["icon_url"] ?? "";
    bannerURL = json["banner_url"] ?? "";
    socialTwitterURL = json["social_twitter_url"] ?? "";
    socialInstagramURL = json["social_instagram_url"] ?? "";
    socialTikTokURL = json["social_tiktok_url"] ?? "";
    verified = json["verified"] ?? false;
    updatedAt = DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now().toUtc();
    createdAt = DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "tag": tag,
      "bio": bio,
      "website": website,
      "icon_url": iconURL,
      "banner_url": bannerURL,
      "social_twitter_url": socialTwitterURL,
      "social_instagram_url": socialInstagramURL,
      "social_tiktok_url": socialTikTokURL,
      "verified": verified,
      "updated_at": updatedAt.toIso8601String(),
      "created_at": createdAt.toIso8601String()
    };
  }
}

class OrganizationUser {
  String organizationID = "";
  String userID = "";
  String title = "";
  List<String> roles = [];
  User user = User();
  DateTime createdAt = DateTime.now().toUtc();

  OrganizationUser();

  OrganizationUser.fromJson(Map<String, dynamic> json) {
    organizationID = json["organization_id"] ?? "";
    userID = json["user_id"] ?? "";
    title = json["title"] ?? "";
    for (int i = 0; i < json["roles"].length; i++) {
      roles.add(json["roles"][i]);
    }
    user = User.fromJson(json["user"]);
    createdAt = DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    return {
      "organization_id": organizationID,
      "user_id": userID,
      "title": title,
      "roles": roles,
      "created_at": createdAt.toIso8601String()
    };
  }
}

Map<String, String> organizationRoles = {
  "ADMIN": "User has full control over the organization. They can remove users, change roles, and delete the organization. Assign this role carefully.",
  "EDITOR": "User can edit organization information, change icon and banners, ",
  "MEMBER": "User is a member of the organization. Nothing more, nothing less.",
  "PENDING": "This role marks that the user is pending approval to join the organization.",
};

/*
{
  "id": "test",
  "name": "Test Org",
  "tag": "TST",
  "bio": "",
  "website": "",
  "icon_url": "",
  "banner_url": "",
  "social_twitter_url": "",
  "social_instagram_url": "",
  "social_tiktok_url": "",
  "verified": false,
  "updated_at": "2023-09-19T11:34:31.809223-07:00",
  "created_at": "0000-12-31T16:07:02-07:52"
}
 */