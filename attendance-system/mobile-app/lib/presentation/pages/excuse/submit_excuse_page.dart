import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/excuse.dart';
import '../../blocs/excuse/excuse_bloc.dart';
import '../../widgets/common/loading_overlay.dart';

/// Submit excuse page
class SubmitExcusePage extends StatefulWidget {
  const SubmitExcusePage({super.key});

  @override
  State<SubmitExcusePage> createState() => _SubmitExcusePageState();
}

class _SubmitExcusePageState extends State<SubmitExcusePage> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  ExcuseType _selectedType = ExcuseType.sick;
  final List<String> _attachments = [];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      setState(() {
        _attachments.addAll(
          result.paths.whereType<String>().toList(),
        );
      });
    }
  }

  void _removeAttachment(int index) {
    setState(() => _attachments.removeAt(index));
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<ExcuseBloc>().add(
            ExcuseSubmitRequested(
              ExcuseRequest(
                date: _selectedDate,
                type: _selectedType,
                reason: _reasonController.text.trim(),
                filePaths: _attachments,
              ),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExcuseBloc, ExcuseState>(
      listener: (context, state) {
        if (state.submitStatus == ExcuseSubmitStatus.success) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('excuse.submit_success'.tr()),
              backgroundColor: AppColors.success,
            ),
          );
        } else if (state.submitStatus == ExcuseSubmitStatus.error) {
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
          isLoading: state.submitStatus == ExcuseSubmitStatus.submitting,
          child: Scaffold(
            appBar: AppBar(
              title: Text('excuse.submit_title'.tr()),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Date picker
                    Text(
                      'excuse.date'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.grey300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('dd MMM yyyy').format(_selectedDate),
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Type selector
                    Text(
                      'excuse.type_label'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: ExcuseType.values.map((type) {
                        final isSelected = type == _selectedType;
                        return ChoiceChip(
                          label: Text(_getTypeName(type)),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() => _selectedType = type);
                          },
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Reason
                    Text(
                      'excuse.reason'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _reasonController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'excuse.reason_hint'.tr(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'excuse.reason_required'.tr();
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Attachments
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'excuse.attachments_label'.tr(),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        TextButton.icon(
                          onPressed: _pickFiles,
                          icon: const Icon(Icons.attach_file),
                          label: Text('excuse.add_file'.tr()),
                        ),
                      ],
                    ),
                    if (_attachments.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...List.generate(_attachments.length, (index) {
                        final path = _attachments[index];
                        final fileName = path.split('/').last;
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeAttachment(index),
                          ),
                          contentPadding: EdgeInsets.zero,
                        );
                      }),
                    ],

                    const SizedBox(height: 32),

                    // Submit button
                    ElevatedButton(
                      onPressed: _submit,
                      child: Text('excuse.submit_button'.tr()),
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

  String _getTypeName(ExcuseType type) {
    switch (type) {
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
}
