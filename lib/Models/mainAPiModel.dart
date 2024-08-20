class Spotlight {
  String? dataId;
  String? title;
  String? description;
  String? poster;
  String? hrefgetseason;

  Spotlight({
    this.dataId,
    this.title,
    this.description,
    this.poster,
    this.hrefgetseason,
  });

  factory Spotlight.fromJson(Map<String, dynamic> json) {
    return Spotlight(
        dataId: json['data_id'],
        title: json['title'],
        description: json['description'],
        hrefgetseason: json["hrefgetseason"]
        // poster: json['poster'],
        // releaseDate: json['tvInfo']['releaseDate'],
        );
  }
}

class Trending {
  String? dataId;
  String? title;
  String? poster;

  Trending({
    this.dataId,
    this.title,
    this.poster,
  });

  factory Trending.fromJson(Map<String, dynamic> json) {
    return Trending(
      dataId: json['data_id'],
      title: json['title'],
      poster: json['poster'],
    );
  }
}
