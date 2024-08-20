import 'dart:convert';
import 'package:better_player/better_player.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class VideoController extends GetxController {
  late BetterPlayerController betterPlayerController;
  var isLoading = true.obs;
  var resolutions = <String, String>{}.obs;
  var servers = <String>["VidHide", "Stream Wish", "File Moon"].obs;
  var selectedServer = "Stream Wish".obs;

  var m3u8Links = <String>[].obs;

  // Track whether the controller has been disposed
  bool disposed = false;

  @override
  void onInit() {
    super.onInit();
    initializePlayer(); // Initialize the player during onInit
    fetchM3u8Links(); // Fetch and play video when the controller initializes
  }

  void initializePlayer() {
    betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true,
        looping: true,
      ),
    );
  }

  @override
  void onClose() {
    // Dispose of the BetterPlayerController to avoid memory leaks
    betterPlayerController.dispose();
    disposed = true; // Mark the controller as disposed
    super.onClose();
  }

  Future<void> fetchM3u8Links() async {
    final apiUrl =
        'https://otaku1-eflaqjv0.b4a.run/api/stream?id=naruto-shipp-den-63?ep=1186';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final streamingInfo = jsonResponse['results']['streamingInfo'] as List?;

        if (streamingInfo != null) {
          m3u8Links.clear(); // Clear any previous links
          for (var server in streamingInfo) {
            if (server['server'] == selectedServer.value) {
              final sources =
                  List<Map<String, dynamic>>.from(server['sources']);
              for (var sourceObj in sources) {
                await processSource(sourceObj);
              }
              break;
            }
          }
          if (m3u8Links.isNotEmpty) {
            setBetterPlayerSource(
                m3u8Links.first); // Start playback immediately
          } else {
            print('No m3u8 links found.');
          }
          isLoading.value = false;
        } else {
          print('No streaming information available.');
          isLoading.value = false;
        }
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        isLoading.value = false;
      }
    } catch (error) {
      print('Error fetching data: $error');
      isLoading.value = false;
    }
  }

  Future<void> processSource(Map<String, dynamic> sourceObj) async {
    final String htmlUrl = sourceObj['source'];

    try {
      final response = await http.get(Uri.parse(htmlUrl));
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch HTML data, status: ${response.statusCode}');
      }

      final htmlData = response.body;
      final apiUrl =
          'https://server2stwish-erzip86p4-kashyap2024s-projects.vercel.app/api/html';
      final apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'text/html'},
        body: htmlData,
      );

      final data = json.decode(apiResponse.body);
      print("this is data:   $data");
      if (data['source'] != null) {
        m3u8Links.add(data['source']); // Store the m3u8 link in the list
        print('m3u8 link added: ${data['source']}');
      } else {
        // processSource(sourceObj);
        print('Invalid response format: $data');
      }
    } catch (error) {
      print('Error processing source: $error');
    }
  }

  void setBetterPlayerSource(String defaultLink) async {
    if (disposed)
      return; // Ensure the controller is not disposed before using it

    Map<String, String> resolutionsMap = {};
    List<BetterPlayerDataSource> dataSources = m3u8Links
        .map((link) => BetterPlayerDataSource(
              BetterPlayerDataSourceType.network,
              link,
            ))
        .toList();

    for (int i = 0; i < m3u8Links.length; i++) {
      resolutionsMap['Quality ${i + 1}'] = m3u8Links[i];
    }

    BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      defaultLink,
      resolutions: resolutionsMap,
    );

    betterPlayerController.setupDataSource(betterPlayerDataSource);
    print('BetterPlayer source set to: $defaultLink');

    betterPlayerController.play(); // Ensure the video starts playing
  }

  void changeServer(String newServer) {
    if (selectedServer.value != newServer) {
      selectedServer.value = newServer;
      isLoading.value = true;
      fetchM3u8Links();
    }
  }
}
