class SeasonInfo {
  String? dataId;
  String? title;
  String? poster;
  AnimeInfo? animeInfo;
  List<Season>? seasons;

  SeasonInfo({
    this.dataId,
    this.title,
    this.poster,
    this.animeInfo,
    this.seasons,
  });

  factory SeasonInfo.fromJson(Map<String, dynamic> json) => SeasonInfo(
        dataId: json["data_id"],
        title: json["title"],
        poster: json["poster"],
        animeInfo: json["animeInfo"] == null
            ? null
            : AnimeInfo.fromJson(json["animeInfo"]),
        seasons: json["seasons"] == null
            ? []
            : List<Season>.from(
                json["seasons"]!.map((x) => Season.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data_id": dataId,
        "title": title,
        "poster": poster,
        "animeInfo": animeInfo?.toJson(),
        "seasons": seasons == null
            ? []
            : List<dynamic>.from(seasons!.map((x) => x.toJson())),
      };
}

class AnimeInfo {
  String? overview;
  String? aired;
  String? duration;
  String? status;
  String? score;
  String? ageRating;
  List<dynamic>? genres;
  String? sorces;

  AnimeInfo({
    this.overview,
    this.aired,
    this.duration,
    this.status,
    this.score,
    this.ageRating,
    this.genres,
    this.sorces,
  });

  factory AnimeInfo.fromJson(Map<String, dynamic> json) => AnimeInfo(
        overview: json["Overview"],
        aired: json["Aired"],
        duration: json["Duration"],
        status: json["Status"],
        score: json["Score"],
        ageRating: json["Age Rating"],
        genres: json["Genres"] == null
            ? []
            : List<dynamic>.from(json["Genres"]!.map((x) => x)),
        sorces: json["Sorces"],
      );

  Map<String, dynamic> toJson() => {
        "Overview": overview,
        "Aired": aired,
        "Duration": duration,
        "Status": status,
        "Score": score,
        "Age Rating": ageRating,
        "Genres":
            genres == null ? [] : List<dynamic>.from(genres!.map((x) => x)),
        "Sorces": sorces,
      };
}

class Season {
  int? season;
  int? dataNumber;
  int? dataId;
  String? hrefgetEpisode;

  Season({
    this.season,
    this.dataNumber,
    this.dataId,
    this.hrefgetEpisode,
  });

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        season: json["Season"],
        dataNumber: json["data_number"],
        dataId: json["data_id"],
        hrefgetEpisode: json["hrefgetEpisode"],
      );

  Map<String, dynamic> toJson() => {
        "Season": season,
        "data_number": dataNumber,
        "data_id": dataId,
        "hrefgetEpisode": hrefgetEpisode,
      };
}
