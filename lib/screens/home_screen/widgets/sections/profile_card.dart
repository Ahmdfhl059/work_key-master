import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

import '../../home_navigation.dart';
import '../home_shared.dart';

class HomeProfileCard extends StatelessWidget {
  final HomeProfileCompletenessModel profile;
  const HomeProfileCard({super.key, required this.profile});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(22),
    onTap: () => HomeNavigation.openTarget(context, 'profile_section'),
    child: HomeCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final indicator = SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: (profile.percentage / 100)
                        .clamp(0.0, 1.0)
                        .toDouble(),
                    strokeWidth: 6,
                    backgroundColor: context.appDivider,
                    color: HomeColors.purple,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                DefaultText(
                  text: '${profile.percentage}%',
                  style: TextStyle(
                    color: context.appInk,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          );
          final details = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultText(
                text: 'Complete your profile',
                style: TextStyle(
                  color: context.appInk,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              DefaultText(
                text: profile.isComplete
                    ? 'Your profile is complete and ready'
                    : '${profile.missingItemsCount} steps left to complete your profile',
                style: TextStyle(
                  color: context.appMuted,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              if (profile.nextItem != null) ...[
                const SizedBox(height: 5),
                DefaultTextButton(
                  text: profile.nextItem!.label,
                  onPressed: () => HomeNavigation.openTarget(
                    context,
                    'profile_section',
                    value: profile.nextItem!.key,
                  ),
                  textStyle: const TextStyle(
                    color: HomeColors.brand,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          );
          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              indicator,
              const SizedBox(width: 14),
              Expanded(child: details),
            ],
          );
        },
      ),
    ),
  );
}
