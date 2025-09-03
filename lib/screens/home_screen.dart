import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      setState(() {
        _startDate = DateTime.parse(startDateString);
        _endDate = DateTime.parse(endDateString);
      });
    } else {
      // Default to last 30 days
      setState(() {
        _endDate = DateTime.now();
        _startDate = _endDate!.subtract(const Duration(days: 30));
      });
    }
    setState(() {
      _isLoading = false;
    });
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

  void _onContinue() async {
    if (_startDate != null && _endDate != null) {
      await _saveDates();
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/gallery',
          arguments: {
            'startDate': _startDate!,
            'endDate': _endDate!,
          },
        );
      }
    }
  }

  String _formatDateRange() {
    if (_startDate == null || _endDate == null) {
      return 'Select date range';
    }

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final canContinue = _startDate != null && _endDate != null;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('GalClean'),
        backgroundColor: cs.surfaceVariant.withOpacity(0.3),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  // Hero Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          cs.primaryContainer.withOpacity(0.3),
                          cs.secondaryContainer.withOpacity(0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: cs.primary.withOpacity(0.2),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.photo_library_outlined,
                            size: 48,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Clean Your Gallery',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select a date range to review your photos',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Date Selection Card
                  Card(
                    elevation: 2,
                    shadowColor: cs.shadow.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.date_range,
                                color: cs.primary,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Select Date Range',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          CustomDatePicker(
                            startDate: _startDate,
                            endDate: _endDate,
                            onStartDateSelected: _onStartDateSelected,
                            onEndDateSelected: _onEndDateSelected,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  cs.primaryContainer,
                                  cs.primaryContainer.withOpacity(0.8),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: cs.outline.withOpacity(0.2),
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      color: cs.onPrimaryContainer,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDateRange(),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: cs.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_startDate != null && _endDate != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: cs.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      '${_calculateDays()} ${_calculateDays() == 1 ? 'day' : 'days'} selected',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: cs.onPrimaryContainer,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Instructions Card
                  Card(
                    elevation: 1,
                    shadowColor: cs.shadow.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            cs.surfaceVariant.withOpacity(0.5),
                            cs.surfaceVariant.withOpacity(0.2),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.swipe,
                                  color: cs.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'How it works',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _EnhancedTipRow(
                              icon: Icons.swipe_left,
                              text: 'Swipe left to delete',
                              iconColor: Colors.red.shade400,
                            ),
                            const SizedBox(height: 8),
                            _EnhancedTipRow(
                              icon: Icons.swipe_right,
                              text: 'Swipe right to keep',
                              iconColor: Colors.green.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: FilledButton(
            onPressed: canContinue ? _onContinue : null,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (canContinue) ...[
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 8),
                ],
                Text(
                  canContinue ? 'Continue' : 'Please select a date range',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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

class _EnhancedTipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const _EnhancedTipRow({
    required this.icon,
    required this.text,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: (iconColor ?? cs.primary).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: iconColor ?? cs.primary,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
