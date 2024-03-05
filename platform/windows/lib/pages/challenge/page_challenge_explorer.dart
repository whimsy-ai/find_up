import 'package:flutter/material.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:steamworks/steamworks.dart';

import '../../utils/datetime_format.dart';
import '../../utils/empty_list_widget.dart';
import '../../utils/steam_collection_ex.dart';
import '../../utils/steam_filter.dart';
import '../explorer/steam/steam_file.dart';
import 'steam_challenge.dart';

class SteamExplorerController extends SteamFilterController {
  SteamExplorerController({super.multipleSelect = true});

  final collections = <SteamCollection>[];

  @override
  void onChanged() async {
    load();
  }

  load() async {
    loading = true;
    update(['list']);
    final res = await SteamClient.instance.getCollections(page: page, tags: {
      if (ageRating != null) ageRating!.value,
      ...shapes.map((e) => e.value),
      ...styles.map((e) => e.value),
    });
    totalPage = (res.total / 50).ceil();
    collections
      ..clear()
      ..addAll(res.list);
    loading = false;
    update(['filter', 'list']);
  }
}

class PageChallengeExplorer extends GetView<SteamExplorerController> {
  @override
  Widget build(BuildContext context) {
    controller.load();
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 300,
            child: Column(
              children: [
                AppBar(
                  title: Text(UI.challenge.tr),
                  actions: [
                    IconButton(
                      tooltip: UI.reload.tr,
                      onPressed: () => controller.load(),
                      icon: Icon(Icons.refresh_outlined),
                    ),
                  ],
                ),
                controller.filterForum<SteamExplorerController>(
                  enabledExpand: false,
                ),
              ],
            ),
          ),
          VerticalDivider(),
          Flexible(
            flex: 3,
            child: GetBuilder<SteamExplorerController>(
              id: 'list',
              builder: (_) {
                if (controller.loading) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return controller.collections.isEmpty
                    ? EmptyListWidget()
                    : ListView.separated(
                        itemCount: controller.collections.length,
                        separatorBuilder: (_, i) => Divider(),
                        itemBuilder: (_, i) => ListTile(
                          leading: controller.collections[i].image.isEmpty
                              ? CircleAvatar()
                              : Image.network(controller.collections[i].image),
                          title: Text(controller.collections[i].name),
                          subtitle: Text(
                              '${controller.collections[i].description}\n'
                              // 'children id ${controller.collections[i].childrenItemId}\n'
                              // 'images: ${controller.collections[i].childrenItemId.length}\n'
                              '${UI.updateTime.tr}: ${formatDate(controller.collections[i].updateTime)}'),
                          trailing: Icon(Icons.play_circle_rounded),
                          onTap: () {
                            PageGameEntry.play(controller
                                .collections[i].childrenItemId
                                .map((e) => SteamSimpleFile(id: e))
                                .toList());
                          },
                        ),
                      );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: UI.createChallenge.tr,
        child: Icon(Icons.add_rounded),
        onPressed: () async {
          final collection = await Get.toNamed('/create_challenge');
        },
      ),
    );
  }
}
