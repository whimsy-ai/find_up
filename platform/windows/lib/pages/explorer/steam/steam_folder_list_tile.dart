import 'package:flutter/material.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';
import 'package:steamworks/steamworks.dart';

import '../../../ui.dart';
import '../../../utils/steam_ex.dart';
import '../../../utils/steam_tags.dart';
import '../../../utils/tag_to_menu_items.dart';
import '../controller.dart';

class SteamFolderListTile extends GetView<ILPExplorerController> {
  final myUserId = SteamClient.instance.steamUser.getSteamId();
  final _controller = ExpansionTileController();

  late final _expand = controller.currentPath == 'steam';

  static final _itemStyle = TextStyle(fontSize: 14, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary,
        onPrimary = Theme.of(context).colorScheme.onPrimary;
    final child = ExpansionTile(
      key: UniqueKey(),
      title: Text(WindowsUI.steamWorkshop.tr),
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
                WindowsUI.steamSubscribed.tr,
                style: TextStyle(color: onPrimary, fontSize: 14),
              ),
              selected: controller.subscribed,
              onSelected: (val) {
                controller.userId = null;
                controller.subscribed = val;
                controller.update(['folders']);
                controller.currentPage = 1;
                controller.reload();
              },
            ),
            ChoiceChip(
              backgroundColor: Colors.grey,
              selectedColor: primary,
              avatar: controller.userId == myUserId
                  ? Icon(
                      Icons.radio_button_checked_rounded,
                      color: onPrimary,
                    )
                  : Icon(
                      Icons.radio_button_off_rounded,
                      color: onPrimary,
                    ),
              label: Text(
                WindowsUI.steamMyFiles.tr,
                style: TextStyle(color: onPrimary, fontSize: 14),
              ),
              selected: controller.userId == myUserId,
              onSelected: (val) {
                controller.subscribed = false;
                controller.userId = val ? myUserId : null;
                controller.update(['folders']);
                controller.currentPage = 1;
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
                      child: DropdownButton(
                        isDense: true,
                        enableFeedback: false,
                        value: controller.voteType,
                        focusColor: Colors.transparent,
                        hint: Text(UI.sort.tr),
                        padding: EdgeInsets.zero,
                        underline: SizedBox.shrink(),
                        elevation: 0,
                        onChanged: (v) {
                          if (v != null) {
                            controller.voteType = v;
                            controller.update(['folders']);
                            controller.currentPage = 1;
                            controller.reload();
                          }
                        },
                        itemHeight: kMinInteractiveDimension,
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        items: [
                          DropdownMenuItem(
                            value: 0,
                            child: Text(
                              UI.updateTime.tr,
                              style: _itemStyle,
                            ),
                          ),
                          DropdownMenuItem(
                            value: 1,
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

            /// style
            Chip(
              backgroundColor: Colors.grey,
              avatar: Icon(Icons.filter_alt_rounded, color: Colors.white),
              label: DefaultTextStyle(
                style: TextStyle(color: Colors.white),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(WindowsUI.style.tr),
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
                        onChanged: (v) => controller.style = v,
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
              onDeleted: () => controller.style = null,
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
                    Text(WindowsUI.ageRating.tr),
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
                        onChanged: (v) => controller.ageRating = v,
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
              onDeleted: () => controller.ageRating = null,
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
                    Text(WindowsUI.shape.tr),
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
                        onChanged: (v) => controller.shape = v,
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
              onDeleted: () => controller.shape = null,
            ),
          ],
        ),
      ],
    );
    return _expand
        ? child
        : InkWell(
            onTap: () {
              controller.openFolder(1);
            },
            child: IgnorePointer(child: child),
          );
  }
}
