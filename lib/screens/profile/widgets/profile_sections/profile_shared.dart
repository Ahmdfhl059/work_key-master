part of '../profile_sections.dart';

class ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final String? actionLabel;
  final VoidCallback? onAction;
  const ProfileSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.actionLabel,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _sectionAccent(icon, scheme);
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: .62)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: Theme.of(context).brightness == Brightness.dark
                  ? .28
                  : .075,
            ),
            blurRadius: 30,
            offset: const Offset(0, 14),
            spreadRadius: -8,
          ),
        ],
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: accent),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 19, 18, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withValues(alpha: .18),
                            accent.withValues(alpha: .07),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: accent.withValues(alpha: .18),
                        ),
                      ),
                      child: Icon(icon, color: accent, size: 21),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: DefaultText(
                        text: title,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.25,
                        ),
                      ),
                    ),
                    if (actionLabel != null)
                      DefaultTextButton(
                        text: actionLabel!,
                        onPressed: onAction,
                        textStyle: TextStyle(
                          color: accent,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 17),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _sectionAccent(IconData value, ColorScheme scheme) {
    final palette = <Color>[
      scheme.primary,
      const Color(0xFF087D68),
      const Color(0xFF4B67C8),
      const Color(0xFFE88C19),
      const Color(0xFF8C55C7),
    ];
    return palette[value.codePoint.abs() % palette.length];
  }
}

class ProfileTimelineItem extends StatelessWidget {
  final String title, subtitle, detail;
  const ProfileTimelineItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.detail,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: HomeColors.purple,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultText(
                text: title,
                style: TextStyle(
                  color: context.appInk,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 3),
                DefaultText(
                  text: subtitle,
                  style: TextStyle(color: context.appMuted, fontSize: 11.5),
                ),
              ],
              if (detail.replaceAll('—', '').trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                DefaultText(
                  text: detail,
                  style: const TextStyle(
                    color: HomeColors.purple,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class ContactRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const ContactRow(this.icon, this.text, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 17, color: context.appMuted),
        const SizedBox(width: 9),
        Expanded(
          child: DefaultText(
            text: text,
            style: TextStyle(color: context.appInk, fontSize: 12.5),
          ),
        ),
      ],
    ),
  );
}
