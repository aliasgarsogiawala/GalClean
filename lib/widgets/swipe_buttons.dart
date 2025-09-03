import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _LabeledFab(
              label: 'Delete',
              color: Theme.of(context).colorScheme.errorContainer,
              foreground: Theme.of(context).colorScheme.onErrorContainer,
              icon: Icons.close,
              heroTag: 'delete',
              onPressed: () {
                HapticFeedback.lightImpact();
                onDelete();
              },
              large: true,
            ),
            if (onUndo != null)
              _LabeledFab(
                label: 'Undo',
                color: Theme.of(context).colorScheme.surfaceVariant,
                foreground: Theme.of(context).colorScheme.onSurfaceVariant,
                icon: Icons.undo,
                heroTag: 'undo',
                onPressed: () {
                  HapticFeedback.selectionClick();
                  onUndo?.call();
                },
                large: false,
              )
            else
              const SizedBox(width: 56),
            _LabeledFab(
              label: 'Keep',
              color: Theme.of(context).colorScheme.primaryContainer,
              foreground: Theme.of(context).colorScheme.onPrimaryContainer,
              icon: Icons.favorite,
              heroTag: 'keep',
              onPressed: () {
                HapticFeedback.lightImpact();
                onKeep();
              },
              large: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _LabeledFab extends StatelessWidget {
  final String label;
  final Color color;
  final Color foreground;
  final IconData icon;
  final String heroTag;
  final VoidCallback onPressed;
  final bool large;

  const _LabeledFab({
    required this.label,
    required this.color,
    required this.foreground,
    required this.icon,
    required this.heroTag,
    required this.onPressed,
    required this.large,
  });

  @override
  Widget build(BuildContext context) {
    final button = large
        ? FloatingActionButton.large(
            onPressed: onPressed,
            backgroundColor: color,
            foregroundColor: foreground,
            heroTag: heroTag,
            child: Icon(icon, size: 32),
          )
        : FloatingActionButton(
            onPressed: onPressed,
            backgroundColor: color,
            foregroundColor: foreground,
            heroTag: heroTag,
            child: Icon(icon),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        button,
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
