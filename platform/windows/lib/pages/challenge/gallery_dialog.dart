import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:steamworks/steamworks.dart';
import 'package:ui/ui.dart';

import '../../utils/empty_list_widget.dart';
import '../../utils/steam_file_ex.dart';
import '../../utils/steam_filter.dart';
import '../../utils/steam_tags.dart';
import '../explorer/steam/steam_cached_image.dart';
import '../explorer/steam/steam_file.dart';
import '../explorer/steam/steam_file_bottom_sheet.dart';

class SteamGalleryController extends SteamFilterController {
  final max = 100;
  final files = <SteamFile>[];
  final _selected = <int, SteamFile>{};

  SteamGalleryController({
    required super.multipleSelect,
    Map<int, SteamFile>? selected,
    int? userId,
  }) {
    if (selected != null) _selected.addAll(selected);
    super.userId = userId;
  }

  void add(SteamFile file) {
    if (_selected.length >= max) return;
    _selected[file.id] = file;
    update(['list']);
  }

  void remove(SteamFile file) {
    _selected.remove(file.id);
    update(['list']);
  }

  bool contains(SteamFile file) => _selected.containsKey(file.id);

  @override
  void onChanged() {
    _load();
  }

  void _load() async {
    if (loading) return;
    loading = true;
    files.clear();
    update(['list']);

    print('load $page');

    final res = await SteamClient.instance.getAllItems(
      type: TagType.file,
      page: page,
      sort: sort,
      search: search,
      subscribed: subscribed,
      tags: {
        ...ageRatings.map((e) => e.name),
        ...shapes.map((e) => e.name),
        ...styles.map((e) => e.name),
      },
      userId: userId,
    );
    files.addAll(res.files);
    print('page $page, length ${files.length}');
    loading = false;
    update(['list']);
  }
}

class SteamGalleryDialog extends StatelessWidget {
  final controller = Get.find<SteamGalleryController>(tag: 'gallery');
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  SteamGalleryDialog._({super.key});

  static Future<Map<int, SteamFile>?> show({
    bool multipleSelect = true,
    Map<int, SteamFile>? selected,
    int? userId,
  }) async {
    Get.put<SteamGalleryController>(
      SteamGalleryController(
        multipleSelect: multipleSelect,
        selected: selected,
        userId: userId,
      ),
      tag: 'gallery',
    );
    return Get.dialog<Map<int, SteamFile>>(
      SteamGalleryDialog._(),
      barrierDismissible: false,
    ).then((value) {
      Get.delete<SteamGalleryController>(tag: 'gallery');
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop) {
          Navigator.of(context).pop(controller._selected);
        }
      },
      child: Container(
        margin: EdgeInsets.all(20),
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: Scaffold(
            key: _key,
            appBar: AppBar(
              title: GetBuilder<SteamGalleryController>(
                  id: 'list',
                  tag: 'gallery',
                  builder: (context) {
                    return Text(
                        '${UI.gallery.tr}   ${controller._selected.length} / ${controller.max}');
                  }),
              actions: [
                controller.pageWidget<SteamGalleryController>(
                  id: 'filter',
                  tag: 'gallery',
                ),
                IconButton(
                  icon: Icon(Icons.menu_rounded),
                  onPressed: () => _key.currentState!.openEndDrawer(),
                ),
              ],
            ),
            endDrawer: Drawer(
              child: SingleChildScrollView(
                child: controller.filterForum<SteamGalleryController>(
                  tag: 'gallery',
                  enabledExpand: false,
                ),
              ),
            ),
            body: GetBuilder<SteamGalleryController>(
                tag: 'gallery',
                id: 'list',
                builder: (c) {
                  if (c.loading) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (c.files.isEmpty) return EmptyListWidget();
                  return MasonryGridView.extent(
                    itemCount: controller.files.length,
                    maxCrossAxisExtent: 120,
                    mainAxisSpacing: 4,
                    crossAxisSpacing: 4,
                    itemBuilder: (context, i) {
                      final file = controller.files[i];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        color: controller.contains(file) ? Colors.blue : null,
                        child: InkWell(
                          onTap: () {
                            if (controller.multipleSelect) {
                              if (controller.contains(file)) {
                                controller.remove(file);
                              } else {
                                controller.add(file);
                              }
                            } else {
                              Get.back(result: {file.id: file});
                            }
                          },
                          // child: SteamFileGirdTile(file: file),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  SteamCachedImage(file.cover),
                                  if (controller.contains(file))
                                    Positioned.fill(
                                      child: ColoredBox(
                                        color: Colors.black.withOpacity(0.5),
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Icon(
                                            Icons.check_circle_outline_rounded,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: InkWell(
                                      onTap: () {
                                        SteamFileBottomSheet.show<
                                            SteamGalleryController>(
                                          file,
                                          tag: 'gallery',
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.info_outline_rounded,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  file.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
          ),
        ),
      ),
    );
  }
}
