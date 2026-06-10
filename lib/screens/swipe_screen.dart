import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../services/gallery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/photo_card.dart';
import '../widgets/swipe_buttons.dart';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  late SwipableStackController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = SwipableStackController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  GalleryService get _gallery =>
      Provider.of<GalleryService>(context, listen: false);

  void _onSwipe(int index, SwipeDirection direction) {
    final galleryService = _gallery;

    if (index < galleryService.photos.length) {
      final photo = galleryService.photos[index];
      if (direction == SwipeDirection.left) {
        galleryService.markForDeletion(photo);
      } else if (direction == SwipeDirection.right) {
        galleryService.markAsKept(photo);
      }
    }

    setState(() => _currentIndex = index + 1);

    if (_currentIndex >= galleryService.photos.length) {
      _navigateToSummary();
    }
  }

  void _navigateToSummary() {
    Navigator.pushReplacementNamed(context, '/summary');
  }

  Future<void> _onEndSession() async {
    final galleryService = _gallery;
    final reviewed = galleryService.deletedCount + galleryService.keptCount;
    final total = galleryService.photos.length;
    final shouldEnd = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('End session?'),
            content: Text(
                'You\'ve reviewed $reviewed of $total photos. End now and see your summary?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Keep swiping'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('End session'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldEnd && mounted) {
      _navigateToSummary();
    }
  }

  void _onDeleteTap() => _controller.next(swipeDirection: SwipeDirection.left);
  void _onKeepTap() => _controller.next(swipeDirection: SwipeDirection.right);

  void _onUndo() {
    if (_currentIndex > 0) {
      _controller.rewind();
      setState(() => _currentIndex = _currentIndex - 1);
      _gallery.undoLastAction();
    }
  }

  void _precacheNext(BuildContext context, GalleryService gallery) {
    final nextIndex = _currentIndex + 1;
    if (nextIndex >= gallery.photos.length) return;
    final next = gallery.photos[nextIndex];
    final size = MediaQuery.of(context).size;
    final targetWidth = (size.width * 2).clamp(600.0, 1600.0).toInt();
    final aspect =
        (next.width > 0 && next.height > 0) ? next.width / next.height : 3 / 4;
    final targetHeight = (targetWidth / aspect).clamp(1, 4000).toInt();
    precacheImage(
      AssetEntityImageProvider(
        next,
        isOriginal: false,
        thumbnailSize: ThumbnailSize(targetWidth, targetHeight),
      ),
      context,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GalClean'),
        actions: [
          IconButton(
            onPressed: _onEndSession,
            icon: const Icon(Icons.flag_outlined),
            tooltip: 'End session',
          ),
        ],
      ),
      body: Consumer<GalleryService>(
        builder: (context, galleryService, child) {
          if (galleryService.photos.isEmpty) {
            return const Center(child: Text('No photos to review'));
          }

          if (_currentIndex >= galleryService.photos.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _navigateToSummary();
            });
            return const Center(child: CircularProgressIndicator());
          }

          _precacheNext(context, galleryService);

          final total = galleryService.photos.length;
          final progress = _currentIndex / total;

          return Column(
            children: [
              _ProgressHeader(
                current: _currentIndex + 1,
                total: total,
                progress: progress,
                kept: galleryService.keptCount,
                deleted: galleryService.deletedCount,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SwipableStack(
                    controller: _controller,
                    onSwipeCompleted: _onSwipe,
                    allowVerticalSwipe: false,
                    itemCount: total,
                    swipeAnchor: SwipeAnchor.bottom,
                    overlayBuilder: (context, properties) {
                      final dir = properties.direction;
                      if (dir == SwipeDirection.right) {
                        return _SwipeStamp(
                          label: 'KEEP',
                          color: AppTheme.keepColor,
                          alignment: Alignment.topLeft,
                          angle: -0.2,
                          opacity: properties.swipeProgress.clamp(0.0, 1.0),
                        );
                      }
                      if (dir == SwipeDirection.left) {
                        return _SwipeStamp(
                          label: 'PASS',
                          color: AppTheme.deleteColor,
                          alignment: Alignment.topRight,
                          angle: 0.2,
                          opacity: properties.swipeProgress.clamp(0.0, 1.0),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    builder: (context, properties) {
                      final index = properties.index;
                      if (index >= galleryService.photos.length) {
                        return const SizedBox.shrink();
                      }
                      return PhotoCard(photo: galleryService.photos[index]);
                    },
                  ),
                ),
              ),
              SwipeButtons(
                onDelete: _onDeleteTap,
                onKeep: _onKeepTap,
                onUndo: _currentIndex > 0 ? _onUndo : null,
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  'Swipe right to keep · left to pass',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int current;
  final int total;
  final double progress;
  final int kept;
  final int deleted;

  const _ProgressHeader({
    required this.current,
    required this.total,
    required this.progress,
    required this.kept,
    required this.deleted,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current of $total',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              Row(
                children: [
                  _CountPill(
                    icon: Icons.favorite_rounded,
                    count: kept,
                    color: AppTheme.keepColor,
                  ),
                  const SizedBox(width: 8),
                  _CountPill(
                    icon: Icons.delete_rounded,
                    count: deleted,
                    color: AppTheme.deleteColor,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation(AppTheme.brandRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;

  const _CountPill({
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 5),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// The "LIKE / NOPE"-style stamp that fades in as the card is dragged.
class _SwipeStamp extends StatelessWidget {
  final String label;
  final Color color;
  final Alignment alignment;
  final double angle;
  final double opacity;

  const _SwipeStamp({
    required this.label,
    required this.color,
    required this.alignment,
    required this.angle,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Align(
        alignment: alignment,
        child: Opacity(
          opacity: opacity,
          child: Transform.rotate(
            angle: angle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
