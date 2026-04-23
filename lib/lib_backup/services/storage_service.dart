import 'dart:io';
import 'package:path_provider/path_provider.dart';

class StorageService {
  static Future<String> getPrimaryPath() async {
    return '/storage/emulated/0';
  }

  static Future<String?> getAppPath() async {
    final dir = await getExternalStorageDirectory();
    return dir?.path;
  }

  static Future<List<String>> getKnownPaths() async {
    return [
      '/storage/emulated/0',
      '/sdcard',
      '/storage/self/primary',
    ];
  }

  static Future<bool> exists(String path) async {
    return FileSystemEntity.typeSync(path) != FileSystemEntityType.notFound;
  }
}