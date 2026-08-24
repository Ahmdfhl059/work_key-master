part of '../components.dart';

class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const SkeletonBox(width: 52, height: 52, radius: 26),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonBox(width: 210, height: 16),
                  const SizedBox(height: 9),
                  const SkeletonBox(width: 125, height: 11),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 17),
        const Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            SkeletonBox(width: 88, height: 27, radius: 9),
            SkeletonBox(width: 74, height: 27, radius: 9),
            SkeletonBox(width: 105, height: 27, radius: 9),
          ],
        ),
        const SizedBox(height: 13),
        Row(
          children: [
            const SkeletonBox(width: 90, height: 11),
            const Spacer(),
            const SkeletonBox(width: 80, height: 13),
          ],
        ),
      ],
    ),
  );
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

String? local;
