import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime) onStartDateSelected;
  final Function(DateTime) onEndDateSelected;

  const CustomDatePicker({
    super.key,
    this.startDate,
    this.endDate,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
  });

  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: startDate != null ? _onlyDate(startDate!) : _onlyDate(now.subtract(const Duration(days: 30))),
      firstDate: DateTime(2020, 1, 1),
      lastDate: endDate != null ? _onlyDate(endDate!) : _onlyDate(now),
      helpText: 'Select start date',
    );
    if (picked != null) {
      onStartDateSelected(_onlyDate(picked));
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: endDate != null ? _onlyDate(endDate!) : _onlyDate(now),
      firstDate: startDate != null ? _onlyDate(startDate!) : DateTime(2020, 1, 1),
      lastDate: _onlyDate(now),
      helpText: 'Select end date',
    );
    if (picked != null) {
      onEndDateSelected(_onlyDate(picked));
    }
  }

  void _setRangeDays(int days) {
    final end = _onlyDate(DateTime.now());
    final start = _onlyDate(end.subtract(Duration(days: days)));
    onStartDateSelected(start);
    onEndDateSelected(end);
  }

  void _setThisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = _onlyDate(now);
    onStartDateSelected(start);
    onEndDateSelected(end);
  }

  void _setThisYear() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = _onlyDate(now);
    onStartDateSelected(start);
    onEndDateSelected(end);
  }

  void _setAllTime() {
    final end = _onlyDate(DateTime.now());
    final start = DateTime(2020, 1, 1);
    onStartDateSelected(start);
    onEndDateSelected(end);
  }

  bool _isSelectedDays(int days) {
    if (startDate == null || endDate == null) return false;
    final end = _onlyDate(DateTime.now());
    final start = _onlyDate(end.subtract(Duration(days: days)));
    return _onlyDate(startDate!) == start && _onlyDate(endDate!) == end;
  }

  bool get _isThisMonthSelected {
    if (startDate == null || endDate == null) return false;
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = _onlyDate(now);
    return _onlyDate(startDate!) == start && _onlyDate(endDate!) == end;
  }

  bool get _isThisYearSelected {
    if (startDate == null || endDate == null) return false;
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final end = _onlyDate(now);
    return _onlyDate(startDate!) == start && _onlyDate(endDate!) == end;
  }

  bool get _isAllTimeSelected {
    if (startDate == null || endDate == null) return false;
    final start = DateTime(2020, 1, 1);
    final end = _onlyDate(DateTime.now());
    return _onlyDate(startDate!) == start && _onlyDate(endDate!) == end;
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('MMM dd, yyyy');
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Custom Date Selection Row
        Row(
          children: [
            Expanded(
              child: _DatePickerButton(
                label: 'From',
                date: startDate,
                formatter: formatter,
                onTap: () => _selectStartDate(context),
                icon: Icons.calendar_today,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward,
                color: cs.onSurfaceVariant,
                size: 16,
              ),
            ),
            Expanded(
              child: _DatePickerButton(
                label: 'To',
                date: endDate,
                formatter: formatter,
                onTap: () => _selectEndDate(context),
                icon: Icons.event,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Quick Select Section
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: cs.primary,
              size: 16,
            ),
            const SizedBox(width: 8),
            Text(
              'Quick Select',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Enhanced Quick Select Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _EnhancedChoiceChip(
              label: '7 days',
              icon: Icons.looks_one,
              selected: _isSelectedDays(7),
              onSelected: (_) => _setRangeDays(7),
            ),
            _EnhancedChoiceChip(
              label: '30 days',
              icon: Icons.date_range,
              selected: _isSelectedDays(30),
              onSelected: (_) => _setRangeDays(30),
            ),
            _EnhancedChoiceChip(
              label: '90 days',
              icon: Icons.calendar_view_month,
              selected: _isSelectedDays(90),
              onSelected: (_) => _setRangeDays(90),
            ),
            _EnhancedChoiceChip(
              label: 'This month',
              icon: Icons.calendar_today,
              selected: _isThisMonthSelected,
              onSelected: (_) => _setThisMonth(),
            ),
            _EnhancedChoiceChip(
              label: 'This year',
              icon: Icons.calendar_today,
              selected: _isThisYearSelected,
              onSelected: (_) => _setThisYear(),
            ),
            _EnhancedChoiceChip(
              label: 'All time',
              icon: Icons.all_inclusive,
              selected: _isAllTimeSelected,
              onSelected: (_) => _setAllTime(),
            ),
          ],
        ),
      ],
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateFormat formatter;
  final VoidCallback onTap;
  final IconData icon;

  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.formatter,
    required this.onTap,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasDate = date != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: hasDate ? cs.primaryContainer.withOpacity(0.3) : cs.surface,
            border: Border.all(
              color: hasDate ? cs.primary.withOpacity(0.5) : cs.outline.withOpacity(0.5),
              width: hasDate ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: hasDate ? cs.primary : cs.onSurfaceVariant,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: hasDate ? cs.primary : cs.onSurfaceVariant,
                      fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                hasDate ? formatter.format(date!) : 'Select $label date',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: hasDate ? cs.onSurface : cs.onSurfaceVariant,
                  fontWeight: hasDate ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnhancedChoiceChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Function(bool) onSelected;

  const _EnhancedChoiceChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
      selected: selected,
      onSelected: onSelected,
      backgroundColor: cs.surface,
      selectedColor: cs.secondaryContainer,
      checkmarkColor: cs.onSecondaryContainer,
      side: BorderSide(
        color: selected ? cs.secondary : cs.outline.withOpacity(0.5),
        width: selected ? 1.5 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
