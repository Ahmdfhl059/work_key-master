part of '../components.dart';

class DefaultText extends StatelessWidget {
  final String text;
  final dynamic overflow;
  final dynamic maxLines;
  final TextAlign? textAlign;
  final TextStyle? style;

  const DefaultText({
    super.key,
    required this.text,
    this.overflow,
    this.maxLines,
    this.textAlign,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final originalColor = style?.color;
    final darkNeutral =
        originalColor != null &&
        originalColor.r == originalColor.g &&
        originalColor.g == originalColor.b &&
        originalColor.computeLuminance() < .7;
    final adaptiveColor =
        theme.brightness == Brightness.dark &&
            (originalColor == context.appInk ||
                originalColor == context.appMuted ||
                originalColor == Colors.black ||
                originalColor == Colors.black87 ||
                darkNeutral)
        ? (originalColor == context.appMuted
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.onSurface)
        : originalColor;
    return Text(
      AppLocalizations.of(context).text(text),
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      style:
          style?.copyWith(color: adaptiveColor) ?? theme.textTheme.bodyMedium,
    );
  }
}

class DefaultTextButton extends StatelessWidget {
  final String text;
  final dynamic onPressed;
  final dynamic textStyle;
  final dynamic fontWeight;
  final dynamic textDecoration;
  final dynamic overflow;
  final dynamic maxLines;

  const DefaultTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontWeight,
    this.textDecoration,
    this.overflow,
    this.maxLines,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = textStyle is TextStyle ? textStyle as TextStyle : null;
    final originalColor = style?.color;
    final darkNeutral =
        originalColor != null &&
        originalColor.r == originalColor.g &&
        originalColor.g == originalColor.b &&
        originalColor.computeLuminance() < .7;
    final effectiveStyle =
        theme.brightness == Brightness.dark &&
            (originalColor == context.appInk ||
                originalColor == context.appMuted ||
                originalColor == Colors.black ||
                originalColor == Colors.black87 ||
                darkNeutral)
        ? style?.copyWith(
            color: originalColor == context.appMuted
                ? theme.colorScheme.onSurfaceVariant
                : theme.colorScheme.onSurface,
          )
        : style;
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Text(
        AppLocalizations.of(context).text(text),
        overflow: overflow,
        maxLines: maxLines,
        style: effectiveStyle,
      ),
    );
  }
}

Future navigateTo(BuildContext context, Widget screen) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 420),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(.035, .025),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

void navigatePop(BuildContext context, bool isSuccess) {
  Navigator.pop(context, isSuccess);
}

void navigateAndFinish(BuildContext context, Widget screen) =>
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 420),
        pageBuilder: (_, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
      (route) => false,
    );
