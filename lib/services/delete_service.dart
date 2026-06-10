import 'package:photo_manager/photo_manager.dart';

class DeleteService {
  /// Deletes [photos] and returns the set of asset ids that were actually
  /// removed.
  ///
  /// It first tries a single batch delete, then retries any leftovers
  /// individually — some platforms (limited access, shared albums) only
  /// delete a subset per call.
  static Future<Set<String>> deleteAndReturnDeletedIds(
    List<AssetEntity> photos,
  ) async {
    final deletedIds = <String>{};
    if (photos.isEmpty) return deletedIds;

    try {
      final batch = await PhotoManager.editor.deleteWithIds(
        photos.map((p) => p.id).toList(),
      );
      deletedIds.addAll(batch);
    } catch (_) {
      // Fall through to the per-item retry below.
    }

    final remaining = photos.where((p) => !deletedIds.contains(p.id));
    for (final p in remaining) {
      try {
        final r = await PhotoManager.editor.deleteWithIds([p.id]);
        if (r.isNotEmpty) {
          deletedIds.addAll(r);
        }
      } catch (_) {
        // Skip ones that can't be deleted; the caller reports partial results.
      }
    }

    return deletedIds;
  }
}
