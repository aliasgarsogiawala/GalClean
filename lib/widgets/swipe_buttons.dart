import 'package:flutter/material.dart';

class SwipeButtons extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onKeep;
  final VoidCallback? onUndo;

  const SwipeButtons({
    super.key,
    required this.onDelete,
    required this.onKeep,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Delete button
          FloatingActionButton.large(
            onPressed: onDelete,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            heroTag: 'delete',
            child: const Icon(Icons.close, size: 32),
          ),

          // Undo button (if available)
          if (onUndo != null)
            FloatingActionButton(
              onPressed: onUndo,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
              heroTag: 'undo',
              child: const Icon(Icons.undo),
            )
          else
            const SizedBox(width: 56), // Placeholder to maintain spacing

          // Keep button
          FloatingActionButton.large(
            onPressed: onKeep,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
            heroTag: 'keep',
            child: const Icon(Icons.favorite, size: 32),
          ),
        ],
      ),
    );
  }
}
