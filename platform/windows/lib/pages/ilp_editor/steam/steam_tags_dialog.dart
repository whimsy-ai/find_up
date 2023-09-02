import 'package:flutter/material.dart';
import 'package:game/ui.dart';
import 'package:get/get.dart';

import '../../../ui.dart';
import '../../../utils/steam_tags.dart';
import '../../../utils/tag_to_menu_items.dart';

class SteamTagsDialog extends StatelessWidget {
  final _shape = Rxn<TagShape>(),
      _style = Rxn<TagStyle>(),
      _age = Rxn<TagAgeRating>();
  final _form = GlobalKey<FormState>();
  final _tags = RxSet<String>();

  SteamTagsDialog._({
    super.key,
    TagShape? shape,
    TagStyle? style,
    TagAgeRating? age,
  }) {
    _shape.value = shape;
    _style.value = style;
    _age.value = age;
  }

  static Future<Set<String>?> show({
    TagShape? shape,
    TagStyle? style,
    TagAgeRating? age,
  }) =>
      Get.dialog<Set<String>>(SteamTagsDialog._(
        shape: shape,
        style: style,
        age: age,
      ));

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(WindowsUI.shareToSteam.tr),
      content: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// 形状
            FormField<TagShape>(
              initialValue: _shape.value,
              onSaved: (v) => _shape.value,
              validator: (val) {
                if (_shape.value == null) return UI.contentCannotEmpty.tr;
                return null;
              },
              builder: (state) => Obx(
                () => Column(
                  children: [
                    ListTile(
                      title: Text(WindowsUI.shape.tr),
                      trailing: DropdownButton(
                        value: _shape.value,
                        onChanged: (val) => _shape.value = val,
                        items: [
                          DropdownMenuItem(
                            value: TagShape.landscape,
                            child: Text(WindowsUI.landscape.tr),
                          ),
                          DropdownMenuItem(
                            value: TagShape.portrait,
                            child: Text(WindowsUI.portrait.tr),
                          ),
                          DropdownMenuItem(
                            value: TagShape.square,
                            child: Text(WindowsUI.square.tr),
                          ),
                        ],
                      ),
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      )
                  ],
                ),
              ),
            ),

            /// 风格
            FormField<TagStyle>(
              initialValue: _style.value,
              onSaved: (v) => _style.value = v,
              validator: (val) {
                if (_style.value == null) return UI.contentCannotEmpty.tr;
                return null;
              },
              builder: (state) => Obx(
                () => Column(
                  children: [
                    ListTile(
                      title: Text(WindowsUI.style.tr),
                      trailing: DropdownButton(
                        value: _style.value,
                        onChanged: (val) => _style.value = val,
                        items: tagToMenuItems(TagStyle.values),
                      ),
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),

            /// 年龄评级
            FormField<TagAgeRating>(
              initialValue: _age.value,
              onSaved: (v) => _age.value = v,
              validator: (val) {
                if (_age.value == null) return UI.contentCannotEmpty.tr;
                return null;
              },
              builder: (state) => Obx(
                () => Column(
                  children: [
                    ListTile(
                      title: Text(WindowsUI.ageRating.tr),
                      trailing: DropdownButton(
                        value: _age.value,
                        onChanged: (val) => _age.value = val,
                        items: [
                          DropdownMenuItem(
                            value: TagAgeRating.everyone,
                            child: Text(WindowsUI.ageEveryone.tr),
                          ),
                          DropdownMenuItem(
                            value: TagAgeRating.questionable,
                            child: Text(WindowsUI.ageQuestionable.tr),
                          ),
                          DropdownMenuItem(
                            value: TagAgeRating.mature,
                            child: Text(WindowsUI.ageMature.tr),
                          ),
                        ],
                      ),
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                  ],
                ),
              ),
            ),

            /// 其它自定义标签
            // ListTile(
            //   title: Text(WindowsUI.customTags.tr),
            //   subtitle: Obx(
            //     () => Wrap(
            //       spacing: 10,
            //       children: _tags
            //           .map((element) => Chip(
            //                 label: Text(element),
            //                 deleteIcon: Icon(Icons.close),
            //                 onDeleted: () => _tags.remove(element),
            //               ))
            //           .toList(),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text(UI.cancel.tr)),
        ElevatedButton(
          child: Text(WindowsUI.shareToSteam.tr),
          onPressed: () {
            if (_form.currentState!.validate()) {
              final tags = _tags.toSet();
              tags
                ..removeAll(TagStyle.values.map((e) => e.value))
                ..removeAll(TagShape.values.map((e) => e.value))
                ..removeAll(TagAgeRating.values.map((e) => e.value))
                ..addAll({
                  _style.value!.value,
                  _shape.value!.value,
                  _age.value!.value,
                });
              Get.back(result: tags);
            }
          },
        ),
      ],
    );
  }
}