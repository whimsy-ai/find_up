import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game/data.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

import 'steam_ex.dart';
import 'steam_tags.dart';

/// Use GetBuilder id: filter
abstract class SteamFilterController extends GetxController {
  bool loading = false;
  final bool multipleSelect;
  Timer? _onChangedDebounce;

  void _onChanged() {
    update(['filter']);
    _onChangedDebounce?.cancel();
    _onChangedDebounce = Timer(
      const Duration(milliseconds: 100),
      () => onChanged(),
    );
  }

  void onChanged();

  @override
  void onClose() {
    _onChangedDebounce?.cancel();
  }

  SteamFilterController({required this.multipleSelect}) {
    if (!Data.isAdult) {
      _ageRatings.add(TagAgeRating.everyone);
    }
  }

  late final _ageRatings = <TagAgeRating>{};
  late final _styles = <TagStyle>{};
  late final _shapes = <TagShape>{};
  int _page = 1;
  int totalPage = 0;

  int get page => _page;

  set page(int value) {
    if (value < 1) value = 1;
    final changed = _page != value;
    _page = value;
    if (changed) _onChanged();
  }

  TagAgeRating? get ageRating => _ageRatings.firstOrNull;

  TagShape? get shape => _shapes.firstOrNull;

  TagStyle? get style => _styles.firstOrNull;

  Set<TagAgeRating> get ageRatings => _ageRatings;

  Set<TagStyle> get styles => _styles;

  Set<TagShape> get shapes => _shapes;

  /// 搜索
  String search = '';

  void clearAgeRating() async {
    if (!await isAdult()) return;
    _ageRatings.clear();
    _onChanged();
  }

  void clearShape() {
    _shapes.clear();
    _onChanged();
  }

  void clearStyle() {
    _styles.clear();
    _onChanged();
  }

  void addTag<T>(T type) async {
    if (type is TagStyle) {
      if (!multipleSelect) _styles.clear();
      _styles.add(type);
    } else if (type is TagShape) {
      if (!multipleSelect) _shapes.clear();
      _shapes.add(type);
    } else if (type is TagAgeRating) {
      if (type != TagAgeRating.everyone) {
        if (!(await isAdult())) return;
      }
      _ageRatings
        ..clear()
        ..add(type);
    }
    _onChanged();
  }

  Future<bool> isAdult() async {
    if (!Data.isAdult) {
      final sure = await Get.dialog<bool>(
        AlertDialog(
          title: Text(UI.adultAgreementTitle.tr),
          content: Text(UI.adultAgreementContent.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text(UI.cancel.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text(UI.confirm.tr),
            ),
          ],
        ),
      );
      if (sure == true) {
        Data.isAdult = true;
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  removeTag<T>(T type) async {
    if (type is TagStyle) {
      _styles.remove(type);
    } else if (type is TagShape) {
      _shapes.remove(type);
    } else if (type is TagAgeRating) {
      _ageRatings.remove(type);
      if (_ageRatings.isEmpty) {
        if (!(await isAdult())) _ageRatings.add(TagAgeRating.everyone);
      }
    }
    _onChanged();
  }

  bool containsTag<T>(T type) {
    if (type is TagStyle) {
      return _styles.contains(type);
    } else if (type is TagShape) {
      return _shapes.contains(type);
    } else if (type is TagAgeRating) {
      return _ageRatings.contains(type);
    }
    return false;
  }

  /// 指定查看作者
  int? _userId;

  int? get userId => _userId;

  set userId(int? value) {
    _userId = value;
    _onChanged();
  }

  /// 订阅
  bool _subscribed = false;

  bool get subscribed => _subscribed;

  set subscribed(bool value) {
    _subscribed = value;
    _onChanged();
  }

  /// 排序
  SteamUGCSort _sort = SteamUGCSort.publishTime;

  SteamUGCSort get sort => _sort;

  set sort(SteamUGCSort value) {
    _sort = value;
    _onChanged();
  }

  late final _searchController = TextEditingController(text: search);

  Widget pageWidget<T extends GetxController>({
    required String id,
    String? tag,
  }) =>
      GetBuilder<T>(
        id: id,
        tag: tag,
        builder: (c) => _pageWidget,
      );

  Widget get _pageWidget => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            child: Icon(Icons.chevron_left_rounded),
            onPressed: () {
              page--;
            },
          ),
          SizedBox(width: 10),
          SizedBox(
            width: 50,
            height: 26,
            child: TextField(
              controller: TextEditingController(
                text: page.toString(),
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                  RegExp(r'[1-9][0-9]*'),
                ),
              ],
              onChanged: (v) {
                page = int.parse(v);
              },
              style: TextStyle(fontSize: 14),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.zero,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 10),
          Text(
            '/ $totalPage',
            style: TextStyle(fontSize: 14),
          ),
          SizedBox(width: 10),
          TextButton(
            child: Icon(Icons.chevron_right_rounded),
            onPressed: () {
              page++;
            },
          ),
        ],
      );

  Widget filterForum<T extends GetxController>({
    String? tag,
    TextStyle chipStyle = const TextStyle(fontSize: 12),
    enabledExpand = true,
    showPageWidget = true,
    showSubscribed = true,
  }) {
    return GetBuilder<T>(
      tag: tag,
      id: 'filter',
      builder: (c) => ExpansionTile(
        initiallyExpanded: true,
        enabled: enabledExpand,
        title: Text(UI.steamWorkshop.tr),
        children: [
          if (showPageWidget) _pageWidget,
          if (userId != null)
            ListTile(
              title: Text(UI.steamAuthorOtherFiles.tr),
              trailing: IconButton(
                  icon: Icon(Icons.close_rounded),
                  onPressed: () {
                    userId = null;
                  }),
            ),

          /// 搜索
          ListTile(
            title: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  size: 16,
                ),
                suffixIcon: search.isEmpty
                    ? null
                    : InkWell(
                        child: Icon(
                          Icons.close_rounded,
                          size: 14,
                        ),
                        onTap: () {
                          _searchController.text = '';
                          search = '';
                        },
                      ),
                contentPadding: EdgeInsets.zero,
                hintText: UI.search.tr,
                hintStyle: TextStyle(fontSize: 14),
              ),
              onChanged: (v) => search = v,
            ),
          ),

          if (showSubscribed)
            ListTile(
              leading: Icon(_subscribed
                  ? Icons.check_box
                  : Icons.check_box_outline_blank_rounded),
              title: Text(UI.steamSubscribed.tr),
              onTap: () {
                subscribed = !_subscribed;
              },
            ),

          /// 排序
          ListTile(
            title: Text(UI.sort.tr),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(right: 8.0),
            child: Wrap(
              alignment: WrapAlignment.end,
              spacing: 10,
              runSpacing: 10,
              children: [
                ChoiceChip(
                  label: Text(UI.vote.tr, style: chipStyle),
                  selected: _sort == SteamUGCSort.vote,
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (v) => sort = SteamUGCSort.vote,
                ),
                ChoiceChip(
                  label: Text(UI.publishTime.tr, style: chipStyle),
                  selected: _sort == SteamUGCSort.publishTime,
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (v) => sort = SteamUGCSort.publishTime,
                ),
                ChoiceChip(
                  label: Text(UI.updateTime.tr, style: chipStyle),
                  selected: _sort == SteamUGCSort.updateTime,
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (v) => sort = SteamUGCSort.updateTime,
                ),
              ],
            ),
          ),

          /// 年龄评级
          ListTile(
            title: Text(UI.ageRating.tr),
            trailing: _ageRatings.isEmpty
                ? null
                : IconButton(
                    onPressed: clearAgeRating, icon: Icon(Icons.close_rounded)),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(right: 8.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                ChoiceChip(
                  label: Text(UI.Everyone.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagAgeRating.everyone);
                    } else {
                      removeTag(TagAgeRating.everyone);
                    }
                  },
                  selected: containsTag(TagAgeRating.everyone),
                ),
                ChoiceChip(
                  label: Text(UI.Questionable.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagAgeRating.questionable);
                    } else {
                      removeTag(TagAgeRating.questionable);
                    }
                  },
                  selected: containsTag(TagAgeRating.questionable),
                ),
                ChoiceChip(
                  label: Text(UI.Mature.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagAgeRating.mature);
                    } else {
                      removeTag(TagAgeRating.mature);
                    }
                  },
                  selected: containsTag(TagAgeRating.mature),
                ),
              ],
            ),
          ),

          /// 风格
          ListTile(
            title: Text(UI.style.tr),
            trailing: _styles.isEmpty
                ? null
                : IconButton(
                    onPressed: clearStyle, icon: Icon(Icons.close_rounded)),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(right: 8.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                ChoiceChip(
                  label: Text(UI.Anime.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagStyle.anime);
                    } else {
                      removeTag(TagStyle.anime);
                    }
                  },
                  selected: containsTag(TagStyle.anime),
                ),
                ChoiceChip(
                  label: Text(UI.Realistic.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagStyle.realistic);
                    } else {
                      removeTag(TagStyle.realistic);
                    }
                  },
                  selected: containsTag(TagStyle.realistic),
                ),
                ChoiceChip(
                  label: Text(UI.Pixel.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagStyle.pixel);
                    } else {
                      removeTag(TagStyle.pixel);
                    }
                  },
                  selected: containsTag(TagStyle.pixel),
                ),
                ChoiceChip(
                  label: Text(UI.AncientChinese.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagStyle.ancientChinese);
                    } else {
                      removeTag(TagStyle.ancientChinese);
                    }
                  },
                  selected: containsTag(TagStyle.ancientChinese),
                ),
                ChoiceChip(
                  label: Text(UI.Other.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagStyle.other);
                    } else {
                      removeTag(TagStyle.other);
                    }
                  },
                  selected: containsTag(TagStyle.other),
                ),
              ],
            ),
          ),

          /// 形状
          ListTile(
            title: Text(UI.shape.tr),
            trailing: _shapes.isEmpty
                ? null
                : IconButton(
                    onPressed: clearShape, icon: Icon(Icons.close_rounded)),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(right: 8.0),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                ChoiceChip(
                  label: Text(UI.Landscape.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagShape.landscape);
                    } else {
                      removeTag(TagShape.landscape);
                    }
                  },
                  selected: containsTag(TagShape.landscape),
                ),
                ChoiceChip(
                  label: Text(UI.Portrait.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagShape.portrait);
                    } else {
                      removeTag(TagShape.portrait);
                    }
                  },
                  selected: containsTag(TagShape.portrait),
                ),
                ChoiceChip(
                  label: Text(UI.Square.tr),
                  padding: EdgeInsets.zero,
                  labelStyle: chipStyle,
                  showCheckmark: false,
                  onSelected: (bool value) {
                    if (value) {
                      addTag(TagShape.square);
                    } else {
                      removeTag(TagShape.square);
                    }
                  },
                  selected: containsTag(TagShape.square),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
