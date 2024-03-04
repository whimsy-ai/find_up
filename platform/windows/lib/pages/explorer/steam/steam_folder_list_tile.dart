import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';
import 'package:steamworks/steamworks.dart';

import '../../../utils/steam_ex.dart';
import '../../../utils/steam_tags.dart';
import '../../../utils/tag_to_menu_items.dart';
import '../ilp_explorer_controller.dart';

class SteamFolderListTile extends GetView<ILPExplorerController> {
  final _controller = ExpansionTileController();

  late final _expand = controller.currentPath == 'steam';

  static final _itemStyle = TextStyle(fontSize: 14, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary,
        onPrimary = Theme.of(context).colorScheme.onPrimary;
    final child = ExpansionTile(
      key: UniqueKey(),
      title: Text(UI.steamWorkshop.tr),
      trailing: Wrap(
        children: [
          InkWell(
            onTap: () {
              SteamClient.instance.openUrl(
                  'https://steamcommunity.com/app/${SteamClient.instance.steamUtils.getAppId()}/workshop/');
            },
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.open_in_new_rounded),
            ),
          )
        ],
      ),
      initiallyExpanded: _expand,
      maintainState: false,
      controller: _controller,
      onExpansionChanged: (v) => _controller.expand(),
      childrenPadding: EdgeInsets.all(10),
      expandedAlignment: Alignment.centerRight,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          runAlignment: WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.end,
          // direction: Axis.vertical,
          children: [
            ChoiceChip(
              showCheckmark: false,
              backgroundColor: Colors.grey,
              selectedColor: primary,
              avatar: controller.subscribed
                  ? Icon(
                      Icons.radio_button_checked_rounded,
                      color: onPrimary,
                    )
                  : Icon(
                      Icons.radio_button_off_rounded,
                      color: onPrimary,
                    ),
              label: Text(
                UI.steamSubscribed.tr,
                style: TextStyle(color: onPrimary, fontSize: 14),
              ),
              selected: controller.subscribed,
              onSelected: (val) {
                controller.userId = null;
                controller.subscribed = val;
                controller.update(['folders']);
                controller.page = 1;
                controller.reload();
              },
            ),
            ChoiceChip(
              showCheckmark: false,
              backgroundColor: Colors.grey,
              selectedColor: primary,
              avatar: controller.userId == SteamClient.instance.userId
                  ? Icon(
                      Icons.radio_button_checked_rounded,
                      color: onPrimary,
                    )
                  : Icon(
                      Icons.radio_button_off_rounded,
                      color: onPrimary,
                    ),
              label: Text(
                UI.steamMyFiles.tr,
                style: TextStyle(color: onPrimary, fontSize: 14),
              ),
              selected: controller.userId == SteamClient.instance.userId,
              onSelected: (val) {
                controller.subscribed = false;
                controller.userId = val ? SteamClient.instance.userId : null;
                controller.update(['folders']);
                controller.page = 1;
                controller.reload();
              },
            ),

            /// sort
            Chip(
              backgroundColor: Colors.grey,
              avatar: Icon(Icons.sort_rounded, color: Colors.white),
              label: DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(UI.sort.tr),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 24,
                      child: DropdownButton<SteamUGCSort>(
                        isDense: true,
                        enableFeedback: false,
                        value: controller.sort,
                        focusColor: Colors.transparent,
                        hint: Text(UI.sort.tr),
                        padding: EdgeInsets.zero,
                        underline: SizedBox.shrink(),
                        elevation: 0,
                        onChanged: (v) {
                          if (v != null) {
                            controller.sort = v;
                            controller.update(['folders']);
                            controller.page = 1;
                            controller.reload();
                          }
                        },
                        itemHeight: kMinInteractiveDimension,
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: [
                          DropdownMenuItem(
                            value: SteamUGCSort.updateTime,
                            child: Text(
                              UI.updateTime.tr,
                              style: _itemStyle,
                            ),
                          ),
                          DropdownMenuItem(
                            value: SteamUGCSort.publishTime,
                            child: Text(
                              UI.publishTime.tr,
                              style: _itemStyle,
                            ),
                          ),
                          DropdownMenuItem(
                            value: SteamUGCSort.vote,
                            child: Text(
                              UI.vote.tr,
                              style: _itemStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// age
            Chip(
              backgroundColor: Colors.grey,
              avatar: Icon(Icons.filter_alt_rounded, color: Colors.white),
              label: DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(UI.ageRating.tr),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 24,
                      child: DropdownButton(
                        isDense: true,
                        value: controller.ageRating,
                        enableFeedback: false,
                        focusColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        underline: SizedBox.shrink(),
                        elevation: 0,
                        onChanged: (v) => controller.addTag(v),
                        itemHeight: kMinInteractiveDimension,
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: tagToMenuItems(
                          TagAgeRating.values,
                          style: _itemStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onDeleted: controller.clearAgeRating,
            ),

            /// style
            Chip(
              backgroundColor: Colors.grey,
              avatar: Icon(Icons.filter_alt_rounded, color: Colors.white),
              label: DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(UI.style.tr),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 24,
                      child: DropdownButton(
                        isDense: true,
                        value: controller.style,
                        enableFeedback: false,
                        focusColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        underline: SizedBox.shrink(),
                        elevation: 0,
                        onChanged: controller.addTag,
                        itemHeight: kMinInteractiveDimension,
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: tagToMenuItems(
                          TagStyle.values,
                          style: _itemStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onDeleted: controller.clearStyle,
            ),

            /// 形状
            Chip(
              backgroundColor: Colors.grey,
              avatar: Icon(Icons.filter_alt_rounded, color: Colors.white),
              label: DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(UI.shape.tr),
                    SizedBox(width: 10),
                    SizedBox(
                      height: 24,
                      child: DropdownButton(
                        isDense: true,
                        value: controller.shape,
                        enableFeedback: false,
                        focusColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        underline: SizedBox.shrink(),
                        elevation: 0,
                        onChanged: controller.addTag,
                        itemHeight: kMinInteractiveDimension,
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: tagToMenuItems(
                          TagShape.values,
                          style: _itemStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              onDeleted: controller.clearShape,
            ),
          ],
        ),
      ],
    );
    return _expand
        ? child
        : InkWell(
            onTap: () {
              controller.openFolder(0);
            },
            child: IgnorePointer(child: child),
          );
  }
}
