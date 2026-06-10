import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_manager/photo_manager.dart';
import '../services/gallery_service.dart';
import '../theme/app_theme.dart';
import '../utils/permissions.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  bool _isLoading = true;
  String? _error;
  bool _didScheduleInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didScheduleInitialLoad) {
      _didScheduleInitialLoad = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadPhotos();
      });
    }
  }

  Future<void> _loadPhotos() async {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      setState(() {
        _error = 'No date range provided';
        _isLoading = false;
      });
      return;
    }

    final startDate = args['startDate'] as DateTime;
    final endDate = args['endDate'] as DateTime;
    final galleryService = Provider.of<GalleryService>(context, listen: false);

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success =
        await galleryService.loadPhotosFromDateRange(startDate, endDate);

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      if (!success) {
        _error = galleryService.error ?? 'Failed to load photos';
      }
    });
  }

  void _onContinueToSwipe() {
    Navigator.pushNamed(context, '/swipe');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Your photos')),
      body: Consumer<GalleryService>(
        builder: (context, galleryService, child) {
          if (_isLoading || galleryService.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Finding your photos...'),
                ],
              ),
            );
          }

          if (_error != null || galleryService.error != null) {
            final message = _error ?? galleryService.error ?? 'Unknown error';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline_rounded,
                        size: 64, color: cs.error),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    if (message.toLowerCase().contains('permission')) ...[
                      FilledButton(
                        onPressed: () => PermissionUtils.openSettings(),
                        child: const Text('Open Settings'),
                      ),
                      const SizedBox(height: 12),
                    ],
                    OutlinedButton(
                      onPressed: _loadPhotos,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (galleryService.photos.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library_outlined,
                        size: 64, color: cs.onSurfaceVariant),
                    const SizedBox(height: 16),
                    Text('No photos found',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(
                      'No photos in this date range. Try a different one.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Change date range'),
                    ),
                  ],
                ),
              ),
            );
          }

          final count = galleryService.photos.length;
          final previewCount = count > 9 ? 9 : count;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.brandGradient,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.brandRed.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.favorite_rounded,
                          size: 40, color: Colors.white),
                      const SizedBox(height: 12),
                      Text(
                        '$count photos to review',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to find the keepers?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: previewCount,
                    itemBuilder: (context, index) {
                      final photo = galleryService.photos[index];
                      final isLast = index == previewCount - 1 && count > 9;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FutureBuilder(
                              future: photo.thumbnailDataWithSize(
                                  const ThumbnailSize(300, 300)),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                }
                                return ColoredBox(
                                  color: cs.surfaceContainerHighest,
                                );
                              },
                            ),
                            if (isLast)
                              Container(
                                color: Colors.black.withValues(alpha: 0.5),
                                alignment: Alignment.center,
                                child: Text(
                                  '+${count - 9}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _onContinueToSwipe,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.style_rounded, size: 20),
                      SizedBox(width: 8),
                      Text('Start swiping'),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
