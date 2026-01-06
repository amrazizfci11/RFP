import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/vacation.dart';
import '../../blocs/vacation/vacation_bloc.dart';
import '../../widgets/common/loading_overlay.dart';

/// Apply vacation page
class ApplyVacationPage extends StatefulWidget {
  const ApplyVacationPage({super.key});

  @override
  State<ApplyVacationPage> createState() => _ApplyVacationPageState();
}

class _ApplyVacationPageState extends State<ApplyVacationPage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  VacationType _selectedType = VacationType.annual;
  DateTime _focusedDay = DateTime.now();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  int get _days {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
      if (_startDate == null) {
        _startDate = selectedDay;
      } else if (_endDate == null) {
        if (selectedDay.isBefore(_startDate!)) {
          _endDate = _startDate;
          _startDate = selectedDay;
        } else {
          _endDate = selectedDay;
        }
      } else {
        _startDate = selectedDay;
        _endDate = null;
      }
    });
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_startDate == null || _endDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('vacation.select_dates'.tr()),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      context.read<VacationBloc>().add(
            VacationApplyRequested(
              VacationRequest(
                type: _selectedType,
                startDate: _startDate!,
                endDate: _endDate!,
                reason: _reasonController.text.trim(),
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VacationBloc, VacationState>(
      listener: (context, state) {
        if (state.applyStatus == VacationApplyStatus.success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('vacation.apply_success'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.applyStatus == VacationApplyStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error ?? 'An error occurred'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        return LoadingOverlay(
          isLoading: state.applyStatus == VacationApplyStatus.submitting,
          child: Scaffold(
            appBar: AppBar(
              title: Text('vacation.apply_title'.tr()),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Type selector
                    Text(
                      'vacation.type_label'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<VacationType>(
                      value: _selectedType,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      items: VacationType.values.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(_getTypeName(type)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedType = value);
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Calendar
                    Card(
                      child: TableCalendar(
                        firstDay: DateTime.now(),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          if (_startDate == null) return false;
                          if (_endDate == null) return isSameDay(day, _startDate);
                          return !day.isBefore(_startDate!) &&
                              !day.isAfter(_endDate!);
                        },
                        onDaySelected: _onDaySelected,
                        calendarStyle: CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          rangeHighlightColor:
                              Theme.of(context).primaryColor.withOpacity(0.2),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Selected dates summary
                    if (_startDate != null || _endDate != null)
                      Card(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'vacation.selected_period'.tr(),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _startDate != null && _endDate != null
                                        ? '${DateFormat('dd MMM').format(_startDate!)} - ${DateFormat('dd MMM').format(_endDate!)}'
                                        : DateFormat('dd MMM').format(_startDate!),
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$_days ${'vacation.days_label'.tr()}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Reason
                    Text(
                      'vacation.reason'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'vacation.reason_hint'.tr(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'vacation.reason_required'.tr();
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 32),

                    // Submit button
                    ElevatedButton(
                      onPressed: _days > 0 ? _submit : null,
                      child: Text('vacation.submit_button'.tr()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getTypeName(VacationType type) {
    switch (type) {
      case VacationType.annual:
        return 'vacation.type.annual'.tr();
      case VacationType.sick:
        return 'vacation.type.sick'.tr();
      case VacationType.unpaid:
        return 'vacation.type.unpaid'.tr();
      case VacationType.maternity:
        return 'vacation.type.maternity'.tr();
      case VacationType.paternity:
        return 'vacation.type.paternity'.tr();
      case VacationType.bereavement:
        return 'vacation.type.bereavement'.tr();
      case VacationType.marriage:
        return 'vacation.type.marriage'.tr();
      case VacationType.hajj:
        return 'vacation.type.hajj'.tr();
      case VacationType.other:
        return 'vacation.type.other'.tr();
    }
  }
}
