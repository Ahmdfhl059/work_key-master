part of '../../activity_screen.dart';

class _ActivitySummary extends StatelessWidget {
  final ActivitySummary summary;

  const _ActivitySummary({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final items = [
      ('Today', summary.today, Icons.today_rounded),
      ('Tests', summary.tests, Icons.quiz_outlined),
      ('Interviews', summary.interviews, Icons.video_call_outlined),
      ('Information', summary.informationRequests, Icons.description_outlined),
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          return Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: colors.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(item.$3, size: 16, color: HomeColors.purple),
                const SizedBox(width: 6),
                Text(
                  '${context.tr(item.$1)} ${item.$2}',
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ScheduleSection extends StatelessWidget {
  final String title;
  final List<ActivityItem> items;
  final ValueChanged<ActivityItem> onOpen;

  const _ScheduleSection({
    required this.title,
    required this.items,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultText(
            text: title,
            style: TextStyle(
              color: context.appInk,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: ActivityCard(
                    item: item,
                    compact: true,
                    onTap: () => onOpen(item),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
