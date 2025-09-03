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
      if (result.length != photos.length) {
        final remaining = photos.where((p) => !result.contains(p.id));
        for (final p in remaining) {
          try {
            final r = await PhotoManager.editor.deleteWithIds([p.id]);
            if (r.isNotEmpty) {
              result.addAll(r);
            }
          } catch (_) {
          }
        }
      }
      return result.length == photos.length;
    } catch (e) {
      var successCount = 0;
      for (final p in photos) {
        try {
          final r = await PhotoManager.editor.deleteWithIds([p.id]);
          if (r.isNotEmpty) successCount++;
        } catch (_) {
        }
      }
      return successCount == photos.length;
    }
  }

  static Future<Set<String>> deleteAndReturnDeletedIds(List<AssetEntity> photos) async {
    final deletedIds = <String>{};
    if (photos.isEmpty) return deletedIds;

    try {
      final batch = await PhotoManager.editor.deleteWithIds(
        photos.map((p) => p.id).toList(),
      );
      deletedIds.addAll(batch);
    } catch (_) {
    }

    final remaining = photos.where((p) => !deletedIds.contains(p.id));
    for (final p in remaining) {
      try {
        final r = await PhotoManager.editor.deleteWithIds([p.id]);
        if (r.isNotEmpty) {
          deletedIds.addAll(r);
        }
      } catch (_) {
      }
    }

    return deletedIds;
  }

  static Future<bool> canDeletePhotos() async {
    try {
      final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      return albums.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
