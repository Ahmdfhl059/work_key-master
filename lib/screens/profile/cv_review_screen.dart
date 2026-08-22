import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cv_file_model.dart';
import '../../logic/cv_cubit/cv_cubit.dart';
import '../../logic/profile_cubit/profile_cubit.dart';
import '../../localization/app_localizations.dart';
import '../../shared/components/components.dart';
import '../../utils/constants.dart';

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

  Future<void> _decide(Map<String, dynamic> suggestion, bool accept) async {
    final id = int.tryParse('${suggestion['id'] ?? ''}');
    if (id == null || _busySuggestionIds.contains(id)) return;
    setState(() => _busySuggestionIds.add(id));
    try {
      final cubit = context.read<CvCubit>();
      late final Map<String, dynamic> updated;
      if (accept) {
        updated = await cubit.acceptSuggestion(id, null);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.tr('cv.decision_saved'))),
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

class _ReviewHeader extends StatelessWidget {
  final CvFileModel file;
  final Map<String, dynamic> review;

  const _ReviewHeader({required this.file, required this.review});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(19),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF29B148), Color(0xFF0FA348)],
      ),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Row(
      children: [
        Container(
          width: 55,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.description_rounded,
            color: Colors.white,
            size: 29,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultText(
                text: file.displayName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              DefaultText(
                text: _localizedLabel(review['stage'], file.statusLabel),
                style: const TextStyle(
                  color: Color(0xFFE2E8FF),
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _DraftCard extends StatelessWidget {
  final Map<String, dynamic> draft;

  const _DraftCard({required this.draft});

  @override
  Widget build(BuildContext context) => _WhiteCard(
    title: context.tr('cv.information_from_cv'),
    icon: Icons.auto_awesome_rounded,
    child: Column(
      children: draft.entries
          .where((entry) => _hasDisplayValue(entry.value))
          .map(
            (entry) => _DraftSection(
              title: context.tr(_humanize(entry.key)),
              value: entry.value,
            ),
          )
          .toList(),
    ),
  );
}

class _DraftSection extends StatelessWidget {
  final String title;
  final dynamic value;

  const _DraftSection({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final lines = _displayLines(value, context: context);
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: DefaultText(
              text: title,
              style: const TextStyle(
                color: HomeColors.purple,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 7),
          ...lines.map(
            (line) => Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7),
                    child: CircleAvatar(
                      radius: 2.5,
                      backgroundColor: HomeColors.brand,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DefaultText(
                      text: line,
                      style: TextStyle(
                        color: context.appInk,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewStepBar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _ReviewStepBar({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.person_outline_rounded,
      Icons.work_outline_rounded,
      Icons.school_outlined,
      Icons.auto_awesome_outlined,
      Icons.fact_check_outlined,
    ];
    const labels = [
      'cv.step_personal',
      'cv.step_experience',
      'cv.step_education',
      'cv.step_skills',
      'cv.step_final',
    ];
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final active = selected == index;
          final colors = Theme.of(context).colorScheme;
          return InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => onSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 105,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              decoration: BoxDecoration(
                color: active ? colors.primary : colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active ? colors.primary : colors.outlineVariant,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[index],
                    size: 20,
                    color: active ? colors.onPrimary : colors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    context.tr(labels[index]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: active ? colors.onPrimary : colors.onSurface,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyReviewStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _WhiteCard(
    title: context.tr('cv.no_changes_title'),
    icon: Icons.check_circle_outline_rounded,
    child: Text(
      context.tr('cv.no_changes_section'),
      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
    ),
  );
}

class _StepControls extends StatelessWidget {
  final int step;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _StepControls({
    required this.step,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      if (step > 0)
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPrevious,
            icon: const Icon(Icons.arrow_back_rounded),
            label: Text(context.tr('common.previous')),
          ),
        ),
      if (step > 0 && step < 4) const SizedBox(width: 10),
      if (step < 4)
        Expanded(
          child: FilledButton.icon(
            onPressed: onNext,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: Text(context.tr('common.next')),
          ),
        ),
    ],
  );
}

class _SuggestionsCard extends StatelessWidget {
  final List<Map<String, dynamic>> suggestions;
  final Set<int> busyIds;
  final bool bulkBusy;
  final Future<void> Function(Map<String, dynamic>, bool) decide;
  final Future<void> Function(List<Map<String, dynamic>>, bool) decideBulk;

  const _SuggestionsCard({
    required this.suggestions,
    required this.busyIds,
    required this.bulkBusy,
    required this.decide,
    required this.decideBulk,
  });

  bool get _hasPending =>
      suggestions.any((item) => _localizedKey(item['status']) == 'pending');

  @override
  Widget build(BuildContext context) => _WhiteCard(
    title: context.tr('cv.review_changes'),
    icon: Icons.compare_arrows_rounded,
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: bulkBusy || !_hasPending
                    ? null
                    : () => decideBulk(suggestions, false),
                icon: const Icon(Icons.undo_rounded),
                label: Text(context.tr('cv.bulk_keep_current')),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: bulkBusy || !_hasPending
                    ? null
                    : () => decideBulk(suggestions, true),
                icon: bulkBusy
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.done_all_rounded),
                label: Text(context.tr('cv.bulk_use_cv')),
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        ...suggestions.map((suggestion) {
          final actionable = suggestion['is_actionable'] == true;
          final selected = suggestion['selected_decision']?.toString();
          final id = int.tryParse('${suggestion['id'] ?? ''}') ?? -1;
          final disabled = busyIds.contains(id) || bulkBusy;
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 11),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.appDivider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DefaultText(
                  text: _localizedLabel(
                    suggestion['display_group'] ?? suggestion['entity_type'],
                    context.tr('cv.profile_information'),
                  ),
                  style: TextStyle(
                    color: context.appInk,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                _ValueComparison(
                  label: context.tr('cv.current'),
                  value: suggestion['current_value'],
                ),
                const SizedBox(height: 6),
                _ValueComparison(
                  label: context.tr('cv.from_cv'),
                  value: suggestion['proposed_value'],
                  highlighted: true,
                ),
                if (actionable) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: disabled
                              ? null
                              : () => decide(suggestion, false),
                          child: Text(
                            selected == 'keep_current' || selected == 'ignore'
                                ? context.tr('cv.current_kept')
                                : context.tr('cv.keep_current'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: disabled
                              ? null
                              : () => decide(suggestion, true),
                          style: FilledButton.styleFrom(
                            backgroundColor: HomeColors.purple,
                          ),
                          child: Text(
                            selected?.startsWith('accept') == true
                                ? context.tr('cv.cv_selected')
                                : context.tr('cv.use_cv'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        }),
      ],
    ),
  );
}

class _ValueComparison extends StatelessWidget {
  final String label;
  final dynamic value;
  final bool highlighted;

  const _ValueComparison({
    required this.label,
    required this.value,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = _displayLines(value, context: context).join(' • ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 62,
          child: DefaultText(
            text: label,
            style: TextStyle(color: context.appMuted, fontSize: 10.5),
          ),
        ),
        Expanded(
          child: DefaultText(
            text: text.isEmpty ? context.tr('common.not_provided') : text,
            style: TextStyle(
              color: highlighted ? HomeColors.purple : context.appInk,
              fontSize: 11.5,
              height: 1.4,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final Map<String, dynamic> review;
  final bool acting;
  final VoidCallback onPressed;

  const _PrimaryAction({
    required this.review,
    required this.acting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final action = _localizedKey(review['next_action']);
    if (action == 'review_suggestions') {
      final pending = _pendingSuggestionIds(review).length;
      return Column(
        children: [
          DefaultText(
            text: context.tr(
              'cv.pending_decisions',
              values: {'count': pending},
            ),
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appMuted, fontSize: 12),
          ),
          const SizedBox(height: 12),
          DefaultButton(
            background: HomeColors.purple,
            text: acting
                ? context.tr('cv.completing_review')
                : context.tr('cv.keep_remaining_continue'),
            uppercase: false,
            height: 54,
            borderRadius: 16,
            fontSize: 14,
            onPress: acting ? () {} : onPressed,
          ),
        ],
      );
    }
    final labelKey = switch (action) {
      'generate_suggestions' => 'cv.action_compare',
      'confirm' => 'cv.action_confirm',
      _ => 'cv.action_refresh',
    };
    final enabled =
        isCvActionAllowed(review, action) &&
        (action != 'confirm' ||
            (review['can_confirm'] == true && isCvReviewComplete(review)));
    return DefaultButton(
      background: HomeColors.purple,
      text: acting ? context.tr('common.please_wait') : context.tr(labelKey),
      uppercase: false,
      height: 54,
      borderRadius: 16,
      fontSize: 14,
      onPress: acting || !enabled ? () {} : onPressed,
    );
  }
}

class _WorkflowActionCard extends StatelessWidget {
  final Map<String, dynamic> review;
  final bool acting;
  final VoidCallback onPressed;

  const _WorkflowActionCard({
    required this.review,
    required this.acting,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => _WhiteCard(
    title: context.tr('cv.next_step'),
    icon: Icons.route_rounded,
    child: Column(
      children: [
        Text(
          _localizedLabel(
            review['next_action'],
            context.tr('cv.action_refresh'),
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 15),
        _PrimaryAction(review: review, acting: acting, onPressed: onPressed),
      ],
    ),
  );
}

class _WhiteCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _WhiteCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.surfaceContainer,
          Theme.of(context).colorScheme.primaryContainer.withValues(alpha: .22),
        ],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: HomeColors.purple, size: 20),
            const SizedBox(width: 8),
            DefaultText(
              text: title,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        child,
      ],
    ),
  );
}

class _ReviewLoading extends StatelessWidget {
  const _ReviewLoading();

  @override
  Widget build(BuildContext context) => const ResponsiveContent(
    maxWidth: 760,
    child: Padding(
      padding: EdgeInsets.only(top: 12),
      child: Column(
        children: [
          SkeletonBox(width: double.infinity, height: 110, radius: 24),
          SizedBox(height: 15),
          SkeletonBox(width: double.infinity, height: 320, radius: 20),
        ],
      ),
    ),
  );
}

class _ReviewError extends StatelessWidget {
  final String message;
  final VoidCallback retry;

  const _ReviewError({required this.message, required this.retry});

  @override
  Widget build(BuildContext context) => Center(
    child: ResponsiveContent(
      maxWidth: 420,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.hourglass_top_rounded,
            color: HomeColors.purple,
            size: 58,
          ),
          const SizedBox(height: 14),
          DefaultText(
            text: message,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appMuted),
          ),
          const SizedBox(height: 18),
          ModernRetryButton(onRetry: retry),
        ],
      ),
    ),
  );
}

Map<String, dynamic> _draft(Map<String, dynamic> review) {
  final raw =
      review['reviewed_json'] ?? review['draft'] ?? review['final_profile'];
  return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
}

List<Map<String, dynamic>> _suggestions(Map<String, dynamic> review) {
  final raw = review['suggestions'];
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

List<Map<String, dynamic>> _suggestionsForStep(
  Map<String, dynamic> review,
  int step,
) {
  final expected = switch (step) {
    0 => 'profile',
    1 => 'experience',
    2 => 'education',
    3 => 'skill',
    _ => '',
  };
  return _suggestions(review).where((item) {
    final entity = _localizedKey(item['entity_type']).toLowerCase();
    if (expected == 'skill') return entity == 'skill' || entity == 'skills';
    return entity == expected;
  }).toList();
}

List<int> _pendingSuggestionIds(Map<String, dynamic> review) =>
    _suggestions(review)
        .where((item) => _localizedKey(item['status']) == 'pending')
        .map((item) {
          return int.tryParse('${item['id'] ?? ''}') ?? -1;
        })
        .where((id) => id >= 0)
        .toList();

String _localizedKey(dynamic value) {
  if (value is Map) {
    final nested =
        value['key'] ??
        value['type'] ??
        value['action'] ??
        value['name'] ??
        value['value'];
    return _localizedKey(nested);
  }
  return '${value ?? ''}';
}

@visibleForTesting
bool isCvReviewComplete(Map<String, dynamic> review) {
  final raw = review['comparison_summary'];
  if (raw is! Map) return false;
  if (raw['is_complete'] == true) return true;
  final unresolved = int.tryParse('${raw['unresolved'] ?? ''}');
  return unresolved == 0;
}

@visibleForTesting
bool isCvActionAllowed(Map<String, dynamic> review, String action) {
  final raw = review['allowed_actions'];
  if (raw is! List) return false;
  return raw.map((item) => item.toString()).contains(action);
}

String _localizedLabel(dynamic value, String fallback) {
  if (value is Map) {
    final text = '${value['label'] ?? value['value'] ?? value['key'] ?? ''}'
        .trim();
    if (text.isNotEmpty && text != 'null') return text;
  }
  final text = '${value ?? ''}'.trim();
  return text.isEmpty || text == 'null' ? fallback : text;
}

bool _hasDisplayValue(dynamic value) => _displayLines(value).isNotEmpty;

List<String> _displayLines(dynamic value, {BuildContext? context}) {
  if (value == null) return const [];
  if (value is String || value is num || value is bool) {
    final text = value.toString().trim();
    return text.isEmpty || text == 'null' ? const [] : [text];
  }
  if (value is List) {
    return value
        .expand((item) => _displayLines(item, context: context))
        .where((line) => line.isNotEmpty)
        .toList();
  }
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    return map.entries.where((entry) => _hasDisplayValue(entry.value)).map((
      entry,
    ) {
      final child = _displayLines(entry.value, context: context).join(', ');
      final rawLabel = _humanize(entry.key);
      final label = context == null ? rawLabel : context.tr(rawLabel);
      return '$label: $child';
    }).toList();
  }
  return const [];
}

String _humanize(String value) {
  final normalized = value.replaceAll('_', ' ').trim().toLowerCase();
  return normalized.isEmpty
      ? normalized
      : '${normalized[0].toUpperCase()}${normalized.substring(1)}';
}
