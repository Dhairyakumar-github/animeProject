import 'package:anime/Service/videoPlayerControllor.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// Ensure this import points to the correct controller

class VideoPlayerScreen2 extends StatelessWidget {
  final VideoController videoController = Get.put(VideoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player'),
      ),
      body: Obx(() {
        // if (videoController.isLoading.value) {
        //   return const Center(child: CircularProgressIndicator());
        // }
        // else
        if (videoController.m3u8Links.isEmpty) {
          return const Center(child: Text('No video source available.'));
        } else {
          return Column(
            children: [
              // BetterPlayer widget
              AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(
                    controller: videoController.betterPlayerController),
              ),
              const SizedBox(height: 20),
              // Server selection
              DropdownButton<String>(
                value: videoController.selectedServer.value,
                onChanged: (newServer) {
                  if (newServer != null) {
                    videoController.changeServer(newServer);
                  }
                },
                items: videoController.servers
                    .map<DropdownMenuItem<String>>((String server) {
                  return DropdownMenuItem<String>(
                    value: server,
                    child: Text(server),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // Display available resolutions or m3u8 links
              Container(
                height: 20,
                color: Colors.blueGrey,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: videoController.m3u8Links.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                          'Resolution: ${videoController.m3u8Links[index]}'),
                      onTap: () {
                        // Update the BetterPlayer source when a resolution is selected
                        videoController.setBetterPlayerSource(
                            videoController.m3u8Links[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}
