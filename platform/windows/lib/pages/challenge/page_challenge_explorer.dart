import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:steamworks/steamworks.dart';

import '../../utils/empty_list_widget.dart';
import '../../utils/steam_file_ex.dart';
import '../../utils/steam_filter.dart';
import '../../utils/steam_tags.dart';
import '../explorer/steam/steam_file.dart';
import '../explorer/steam/steam_file_list_tile.dart';

class SteamExplorerController extends SteamFilterController {
  SteamExplorerController({super.multipleSelect = true});

  late SteamFiles files;

  @override
  void onChanged() async {
    load();
  }

  load() async {
    loading = true;
    update(['list']);
    final res = await SteamClient.instance.getAllItems(
      type: TagType.challenge,
      subscribed: subscribed,
      page: page,
      sort: sort,
      search: search,
      tags: {
        if (ageRating != null) ageRating!.value,
        ...shapes.map((e) => e.value),
        ...styles.map((e) => e.value),
      },
    );
    totalPage = (res.total / 50).ceil();
    files = res;
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
                Expanded(
                  child: SingleChildScrollView(
                    child: controller.filterForum<SteamExplorerController>(
                      enabledExpand: false,
                    ),
                  ),
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
                return controller.files.files.isEmpty
                    ? EmptyListWidget()
                    : _fileList();
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

  Widget _fileList() => MasonryGridView.extent(
        itemCount: controller.files.current,
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, i) {
          final file = controller.files.files[i];
          print('${file.name} ${file.type}');
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              child: SteamFileGirdTile<SteamExplorerController>(file: file),
              onTap: () {
                PageGameEntry.play(file.children);
              },
            ),
          );
        },
      );
}
