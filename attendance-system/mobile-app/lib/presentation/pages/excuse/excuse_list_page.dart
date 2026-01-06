import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/excuse.dart';
import '../../blocs/excuse/excuse_bloc.dart';
import 'submit_excuse_page.dart';

/// Excuse list page
class ExcuseListPage extends StatefulWidget {
  const ExcuseListPage({super.key});

  @override
  State<ExcuseListPage> createState() => _ExcuseListPageState();
}

class _ExcuseListPageState extends State<ExcuseListPage> {
  @override
  void initState() {
    super.initState();
    context.read<ExcuseBloc>().add(const ExcuseListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('excuse.title'.tr()),
      ),
      body: BlocBuilder<ExcuseBloc, ExcuseState>(
        builder: (context, state) {
          if (state.status == ExcuseStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == ExcuseStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text(state.error ?? 'An error occurred'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<ExcuseBloc>()
                        .add(const ExcuseListRequested()),
                    child: Text('common.retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (state.excuses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy_outlined,
                    size: 64,
                    color: AppColors.grey400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'excuse.empty'.tr(),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<ExcuseBloc>().add(const ExcuseListRequested());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.excuses.length,
              itemBuilder: (context, index) {
                final excuse = state.excuses[index];
                return _ExcuseCard(excuse: excuse);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SubmitExcusePage()),
          );
        },
        icon: const Icon(Icons.add),
        label: Text('excuse.submit'.tr()),
      ),
    );
  }
}

class _ExcuseCard extends StatelessWidget {
  final Excuse excuse;

  const _ExcuseCard({required this.excuse});

  Color get _statusColor {
    switch (excuse.status) {
      case ExcuseStatus.pending:
        return AppColors.warning;
      case ExcuseStatus.approved:
        return AppColors.success;
      case ExcuseStatus.rejected:
        return AppColors.error;
    }
  }

  String get _statusText {
    switch (excuse.status) {
      case ExcuseStatus.pending:
        return 'excuse.status.pending'.tr();
      case ExcuseStatus.approved:
        return 'excuse.status.approved'.tr();
      case ExcuseStatus.rejected:
        return 'excuse.status.rejected'.tr();
    }
  }

  String get _typeText {
    switch (excuse.type) {
      case ExcuseType.sick:
        return 'excuse.type.sick'.tr();
      case ExcuseType.personal:
        return 'excuse.type.personal'.tr();
      case ExcuseType.emergency:
        return 'excuse.type.emergency'.tr();
      case ExcuseType.other:
        return 'excuse.type.other'.tr();
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
                  DateFormat('dd MMM yyyy').format(excuse.date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _typeText,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              excuse.reason,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey600,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (excuse.attachments.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.attach_file, size: 16, color: AppColors.grey500),
                  const SizedBox(width: 4),
                  Text(
                    'excuse.attachments'.tr(args: ['${excuse.attachments.length}']),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (excuse.reviewNotes != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  excuse.reviewNotes!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
