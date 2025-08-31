import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:intl/intl.dart';

class PhotoCard extends StatelessWidget {
  final AssetEntity photo;
  final double? swipeProgress;

  const PhotoCard({
    super.key,
    required this.photo,
    this.swipeProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Photo image
          FutureBuilder(
            future: photo.originBytes,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: MemoryImage(snapshot.data!),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(
                    child: Icon(Icons.error, size: 48),
                  ),
                );
              } else {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),

          // Swipe direction indicator overlay
          if (swipeProgress != null) ...[
            _buildSwipeOverlay(context, swipeProgress!),
          ],

          // Photo info overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DateFormat('MMMM dd, yyyy').format(photo.createDateTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: Colors.white.withOpacity(0.8),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(photo.createDateTime),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      if (photo.width != null && photo.height != null) ...[
                        Icon(
                          Icons.photo_size_select_actual,
                          color: Colors.white.withOpacity(0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${photo.width} × ${photo.height}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeOverlay(BuildContext context, double swipeProgress) {
    final horizontalProgress = swipeProgress;
    final isSwipingLeft = horizontalProgress < 0;
    final isSwipingRight = horizontalProgress > 0;
    final opacity = (horizontalProgress.abs() * 2).clamp(0.0, 1.0);

    if (opacity < 0.1) return const SizedBox.shrink();

    Color overlayColor;
    IconData icon;
    String text;

    if (isSwipingLeft) {
      overlayColor = Colors.red.withOpacity(opacity * 0.8);
      icon = Icons.delete;
      text = 'DELETE';
    } else {
      overlayColor = Colors.green.withOpacity(opacity * 0.8);
      icon = Icons.favorite;
      text = 'KEEP';
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: overlayColor,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
