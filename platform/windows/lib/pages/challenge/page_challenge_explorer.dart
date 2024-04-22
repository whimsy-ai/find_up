import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:game/game/game_mode.dart';
import 'package:game/game/page_game_entry.dart';
import 'package:get/get.dart';
import 'package:steamworks/steamworks.dart';
import 'package:ui/ui.dart';
import 'package:windows/pages/challenge/random_challenge.dart';

import '../../utils/empty_list_widget.dart';
import '../../utils/steam_file_ex.dart';
import '../../utils/steam_filter.dart';
import '../../utils/steam_tags.dart';
import '../../utils/window_frame.dart';
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
    return WindowFrame(
      title: UI.challenge.tr,
      child: Scaffold(
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: controller.filterForum<SteamExplorerController>(
                  enabledExpand: false,
                ),
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
          child: Icon(Icons.add),
          onPressed: () {
            Get.toNamed('/create_challenge', id: 1);
          },
        ),
      ),
    );
  }

  Widget _fileList() => MasonryGridView.extent(
        itemCount: controller.page == 1
            ? controller.files.current + 1
            : controller.files.current,
        maxCrossAxisExtent: 200,
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        itemBuilder: (context, i) {
          if (controller.page <= 1 && i == 0) {
            return RandomChallengeDialog.rgbDiceCard();
          }
          final file = controller.files.files[i - 1];
          // print('${file.name} ${file.type}');
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              child: SteamFileGirdTile<SteamExplorerController>(file: file),
              onTap: () {
                PageGameEntry.play(
                  id: 1,
                  file.children,
                  mode: GameMode.challenge,
                );
              },
            ),
          );
        },
      );
}
