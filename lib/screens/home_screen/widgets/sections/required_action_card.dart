import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

import '../../home_navigation.dart';

class HomeRequiredActionCard extends StatelessWidget {
  final HomeRequiredActionModel action;
  const HomeRequiredActionCard({super.key, required this.action});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(action.dateTime ?? '');
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFFFFF8EB), Color(0xFFFFF2DA)]), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFFFDDA8))),
      child: Row(children: [
        Container(width: 50, height: 50, decoration: BoxDecoration(color: HomeColors.warning, borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 28)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const DefaultText(text: 'NEEDS YOUR ATTENTION', style: TextStyle(color: Color(0xFFA95D00), fontSize: 10, letterSpacing: .5, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          DefaultText(text: action.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: HomeColors.ink, fontSize: 15.5, fontWeight: FontWeight.w800)),
          if (action.subtitle != null) DefaultText(text: action.subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: HomeColors.muted, fontSize: 11.5, height: 1.35)),
          if (date != null) Padding(padding: const EdgeInsets.only(top: 5), child: DefaultText(text: DateFormat('MMM d • h:mm a').format(date.toLocal()), style: const TextStyle(color: Color(0xFFA95D00), fontSize: 11, fontWeight: FontWeight.w700))),
        ])),
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: DefaultIconButton(
            onPressed: () => HomeNavigation.openTarget(context, action.target?.type ?? '', id: action.target?.id, value: action.target?.value),
            size: 20,
            color: const Color(0xFFA95D00),
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ),
      ]),
    );
  }
}
