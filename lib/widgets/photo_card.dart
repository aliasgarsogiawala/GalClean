import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:intl/intl.dart';

/// A single full-bleed photo "profile card" in the swipe deck.
class PhotoCard extends StatelessWidget {
  final AssetEntity photo;

  const PhotoCard({
    super.key,
    required this.photo,
  });

  @override
  Widget build(BuildContext context) {
    // Render at roughly device resolution so cards look crisp, not pixelated.
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final size = MediaQuery.of(context).size;
    final targetWidth = (size.width * dpr).clamp(600.0, 1600.0).toInt();
    final aspect = (photo.width > 0 && photo.height > 0)
        ? photo.width / photo.height
        : 3 / 4;
    final targetHeight = (targetWidth / aspect).clamp(1.0, 4000.0).toInt();

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              AssetEntityImage(
                photo,
                isOriginal: false,
                thumbnailSize: ThumbnailSize(targetWidth, targetHeight),
                fit: BoxFit.cover,
                frameBuilder: (context, child, frame, wasSync) {
                  if (wasSync) return child;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: frame == null
                        ? const ColoredBox(color: Color(0xFF1A1A1A))
                        : child,
                  );
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const ColoredBox(
                    color: Color(0xFF1A1A1A),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Colors.white70,
                        strokeWidth: 2.5,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stack) => const ColoredBox(
                  color: Color(0xFF1A1A1A),
                  child: Center(
                    child: Icon(Icons.broken_image_outlined,
                        color: Colors.white38, size: 48),
                  ),
                ),
              ),

              // Bottom gradient + metadata, styled like a dating profile card.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Color(0xE6000000),
                        Color(0x00000000),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat('MMMM d, yyyy').format(photo.createDateTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _MetaChip(
                            icon: Icons.access_time_rounded,
                            label: DateFormat('h:mm a')
                                .format(photo.createDateTime),
                          ),
                          if (photo.width > 0 && photo.height > 0)
                            _MetaChip(
                              icon: Icons.aspect_ratio_rounded,
                              label: '${photo.width} × ${photo.height}',
                            ),
                          if (photo.type == AssetType.video)
                            const _MetaChip(
                              icon: Icons.videocam_rounded,
                              label: 'Video',
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
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
