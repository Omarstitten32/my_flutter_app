import 'package:flutter/material.dart';
import '../models/file_item.dart';

class DetailsScreen extends StatelessWidget {
  final FileItem item;

  const DetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              leading: Icon(item.isDirectory ? Icons.folder : Icons.insert_drive_file),
              title: Text(item.name),
              subtitle: const Text('Name'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(item.path),
              subtitle: const Text('Path'),
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: Text(item.extension.isEmpty ? '-' : item.extension),
              subtitle: const Text('Extension'),
            ),
            ListTile(
              leading: const Icon(Icons.storage),
              title: Text(item.size.toString()),
              subtitle: const Text('Size'),
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: Text(item.modified.toIso8601String()),
              subtitle: const Text('Modified'),
            ),
            ListTile(
              leading: const Icon(Icons.visibility),
              title: Text(item.isHidden ? 'Yes' : 'No'),
              subtitle: const Text('Hidden'),
            ),
          ],
        ),
      ),
    );
  }
}