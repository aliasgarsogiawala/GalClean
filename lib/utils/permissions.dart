import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestGalleryPermissions() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if (state.isAuth || state == PermissionState.limited) {
      return true;
    }

    if (Platform.isAndroid) {
      await Permission.storage.request();
      await Permission.manageExternalStorage.request();
      final s = await Permission.storage.status;
      return s.isGranted;
    }
    return false;
  }

  static Future<bool> hasGalleryPermissions() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
]    return state.isAuth || state == PermissionState.limited;
  }

  static Future<bool> isLimitedAccess() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    return state == PermissionState.limited;
  }

  static Future<bool> ensureFullAccessForDeletion() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if (state.isAuth && state != PermissionState.limited) return true;

    if (Platform.isIOS) {
      await PhotoManager.presentLimited();
      final PermissionState retry = await PhotoManager.requestPermissionExtend();
      if (retry.isAuth && retry != PermissionState.limited) return true;
      await openAppSettings();
      final PermissionState afterSettings = await PhotoManager.requestPermissionExtend();
      return afterSettings.isAuth && afterSettings != PermissionState.limited;
    }

    return state.isAuth;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
