import 'package:flutter/material.dart';

class ActionSheet extends StatelessWidget {
  final VoidCallback onOpen;
  final VoidCallback onCopy;
  final VoidCallback onMove;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onCompress;
  final VoidCallback onFavorite;

  const ActionSheet({
    super.key,
    required this.onOpen,
    required this.onCopy,
    required this.onMove,
    required this.onRename,
    required this.onDelete,
    required this.onShare,
    required this.onCompress,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: [
          ListTile(leading: const Icon(Icons.open_in_new), title: const Text('Open'), onTap: onOpen),
          ListTile(leading: const Icon(Icons.copy), title: const Text('Copy'), onTap: onCopy),
          ListTile(leading: const Icon(Icons.drive_file_move), title: const Text('Move'), onTap: onMove),
          ListTile(leading: const Icon(Icons.edit), title: const Text('Rename'), onTap: onRename),
          ListTile(leading: const Icon(Icons.share), title: const Text('Share'), onTap: onShare),
          ListTile(leading: const Icon(Icons.archive), title: const Text('Compress'), onTap: onCompress),
          ListTile(leading: const Icon(Icons.star), title: const Text('Favorite'), onTap: onFavorite),
          ListTile(leading: const Icon(Icons.delete), title: const Text('Delete'), onTap: onDelete),
        ],
      ),
    );
  }
}