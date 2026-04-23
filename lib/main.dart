import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.storage.request();
  runApp(const FileManagerApp());
}

class FileManagerApp extends StatelessWidget {
  const FileManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'File Manager',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.blueAccent,
        scaffoldBackgroundColor: Colors.black87,
      ),
      home: const FileManagerHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FileManagerHome extends StatefulWidget {
  const FileManagerHome({super.key});

  @override
  State<FileManagerHome> createState() => _FileManagerHomeState();
}

class _FileManagerHomeState extends State<FileManagerHome> {
  Directory? _currentDirectory;
  List<FileSystemEntity> _files = [];
  bool _isLoading = true;
  String _errorMessage = '';
  FileSystemEntity? _copiedEntity;
  bool _isCutOperation = false;

  @override
  void initState() {
    super.initState();
    _loadInitialDirectory();
  }

  Future<void> _loadInitialDirectory() async {
    try {
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null && await downloadsDir.exists()) {
        _currentDirectory = downloadsDir;
      } else {
        _currentDirectory = Directory('/storage/emulated/0');
      }
      await _loadFiles();
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load directory: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadFiles() async {
    if (_currentDirectory == null) return;
    setState(() => _isLoading = true);
    try {
      final List<FileSystemEntity> contents = _currentDirectory!.listSync();
      contents.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return a.path.compareTo(b.path);
      });
      _files = contents;
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Cannot read directory: $e';
    }
    setState(() => _isLoading = false);
  }

  void _openDirectory(Directory dir) {
    setState(() => _currentDirectory = dir);
    _loadFiles();
  }

  void _goBack() {
    if (_currentDirectory != null && _currentDirectory!.path != '/') {
      final parent = Directory(_currentDirectory!.path.substring(0, _currentDirectory!.path.lastIndexOf('/')));
      if (parent.path.isNotEmpty) {
        setState(() => _currentDirectory = parent);
        _loadFiles();
      }
    }
  }

  Future<void> _createFolder() async {
    final TextEditingController controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty && _currentDirectory != null) {
      try {
        final newFolder = Directory('${_currentDirectory!.path}/$result');
        await newFolder.create();
        await _loadFiles();
        _showSnackBar('Folder created');
      } catch (e) {
        _showSnackBar('Failed to create folder: $e');
      }
    }
  }

  Future<void> _deleteEntity(FileSystemEntity entity) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete ${entity.path.split('/').last}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm == true) {
      try {
        if (entity is Directory) await entity.delete(recursive: true);
        else if (entity is File) await entity.delete();
        await _loadFiles();
        _showSnackBar('Deleted successfully');
      } catch (e) {
        _showSnackBar('Delete failed: $e');
      }
    }
  }

  void _copyEntity(FileSystemEntity entity, {bool cut = false}) {
    _copiedEntity = entity;
    _isCutOperation = cut;
    _showSnackBar('${cut ? 'Cut' : 'Copied'}: ${entity.path.split('/').last}');
  }

  Future<void> _pasteHere() async {
    if (_copiedEntity == null || _currentDirectory == null) return;
    final destination = _currentDirectory!.path;
    final sourcePath = _copiedEntity!.path;
    final fileName = sourcePath.split('/').last;
    final destPath = '$destination/$fileName';

    try {
      if (_copiedEntity is Directory) {
        final destDir = Directory(destPath);
        if (_isCutOperation) {
          await _copiedEntity!.rename(destPath);
        } else {
          await _copyDirectory(_copiedEntity as Directory, destDir);
        }
      } else if (_copiedEntity is File) {
        final destFile = File(destPath);
        if (_isCutOperation) {
          await _copiedEntity!.rename(destPath);
        } else {
          await (_copiedEntity as File).copy(destPath);
        }
      }
      await _loadFiles();
      _showSnackBar('Pasted successfully');
      if (_isCutOperation) _copiedEntity = null;
    } catch (e) {
      _showSnackBar('Paste failed: $e');
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    if (!await destination.exists()) await destination.create();
    final entities = source.listSync();
    for (final entity in entities) {
      final destPath = '${destination.path}/${entity.path.split('/').last}';
      if (entity is Directory) {
        await _copyDirectory(entity, Directory(destPath));
      } else if (entity is File) {
        await entity.copy(destPath);
      }
    }
  }

  void _showDetails(FileSystemEntity entity) {
    final stat = entity.statSync();
    final type = entity is Directory ? 'Directory' : 'File';
    final size = entity is File ? _formatSize(stat.size) : '—';
    final modified = DateTime.fromMillisecondsSinceEpoch(stat.modified.millisecondsSinceEpoch);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(entity.path.split('/').last),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: $type'),
            Text('Path: ${entity.path}'),
            if (entity is File) Text('Size: $size'),
            Text('Modified: $modified'),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentDirectory?.path ?? 'File Manager'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
        actions: [
          IconButton(icon: const Icon(Icons.create_new_folder), onPressed: _createFolder),
          if (_copiedEntity != null)
            IconButton(icon: const Icon(Icons.paste), onPressed: _pasteHere),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, style: const TextStyle(color: Colors.red)))
              : _files.isEmpty
                  ? const Center(child: Text('This folder is empty'))
                  : ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (ctx, index) {
                        final entity = _files[index];
                        final isDir = entity is Directory;
                        final name = entity.path.split('/').last;
                        final icon = isDir ? Icons.folder : Icons.insert_drive_file;
                        return Dismissible(
                          key: Key(entity.path),
                          background: Container(color: Colors.red, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20), child: const Icon(Icons.delete, color: Colors.white)),
                          confirmDismiss: (dir) async {
                            if (dir == DismissDirection.endToStart) {
                              await _deleteEntity(entity);
                              return false;
                            }
                            return false;
                          },
                          child: ListTile(
                            leading: Icon(icon, color: isDir ? Colors.amber : Colors.blue),
                            title: Text(name),
                            subtitle: entity is File ? Text(_formatSize(entity.statSync().size)) : null,
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'copy') _copyEntity(entity);
                                if (value == 'cut') _copyEntity(entity, cut: true);
                                if (value == 'delete') _deleteEntity(entity);
                                if (value == 'details') _showDetails(entity);
                                if (value == 'share' && entity is File) Share.shareXFiles([XFile(entity.path)]);
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(value: 'copy', child: Text('Copy')),
                                const PopupMenuItem(value: 'cut', child: Text('Cut')),
                                const PopupMenuItem(value: 'delete', child: Text('Delete')),
                                const PopupMenuItem(value: 'details', child: Text('Details')),
                                if (entity is File) const PopupMenuItem(value: 'share', child: Text('Share')),
                              ],
                            ),
                            onTap: () {
                              if (isDir) _openDirectory(entity as Directory);
                              else _showDetails(entity);
                            },
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pasteHere(),
        child: const Icon(Icons.paste),
      ),
    );
  }
}
