import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

class Helpers {
  static String formatBytes(int bytes, {int decimals = 1}) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return '${size.toStringAsFixed(decimals)} ${suffixes[i]}';
  }

  static String formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  static String fileName(String path) {
    return p.basename(path);
  }

  static String fileExtension(String path) {
    return p.extension(path).toLowerCase();
  }

  static String fileTitle(String path) {
    return p.basenameWithoutExtension(path);
  }

  static bool isHidden(String path) {
    return p.basename(path).startsWith('.');
  }

  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}