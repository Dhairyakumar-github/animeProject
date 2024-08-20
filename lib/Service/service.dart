import 'dart:convert';

import 'package:anime/Models/animeHomePageModel.dart';
import 'package:anime/Models/episodsData.dart';
import 'package:anime/Models/mainAPiModel.dart';
import 'package:anime/Service/converter.dart';
import 'package:anime/Service/videoPlayerControllor.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class Service extends GetxController {
  Service get instance => Get.find();
  final M3u8Controller m3u8Controller = Get.put(M3u8Controller());
  // final VideoController videoController = Get.put(VideoController());
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    getMainData();
    // mymain();
    // m3u8Controller.fetchM3u8Links();
  }

  final RxList<Spotlight> animeList = <Spotlight>[].obs;
  final RxList<Trending> trandingAnimeList = <Trending>[].obs;
  final RxList<Season> seasonsList = <Season>[].obs;
  var seasonInfoData = SeasonInfo().obs;
  RxList episodsInfoData = <EpisodsData>[].obs;
  var selectedSeason = '1'.obs;
  RxBool rebuildListView = false.obs;

  // var dropdownValue = seasonsList.first.obs;

  RxBool isSeasonLoading = false.obs;
  RxBool isEpisodsDataLoading = false.obs;
  // final RxList<Season> seasonList = <Season>[].obs;
  // final Rx<SeasonInfo> seasonInfoData = <SeasonInfo>.obs;

  Future<void> getMainData() async {
    final String url = "https://anime-otaku-api.vercel.app/api";

    final responce = await http.get(Uri.parse(url));
    if (responce.statusCode == 200) {
      final data = jsonDecode(responce.body);

      final List<dynamic> spotlightList = data['results']['spotlights'];

      for (Map<String, dynamic> index in spotlightList) {
        animeList.add(Spotlight.fromJson(index));
      }

      final List<dynamic> trndingList = data['results']['trending'];

      for (Map<String, dynamic> index in trndingList) {
        trandingAnimeList.add(Trending.fromJson(index));
      }

      //
      // print(animeList[8].title);
      // print("hello");
      // print(trandingAnimeList[8].title);
    }
  }

  Future<void> getSeasonData({id}) async {
    isSeasonLoading.value = true;
    seasonInfoData.value = SeasonInfo();
    seasonsList.value = [];
    final String url = "https://anime-otaku-api.vercel.app/api/info?id=$id";
    final responce = await http.get(Uri.parse(url));
    if (responce.statusCode == 200) {
      final data = jsonDecode(responce.body);
      seasonInfoData.value = SeasonInfo.fromJson(data['results']);
      final List<dynamic> tseasonList = data['results']['seasons'];
      for (Map<String, dynamic> index in tseasonList) {
        seasonsList.add(Season.fromJson(index));
      }
      print("hello");
      // print(trandingAnimeList[8].title);
      print(seasonInfoData);
      print("hello2");
      // print(seasonsList[0].hrefgetEpisode);
    }
    isSeasonLoading.value = false;
  }

  // get episodes data

  Future<void> getEpisodesData({id}) async {
    try {
      isEpisodsDataLoading.value = true;

      print("getEpisodesData Called!");
      print("thi is the id iwq got : $id");

      final String url = "https://anime-otaku-api.vercel.app/api/stream?id=$id";
      final responce = await http.get(Uri.parse(url));
      episodsInfoData.clear();
      if (responce.statusCode == 200) {
        final data = jsonDecode(responce.body);

        episodsInfoData.clear();
        final List<dynamic> episodsList = data['results']['episodes'];
        for (Map<String, dynamic> index in episodsList) {
          episodsInfoData.add(EpisodsData.fromJson(index));
        }
        // episodsInfoData.value = EpisodsData.fromJson(data['results']);

        // print("hello");
        // print(trandingAnimeList[8].title);
        // print(seasonInfoData);
        // print("hello 4");
        // print(episodsInfoData);
      }
      isEpisodsDataLoading.value = false;
    } catch (e) {
      print("Error: $e");
      throw "something went wrong";
    }
  }

  // -------------------------

  void mymain() async {
    // URL from which to fetch the HTML data
    const htmlUrl = 'https://filemoon.nl/e/439i3zfeerwp';

    try {
      // Fetch the HTML data
      final response = await http.get(Uri.parse(htmlUrl));

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch HTML data, status: ${response.statusCode}');
      }

      final htmlData = response.body;

      // Now that we have the HTML data, send it to the API
      const apiUrl = 'https://server3moon.vercel.app/api/html';

      final apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'text/html',
        },
        body: htmlData,
      );

      final data = json.decode(apiResponse.body);

      print('Response from server: ${data["source"]}');

      if (data != null && data['source'] != null) {
        try {
          final linkResponse = await http.get(Uri.parse(data['source']));

          if (linkResponse.statusCode == 200) {
            print(
                'm3u8 link is valid and accessible: ${linkResponse.statusCode}');
          } else {
            print(
                'm3u8 link is not accessible, status: ${linkResponse.statusCode}');
          }
        } catch (error) {
          print('Error checking m3u8 link: ${error.toString()}');
        }
      } else {
        print('Invalid response format: $data');
      }
    } catch (error) {
      print('Error: ${error.toString()}');
    }
  }
}
