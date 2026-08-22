import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/application_cubit/application_cubit.dart';
import '../../logic/application_cubit/application_state.dart';
import '../../data/models/job_model.dart';
import '../../utils/constants.dart';
import '../../localization/app_localizations.dart';

class ApplyJobResult {
  final String message;
  final int? applicationId;

  const ApplyJobResult(this.message, {this.applicationId});
}

class ApplyJobSheet extends StatefulWidget {
  final JobModel job;
  const ApplyJobSheet({super.key, required this.job});

  @override
  State<ApplyJobSheet> createState() => _ApplyJobSheetState();
}

class _ApplyJobSheetState extends State<ApplyJobSheet> {
  final _coverLetterController = TextEditingController();
  final Map<int, dynamic> _answers = {};

  @override
  void dispose() {
    _coverLetterController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final coverLetter = _coverLetterController.text.trim();
    final missing = widget.job.screeningQuestions.any(
      (question) => question.required && !_hasAnswer(question),
    );
    if (missing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.tr('jobs.answer_required_questions'))),
      );
      return;
    }
    final screeningAnswers = widget.job.screeningQuestions
        .where(_hasAnswer)
        .map(_answerPayload)
        .toList();
    await context.read<ApplicationCubit>().applyForJob(widget.job.id, {
      'cover_letter': coverLetter.isEmpty ? null : coverLetter,
      'consent_to_share_profile': true,
      'screening_answers': screeningAnswers,
    });
  }

  bool _hasAnswer(JobScreeningQuestion question) {
    final answer = _answers[question.id];
    if (answer is Iterable) return answer.isNotEmpty;
    return answer != null && answer.toString().trim().isNotEmpty;
  }

  Map<String, dynamic> _answerPayload(JobScreeningQuestion question) {
    final answer = _answers[question.id];
    if (question.type == 'single_choice' ||
        question.type == 'multiple_choice') {
      return {
        'question_id': question.id,
        'selected_option_ids': answer is Iterable ? answer.toList() : [answer],
      };
    }
    return {'question_id': question.id, 'value': answer};
  }

  @override
  Widget build(BuildContext context) =>
      BlocConsumer<ApplicationCubit, ApplicationStates>(
        listener: (context, state) {
          if (state is ApplicationActionSuccessState) {
            Navigator.pop(
              context,
              ApplyJobResult(state.message, applicationId: state.applicationId),
            );
          } else if (state is ApplicationErrorState) {
            final error = state.error.toLowerCase();
            if (error.contains('already applied') ||
                error.contains('already submitted') ||
                error.contains('تم التقديم') ||
                error.contains('سبق وقدمت')) {
              Navigator.pop(
                context,
                ApplyJobResult(context.tr('jobs.already_applied')),
              );
            } else {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error)));
            }
          }
        },
        builder: (context, state) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              18 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.appDivider,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    context.tr(
                      'jobs.apply_title',
                      values: {'job': widget.job.title},
                    ),
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    context.tr('jobs.profile_application_info'),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _coverLetterController,
                    minLines: 5,
                    maxLines: 9,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: context.tr('jobs.cover_letter'),
                      hintText: context.tr('jobs.cover_letter_hint'),
                      alignLabelWithHint: true,
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 105),
                        child: Icon(Icons.edit_note_rounded),
                      ),
                    ),
                  ),
                  if (widget.job.screeningQuestions.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    ...widget.job.screeningQuestions.map(_questionField),
                  ],
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: state is ApplicationLoadingState
                          ? null
                          : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: HomeColors.purple,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: state is ApplicationLoadingState
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(context.tr('jobs.submit')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _questionField(JobScreeningQuestion question) {
    final label = '${question.text}${question.required ? ' *' : ''}';
    if (question.type == 'boolean') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: DropdownButtonFormField<bool>(
          decoration: InputDecoration(labelText: label),
          value: _answers[question.id] as bool?,
          items: [
            DropdownMenuItem(
              value: true,
              child: Text(context.tr('common.yes')),
            ),
            DropdownMenuItem(
              value: false,
              child: Text(context.tr('common.no')),
            ),
          ],
          onChanged: (value) => setState(() => _answers[question.id] = value),
        ),
      );
    }
    if (question.type == 'single_choice') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Column(
            children: question.options
                .map(
                  (option) => RadioListTile<int>(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: option.id,
                    groupValue: _answers[question.id] as int?,
                    title: Text(option.text),
                    onChanged: (value) =>
                        setState(() => _answers[question.id] = value),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
    if (question.type == 'multiple_choice') {
      final selected = (_answers[question.id] as Set<int>?) ?? <int>{};
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: InputDecorator(
          decoration: InputDecoration(labelText: label),
          child: Column(
            children: question.options
                .map(
                  (option) => CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: selected.contains(option.id),
                    title: Text(option.text),
                    onChanged: (checked) => setState(() {
                      final values = Set<int>.from(selected);
                      checked == true
                          ? values.add(option.id)
                          : values.remove(option.id);
                      _answers[question.id] = values;
                    }),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        keyboardType: question.type == 'number'
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        onChanged: (value) => _answers[question.id] = question.type == 'number'
            ? num.tryParse(value)
            : value,
      ),
    );
  }
}
