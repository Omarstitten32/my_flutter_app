import 'dart:io';
import 'package:path/path.dart' as p;
import '../models/file_item.dart';

class FileService {
  static Future<List<FileItem>> listItems(String path, {bool showHidden = false}) async {
    final dir = Directory(path);
    if (!await dir.exists()) return [];
    final items = <FileItem>[];
    await for (final entity in dir.list(followLinks: false)) {
      final name = p.basename(entity.path);
      if (!showHidden && name.startsWith('.')) continue;
      final stat = await entity.stat();
      items.add(
        FileItem(
          name: name,
          path: entity.path,
          isDirectory: entity is Directory,
          size: stat.size,
          modified: stat.modified,
          extension: p.extension(entity.path).toLowerCase(),
          isHidden: name.startsWith('.'),
        ),
      );
    }
    items.sort(
      (a, b) => a.isDirectory == b.isDirectory
          ? a.name.toLowerCase().compareTo(b.name.toLowerCase())
          : (a.isDirectory ? -1 : 1),
    );
    return items;
  }

  static Future<bool> createFolder(String parentPath, String name) async {
    try {
      await Directory('$parentPath/$name').create(recursive: true);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> renameItem(String oldPath, String newName) async {
    try {
      final parent = p.dirname(oldPath);
      final newPath = p.join(parent, newName);
      final type = FileSystemEntity.typeSync(oldPath);
      if (type == FileSystemEntityType.directory) {
        await Directory(oldPath).rename(newPath);
      } else {
        await File(oldPath).rename(newPath);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteItem(String path) async {
    try {
      final type = FileSystemEntity.typeSync(path);
      if (type == FileSystemEntityType.directory) {
        await Directory(path).delete(recursive: true);
      } else {
        await File(path).delete();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> copyItem(String sourcePath, String destinationPath) async {
    try {
      final type = FileSystemEntity.typeSync(sourcePath);
      if (type == FileSystemEntityType.file) {
        await File(sourcePath).copy(destinationPath);
      } else if (type == FileSystemEntityType.directory) {
        await Directory(destinationPath).create(recursive: true);
        await for (final entity in Directory(sourcePath).list(recursive: true, followLinks: false)) {
          final relative = p.relative(entity.path, from: sourcePath);
          final target = p.join(destinationPath, relative);
          if (entity is Directory) {
            await Directory(target).create(recursive: true);
          } else if (entity is File) {
            await File(target).create(recursive: true);
            await entity.copy(target);
          }
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> moveItem(String sourcePath, String destinationPath) async {
    try {
      final type = FileSystemEntity.typeSync(sourcePath);
      if (type == FileSystemEntityType.file) {
        await File(sourcePath).rename(destinationPath);
      } else {
        await Directory(sourcePath).rename(destinationPath);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static bool isImage(String path) => ['.jpg', '.jpeg', '.png', '.gif', '.webp'].contains(p.extension(path).toLowerCase());
  static bool isVideo(String path) => ['.mp4', '.mkv', '.avi', '.mov'].contains(p.extension(path).toLowerCase());
  static bool isAudio(String path) => ['.mp3', '.wav', '.aac', '.ogg'].contains(p.extension(path).toLowerCase());
  static bool isPdf(String path) => p.extension(path).toLowerCase() == '.pdf';
  static bool isZip(String path) => p.extension(path).toLowerCase() == '.zip';
  static bool isText(String path) => ['.txt', '.json', '.xml', '.yaml', '.dart', '.csv'].contains(p.extension(path).toLowerCase());
}