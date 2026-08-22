import 'package:flutter/material.dart';
import 'package:work_key/localization/app_localizations.dart';

enum AppSnackBarType { success, error, warning, info }

abstract final class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    AppSnackBarType type = AppSnackBarType.info,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final colors = _colors(type, scheme);
    final localizedTitle = title == null ? null : context.tr(title);
    final cleanedMessage = message.replaceFirst(RegExp(r'^Exception:\s*'), '');
    var localizedMessage = context.tr(cleanedMessage);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    if (isArabic &&
        localizedMessage == cleanedMessage &&
        !RegExp(r'[\u0600-\u06FF]').hasMatch(cleanedMessage)) {
      localizedMessage = context.tr(
        type == AppSnackBarType.success
            ? 'success.saved'
            : type == AppSnackBarType.error
            ? 'errors.unexpected'
            : cleanedMessage,
      );
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
          duration: duration,
          dismissDirection: DismissDirection.horizontal,
          content: Container(
            constraints: const BoxConstraints(minHeight: 70),
            padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colors.accent.withValues(alpha: .20)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1B2831).withValues(alpha: .16),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(_icon(type), color: colors.accent, size: 23),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (localizedTitle != null) ...[
                        Text(
                          localizedTitle,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                      ],
                      Text(
                        localizedMessage,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: localizedTitle == null
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: localizedTitle == null
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: messenger.hideCurrentSnackBar,
                  icon: const Icon(Icons.close_rounded, size: 19),
                  color: scheme.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
        ),
      );
  }

  static void success(BuildContext context, String message, {String? title}) =>
      show(context, message, type: AppSnackBarType.success, title: title);

  static void error(BuildContext context, String message, {String? title}) =>
      show(context, message, type: AppSnackBarType.error, title: title);

  static void warning(BuildContext context, String message, {String? title}) =>
      show(context, message, type: AppSnackBarType.warning, title: title);

  static _SnackColors _colors(AppSnackBarType type, ColorScheme scheme) =>
      switch (type) {
        AppSnackBarType.success => _SnackColors(
          scheme.primary,
          scheme.primaryContainer.withValues(alpha: .96),
        ),
        AppSnackBarType.error => _SnackColors(
          scheme.error,
          scheme.errorContainer,
        ),
        AppSnackBarType.warning => _SnackColors(
          scheme.tertiary,
          scheme.tertiaryContainer,
        ),
        AppSnackBarType.info => _SnackColors(
          scheme.secondary,
          scheme.secondaryContainer,
        ),
      };

  static IconData _icon(AppSnackBarType type) => switch (type) {
    AppSnackBarType.success => Icons.check_circle_rounded,
    AppSnackBarType.error => Icons.error_rounded,
    AppSnackBarType.warning => Icons.warning_amber_rounded,
    AppSnackBarType.info => Icons.info_rounded,
  };
}

class _SnackColors {
  final Color accent;
  final Color surface;
  const _SnackColors(this.accent, this.surface);
}
