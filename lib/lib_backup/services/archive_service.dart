import 'dart:io';
import 'package:archive/archive.dart';

class ArchiveService {
  static Future<bool> extractZip(String zipPath, String targetDir) async {
    try {
      final bytes = await File(zipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        final outPath = '$targetDir/${file.name}';
        if (file.isFile) {
          await File(outPath).create(recursive: true);
          await File(outPath).writeAsBytes(file.content as List<int>);
        } else {
          await Directory(outPath).create(recursive: true);
        }
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> createZip(List<String> paths, String outputPath) async {
    try {
      final archive = Archive();
      for (final path in paths) {
        final file = File(path);
        if (await file.exists()) {
          final name = path.split('/').last;
          final bytes = await file.readAsBytes();
          archive.addFile(ArchiveFile(name, bytes.length, bytes));
        }
      }
      final zipBytes = ZipEncoder().encode(archive);
      if (zipBytes != null) {
        await File(outputPath).writeAsBytes(zipBytes);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}