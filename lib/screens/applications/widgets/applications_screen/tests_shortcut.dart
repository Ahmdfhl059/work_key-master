part of '../../applications_screen.dart';

class _TestsShortcut extends StatelessWidget {
  final VoidCallback onTap;

  const _TestsShortcut({required this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: context.appSoftBrand,
    borderRadius: BorderRadius.circular(17),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        child: Row(
          children: [
            CircleAvatar(
              radius: 21,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.quiz_rounded, color: HomeColors.purple),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultText(
                    text: context.tr('tests.title'),
                    style: TextStyle(
                      color: context.appInk,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  DefaultText(
                    text: context.tr('tests.short_description'),
                    style: TextStyle(color: context.appMuted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: HomeColors.purple,
            ),
          ],
        ),
      ),
    ),
  );
}
