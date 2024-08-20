// lib/video_player_screen.dart
import 'package:anime/Models/animeHomePageModel.dart';
import 'package:anime/Service/service.dart';
import 'package:anime/Service/videoPlayerControllor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoPlayerScreen extends StatelessWidget {
  @override
  // const VideoPlayerScreen();
  Widget build(BuildContext context) {
    // Instantiate the VideoController using GetX
    final VideoController videoController = Get.put(VideoController());
    final Service serviceControllor = Get.find();
    var dropdoenValue = serviceControllor.seasonInfoData.value.seasons?.first;
    return Scaffold(
      appBar: AppBar(
        title: Text("Better Player Example"),
      ),
      body: SingleChildScrollView(
        child: Obx(() {
          // print(" thi si href for testing:  ${data.hrefgetEpisode}");
          return Column(
            children: [
              // Chips to select server
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  spacing: 8.0, // Space between chips
                  children: videoController.servers.map(
                    (String server) {
                      return ChoiceChip(
                        label: Text(server),
                        selected:
                            videoController.selectedServer.value == server,
                        selectedColor: Colors.blue, // Color when selected
                        backgroundColor:
                            Colors.grey[300], // Color when not selected
                        onSelected: (bool selected) {
                          if (selected) {
                            videoController
                                .changeServer(server); // Change server
                          }
                        },
                      );
                    },
                  ).toList(),
                ),
              ),
              // Video player
              // Expanded(
              //   child: AspectRatio(
              //     aspectRatio: 16 / 9,
              //     child: BetterPlayer(
              //       controller: videoController.betterPlayerController,
              //     ),
              //   ),
              // ),
              // DropdownButton<String>(
              //     // value: dropdoenValue.toString(),
              //     items: serviceControllor.seasonInfoData.value.seasons
              //         ?.map<DropdownMenuItem<String>>((e) {
              //       return DropdownMenuItem(
              //         value: e.hrefgetEpisode,
              //         child: Text(e.season.toString()),
              //       );
              //     }).toList(),
              //     onChanged: (value) {
              //       // dropdoenValue = value as Season?;
              //     }),
              // SizedBox(
              //   height: 500,
              //   child: FutureBuilder(
              //       future: serviceControllor.getEpisodesData(
              //           id: data.hrefgetEpisode),
              //       builder: (context, snapshot) {
              //         // if (snapshot.hasError) {
              //         //   return Text("hsihdsi");
              //         // }
              //         if (serviceControllor.isEpisodsDataLoading.value) {
              //           return Text("Loading");
              //         }
              //         return SizedBox(
              //           height: 300,
              //           child: ListView.builder(
              //             itemCount: serviceControllor.episodsInfoData.length,
              //             itemBuilder: (context, index) {
              //               return SizedBox(
              //                 height: 30,
              //                 child: Container(
              //                   color: Colors.green,
              //                   child: Card(
              //                     child: Text("episods : ${index + 1}"),
              //                   ),
              //                 ),
              //               );
              //             },
              //           ),
              //         );
              //       }),
              // ),

              // Expanded(child: ListView.builder(itemBuilder: itemBuilder))
            ],
          );
        }),
      ),
    );
  }
}
