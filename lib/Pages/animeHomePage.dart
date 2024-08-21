import 'package:anime/Pages/videoplayer.dart';
import 'package:anime/Pages/videoplayerScreen.dart';
import 'package:anime/Service/service.dart';
import 'package:anime/Service/videoPlayerControllor.dart';
import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AnimeHomePage extends StatelessWidget {
  final Service controller = Get.put(Service());
  final VideoController videoController = Get.put(VideoController());

  final data;

  AnimeHomePage({
    super.key,
    required this.data,
  }) {
    awake();
  }

  void awake() async {
    // Fetch season data by default when the widget is created
    await controller.getSeasonData(id: data.hrefgetseason);
    print("this is hrefgetdata.... = ${data.hrefgetseason}");
    print(
        "this is episods data id.... = ${controller.animeList[1].hrefgetseason}");
    await controller.getEpisodesData(
        id: controller.seasonsList[0].hrefgetEpisode!);
    videoController.streamId.value = controller.episodsInfoData[0].hrefdataid;
    await videoController.fetchM3u8Links();
    // controller.selectedSeason.value = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(data.title)),
      body: PopScope(
        onPopInvoked: (didPop) {
          controller.seasonsList.clear();
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Poster: ${data.title}"),
                  SizedBox(height: 20),
                  Obx(() {
                    if (videoController.m3u8Links.value.isEmpty ||
                        videoController.isVideoLoading.value) {
                      return AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: const Color.fromARGB(255, 119, 123, 126),
                          child: Center(
                              child: Text(
                            videoController.videoError.value.toString() == ""
                                ? "Loading..."
                                : videoController.videoError.value,
                          )),
                        ),
                      );
                    }

                    if (videoController.videoError.value.isNotEmpty) {
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          color: const Color.fromARGB(255, 216, 178, 166),
                          child: Center(
                              child: Text(
                                  videoController.videoError.value.toString())),
                        ),
                      );
                    }
                    return AspectRatio(
                      aspectRatio: 16 / 9,
                      // child: videoController.isVideoLoading.value
                      //     ? Container(
                      //         color: Colors.blue,
                      //         child: Center(
                      //           child: Text(
                      //             videoController.videoError.value.toString() ==
                      //                     ""
                      //                 ? "Loading..."
                      //                 : videoController.videoError.value,
                      //           ),
                      //         ),
                      //       )
                      // :
                      child: BetterPlayer(
                        controller: videoController.betterPlayerController,
                      ),
                    );
                  }),
                  SizedBox(
                    height: 500,
                    child: Obx(
                      () {
                        // Check if the season data is loading
                        if (controller.isSeasonLoading.value) {
                          return Center(child: CircularProgressIndicator());
                        }
                        // Check if there's no season data
                        if (controller.seasonsList.isEmpty) {
                          return Center(child: Text("No data found"));
                        }

                        // If no selected season, set it to the first one
                        // if (controller.selectedSeason.value.isNotEmpty) {
                        //   controller.selectedSeason.value =
                        //       controller.seasonsList.first.hrefgetEpisode!;
                        //   controller.getEpisodesData(
                        //       id: controller.selectedSeason
                        //           .value); // Fetch episodes for the first season
                        // }

                        return Column(
                          children: [
                            // Video player

                            // if (controller.selectedSeason.value.isNotEmpty)

                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Wrap(
                                spacing: 8.0, // Space between chips
                                children: videoController.servers.map(
                                  (String server) {
                                    return ChoiceChip(
                                      label: Text(server),
                                      selected: videoController
                                              .selectedServer.value ==
                                          server,
                                      selectedColor:
                                          Colors.blue, // Color when selected
                                      backgroundColor: Colors
                                          .grey[300], // Color when not selected
                                      onSelected: (bool selected) {
                                        if (selected) {
                                          videoController.changeServer(
                                              server); // Change server
                                        }
                                      },
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                            DropdownMenu(
                              initialSelection: controller.selectedSeason.value,
                              dropdownMenuEntries:
                                  controller.seasonsList.map((e) {
                                return DropdownMenuEntry(
                                  label: e.season.toString(),
                                  value: e.hrefgetEpisode,
                                );
                              }).toList(),
                              onSelected: (value) {
                                print(value);
                                controller.selectedSeason.value =
                                    value!; // Update selected season
                                controller.getEpisodesData(id: value);
                                // Fetch episodes for the selected season
                                print(
                                    " tjhis is ddfdfref ${controller.episodsInfoData.length}");
                              },
                            ),
                            Expanded(
                              child: Obx(
                                () {
                                  // print(
                                  //     " tjhis is ddfdfref ${controller.episodsInfoData[0].dataId}");
                                  // Check if the episodes data is loading
                                  if (controller.isEpisodsDataLoading.value) {
                                    return Center(
                                        child: CircularProgressIndicator());
                                  }
                                  // Check if there's no episodes data
                                  if (controller.episodsInfoData.isEmpty) {
                                    return Center(child: Text("No Episodes"));
                                  }
                                  return ListView.builder(
                                    itemCount:
                                        controller.episodsInfoData.length,
                                    itemBuilder: (context, index) {
                                      return ListTile(
                                        title: Text("Episode ${index + 1}"),
                                        onTap: () async {
                                          print(
                                              "${controller.episodsInfoData[index].hrefdataid}");
                                          videoController.streamId.value =
                                              controller.episodsInfoData[index]
                                                  .hrefdataid;
                                          await videoController
                                              .fetchM3u8Links();
                                        },
                                        // onTap: () {
                                        //   // Navigate to video player screen
                                        //   // Get.to(() => VideoPlayerScreen2(
                                        //   //         // data: controller
                                        //   //         //     .episodsInfoData[index],
                                        //   //         )
                                        //   //     // VideoPlayerScreen(
                                        //   //     //     data: controller
                                        //   //     //         .episodsInfoData[index]),
                                        //   //     );
                                        // },
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
