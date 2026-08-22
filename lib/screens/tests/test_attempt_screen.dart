import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

import '../../data/models/test_assignment_model.dart';
import '../../logic/tests_cubit/tests_cubit.dart';
import '../../logic/tests_cubit/tests_state.dart';
import '../../localization/app_localizations.dart';
import '../../shared/components/app_snackbar.dart';
import '../../services/secure_session_service.dart';
import '../../utils/constants.dart';
import '../../utils/media_url.dart';
import '../../utils/shared preferences.dart';

class TestAttemptScreen extends StatefulWidget {
  final TestAssignmentModel assignment;
  final Map<String, dynamic> attempt;

  const TestAttemptScreen({
    super.key,
    required this.assignment,
    required this.attempt,
  });

  @override
  State<TestAttemptScreen> createState() => _TestAttemptScreenState();
}

class _TestAttemptScreenState extends State<TestAttemptScreen>
    with WidgetsBindingObserver {
  final Map<int, dynamic> _answers = {};
  final Set<int> _uploadedFiles = {};
  bool _submitting = false;
  bool _leftApp = false;

  List<Map<String, dynamic>> get _questions {
    final raw =
        widget.attempt['questions'] ??
        (widget.attempt['test'] is Map
            ? widget.attempt['test']['questions']
            : null) ??
        (widget.attempt['attempt'] is Map
            ? widget.attempt['attempt']['questions']
            : null);
    return raw is List
        ? raw.whereType<Map>().map(Map<String, dynamic>.from).toList()
        : const [];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(SecureSessionService.setSecure(true));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(SecureSessionService.setSecure(false));
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (!_leftApp) {
        _leftApp = true;
        unawaited(_submit(violation: true));
      }
    } else if (state == AppLifecycleState.resumed && _leftApp && mounted) {
      Navigator.pop(context, 'left_app');
    }
  }

  Future<void> _submit({bool violation = false}) async {
    if (_submitting) return;
    _submitting = true;
    if (violation) {
      await context.read<TestsCubit>().forfeitTest(
        widget.assignment.id,
        reason: 'app_backgrounded',
      );
      return;
    }
    final payload = _answers.entries
        .map(
          (entry) => <String, dynamic>{
            'question_id': entry.key,
            if (entry.value is Iterable)
              'selected_option_ids': (entry.value as Iterable).toList()
            else if (entry.value is int)
              'selected_option_ids': [entry.value]
            else
              'answer_text': entry.value.toString(),
          },
        )
        .toList();
    final attemptId =
        int.tryParse(
          '${widget.attempt['id'] ?? widget.attempt['attempt_id']}',
        ) ??
        -1;
    if (attemptId < 0) {
      _submitting = false;
      return;
    }
    await context.read<TestsCubit>().submitTest(
      widget.assignment.id,
      attemptId,
      payload,
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: BlocListener<TestsCubit, TestsStates>(
      listener: (context, state) {
        if (state is TestSubmittedState && mounted) {
          Navigator.pop(context, state.message);
        } else if (state is TestsErrorState) {
          _submitting = false;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(widget.assignment.test.title),
          actions: const [
            Padding(
              padding: EdgeInsetsDirectional.only(end: 16),
              child: Icon(Icons.shield_rounded, color: HomeColors.brand),
            ),
          ],
        ),
        body: _questions.isEmpty
            ? Center(child: Text(context.tr('tests.no_questions')))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _questions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final question = _questions[index];
                  final id =
                      int.tryParse('${question['id'] ?? index}') ?? index;
                  final options = question['options'] is List
                      ? question['options'] as List
                      : const [];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${index + 1}. ${question['question_text'] ?? question['question'] ?? question['text'] ?? ''}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                          if (resolveMediaUrl(question['image_url']) !=
                              null) ...[
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                resolveMediaUrl(question['image_url'])!,
                                headers: {
                                  if (CacheHelper.getData(key: 'token') != null)
                                    'Authorization':
                                        'Bearer ${CacheHelper.getData(key: 'token')}',
                                },
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox.shrink(),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          if (_questionType(question) == 'file_upload' ||
                              _questionType(question) == 'file')
                            OutlinedButton.icon(
                              onPressed: () => _pickAnswerFile(id),
                              icon: const Icon(Icons.upload_file_rounded),
                              label: Text(
                                _uploadedFiles.contains(id)
                                    ? context.tr('tests.file_uploaded')
                                    : context.tr('tests.choose_file'),
                              ),
                            )
                          else if (options.isEmpty)
                            TextField(
                              onChanged: (value) => _answers[id] = value,
                              decoration: InputDecoration(
                                hintText: context.tr('tests.type_answer'),
                              ),
                            )
                          else if (_questionType(question) == 'multiple_choice')
                            ...options.map((option) {
                              final value = option is Map
                                  ? int.tryParse('${option['id']}')
                                  : int.tryParse('$option');
                              if (value == null) return const SizedBox.shrink();
                              final selected =
                                  (_answers[id] as Set<int>?) ?? <int>{};
                              final label = option is Map
                                  ? '${option['option_text'] ?? option['label'] ?? option['text'] ?? ''}'
                                  : '$option';
                              return CheckboxListTile(
                                value: selected.contains(value),
                                title: Text(label),
                                onChanged: (checked) => setState(() {
                                  final values = Set<int>.from(selected);
                                  checked == true
                                      ? values.add(value)
                                      : values.remove(value);
                                  _answers[id] = values;
                                }),
                              );
                            })
                          else
                            ...options.map((option) {
                              final value = option is Map
                                  ? option['id'] ??
                                        option['value'] ??
                                        option['text']
                                  : option;
                              final label = option is Map
                                  ? '${option['option_text'] ?? option['label'] ?? option['text'] ?? option['value'] ?? ''}'
                                  : '$option';
                              return RadioListTile<dynamic>(
                                value: value,
                                groupValue: _answers[id],
                                title: Text(label),
                                onChanged: (selected) =>
                                    setState(() => _answers[id] = selected),
                              );
                            }),
                        ],
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(context.tr('tests.submit')),
            ),
          ),
        ),
      ),
    ),
  );

  String _questionType(Map<String, dynamic> question) {
    final value = question['question_type'] ?? question['type'];
    return value is Map
        ? '${value['key'] ?? value['value'] ?? ''}'
        : '${value ?? ''}';
  }

  Future<void> _pickAnswerFile(int questionId) async {
    final files = await FilePicker.pickFiles();
    if (files.isEmpty || files.first.path == null || !mounted) return;
    final attemptId =
        int.tryParse(
          '${widget.attempt['id'] ?? widget.attempt['attempt_id']}',
        ) ??
        -1;
    if (attemptId < 0) return;
    try {
      await context.read<TestsCubit>().uploadFileAnswer(
        attemptId,
        questionId,
        files.first.path!,
        files.first.name,
      );
      if (mounted) setState(() => _uploadedFiles.add(questionId));
    } catch (error) {
      if (mounted) {
        AppSnackBar.error(context, '$error');
      }
    }
  }
}
