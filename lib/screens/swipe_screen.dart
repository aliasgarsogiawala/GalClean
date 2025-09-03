import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import '../services/gallery_service.dart';
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

  void _onSwipe(int index, SwipeDirection direction) {
    final galleryService = Provider.of<GalleryService>(context, listen: false);

    if (index < galleryService.photos.length) {
      final photo = galleryService.photos[index];

      if (direction == SwipeDirection.left) {
        galleryService.markForDeletion(photo);
      } else if (direction == SwipeDirection.right) {
        galleryService.markAsKept(photo);
      }
    }

    setState(() {
      _currentIndex = index + 1;
    });

    // Check if we've gone through all photos
    if (_currentIndex >= galleryService.photos.length) {
      _navigateToSummary();
    }
  }

  void _navigateToSummary() {
    Navigator.pushReplacementNamed(context, '/summary');
  }

  Future<void> _onEndSession() async {
    final galleryService = Provider.of<GalleryService>(context, listen: false);
    final reviewed = galleryService.deletedCount + galleryService.keptCount;
    final total = galleryService.photos.length;
    final shouldEnd = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('End Session?'),
            content: Text('You\'ve reviewed $reviewed of $total photos. End the session and view summary?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Continue Reviewing'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('End Session'),
              ),
            ],
          ),
        ) ??
        false;

    if (shouldEnd) {
      _navigateToSummary();
    }
  }

  void _onDeleteTap() {
    _controller.next(swipeDirection: SwipeDirection.left);
  }

  void _onKeepTap() {
    _controller.next(swipeDirection: SwipeDirection.right);
  }

  void _onUndo() {
    final galleryService = Provider.of<GalleryService>(context, listen: false);

    if (_currentIndex > 0) {
      _controller.rewind();
      setState(() {
        _currentIndex = _currentIndex - 1;
      });
      galleryService.undoLastAction();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clean Photos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: _onEndSession,
            icon: const Icon(Icons.stop_circle_outlined),
            tooltip: 'End session and view summary',
          ),
          Consumer<GalleryService>(
            builder: (context, galleryService, child) {
              return IconButton(
                onPressed: _currentIndex > 0 ? _onUndo : null,
                icon: const Icon(Icons.undo),
                tooltip: 'Undo',
              );
            },
          ),
        ],
      ),
      body: Consumer<GalleryService>(
        builder: (context, galleryService, child) {
          if (galleryService.photos.isEmpty) {
            return const Center(
              child: Text('No photos to review'),
            );
          }

          if (_currentIndex >= galleryService.photos.length) {
            // This should not happen as we navigate away, but just in case
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _navigateToSummary();
            });
            return const Center(child: CircularProgressIndicator());
          }

          // Prefetch next image to reduce perceived jank (placed outside widget tree)
          final nextIndex = _currentIndex + 1;
          if (nextIndex < galleryService.photos.length) {
            final next = galleryService.photos[nextIndex];
            final size = MediaQuery.of(context).size;
            final targetWidth = (size.width * 2).clamp(600.0, 1600.0).toInt();
            final aspect = (next.width > 0 && next.height > 0)
                ? next.width / next.height
                : 4 / 5;
            final targetHeight = ((targetWidth / aspect).clamp(1, 4000)).toInt();
            final provider = AssetEntityImageProvider(
              next,
              isOriginal: false,
              thumbnailSize: ThumbnailSize(targetWidth, targetHeight),
            );
            // fire-and-forget
            precacheImage(provider, context);
          }

          return Column(
            children: [
              // Progress indicator
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_currentIndex + 1} of ${galleryService.photos.length}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          'Deleted: ${galleryService.deletedCount} | Kept: ${galleryService.keptCount}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _currentIndex / galleryService.photos.length,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                    ),
                  ],
                ),
              ),

              // Swipable photo stack
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SwipableStack(
                    controller: _controller,
                    onSwipeCompleted: _onSwipe,
                    allowVerticalSwipe: false,
                    itemCount: galleryService.photos.length,
                    builder: (context, properties) {
                      final index = properties.index;
                      if (index >= galleryService.photos.length) {
                        return const SizedBox.shrink();
                      }

                      return PhotoCard(
                        photo: galleryService.photos[index],
                        swipeProgress: null, // Simplified for v2.0.0 compatibility
                      );
                    },
                  ),
                ),
              ),

              // Action buttons
              SwipeButtons(
                onDelete: _onDeleteTap,
                onKeep: _onKeepTap,
                onUndo: _currentIndex > 0 ? _onUndo : null,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: OutlinedButton.icon(
                  onPressed: _onEndSession,
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text('End Session'),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
