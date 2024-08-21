import 'dart:convert';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class VideoController extends GetxController {
  late BetterPlayerController betterPlayerController;
  var isLoading = true.obs;
  var resolutions = <String, String>{}.obs;
  var servers = <String>["VidHide", "Stream Wish", "File Moon"].obs;
  var selectedServer = "Stream Wish".obs;
  final RxString streamId = "".obs;
  var m3u8Links = <String>[].obs;
  bool disposed = false;

  @override
  void onInit() {
    super.onInit();
    initializePlayer();
  }

  void initializePlayer() {
    betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        autoPlay: true, // Start with autoPlay off, enable later
        looping: true,
        handleLifecycle: true,
        autoDispose: true,
        controlsConfiguration:
            BetterPlayerControlsConfiguration(showControls: true),
        // placeholder: Container(
        //   color: Colors.grey,
        // ),
        // showPlaceholderUntilPlay: true,
        // loading: Container(
        //   child: Center(
        //     child: CircularProgressIndicator(),
        //   ),
        // ),
      ),
    );
  }

  @override
  void onClose() {
    betterPlayerController.dispose();
    disposed = true;
    super.onClose();
  }

  Future<void> fetchM3u8Links({
    int retryCount = 3,
  }) async {
    final apiUrl = 'https://otaku1-eflaqjv0.b4a.run/api/stream?id=$streamId';

    try {
      final response = await retryFetch(
        () async => await http.get(Uri.parse(apiUrl)),
        retryCount: retryCount,
        delayBetweenRetries: Duration(seconds: 2),
      );

      if (response != null && response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final streamingInfo = jsonResponse['results']['streamingInfo'] as List?;

        if (streamingInfo != null) {
          m3u8Links.clear();
          for (var server in streamingInfo) {
            if (server['server'] == selectedServer.value) {
              final sources =
                  List<Map<String, dynamic>>.from(server['sources']);
              for (var sourceObj in sources) {
                await processSource(sourceObj, retryCount: retryCount);
              }
              break;
            }
          }
          if (m3u8Links.isNotEmpty) {
            setBetterPlayerSource(m3u8Links.first);
          } else {
            print('No m3u8 links found.');
          }
          isLoading.value = false;
        } else {
          print('No streaming information available.');
          isLoading.value = false;
        }
      } else {
        print('Failed to fetch data: ${response?.statusCode}');
        isLoading.value = false;
      }
    } catch (error) {
      print('Error fetching data: $error');
      isLoading.value = false;
    }
  }

  Future<void> processSource(Map<String, dynamic> sourceObj,
      {int retryCount = 3}) async {
    final String htmlUrl = sourceObj['source'];

    try {
      final response = await retryFetch(
        () async => await http.get(Uri.parse(htmlUrl)),
        retryCount: retryCount,
        delayBetweenRetries: Duration(seconds: 2),
      );

      if (response != null && response.statusCode == 200) {
        final htmlData = response.body;
        final apiUrl =
            'https://server2stwish-erzip86p4-kashyap2024s-projects.vercel.app/api/html';
        final apiResponse = await retryFetch(
          () async => await http.post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'text/html'},
            body: htmlData,
          ),
          retryCount: retryCount,
          delayBetweenRetries: Duration(seconds: 2),
        );

        if (apiResponse != null && apiResponse.body.isNotEmpty) {
          try {
            final data = json.decode(apiResponse.body);
            print("Processed data: $data");
            if (data['source'] != null) {
              m3u8Links.add(data['source']);
              print('m3u8 link added: ${data['source']}');
            } else {
              print('Invalid response format: $data');
            }
          } catch (e) {
            print('Error decoding response: $e');
          }
        } else {
          print('API response is empty or null');
        }
      } else {
        print('Failed to fetch HTML data, status: ${response?.statusCode}');
      }
    } catch (error) {
      print('Error processing source: $error');
    }
  }

  Future<http.Response?> retryFetch(
      Future<http.Response> Function() fetchFunction,
      {int retryCount = 3,
      Duration delayBetweenRetries = const Duration(seconds: 2)}) async {
    for (int i = 0; i < retryCount; i++) {
      try {
        final response = await fetchFunction();
        if (response.statusCode == 200) {
          return response;
        }
      } catch (error) {
        print('Fetch attempt ${i + 1} failed: $error');
      }

      if (i < retryCount - 1) {
        await Future.delayed(delayBetweenRetries);
      }
    }
    return null;
  }

  void setBetterPlayerSource(String defaultLink) async {
    if (disposed) return;

    Map<String, String> resolutionsMap = {};
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

    betterPlayerController.play();
  }

  void changeServer(String newServer) {
    if (selectedServer.value != newServer) {
      selectedServer.value = newServer;
      isLoading.value = true;
      fetchM3u8Links();
    }
  }
}
