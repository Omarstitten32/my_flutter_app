import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> shareText(String text) async {
    await Share.share(text);
  }

  static Future<void> shareFile(String path) async {
    await Share.shareXFiles([XFile(path)]);
  }
}