import 'package:pel_portal/models/user.dart';

const defaultIconURL = "https://firebasestorage.googleapis.com/v0/b/pacific-esports.appspot.com/o/schools%2Fdefault.png?alt=media&token=1b1c77b9-df1c-4308-9019-d9b7fef32ea8";
const defaultBannerURL = "https://firebasestorage.googleapis.com/v0/b/pacific-esports.appspot.com/o/schools%2Fdefault-banner.png?alt=media&token=fb2dbcfb-fac6-4364-b36b-18015f86b644";

class Team {
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
  String game = "";
  int averageRank = 0;
  DateTime updatedAt = DateTime.now().toUtc();
  DateTime createdAt = DateTime.now().toUtc();

  List<TeamUser> users = [];


  Team();

  Team.fromJson(Map<String, dynamic> json) {
    id = json["id"] ?? "";
    name = json["name"] ?? "";
    tag = json["tag"] ?? "";
    bio = json["bio"] ?? "";
    website = json["website"] ?? "";
    iconURL = json["icon_url"] ?? "";
    bannerURL = json["banner_url"] ?? defaultBannerURL;
    socialTwitterURL = json["social_twitter_url"] ?? "";
    socialInstagramURL = json["social_instagram_url"] ?? "";
    socialTikTokURL = json["social_tiktok_url"] ?? "";
    game = json["game"] ?? "";
    averageRank = json["average_rank"] ?? 0;
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
      "game": game,
      "average_rank": averageRank,
      "updated_at": updatedAt.toIso8601String(),
      "created_at": createdAt.toIso8601String()
    };
  }
}

class TeamUser {
  String teamID = "";
  String userID = "";
  String title = "";
  List<String> roles = [];
  User user = User();
  DateTime createdAt = DateTime.now().toUtc();

  TeamUser();

  TeamUser.fromJson(Map<String, dynamic> json) {
    teamID = json["team_id"] ?? "";
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
      "team_id": teamID,
      "user_id": userID,
      "title": title,
      "roles": roles,
      "created_at": createdAt.toIso8601String()
    };
  }
}

Map<String, String> teamRoles = {
  "ADMIN": "User has full control over the team. They can remove users, change roles, and delete the team. Assign this role carefully.",
  "CAPTAIN": "User is the team captain, they can sign up for tournaments, manage the team, and more.",
  "EDITOR": "User can edit team information, change icon, etc.",
  "ACTIVE": "User is an active member of the team.",
  "RESERVE": "User is a reserve member of the team.",
  "MEMBER": "User is a member of the team. Nothing more, nothing less.",
  "PENDING": "This role marks that the user is pending approval to join the team.",
};

/*
{
  "id": "cloud9",
  "name": "Cloud9",
  "tag": "C9",
  "bio": "",
  "website": "https://cloud9.gg",
  "icon_url": "",
  "banner_url": "https://somebanner.com",
  "game": "Valorant",
  "average_rank": 5,
  "social_twitter_url": "",
  "social_instagram_url": "",
  "social_tiktok_url": "",
  "updated_at": "2023-09-19T12:12:25.987871-07:00",
  "created_at": "0000-12-31T16:07:02-07:52"
}
 */