import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:intl/intl.dart';

class PhotoCard extends StatelessWidget {
  final AssetEntity photo;
  final double? swipeProgress; // kept for compatibility; overlay not rendered here

  const PhotoCard({
    super.key,
    required this.photo,
    this.swipeProgress,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        shadowColor: Colors.black.withOpacity(0.2),
        child: Stack(
          children: [
            // Photo image using AssetEntityImage for simplicity and performance
            Positioned.fill(
              child: AssetEntityImage(
                photo,
                thumbnailSize: const ThumbnailSize(200, 200),
                fit: BoxFit.cover,
              ),
            ),

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
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withOpacity(0.85),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('h:mm a').format(photo.createDateTime),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        // Resolution info
                        Icon(
                          Icons.photo_size_select_actual,
                          color: Colors.white.withOpacity(0.85),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${photo.width} × ${photo.height}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
