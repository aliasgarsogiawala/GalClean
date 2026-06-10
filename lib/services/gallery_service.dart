import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import '../utils/permissions.dart';
import 'delete_service.dart';

/// A single review decision, kept so [GalleryService.undoLastAction] can
/// reverse exactly what the user last did (and not just guess).
enum _SwipeAction { keep, delete }

class _ReviewRecord {
  _ReviewRecord(this.photo, this.action);
  final AssetEntity photo;
  final _SwipeAction action;
}

class GalleryService extends ChangeNotifier {
  List<AssetEntity> _photos = [];
  final List<AssetEntity> _photosToDelete = [];
  final List<AssetEntity> _keptPhotos = [];
  final List<_ReviewRecord> _history = [];
  bool _isLoading = false;
  String? _error;

  List<AssetEntity> get photos => _photos;
  List<AssetEntity> get photosToDelete => _photosToDelete;
  List<AssetEntity> get keptPhotos => _keptPhotos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalPhotos => _photos.length;
  int get deletedCount => _photosToDelete.length;
  int get keptCount => _keptPhotos.length;

  Future<bool> loadPhotosFromDateRange(DateTime startDate, DateTime endDate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      bool hasPermission = await PermissionUtils.hasGalleryPermissions();
      if (!hasPermission) {
        hasPermission = await PermissionUtils.requestGalleryPermissions();
        if (!hasPermission) {
          _error = 'Gallery permission is required to access photos';
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        hasAll: true,
      );

      if (albums.isEmpty) {
        _error = 'No photo albums found';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final recentAlbum = albums.first;
      final assetCount = await recentAlbum.assetCountAsync;
      final assets = await recentAlbum.getAssetListRange(
        start: 0,
        end: assetCount,
      );

      _photos = assets.where((asset) {
        final photoDate = asset.createDateTime;
        return photoDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
               photoDate.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      _photos.sort((a, b) => b.createDateTime.compareTo(a.createDateTime));

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to load photos: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void markForDeletion(AssetEntity photo) {
    if (!_photosToDelete.contains(photo)) {
      _photosToDelete.add(photo);
      _keptPhotos.remove(photo);
      _history.add(_ReviewRecord(photo, _SwipeAction.delete));
      notifyListeners();
    }
  }

  void markAsKept(AssetEntity photo) {
    if (!_keptPhotos.contains(photo)) {
      _keptPhotos.add(photo);
      _photosToDelete.remove(photo);
      _history.add(_ReviewRecord(photo, _SwipeAction.keep));
      notifyListeners();
    }
  }

  /// Reverses the most recent decision (keep or delete) for the right photo.
  void undoLastAction() {
    if (_history.isEmpty) return;

    final last = _history.removeLast();
    if (last.action == _SwipeAction.delete) {
      _photosToDelete.remove(last.photo);
    } else {
      _keptPhotos.remove(last.photo);
    }
    notifyListeners();
  }

  Future<bool> deleteMarkedPhotos() async {
    if (_photosToDelete.isEmpty) return true;

    final canDelete = await PermissionUtils.ensureFullAccessForDeletion();
    if (!canDelete) {
      _error = 'Full photo access is required to delete photos. Please grant "Full Access" in Settings > Privacy > Photos.';
      notifyListeners();
      return false;
    }

    try {
      final deletedIds = await DeleteService.deleteAndReturnDeletedIds(_photosToDelete);

      if (deletedIds.isNotEmpty) {
        _photos.removeWhere((photo) => deletedIds.contains(photo.id));
        _photosToDelete.removeWhere((photo) => deletedIds.contains(photo.id));
      }

      final allDeleted = _photosToDelete.isEmpty;

      if (!allDeleted) {
        _error = 'Some photos could not be deleted. This can happen with limited access, shared albums, or system restrictions.';
      } else {
        _error = null;
      }

      notifyListeners();
      return allDeleted;
    } catch (e) {
      _error = 'Failed to delete photos: $e';
      notifyListeners();
      return false;
    }
  }

  void resetSelection() {
    _photosToDelete.clear();
    _keptPhotos.clear();
    _history.clear();
    _error = null;
    notifyListeners();
  }

  void clearPhotos() {
    _photos.clear();
    _photosToDelete.clear();
    _keptPhotos.clear();
    _history.clear();
    _error = null;
    notifyListeners();
  }
}
