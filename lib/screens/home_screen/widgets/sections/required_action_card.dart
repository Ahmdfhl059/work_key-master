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
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final warningText = dark
        ? const Color(0xFFFFC36A)
        : const Color(0xFFA95D00);
    final date = DateTime.tryParse(action.dateTime ?? '');
    final targetType = action.target?.type.trim().isNotEmpty == true
        ? action.target!.type
        : action.type;
    void openAction() => HomeNavigation.openTarget(
      context,
      targetType,
      id: action.target?.id,
      value: action.target?.value,
    );
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: openAction,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: dark
                ? const [Color(0xFF292117), Color(0xFF211B14)]
                : const [Color(0xFFFFF8EB), Color(0xFFFFF2DA)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: dark
                ? HomeColors.warning.withValues(alpha: .48)
                : const Color(0xFFFFDDA8),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: HomeColors.warning,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.bolt_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DefaultText(
                    text: 'NEEDS YOUR ATTENTION',
                    style: TextStyle(
                      color: warningText,
                      fontSize: 10,
                      letterSpacing: .5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DefaultText(
                    text: action.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (action.subtitle != null)
                    DefaultText(
                      text: action.subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  if (date != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: DefaultText(
                        text: DateFormat(
                          'MMM d • h:mm a',
                          Localizations.localeOf(context).toLanguageTag(),
                        ).format(date.toLocal()),
                        style: TextStyle(
                          color: warningText,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: dark
                    ? HomeColors.warning.withValues(alpha: .14)
                    : Colors.white,
                shape: BoxShape.circle,
              ),
              child: DefaultIconButton(
                onPressed: openAction,
                size: 20,
                color: warningText,
                icon: const Icon(Icons.arrow_forward_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
