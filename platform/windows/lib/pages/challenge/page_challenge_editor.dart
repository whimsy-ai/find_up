import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:game/global_progress_indicator_dialog.dart';
import 'package:game/info_table.dart';
import 'package:game/utils/input_decoration_outline_collapsed.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:oktoast/oktoast.dart';
import 'package:steamworks/steamworks.dart';

import '../../utils/steam_collection_ex.dart';
import '../../utils/steam_ex.dart';
import '../../utils/steam_tags.dart';
import '../challenge/gallery_dialog.dart';
import '../explorer/steam/steam_cached_image.dart';
import '../explorer/steam/steam_file.dart';
import '../ilp_editor/steam/upload_success_dialog.dart';
import 'steam_challenge.dart';

class PageCreateChallenge extends GetView<CreateChallengeController> {
  final _form = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(UI.createChallenge.tr),
      ),
      body: Column(
        children: [
          Form(
            key: _form,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: GetBuilder<CreateChallengeController>(
              id: 'form',
              builder: (c) {
                return Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// upload avatar
                    Expanded(
                      flex: 3,
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: _selectImage,
                          child: Container(
                            constraints: BoxConstraints(
                              minHeight: 200,
                              maxHeight: 300,
                            ),
                            child: controller._image == null
                                ? Icon(Icons.image_search_rounded)
                                : Image.file(File(controller.image!)),
                          ),
                        ),
                      ),
                    ),

                    /// info forum
                    Expanded(
                      flex: 10,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: TextFormField(
                              initialValue: controller.name,
                              decoration: inputDecorationOutlineCollapsed(
                                hintText: UI.challengeName.tr,
                              ),
                              validator: (v) {
                                if (v!.isEmpty) {
                                  return UI.contentCannotEmpty.tr;
                                }
                                return null;
                              },
                              onChanged: (c) => controller.name = c,
                            ),
                          ),
                          ListTile(
                            title: TextFormField(
                              minLines: 3,
                              maxLines: 3,
                              initialValue: controller.desc,
                              onChanged: (c) => controller.desc = c,
                              decoration: inputDecorationOutlineCollapsed(
                                hintText: UI.ilpDesc.tr,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(UI.fileInfo.tr),
                            subtitle: InfoTable(
                              runSpace: 10,
                              rows: [
                                (UI.imageLength.tr, controller.imageLength),
                                (
                                  UI.ageRating.tr,
                                  controller.ageRating?.value.tr ?? '',
                                ),
                                (
                                  UI.style.tr,
                                  controller.styles
                                      .map((e) => e.value.tr)
                                      .join(', ')
                                ),
                                (
                                  UI.shape.tr,
                                  controller.shapes
                                      .map((e) => e.value.tr)
                                      .join(', ')
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: GetBuilder<CreateChallengeController>(
                id: 'list',
                builder: (c) {
                  return Column(
                    children: [
                      ListTile(
                        title: Wrap(
                          spacing: 10,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          runAlignment: WrapAlignment.start,
                          alignment: WrapAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(Icons.add_rounded),
                              onPressed: _selectSteamFiles,
                            ),
                            Text(
                                '${UI.fileList.tr} ${controller.list.length} / 100'),
                            IconButton(
                              icon: Icon(Icons.delete_forever_rounded),
                              onPressed: _clearSelected,
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: MasonryGridView.extent(
                          itemCount: controller.list.length,
                          maxCrossAxisExtent: 120,
                          mainAxisSpacing: 4,
                          crossAxisSpacing: 4,
                          itemBuilder: (context, i) {
                            final file = controller.list.values.elementAt(i);
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    children: [
                                      SteamCachedImage(file.cover),
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: InkWell(
                                          onTap: () => _removeSteamFile(file),
                                          child: ColoredBox(
                                            color:
                                                Colors.black.withOpacity(0.7),
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.close_rounded,
                                                color: Colors.white,
                                              ),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submit,
        child: Icon(Icons.save_rounded),
      ),
    );
  }

  void _selectSteamFiles() async {
    final list = await SteamGalleryDialog.show(selected: controller.list);
    if (list == null || list.isEmpty) return;
    controller.list
      ..clear()
      ..addAll(list);
  }

  void _removeSteamFile(SteamFile file) async {
    controller.list.remove(file.id);
  }

  void _selectImage() async {
    final file = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(
          label: 'image',
          extensions: <String>['png', 'jpeg', 'jpg'],
        )
      ],
    );
    if (file == null) return;
    controller.image = file.path;
  }

  void _submit() async {
    if (_form.currentState!.validate()) {
      if (controller.list.isEmpty) {
        return _selectSteamFiles();
      }
      GlobalProgressIndicatorDialog.show(UI.steamUploading.tr);
      final collection = SteamCollection(
        id: 0,
        ownerId: 0,
        name: controller.name,
        description: controller._desc,
        version: 1,
        publishTime: DateTime.now(),
        updateTime: DateTime.now(),
        image: controller.image,
        ageRating: controller.ageRating!,
        styles: controller.styles.toList(),
        shapes: controller.shapes.toList(),
        childrenItemId: controller.list.keys.toList(),
        items: controller.list.values
            .map((e) => CollectionItem(
                id: e.id,
                name: e.name,
                image: e.cover,
                ownerId: e.steamIdOwner))
            .toList(),
      );
      print(
          'name ${collection.name}, desc ${collection.description}, children ${collection.childrenItemId},'
          ' age ${collection.ageRating}, style ${collection.styles}, shape ${collection.shapes}');
      try {
        final res = await SteamClient.instance.createCollection(
          collection,
          visibility: ERemoteStoragePublishedFileVisibility.public,
        );
        Get.back();
        SteamUploadSuccessDialog.show(result: res);
      } catch (e) {
        Get.back();
        showToast(UI.failed.tr);
      }
    }
  }

  void _clearSelected() async {
    if (controller.list.isEmpty) return;
    final sure = await Get.dialog<bool>(AlertDialog(
      title: Text(UI.confirm.tr),
      actions: [
        TextButton(
          child: Text(UI.ok.tr),
          onPressed: () => Get.back(result: true),
        ),
        ElevatedButton(
          child: Text(UI.cancel.tr),
          onPressed: () => Get.back(),
        ),
      ],
    ));
    if (sure == true) controller.list.clear();
  }
}

class CreateChallengeController extends GetxController {
  String? _image;
  String _name = '', _desc = '';
  int imageLength = 0;
  TagAgeRating? ageRating;
  final shapes = <TagShape>{};
  final styles = <TagStyle>{};
  late final list = <int, SteamFile>{}.obs
    ..listen((v) {
      final ageRatings = v.values.map((e) => e.ageRating).nonNulls;
      if (ageRatings.contains(TagAgeRating.mature)) {
        ageRating = TagAgeRating.mature;
      } else if (ageRatings.contains(TagAgeRating.questionable)) {
        ageRating = TagAgeRating.questionable;
      } else {
        ageRating = ageRatings.isEmpty ? null : TagAgeRating.everyone;
      }

      shapes
        ..clear()
        ..addAll(v.values.map((e) => e.shape).nonNulls);
      styles
        ..clear()
        ..addAll(v.values.map((e) => e.style).nonNulls);
      imageLength = v.values.map((e) => e.infos.length).sum;
      update(['form', 'list']);
    });

  String? get image => _image;

  set image(String? value) {
    _image = value;
    update(['form']);
  }

  String get name => _name;

  set name(String value) {
    _name = value;
    update(['form']);
  }

  get desc => _desc;

  set desc(value) {
    _desc = value;
    update(['form']);
  }

  /// 从steam下载选择的ugc文件
  downloadAll() async {
    await Future.wait(list.values
        .map((file) => SteamClient.instance.downloadUGCItem(file.id)));
  }
}
