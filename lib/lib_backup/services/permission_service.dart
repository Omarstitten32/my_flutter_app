import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAll() async {
    final storage = await Permission.storage.request();
    final manage = await Permission.manageExternalStorage.request();
    return storage.isGranted || manage.isGranted;
  }

  static Future<bool> hasManageStorage() async {
    return await Permission.manageExternalStorage.isGranted;
  }

  static Future<bool> openSettingsIfNeeded() async {
    return await openAppSettings();
  }
}