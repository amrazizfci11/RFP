import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:open_file/open_file.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/attendance.dart';
import '../../../domain/repositories/reports_repository.dart';
import '../../blocs/reports/reports_bloc.dart';

/// Reports page
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    context.read<ReportsBloc>().add(const ReportsLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('reports.title'.tr()),
      ),
      body: BlocConsumer<ReportsBloc, ReportsState>(
        listener: (context, state) {
          if (state.downloadStatus == DownloadStatus.completed &&
              state.downloadedFilePath != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('reports.download_success'.tr()),
                backgroundColor: AppColors.success,
                action: SnackBarAction(
                  label: 'reports.open'.tr(),
                  onPressed: () {
                    OpenFile.open(state.downloadedFilePath!);
                  },
                ),
              ),
            );
          } else if (state.downloadStatus == DownloadStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error ?? 'Download failed'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Report type selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'reports.select_type'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: ReportType.values
                                .where((t) => t != ReportType.custom)
                                .map((type) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(_getTypeName(type)),
                                        selected: state.reportType == type,
                                        onSelected: (_) {
                                          context
                                              .read<ReportsBloc>()
                                              .add(ReportsTypeChanged(type));
                                        },
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Report content
                if (state.status == ReportsStatus.loading)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                else if (state.report != null) ...[
                  // Summary card
                  _SummaryCard(summary: state.report!.summary),

                  const SizedBox(height: 16),

                  // Daily breakdown
                  if (state.report!.dailyBreakdown != null)
                    _BreakdownCard(breakdown: state.report!.dailyBreakdown!),

                  const SizedBox(height: 16),

                  // Download buttons
                  _DownloadButtons(
                    isDownloading:
                        state.downloadStatus == DownloadStatus.downloading,
                    onDownloadPdf: () {
                      context.read<ReportsBloc>().add(
                            const ReportsDownloadRequested(
                              format: ReportFormat.pdf,
                            ),
                          );
                    },
                    onDownloadExcel: () {
                      context.read<ReportsBloc>().add(
                            const ReportsDownloadRequested(
                              format: ReportFormat.excel,
                            ),
                          );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  String _getTypeName(ReportType type) {
    switch (type) {
      case ReportType.daily:
        return 'reports.type.daily'.tr();
      case ReportType.weekly:
        return 'reports.type.weekly'.tr();
      case ReportType.monthly:
        return 'reports.type.monthly'.tr();
      case ReportType.yearly:
        return 'reports.type.yearly'.tr();
      case ReportType.custom:
        return 'reports.type.custom'.tr();
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final AttendanceSummary summary;

  const _SummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'reports.summary'.tr(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getPercentageColor(summary.attendancePercentage)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${summary.attendancePercentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getPercentageColor(summary.attendancePercentage),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                _SummaryItem(
                  label: 'reports.working_days'.tr(),
                  value: '${summary.totalWorkingDays}',
                  color: AppColors.grey600,
                ),
                _SummaryItem(
                  label: 'reports.present'.tr(),
                  value: '${summary.presentDays}',
                  color: AppColors.success,
                ),
                _SummaryItem(
                  label: 'reports.absent'.tr(),
                  value: '${summary.absentDays}',
                  color: AppColors.error,
                ),
                _SummaryItem(
                  label: 'reports.late'.tr(),
                  value: '${summary.lateDays}',
                  color: AppColors.warning,
                ),
                _SummaryItem(
                  label: 'reports.vacation'.tr(),
                  value: '${summary.vacationDays}',
                  color: AppColors.info,
                ),
                _SummaryItem(
                  label: 'reports.excuse'.tr(),
                  value: '${summary.excuseDays}',
                  color: AppColors.grey500,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 90) return AppColors.success;
    if (percentage >= 75) return AppColors.warning;
    return AppColors.error;
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _BreakdownCard extends StatelessWidget {
  final List<DailyBreakdown> breakdown;

  const _BreakdownCard({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'reports.daily_breakdown'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...breakdown.take(10).map((day) => _DayRow(day: day)),
            if (breakdown.length > 10)
              TextButton(
                onPressed: () {
                  // Show full breakdown
                },
                child: Text('reports.view_all'.tr()),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  final DailyBreakdown day;

  const _DayRow({required this.day});

  Color get _statusColor {
    switch (day.status) {
      case AttendanceStatus.present:
        return AppColors.success;
      case AttendanceStatus.absent:
        return AppColors.error;
      case AttendanceStatus.late:
        return AppColors.warning;
      case AttendanceStatus.vacation:
        return AppColors.info;
      default:
        return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _statusColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              DateFormat('EEE, dd MMM').format(day.date),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              day.checkIn ?? '--:--',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              day.checkOut ?? '--:--',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              day.workingHours ?? '-',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _DownloadButtons extends StatelessWidget {
  final bool isDownloading;
  final VoidCallback onDownloadPdf;
  final VoidCallback onDownloadExcel;

  const _DownloadButtons({
    required this.isDownloading,
    required this.onDownloadPdf,
    required this.onDownloadExcel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isDownloading ? null : onDownloadPdf,
            icon: const Icon(Icons.picture_as_pdf),
            label: Text('reports.download_pdf'.tr()),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isDownloading ? null : onDownloadExcel,
            icon: const Icon(Icons.table_chart),
            label: Text('reports.download_excel'.tr()),
          ),
        ),
      ],
    );
  }
}
