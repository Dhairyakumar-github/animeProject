import 'package:anime/Pages/animeHomePage.dart';
import 'package:anime/Service/service.dart';
import 'package:anime/Service/videoPlayerControllor.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  // VideoController vcon = Get.put(VideoController());
  // final VideoController videoController = VideoController();
  HomePage({super.key});
  Service controllor = Get.put(Service());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () {
          if (controllor.animeList.isEmpty) {
            return CircularProgressIndicator();
          }
          return ListView.builder(
            itemCount: controllor.animeList.length,
            itemBuilder: (context, index) {
              final data = controllor.animeList[index];
              return GestureDetector(
                onTap: () async {
                  // controllor.getAnimeData(id: data.hrefgetseason);
                  Get.to(
                    () => AnimeHomePage(
                      // videoController: videoController,
                      data: data,
                    ),
                  );
                  // await vcon.fetchM3u8Links();
                },
                child: Card(
                  child: ListTile(
                    title: Text(data.title.toString()),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
