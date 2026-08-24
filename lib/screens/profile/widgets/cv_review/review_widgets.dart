part of '../../cv_review_screen.dart';

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
              icon: _draftSectionIcon(entry.key),
            ),
          )
          .toList(),
    ),
  );
}

class _DraftSection extends StatelessWidget {
  final String title;
  final dynamic value;
  final IconData icon;

  const _DraftSection({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final lines = _displayLines(value, context: context);
    if (lines.isEmpty) return const SizedBox.shrink();
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 31,
                height: 31,
                decoration: BoxDecoration(
                  color: context.appSoftBrand,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: colors.primary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DefaultText(
                  text: title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
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

IconData _draftSectionIcon(String key) {
  final value = key.toLowerCase();
  if (value.contains('experience')) return Icons.work_history_outlined;
  if (value.contains('education')) return Icons.school_outlined;
  if (value.contains('skill')) return Icons.bolt_rounded;
  if (value.contains('profile')) return Icons.person_outline_rounded;
  if (value.contains('language')) return Icons.translate_rounded;
  if (value.contains('certificate')) return Icons.workspace_premium_outlined;
  return Icons.article_outlined;
}
