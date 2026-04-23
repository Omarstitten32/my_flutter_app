import 'package:flutter/material.dart';

class PathBar extends StatelessWidget {
  final String path;
  final ValueChanged<String> onNavigate;

  const PathBar({
    super.key,
    required this.path,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final parts = path.split('/').where((e) => e.isNotEmpty).toList();
    final items = <Widget>[];
    String current = '';
    items.add(TextButton(onPressed: () => onNavigate('/'), child: const Text('/')));
    for (final part in parts) {
      current += '/$part';
      items.add(const Text('>'));
      items.add(TextButton(onPressed: () => onNavigate(current), child: Text(part, overflow: TextOverflow.ellipsis)));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: items),
    );
  }
}