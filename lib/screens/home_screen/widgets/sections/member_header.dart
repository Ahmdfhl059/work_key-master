import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/data/models/home_response_model.dart';
import 'package:work_key/logic/notifications_cubit/notifications_cubit.dart';
import 'package:work_key/logic/notifications_cubit/notifications_state.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';

import '../../home_navigation.dart';
import '../home_shared.dart';

class HomeMemberHeader extends StatelessWidget {
  final HomeViewerModel? viewer;
  const HomeMemberHeader({super.key, this.viewer});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      HomeNetworkAvatar(url: viewer?.avatarUrl, radius: 28),
      const SizedBox(width: 13),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DefaultText(
              text: 'Welcome back',
              style: TextStyle(color: context.appMuted, fontSize: 12.5),
            ),
            const SizedBox(height: 3),
            DefaultText(
              text: viewer?.name ?? 'Job seeker',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.appInk,
                fontSize: 20,
                height: 1.2,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
      BlocBuilder<NotificationsCubit, NotificationsStates>(
        builder: (context, _) {
          final count = context.read<NotificationsCubit>().unreadCount;
          return Badge(
            isLabelVisible: count > 0,
            label: Text(count > 99 ? '99+' : '$count'),
            offset: const Offset(4, -5),
            backgroundColor: Colors.red.shade600,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: DefaultIconButton(
                onPressed: () =>
                    HomeNavigation.openTarget(context, 'notifications'),
                size: 22,
                color: HomeColors.brand,
                icon: const Icon(Icons.notifications_none_rounded),
              ),
            ),
          );
        },
      ),
    ],
  );
}
