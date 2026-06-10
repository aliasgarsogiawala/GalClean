import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../widgets/date_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLastUsedDates();
  }

  Future<void> _loadLastUsedDates() async {
    final prefs = await SharedPreferences.getInstance();
    final startDateString = prefs.getString('last_start_date');
    final endDateString = prefs.getString('last_end_date');

    if (startDateString != null && endDateString != null) {
      _startDate = DateTime.parse(startDateString);
      _endDate = DateTime.parse(endDateString);
    } else {
      // Default to the last 30 days.
      _endDate = DateTime.now();
      _startDate = _endDate!.subtract(const Duration(days: 30));
    }
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveDates() async {
    if (_startDate != null && _endDate != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_start_date', _startDate!.toIso8601String());
      await prefs.setString('last_end_date', _endDate!.toIso8601String());
    }
  }

  void _onStartDateSelected(DateTime date) {
    setState(() {
      _startDate = date;
      if (_endDate != null && _endDate!.isBefore(date)) {
        _endDate = date;
      }
    });
  }

  void _onEndDateSelected(DateTime date) {
    setState(() {
      _endDate = date;
      if (_startDate != null && _startDate!.isAfter(date)) {
        _startDate = date;
      }
    });
  }

  Future<void> _onContinue() async {
    if (_startDate != null && _endDate != null) {
      await _saveDates();
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/gallery',
          arguments: {'startDate': _startDate!, 'endDate': _endDate!},
        );
      }
    }
  }

  String _formatDateRange() {
    if (_startDate == null || _endDate == null) return 'Select date range';
    final formatter = DateFormat('MMM dd, yyyy');
    return '${formatter.format(_startDate!)} - ${formatter.format(_endDate!)}';
  }

  int _calculateDays() {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final canContinue = _startDate != null && _endDate != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      gradient: AppTheme.brandGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.brandRed.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.photo_library_rounded,
                            size: 44,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Meet your photos',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pick a date range and start matching with the photos worth keeping.',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    height: 1.35,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Date selection
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.date_range_rounded,
                                color: cs.primary, size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Date range',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        CustomDatePicker(
                          startDate: _startDate,
                          endDate: _endDate,
                          onStartDateSelected: _onStartDateSelected,
                          onEndDateSelected: _onEndDateSelected,
                        ),
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today_rounded,
                                      color: cs.primary, size: 16),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _formatDateRange(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            color: cs.primary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              if (canContinue) ...[
                                const SizedBox(height: 8),
                                Text(
                                  '${_calculateDays()} ${_calculateDays() == 1 ? 'day' : 'days'} of memories',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // How it works
                  _SectionCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.swipe_rounded,
                                color: cs.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'How it works',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const _TipRow(
                          icon: Icons.favorite_rounded,
                          text: 'Swipe right to keep the keepers',
                          color: AppTheme.keepColor,
                        ),
                        const SizedBox(height: 10),
                        const _TipRow(
                          icon: Icons.close_rounded,
                          text: 'Swipe left to mark for deletion',
                          color: AppTheme.deleteColor,
                        ),
                        const SizedBox(height: 10),
                        const _TipRow(
                          icon: Icons.replay_rounded,
                          text: 'Changed your mind? Rewind any swipe',
                          color: AppTheme.undoColor,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: canContinue ? _onContinue : null,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(canContinue
                            ? 'Find my photos'
                            : 'Select a date range'),
                        if (canContinue) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _TipRow({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}
