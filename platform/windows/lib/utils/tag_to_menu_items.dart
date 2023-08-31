import 'package:flutter/material.dart';
import 'package:get/get.dart';

List<DropdownMenuItem> tagToMenuItems(
  List<dynamic> tags, {
  TextStyle? style,
}) {
  return tags.map((e) {
    // print('e $e ${e.value}');
    final String string = e.value;
    return DropdownMenuItem(
      value: e,
      child: Text(
        string.tr,
        style: style,
      ),
    );
  }).toList();
}
