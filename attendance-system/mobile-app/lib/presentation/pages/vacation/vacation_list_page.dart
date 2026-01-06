import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/vacation.dart';
import '../../blocs/vacation/vacation_bloc.dart';
import 'apply_vacation_page.dart';

/// Vacation list page
class VacationListPage extends StatefulWidget {
  const VacationListPage({super.key});

  @override
  State<VacationListPage> createState() => _VacationListPageState();
}

class _VacationListPageState extends State<VacationListPage> {
  @override
  void initState() {
    super.initState();
    context.read<VacationBloc>().add(const VacationListRequested());
    context.read<VacationBloc>().add(const VacationBalanceRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('vacation.title'.tr()),
      ),
      body: BlocBuilder<VacationBloc, VacationState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<VacationBloc>().add(const VacationListRequested());
              context.read<VacationBloc>().add(const VacationBalanceRequested());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Balance card
                if (state.balance != null) _BalanceCard(balance: state.balance!),

                const SizedBox(height: 16),

                // Vacation list
                if (state.status == VacationListStatus.loading)
                  const Center(child: CircularProgressIndicator())
                else if (state.vacations.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.beach_access_outlined,
                            size: 64,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'vacation.empty'.tr(),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...state.vacations.map((vacation) => _VacationCard(vacation: vacation)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ApplyVacationPage()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text('vacation.apply'.tr()),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final VacationBalance balance;

  const _BalanceCard({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'vacation.balance'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _BalanceItem(
                    label: 'vacation.annual'.tr(),
                    used: balance.annualUsed,
                    total: balance.annualTotal,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _BalanceItem(
                    label: 'vacation.sick'.tr(),
                    used: balance.sickUsed,
                    total: balance.sickTotal,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceItem extends StatelessWidget {
  final String label;
  final int used;
  final int total;
  final Color color;

  const _BalanceItem({
    required this.label,
    required this.used,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = total - used;
    final progress = total > 0 ? used / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '$remaining',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              ' / $total',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

class _VacationCard extends StatelessWidget {
  final Vacation vacation;

  const _VacationCard({required this.vacation});

  Color get _statusColor {
    switch (vacation.status) {
      case VacationStatus.pending:
        return AppColors.warning;
      case VacationStatus.approved:
        return AppColors.success;
      case VacationStatus.rejected:
        return AppColors.error;
      case VacationStatus.cancelled:
        return AppColors.grey500;
    }
  }

  String get _statusText {
    switch (vacation.status) {
      case VacationStatus.pending:
        return 'vacation.status.pending'.tr();
      case VacationStatus.approved:
        return 'vacation.status.approved'.tr();
      case VacationStatus.rejected:
        return 'vacation.status.rejected'.tr();
      case VacationStatus.cancelled:
        return 'vacation.status.cancelled'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _statusText,
                    style: TextStyle(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  '${vacation.days} ${'vacation.days_label'.tr()}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${DateFormat('dd MMM').format(vacation.startDate)} - ${DateFormat('dd MMM yyyy').format(vacation.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              vacation.reason,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
