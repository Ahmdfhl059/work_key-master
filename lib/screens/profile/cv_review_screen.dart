import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cv_file_model.dart';
import '../../logic/cv_cubit/cv_cubit.dart';
import '../../logic/profile_cubit/profile_cubit.dart';
import '../../localization/app_localizations.dart';
import '../../shared/components/app_snackbar.dart';
import '../../shared/components/components.dart';
import '../../utils/constants.dart';

part 'widgets/cv_review/review_widgets.dart';
part 'widgets/cv_review/review_step_widgets.dart';
part 'widgets/cv_review/suggestion_widgets.dart';
part 'widgets/cv_review/suggestion_editor.dart';
part 'widgets/cv_review/review_actions_states.dart';
part 'widgets/cv_review/review_helpers.dart';

class CvReviewScreen extends StatefulWidget {
  final CvFileModel cvFile;

  const CvReviewScreen({super.key, required this.cvFile});

  @override
  State<CvReviewScreen> createState() => _CvReviewScreenState();
}

class _CvReviewScreenState extends State<CvReviewScreen> {
  Map<String, dynamic>? _review;
  bool _loading = true;
  bool _acting = false;
  bool _bulkActing = false;
  final Set<int> _busySuggestionIds = <int>{};
  int _step = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final review = await context.read<CvCubit>().getReview(widget.cvFile.id);
      if (mounted) setState(() => _review = review);
    } catch (_) {
      if (mounted) {
        setState(() => _error = context.tr('cv.not_ready'));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshReviewSilently() async {
    try {
      final review = await context.read<CvCubit>().getReview(widget.cvFile.id);
      if (mounted) setState(() => _review = review);
    } catch (_) {
      // Keep the last usable review visible. The next explicit refresh can
      // recover without replacing the whole wizard with an error page.
    }
  }

  @override
  Widget build(BuildContext context) {
    final review = _review;
    final action = review == null ? '' : _localizedKey(review['next_action']);
    final showWizard = action == 'review_suggestions' || action == 'confirm';
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        surfaceTintColor: Colors.transparent,
        title: Text(
          context.tr('cv.review_title'),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: _loading
          ? const _ReviewLoading()
          : _error != null || review == null
          ? _ReviewError(message: _error ?? '', retry: _load)
          : ResponsiveContent(
              maxWidth: 760,
              child: ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 38),
                children: [
                  _ReviewHeader(file: widget.cvFile, review: review),
                  const SizedBox(height: 15),
                  if (!showWizard) ...[
                    _WorkflowActionCard(
                      review: review,
                      acting: _acting,
                      onPressed: _performNextAction,
                    ),
                  ] else ...[
                    _ReviewStepBar(
                      selected: _step,
                      onSelected: (value) => setState(() => _step = value),
                    ),
                    const SizedBox(height: 18),
                    if (_step < 4 &&
                        _suggestionsForStep(review, _step).isNotEmpty)
                      _SuggestionsCard(
                        suggestions: _suggestionsForStep(review, _step),
                        busyIds: _busySuggestionIds,
                        bulkBusy: _bulkActing,
                        decide: _decide,
                        decideBulk: _decideBulk,
                        edit: _editSuggestion,
                      )
                    else if (_step < 4)
                      _EmptyReviewStep(),
                    if (_step == 4) ...[
                      if (_draft(review).isNotEmpty)
                        _DraftCard(draft: _draft(review)),
                      const SizedBox(height: 18),
                      _PrimaryAction(
                        review: review,
                        acting: _acting,
                        onPressed: _performNextAction,
                      ),
                    ],
                    const SizedBox(height: 16),
                    _StepControls(
                      step: _step,
                      onPrevious: () => setState(() => _step--),
                      onNext: () => setState(() => _step++),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Future<void> _performNextAction() async {
    if (_acting ||
        _bulkActing ||
        _busySuggestionIds.isNotEmpty ||
        _review == null) {
      return;
    }
    final action = _localizedKey(_review!['next_action']);
    setState(() => _acting = true);
    try {
      final cubit = context.read<CvCubit>();
      if (!isCvActionAllowed(_review!, action)) {
        await _refreshReviewSilently();
        return;
      }
      if (action == 'generate_suggestions') {
        await cubit.generateSuggestions(widget.cvFile.id);
        await _refreshReviewSilently();
      } else if (action == 'confirm') {
        if (_review!['can_confirm'] != true || !isCvReviewComplete(_review!)) {
          await _refreshReviewSilently();
          return;
        }
        final confirmation = await cubit.confirmReview(widget.cvFile.id);
        if (confirmation != null && mounted) {
          await _publishConfirmedProfile(confirmation);
          if (mounted) Navigator.pop(context, true);
        }
      } else if (action == 'review_suggestions') {
        final pending = _pendingSuggestionIds(_review!);
        if (pending.isNotEmpty) {
          final review = await cubit.decideBulkSuggestions(
            widget.cvFile.id,
            pending,
            'reject',
          );
          if (mounted) {
            setState(() {
              _review = review;
              _step = 4;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.tr('cv.bulk_saved'))),
            );
          }
        } else {
          await _refreshReviewSilently();
        }
      } else {
        await _refreshReviewSilently();
      }
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _decide(
    Map<String, dynamic> suggestion,
    bool accept, {
    Map<String, dynamic>? editedValue,
  }) async {
    final id = int.tryParse('${suggestion['id'] ?? ''}');
    if (id == null || _busySuggestionIds.contains(id)) return;
    setState(() => _busySuggestionIds.add(id));
    try {
      final cubit = context.read<CvCubit>();
      late final Map<String, dynamic> updated;
      if (accept) {
        updated = await cubit.acceptSuggestion(id, editedValue);
      } else {
        updated = await cubit.rejectSuggestion(
          id,
          'Keep the current profile value',
        );
      }
      if (mounted) {
        _replaceSuggestion(updated);
        await _refreshReviewSilently();
      }
      if (mounted) {
        AppSnackBar.success(
          context,
          context.tr(
            editedValue == null ? 'cv.decision_saved' : 'cv.edited_value_saved',
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('cv.decision_error'))),
        );
      }
    } finally {
      if (mounted) setState(() => _busySuggestionIds.remove(id));
    }
  }

  Future<void> _editSuggestion(Map<String, dynamic> suggestion) async {
    if (suggestion['can_edit'] != true) return;
    final edited = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SuggestionEditor(suggestion: suggestion),
    );
    if (edited == null || !mounted) return;
    await _decide(suggestion, true, editedValue: edited);
  }

  Future<void> _decideBulk(
    List<Map<String, dynamic>> suggestions,
    bool accept,
  ) async {
    if (_bulkActing) return;
    final ids = suggestions
        .where((item) => _localizedKey(item['status']) == 'pending')
        .map((item) => int.tryParse('${item['id'] ?? ''}') ?? -1)
        .where((id) => id >= 0)
        .toList();
    if (ids.isEmpty) return;
    setState(() => _bulkActing = true);
    try {
      final review = await context.read<CvCubit>().decideBulkSuggestions(
        widget.cvFile.id,
        ids,
        accept ? 'accept' : 'reject',
      );
      if (!mounted) return;
      setState(() => _review = review);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.tr('cv.bulk_saved'))));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('cv.decision_error'))),
        );
      }
    } finally {
      if (mounted) setState(() => _bulkActing = false);
    }
  }

  void _replaceSuggestion(Map<String, dynamic> updated) {
    final review = _review;
    if (review == null) return;
    final id = int.tryParse('${updated['id'] ?? ''}');
    if (id == null) return;
    final suggestions = _suggestions(review);
    final index = suggestions.indexWhere(
      (item) => int.tryParse('${item['id'] ?? ''}') == id,
    );
    if (index < 0) return;
    suggestions[index] = updated;
    setState(() {
      _review = Map<String, dynamic>.from(review)
        ..['suggestions'] = suggestions;
    });
  }

  Future<void> _publishConfirmedProfile(
    Map<String, dynamic> confirmation,
  ) async {
    final profileCubit = context.read<ProfileCubit>();
    profileCubit.applyConfirmedCvProfile(confirmation['profile']);
  }
}
