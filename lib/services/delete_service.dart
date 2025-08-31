import 'package:photo_manager/photo_manager.dart';

class DeleteService {
  static Future<bool> deletePhoto(AssetEntity photo) async {
    try {
      final result = await PhotoManager.editor.deleteWithIds([photo.id]);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deletePhotos(List<AssetEntity> photos) async {
    if (photos.isEmpty) return true;

    try {
      final result = await PhotoManager.editor.deleteWithIds(
        photos.map((photo) => photo.id).toList(),
      );
      // If partial, try deleting remaining one-by-one for better success rate
      if (result.length != photos.length) {
        final remaining = photos.where((p) => !result.contains(p.id));
        for (final p in remaining) {
          try {
            final r = await PhotoManager.editor.deleteWithIds([p.id]);
            if (r.isNotEmpty) {
              result.addAll(r);
            }
          } catch (_) {
            // ignore single failure
          }
        }
      }
      return result.length == photos.length;
    } catch (e) {
      // As a last resort, attempt per-item deletion
      var successCount = 0;
      for (final p in photos) {
        try {
          final r = await PhotoManager.editor.deleteWithIds([p.id]);
          if (r.isNotEmpty) successCount++;
        } catch (_) {
          // ignore
        }
      }
      return successCount == photos.length;
    }
  }

  // Returns the set of IDs that were successfully deleted.
  static Future<Set<String>> deleteAndReturnDeletedIds(List<AssetEntity> photos) async {
    final deletedIds = <String>{};
    if (photos.isEmpty) return deletedIds;

    try {
      final batch = await PhotoManager.editor.deleteWithIds(
        photos.map((p) => p.id).toList(),
      );
      deletedIds.addAll(batch);
    } catch (_) {
      // ignore and fallback to per-item
    }

    // Per-item fallback for anything not deleted in batch
    final remaining = photos.where((p) => !deletedIds.contains(p.id));
    for (final p in remaining) {
      try {
        final r = await PhotoManager.editor.deleteWithIds([p.id]);
        if (r.isNotEmpty) {
          deletedIds.addAll(r);
        }
      } catch (_) {
        // ignore
      }
    }

    return deletedIds;
  }

  static Future<bool> canDeletePhotos() async {
    // Check if the app has permission to delete photos
    try {
      final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      return albums.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
