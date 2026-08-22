import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../data/repo/application_repo.dart';
import '../../localization/app_localizations.dart';
import '../../shared/components/components.dart';
import '../../shared/components/app_snackbar.dart';

class InformationRequestScreen extends StatefulWidget {
  final int informationRequestId;

  const InformationRequestScreen({
    super.key,
    required this.informationRequestId,
  });

  @override
  State<InformationRequestScreen> createState() =>
      _InformationRequestScreenState();
}

class _InformationRequestScreenState extends State<InformationRequestScreen> {
  final _repo = ApplicationRepo();
  final _message = TextEditingController();
  late Future<Map<String, dynamic>> _future;
  List<PlatformFile> _files = const [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _future = _repo.getInformationRequest(widget.informationRequestId);
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.tr('applications.requested_information')),
    ),
    body: FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData &&
            snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: ModernRetryButton(
              onRetry: () => setState(
                () => _future = _repo.getInformationRequest(
                  widget.informationRequestId,
                ),
              ),
            ),
          );
        }
        final data = snapshot.data!;
        final requested = data['requested_items'] is List
            ? data['requested_items'] as List
            : const [];
        final canRespond = data['can_respond'] == true;
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              '${data['message'] ?? ''}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (requested.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...requested.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.checklist_rounded),
                  title: Text(
                    item is Map
                        ? '${item['label'] ?? item['name'] ?? item['type'] ?? ''}'
                        : '$item',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _message,
              enabled: canRespond,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(
                labelText: context.tr('applications.your_response'),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: canRespond && !_submitting ? _pickFiles : null,
              icon: const Icon(Icons.attach_file_rounded),
              label: Text(
                _files.isEmpty
                    ? context.tr('applications.attach_files')
                    : context.tr(
                        'applications.files_selected',
                        values: {'count': _files.length},
                      ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: canRespond && !_submitting ? _submit : null,
              child: _submitting
                  ? const SizedBox.square(
                      dimension: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      canRespond
                          ? context.tr('applications.submit_information')
                          : context.tr('applications.already_responded'),
                    ),
            ),
          ],
        );
      },
    ),
  );

  Future<void> _pickFiles() async {
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result.isNotEmpty && mounted) setState(() => _files = result);
  }

  Future<void> _submit() async {
    if (_message.text.trim().isEmpty && _files.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final attachments = <MultipartFile>[];
      for (final file in _files) {
        if (file.path != null) {
          attachments.add(
            await MultipartFile.fromFile(file.path!, filename: file.name),
          );
        }
      }
      final message = await _repo.respondToInformationRequest(
        widget.informationRequestId,
        FormData.fromMap({
          if (_message.text.trim().isNotEmpty) 'message': _message.text.trim(),
          if (attachments.isNotEmpty) 'attachments[]': attachments,
        }),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      setState(() {
        _future = _repo.getInformationRequest(widget.informationRequestId);
        _submitting = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _submitting = false);
      AppSnackBar.error(context, '$error');
    }
  }
}
