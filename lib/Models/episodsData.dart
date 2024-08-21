class EpisodsData {
  String? dataId;
  String? episodeNo;
  String? title;
  String? hrefdataid;

  EpisodsData({this.dataId, this.episodeNo, this.title, this.hrefdataid});

  EpisodsData.fromJson(Map<String, dynamic> json) {
    dataId = json['data_id'];
    episodeNo = json['episode_no'];
    title = json['title'];
    hrefdataid = json["hrefdataid"];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data_id'] = this.dataId;
    data['episode_no'] = this.episodeNo;
    data['title'] = this.title;
    data["hrefdataid"] = this.hrefdataid;
    return data;
  }
}
