import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as p;
import '../providers/app_provider.dart';
import '../services/file_service.dart';
import '../services/archive_service.dart';
import '../services/share_service.dart';
import '../widgets/file_tile.dart';
import '../widgets/path_bar.dart';
import '../widgets/action_sheet.dart';
import '../models/file_item.dart';

class FileBrowserScreen extends StatefulWidget {
  const FileBrowserScreen({super.key});

  @override
  State<FileBrowserScreen> createState() => _FileBrowserScreenState();
}

class _FileBrowserScreenState extends State<FileBrowserScreen> {
  List<FileItem> items = [];
  bool loading = true;
  String? currentActionPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = context.read<AppProvider>();
    setState(() => loading = true);
    final list = await FileService.listItems(
      provider.currentPath,
      showHidden: provider.showHidden,
    );
    setState(() {
      items = _applySearchAndSort(list, provider);
      loading = false;
    });
  }

  List<FileItem> _applySearchAndSort(List<FileItem> list, AppProvider provider) {
    List<FileItem> result = list;

    if (provider.query.trim().isNotEmpty) {
      final q = provider.query.trim().toLowerCase();
      result = result.where((e) => e.name.toLowerCase().contains(q)).toList();
    }

    result.sort((a, b) {
      int compare;
      switch (provider.sortBy) {
        case 'size':
          compare = a.size.compareTo(b.size);
          break;
        case 'date':
          compare = a.modified.compareTo(b.modified);
          break;
        default:
          compare = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      }
      if (a.isDirectory != b.isDirectory) {
        return a.isDirectory ? -1 : 1;
      }
      return provider.ascending ? compare : -compare;
    });

    return result;
  }

  Future<void> _navigate(String path) async {
    context.read<AppProvider>().setPath(path);
    await _load();
  }

  Future<void> _open(FileItem item) async {
    if (item.isDirectory) {
      await _navigate(item.path);
      return;
    }
    if (FileService.isImage(item.path) ||
        FileService.isVideo(item.path) ||
        FileService.isAudio(item.path) ||
        FileService.isPdf(item.path) ||
        FileService.isText(item.path)) {
      await ShareService.shareFile(item.path);
    }
  }

  Future<void> _askCreateFolder() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isNotEmpty) {
                await FileService.createFolder(context.read<AppProvider>().currentPath, name);
                if (mounted) Navigator.pop(context);
                await _load();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _renameItem(FileItem item) async {
    final ctrl = TextEditingController(text: item.name);
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newName = ctrl.text.trim();
              if (newName.isNotEmpty) {
                await FileService.renameItem(item.path, newName);
                if (mounted) Navigator.pop(context);
                await _load();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(FileItem item) async {
    await FileService.deleteItem(item.path);
    await _load();
  }

  Future<void> _copyItem(FileItem item) async {
    context.read<AppProvider>().setClipboard([item.path], cut: false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied')),
    );
  }

  Future<void> _cutItem(FileItem item) async {
    context.read<AppProvider>().setClipboard([item.path], cut: true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cut')),
    );
  }

  Future<void> _pasteItems() async {
    final provider = context.read<AppProvider>();
    if (provider.clipboard.isEmpty) return;

    final destDir = provider.currentPath;
    for (final source in provider.clipboard) {
      final base = p.basename(source);
      final target = p.join(destDir, base);
      if (provider.cutMode) {
        await FileService.moveItem(source, target);
      } else {
        await FileService.copyItem(source, target);
      }
    }
    provider.clearClipboard();
    await _load();
  }

  Future<void> _compressItem(FileItem item) async {
    final out = p.join(
      context.read<AppProvider>().currentPath,
      '${item.name}.zip',
    );
    await ArchiveService.createZip([item.path], out);
    await _load();
  }

  Future<void> _extractZip(FileItem item) async {
    final target = p.join(
      context.read<AppProvider>().currentPath,
      item.name.replaceAll('.zip', ''),
    );
    await Directory(target).create(recursive: true);
    await ArchiveService.extractZip(item.path, target);
    await _load();
  }

  void _showActions(FileItem item) {
    showModalBottomSheet(
      context: context,
      builder: (_) => ActionSheet(
        onOpen: () {
          Navigator.pop(context);
          _open(item);
        },
        onCopy: () {
          Navigator.pop(context);
          _copyItem(item);
        },
        onMove: () {
          Navigator.pop(context);
          _cutItem(item);
        },
        onRename: () {
          Navigator.pop(context);
          _renameItem(item);
        },
        onDelete: () {
          Navigator.pop(context);
          _deleteItem(item);
        },
        onShare: () {
          Navigator.pop(context);
          ShareService.shareFile(item.path);
        },
        onCompress: () {
          Navigator.pop(context);
          _compressItem(item);
        },
        onFavorite: () {
          Navigator.pop(context);
          context.read<AppProvider>().addFavorite(item.path);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              provider.setQuery(v);
              _load();
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: PathBar(
            path: provider.currentPath,
            onNavigate: _navigate,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.create_new_folder),
              onPressed: _askCreateFolder,
            ),
            IconButton(
              icon: const Icon(Icons.paste),
              onPressed: _pasteItems,
            ),
            IconButton(
              icon: const Icon(Icons.visibility),
              onPressed: () {
                provider.toggleHidden();
                _load();
              },
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                provider.toggleSort(v);
                _load();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'name', child: Text('Name')),
                PopupMenuItem(value: 'size', child: Text('Size')),
                PopupMenuItem(value: 'date', child: Text('Date')),
              ],
            ),
          ],
        ),
        Expanded(
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final selected = provider.selected.contains(item.path);
                      return FileTile(
                        item: item,
                        selected: selected,
                        onTap: () => _open(item),
                        onLongPress: () => _showActions(item),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }
}