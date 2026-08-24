part of '../../job_details_screen.dart';

class _HeroTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _HeroTag(this.icon, this.text);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: .15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

class _SkillWrap extends StatelessWidget {
  final List<SkillModel> skills;
  final bool required;

  const _SkillWrap({required this.skills, this.required = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = required ? colors.primary : colors.tertiary;
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: skills
          .map(
            (skill) => Chip(
              avatar: Icon(
                required ? Icons.bolt_rounded : Icons.add_rounded,
                size: 15,
                color: accent,
              ),
              label: Text(skill.name),
              backgroundColor: accent.withValues(alpha: .10),
              side: BorderSide(color: accent.withValues(alpha: .22)),
            ),
          )
          .toList(),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;
  final bool benefits;

  const _BulletList({required this.items, this.benefits = false});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final accent = benefits ? colors.tertiary : colors.primary;
    return Column(
      children: items
          .map(
            (text) => Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Icon(
                      benefits
                          ? Icons.stars_rounded
                          : Icons.check_circle_rounded,
                      size: 16,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DefaultText(
                      text: text,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _FactChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FactChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: colors.secondary.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.secondary),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
