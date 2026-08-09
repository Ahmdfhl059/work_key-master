import 'package:flutter/material.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

import '../home_shared.dart';

class HomeMemberHeader extends StatelessWidget {
  final HomeViewerModel? viewer;
  const HomeMemberHeader({super.key, this.viewer});

  @override
  Widget build(BuildContext context) => Row(children: [
        HomeNetworkAvatar(url: viewer?.avatarUrl, radius: 28),
        const SizedBox(width: 13),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const DefaultText(text: 'Welcome back', style: TextStyle(color: HomeColors.muted, fontSize: 12.5)),
          const SizedBox(height: 3),
          DefaultText(text: viewer?.name ?? 'Job seeker', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: HomeColors.ink, fontSize: 20, height: 1.2, fontWeight: FontWeight.w800)),
        ])),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: HomeColors.divider)),
          child: DefaultIconButton(onPressed: () {}, size: 22, color: HomeColors.brand, icon: const Icon(Icons.notifications_none_rounded)),
        ),
      ]);
}
