class EpisodsData {
  String? dataId;
  String? episodeNo;
  String? title;

  EpisodsData({this.dataId, this.episodeNo, this.title});

  EpisodsData.fromJson(Map<String, dynamic> json) {
    dataId = json['data_id'];
    episodeNo = json['episode_no'];
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['data_id'] = this.dataId;
    data['episode_no'] = this.episodeNo;
    data['title'] = this.title;
    return data;
  }
}
