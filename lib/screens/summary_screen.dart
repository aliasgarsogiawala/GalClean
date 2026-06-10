import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gallery_service.dart';
import '../theme/app_theme.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  bool _isDeleting = false;
  bool _deletionComplete = false;
  String? _deletionError;

  Future<void> _confirmAndDelete() async {
    final galleryService = Provider.of<GalleryService>(context, listen: false);

    if (galleryService.photosToDelete.isEmpty) {
      _showSnackBar('No photos marked for deletion');
      return;
    }

    final confirmed = await _showDeleteConfirmationDialog();
    if (!confirmed) return;

    setState(() {
      _isDeleting = true;
      _deletionError = null;
    });

    try {
      final success = await galleryService.deleteMarkedPhotos();
      if (!mounted) return;

      setState(() {
        _isDeleting = false;
        _deletionComplete = success;
        _deletionError = success
            ? null
            : (galleryService.error ?? 'Failed to delete some photos');
      });

      _showSnackBar(
          success ? 'Photos deleted successfully!' : 'Failed to delete photos');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isDeleting = false;
        _deletionError = 'Error deleting photos: $e';
      });
      _showSnackBar('Error occurred while deleting photos');
    }
  }

  Future<bool> _showDeleteConfirmationDialog() async {
    final galleryService = Provider.of<GalleryService>(context, listen: false);

    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm deletion'),
            content: Text(
              'Permanently delete ${galleryService.photosToDelete.length} photos? This can\'t be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _startNewSession() {
    final galleryService = Provider.of<GalleryService>(context, listen: false);
    galleryService.clearPhotos();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Summary'),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<GalleryService>(
          builder: (context, galleryService, child) {
            final reviewedCount =
                galleryService.keptCount + galleryService.deletedCount;
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Headline card
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: _deletionComplete
                          ? AppTheme.keepGradient
                          : AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (_deletionComplete
                                  ? AppTheme.keepColor
                                  : AppTheme.brandRed)
                              .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _deletionComplete
                              ? Icons.check_circle_rounded
                              : Icons.celebration_rounded,
                          size: 56,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          _deletionComplete
                              ? 'Gallery cleaned!'
                              : 'That\'s a wrap!',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _deletionComplete
                              ? 'Your gallery is lighter and tidier.'
                              : 'Review your picks, then confirm deletion.',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.95),
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: 'Reviewed',
                          value: '$reviewedCount',
                          icon: Icons.done_all_rounded,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Keeping',
                          value: '${galleryService.keptCount}',
                          icon: Icons.favorite_rounded,
                          color: AppTheme.keepColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: 'Deleting',
                          value: '${galleryService.deletedCount}',
                          icon: Icons.delete_rounded,
                          color: AppTheme.deleteColor,
                        ),
                      ),
                    ],
                  ),

                  if (_deletionError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline_rounded,
                              color: cs.onErrorContainer),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _deletionError!,
                              style: TextStyle(color: cs.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  if (!_deletionComplete &&
                      galleryService.photosToDelete.isNotEmpty) ...[
                    FilledButton(
                      onPressed: _isDeleting ? null : _confirmAndDelete,
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.error,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: _isDeleting
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Deleting photos...'),
                              ],
                            )
                          : Text(
                              'Delete ${galleryService.photosToDelete.length} photos'),
                    ),
                    const SizedBox(height: 12),
                  ],

                  OutlinedButton(
                    onPressed: _isDeleting ? null : _startNewSession,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('Start new session'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
