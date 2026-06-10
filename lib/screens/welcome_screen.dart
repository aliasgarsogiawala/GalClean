import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  void _goToHome(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.brandGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                _AnimatedIn(
                  delayMs: 0,
                  child: Container(
                    width: 120,
                    height: 120,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                _AnimatedIn(
                  delayMs: 120,
                  child: Text(
                    'GalClean',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                  ),
                ),
                const SizedBox(height: 12),
                _AnimatedIn(
                  delayMs: 220,
                  child: Text(
                    'Swipe right to keep, left to let go.\nFind the photos you truly love.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                const Spacer(flex: 3),
                _AnimatedIn(
                  delayMs: 320,
                  child: FilledButton(
                    onPressed: () => _goToHome(context),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.brandRed,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('Start swiping'),
                  ),
                ),
                const SizedBox(height: 12),
                _AnimatedIn(
                  delayMs: 360,
                  child: TextButton(
                    onPressed: () => _goToHome(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withValues(alpha: 0.9),
                    ),
                    child: const Text('Skip intro'),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'by Aliasgar Sogiawala',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small helper that fades + slides its child up once, on first build.
class _AnimatedIn extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _AnimatedIn({required this.child, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
      child: child,
    );
  }
}
