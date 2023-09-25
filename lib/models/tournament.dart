import 'package:pel_portal/models/team.dart';

const defaultBannerURL = "https://firebasestorage.googleapis.com/v0/b/pacific-esports.appspot.com/o/schools%2Fdefault-banner.png?alt=media&token=fb2dbcfb-fac6-4364-b36b-18015f86b644";

class Tournament {
  String id = "";
  String name = "";
  String description = "";
  String game = "";
  String bannerURL = defaultBannerURL;
  int minRank = 0;
  int maxRank = 0;
  DateTime registrationStart = DateTime.now().toUtc();
  DateTime registrationEnd = DateTime.now().toUtc();
  DateTime seasonStart = DateTime.now().toUtc();
  DateTime seasonEnd = DateTime.now().toUtc();
  DateTime updatedAt = DateTime.now().toUtc();
  DateTime createdAt = DateTime.now().toUtc();

  List<TournamentTeam> teams = [];

  Tournament();

  Tournament.fromJson(Map<String, dynamic> json) {
    id = json["id"] ?? "";
    name = json["name"] ?? "";
    description = json["description"] ?? "";
    game = json["game"] ?? "";
    bannerURL = json["banner_url"] ?? defaultBannerURL;
    minRank = json["min_rank"] ?? 0;
    maxRank = json["max_rank"] ?? 0;
    registrationStart = DateTime.tryParse(json["registration_start"] ?? "") ?? DateTime.now().toUtc();
    registrationEnd = DateTime.tryParse(json["registration_end"] ?? "") ?? DateTime.now().toUtc();
    seasonStart = DateTime.tryParse(json["season_start"] ?? "") ?? DateTime.now().toUtc();
    seasonEnd = DateTime.tryParse(json["season_end"] ?? "") ?? DateTime.now().toUtc();
    updatedAt = DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now().toUtc();
    createdAt = DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "description": description,
      "game": game,
      "banner_url": bannerURL,
      "min_rank": minRank,
      "max_rank": maxRank,
      "registration_start": registrationStart.toIso8601String(),
      "registration_end": registrationEnd.toIso8601String(),
      "season_start": seasonStart.toIso8601String(),
      "season_end": seasonEnd.toIso8601String(),
      "updated_at": updatedAt.toIso8601String(),
      "created_at": createdAt.toIso8601String()
    };
  }
}

class TournamentTeam {
  String tournamentID = "";
  String teamID = "";
  Team team = Team();
  DateTime createdAt = DateTime.now().toUtc();

  TournamentTeam();

  TournamentTeam.fromJson(Map<String, dynamic> json) {
    tournamentID = json["tournament_id"] ?? "";
    teamID = json["team_id"] ?? "";
    team = Team.fromJson(json["team"] ?? {});
    createdAt = DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now().toUtc();
  }

  Map<String, dynamic> toJson() {
    return {
      "tournament_id": tournamentID,
      "team_id": teamID,
      "team": team.toJson(),
      "created_at": createdAt.toIso8601String()
    };
  }
}

/*
{
  "id": "e7f2ddf5-8d9e-4d59-be8f-f8359f759711",
  "name": "Awesome Tournament",
  "description": "this is a very cool tournament coming up!",
  "game": "VALORANT",
  "banner_url": "https://somebanner.com",
  "min_rank": 1,
  "max_rank": 10,
  "registration_start": "2023-09-21T03:34:38.661-07:00",
  "registration_end": "2023-10-21T03:34:38.661-07:00",
  "season_start": "2023-10-21T03:34:38.661-07:00",
  "season_end": "2023-12-21T02:34:38.661-08:00",
  "updated_at": "2023-09-24T16:25:26.842406-07:00",
  "created_at": "0000-12-31T16:07:02-07:52"
}
 */