import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class FolderListTile extends StatelessWidget {
  final (String, String) folder;
  final bool isFixedFolder;
  final bool selected;
  final void Function()? onTap;
  final void Function()? onRemove;

  FolderListTile({
    super.key,
    required this.folder,
    required this.isFixedFolder,
    required this.selected,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(folder.$1),
        subtitle: isFixedFolder
            ? null
            : Text(
                folder.$2,
                style: TextStyle(fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        selected: selected,
        selectedTileColor:
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
        onTap: selected ? null : onTap,
        trailing: isFixedFolder
            ? null
            : Wrap(
                spacing: 8,
                children: [
                  InkWell(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.folder_open_rounded),
                    ),
                    onTap: () => launchUrlString(folder.$2),
                  ),
                  InkWell(
                    onTap: onRemove,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ],
              ),
      );
}
