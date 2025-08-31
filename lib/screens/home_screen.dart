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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Cleaner'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Icon(
                    Icons.photo_library_outlined,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Clean Your Gallery',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Pick a date range, then swipe left to delete or right to keep.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date Range',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          CustomDatePicker(
                            startDate: _startDate,
                            endDate: _endDate,
                            onStartDateSelected: _onStartDateSelected,
                            onEndDateSelected: _onEndDateSelected,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  _formatDateRange(),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (_startDate != null && _endDate != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_calculateDays()} days selected',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
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

                  const SizedBox(height: 24),

                  Card(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          _TipRow(icon: Icons.swipe_left, text: 'Swipe left to delete'),
                          SizedBox(height: 8),
                          _TipRow(icon: Icons.swipe_right, text: 'Swipe right to keep'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: FilledButton(
          onPressed: canContinue ? _onContinue : null,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Text('Continue'),
          ),
        ),
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
