import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// The classic swipe-app action row: pass (✕), rewind (↺) and keep (♥).
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
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CircleButton(
              icon: Icons.close_rounded,
              gradient: AppTheme.deleteGradient,
              size: 68,
              iconSize: 34,
              heroTag: 'delete',
              tooltip: 'Pass — mark for deletion',
              onPressed: () {
                HapticFeedback.mediumImpact();
                onDelete();
              },
            ),
            const SizedBox(width: 24),
            _CircleButton(
              icon: Icons.replay_rounded,
              gradient: const LinearGradient(
                colors: [AppTheme.undoColor, Color(0xFFFF8A3C)],
              ),
              size: 52,
              iconSize: 24,
              heroTag: 'undo',
              tooltip: 'Rewind last swipe',
              enabled: onUndo != null,
              onPressed: () {
                HapticFeedback.selectionClick();
                onUndo?.call();
              },
            ),
            const SizedBox(width: 24),
            _CircleButton(
              icon: Icons.favorite_rounded,
              gradient: AppTheme.keepGradient,
              size: 68,
              iconSize: 32,
              heroTag: 'keep',
              tooltip: 'Keep — it\'s a match',
              onPressed: () {
                HapticFeedback.mediumImpact();
                onKeep();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Gradient gradient;
  final double size;
  final double iconSize;
  final String heroTag;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  const _CircleButton({
    required this.icon,
    required this.gradient,
    required this.size,
    required this.iconSize,
    required this.heroTag,
    required this.tooltip,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color shadowColor =
        gradient.colors.first.withValues(alpha: enabled ? 0.45 : 0.0);

    return Tooltip(
      message: tooltip,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: enabled ? gradient : null,
            color: enabled ? null : Colors.grey.shade400,
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? onPressed : null,
              child: Icon(icon, color: Colors.white, size: iconSize),
            ),
          ),
        ),
      ),
    );
  }
}
