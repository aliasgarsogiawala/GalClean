import 'dart:io';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  // Request basic gallery permissions sufficient for reading assets
  static Future<bool> requestGalleryPermissions() async {
    // Prefer photo_manager's unified API
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    // Treat authorized or limited as sufficient for browsing
    if (state.isAuth || state == PermissionState.limited) {
      return true;
    }

    // As a fallback on Android, request manage external storage (older devices)
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
    // authorized or limited
    return state.isAuth || state == PermissionState.limited;
  }

  static Future<bool> isLimitedAccess() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    return state == PermissionState.limited; // iOS 14+ limited library
  }

  // Ensure we have full access needed to delete photos (iOS requires full access)
  static Future<bool> ensureFullAccessForDeletion() async {
    final PermissionState state = await PhotoManager.requestPermissionExtend();
    if (state.isAuth && state != PermissionState.limited) return true;

    // Try asking for more access via system UI where possible
    if (Platform.isIOS) {
      // Show the limited-library picker to let user broaden selection
      await PhotoManager.presentLimited();
      final PermissionState retry = await PhotoManager.requestPermissionExtend();
      if (retry.isAuth && retry != PermissionState.limited) return true;
      // Open settings if still limited/denied
      await openAppSettings();
      final PermissionState afterSettings = await PhotoManager.requestPermissionExtend();
      return afterSettings.isAuth && afterSettings != PermissionState.limited;
    }

    // On Android, authorized implies we can delete if we own the media
    return state.isAuth;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
