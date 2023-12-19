import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:i18n/ui.dart';

import 'controller.dart';

class LinkEditor extends GetView<ILPEditorController> {
  final Link? link;
  final _formKey = GlobalKey<FormState>();
  final _urlFocusNode = FocusNode();
  late final _nameController = TextEditingController(
        text: link?.name ?? '${UI.link.tr} ${controller.links.length + 1}',
      ),
      _urlController = TextEditingController(text: link?.url ?? '');

  static Future show([Link? link]) => Get.dialog(LinkEditor(link: link));

  LinkEditor({super.key, this.link});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(link == null ? UI.addLink.tr : UI.modifyLink.tr),
      content: Container(
        constraints: BoxConstraints(minWidth: 300),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: TextFormField(
                  autofocus: true,
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${UI.link.tr} ${UI.name.tr}(*)',
                  ),
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) => _urlFocusNode.requestFocus(),
                  validator: (val) {
                    if (val!.isEmpty) {
                      return UI.contentCannotEmpty.tr;
                    }
                    return null;
                  },
                ),
              ),
              ListTile(
                title: TextFormField(
                  focusNode: _urlFocusNode,
                  controller: _urlController,
                  autofocus: true,
                  maxLines: null,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: '${UI.link.tr} ${UI.url.tr}(*)',
                  ),
                  validator: (val) {
                    if (val!.isEmpty) return UI.contentCannotEmpty.tr;
                    final uri = Uri.parse(val);
                    if (!uri.isScheme('https')) {
                      return UI.ilpEditorLinkProtocolLimit.tr;
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text(UI.cancel.tr)),
        ElevatedButton(
          onPressed: _submit,
          child: Text(link == null ? UI.addLink.tr : UI.modifyLink.tr),
        ),
      ],
    );
  }

  _submit() {
    if (_formKey.currentState!.validate()) {
      if (link != null) {
        link!.name = _nameController.text;
        link!.url = _urlController.text;
        controller.update(['editor']);
      } else {
        controller.links.add(Link(_nameController.text, _urlController.text));
      }
      Get.back();
    }
  }
}
