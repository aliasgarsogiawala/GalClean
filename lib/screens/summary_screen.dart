import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gallery_service.dart';
import '../services/delete_service.dart';

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

      setState(() {
        _isDeleting = false;
        _deletionComplete = success;
        _deletionError = success ? null : (galleryService.error ?? 'Failed to delete some photos');
      });

      if (success) {
        _showSnackBar('Photos deleted successfully!');
      } else {
        _showSnackBar('Failed to delete photos');
      }
    } catch (e) {
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
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to permanently delete ${galleryService.photosToDelete.length} photos? This action cannot be undone.',
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
    ) ?? false;
  }

  void _showSnackBar(String message) {
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
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cleaning Summary'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          automaticallyImplyLeading: false,
        ),
        body: Consumer<GalleryService>(
          builder: (context, galleryService, child) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Completion message
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Icon(
                            _deletionComplete
                              ? Icons.check_circle_outline
                              : Icons.cleaning_services,
                            size: 64,
                            color: _deletionComplete
                              ? Colors.green
                              : Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _deletionComplete
                              ? 'Gallery Cleaned!'
                              : 'Cleaning Complete!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _deletionComplete
                              ? 'Your gallery has been successfully cleaned.'
                              : 'Review your selections and confirm deletion.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Statistics
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'Total Reviewed',
                          '${galleryService.totalPhotos}',
                          Icons.photo_library,
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'To Delete',
                          '${galleryService.deletedCount}',
                          Icons.delete_outline,
                          Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context,
                          'To Keep',
                          '${galleryService.keptCount}',
                          Icons.favorite_outline,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),

                  if (_deletionError != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _deletionError!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Action buttons
                  if (!_deletionComplete && galleryService.photosToDelete.isNotEmpty) ...[
                    FilledButton(
                      onPressed: _isDeleting ? null : _confirmAndDelete,
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                Text('Deleting Photos...'),
                              ],
                            )
                          : Text('Delete ${galleryService.photosToDelete.length} Photos'),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  OutlinedButton(
                    onPressed: _isDeleting ? null : _startNewSession,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: Text('Start New Session'),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
