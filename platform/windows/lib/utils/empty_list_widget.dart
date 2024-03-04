import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

class EmptyListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: Wrap(
          spacing: 10,
          children: [
            Icon(
              Icons.file_copy_sharp,
              color: Colors.grey,
            ),
            Text(
              UI.empty.tr,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
}
