part of '../application_details_screen.dart';

class _DetailsLoading extends StatelessWidget {
  const _DetailsLoading();

  @override
  Widget build(BuildContext context) => ResponsiveContent(
    maxWidth: 760,
    child: ListView(
      padding: const EdgeInsets.only(top: 12),
      children: [
        Container(
          height: 210,
          decoration: BoxDecoration(
            color: context.appSoftBrand,
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          3,
          (_) => Container(
            height: 115,
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    ),
  );
}
