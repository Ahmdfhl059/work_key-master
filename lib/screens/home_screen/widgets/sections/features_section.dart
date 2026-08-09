import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

import '../home_shared.dart';

class HomeFeaturesSection extends StatelessWidget {
  final List<HomeFeatureModel> features;
  const HomeFeaturesSection({super.key, required this.features});

  IconData _icon(String key) => key.contains('cv') ? Icons.description_outlined : key.contains('tracking') ? Icons.track_changes_rounded : Icons.auto_awesome_rounded;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const HomeSectionHeader(title: 'Everything your career needs'),
        const SizedBox(height: 14),
        LayoutBuilder(builder: (context, constraints) {
          final columns = constraints.maxWidth >= 700 ? 3 : 1;
          final width = (constraints.maxWidth - (12 * (columns - 1))) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: features.map((feature) => SizedBox(
              width: width,
              child: HomeCard(
                padding: const EdgeInsets.all(14),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 46, height: 46, decoration: BoxDecoration(color: HomeColors.softBlue, borderRadius: BorderRadius.circular(14)), child: Icon(_icon(feature.key), color: HomeColors.brand)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    DefaultText(text: feature.title, style: const TextStyle(color: HomeColors.ink, fontSize: 13, height: 1.3, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    DefaultText(text: feature.description, style: const TextStyle(color: HomeColors.muted, fontSize: 10.5, height: 1.4)),
                  ])),
                ]),
              ),
            )).toList(),
          );
        }),
      ]);
}
