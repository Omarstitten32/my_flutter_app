import 'package:flutter/material.dart';
import '../models/file_item.dart';

class FileTile extends StatelessWidget {
  final FileItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool selected;

  const FileTile({
    super.key,
    required this.item,
    required this.onTap,
    required this.onLongPress,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      leading: Icon(item.isDirectory ? Icons.folder : Icons.insert_drive_file),
      title: Text(item.name),
      subtitle: Text('${item.extension} • ${item.size}'),
      trailing: Text('${item.modified.year}-${item.modified.month}-${item.modified.day}'),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}