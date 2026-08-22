import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_radio_group/flutter_radio_group.dart';

import '../../logic/local_cubit/local_cubit.dart';
import '../../logic/local_cubit/local_state.dart';
import '../../localization/app_localizations.dart';
import '../../utils/constants.dart';

class CustomTextFormFiled extends StatefulWidget {
  final TextEditingController controller;
  final dynamic borderColor;
  final dynamic iconColor;
  final TextInputType type;
  final dynamic label;
  final dynamic onSubmit;
  final dynamic onChange;
  final dynamic onTap;
  final dynamic validate;
  final dynamic prefix;
  final dynamic circularSize;
  final bool isPassword;
  final bool readOnly;
  final bool border;
  final String? hintText;

  const CustomTextFormFiled({
    super.key,
    this.label,
    required this.controller,
    required this.type,
    this.prefix,
    this.onSubmit,
    this.onChange,
    this.validate,
    this.onTap,
    this.isPassword = false,
    this.borderColor,
    this.iconColor,
    this.readOnly = false,
    this.border = true,
    this.hintText,
    this.circularSize,
  });

  @override
  CustomTextFormFiledState createState() => CustomTextFormFiledState();
}

class CustomTextFormFiledState extends State<CustomTextFormFiled> {
  bool _obscureText = true;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode()..addListener(_onFocusChanged);
  }

  void _onFocusChanged() => setState(() {});

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChanged)
      ..dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final radius = (widget.circularSize is num)
        ? (widget.circularSize as num).toDouble().clamp(14.0, 26.0)
        : 18.0;
    final accent = widget.borderColor is Color
        ? widget.borderColor as Color
        : colors.primary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius + 2),
        boxShadow: _focusNode.hasFocus
            ? [
                BoxShadow(
                  color: accent.withValues(alpha: .18),
                  blurRadius: 20,
                  offset: const Offset(0, 7),
                ),
              ]
            : const [],
      ),
      child: TextFormField(
        focusNode: _focusNode,
        readOnly: widget.readOnly,
        controller: widget.controller,
        keyboardType: widget.type,
        onFieldSubmitted: widget.onSubmit,
        onChanged: widget.onChange,
        onTap: widget.onTap,
        validator: widget.validate,
        obscureText: _obscureText,
        cursorColor: accent,
        style: TextStyle(
          color: colors.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: _focusNode.hasFocus
              ? colors.primaryContainer.withValues(alpha: .26)
              : colors.surfaceContainer,
          hintText: widget.hintText,
          suffixIcon: widget.isPassword
              ? IconButton(
                  onPressed: _togglePasswordVisibility,
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      _obscureText
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      key: ValueKey(_obscureText),
                    ),
                  ),
                )
              : null,
          prefixIcon: widget.prefix == null
              ? null
              : Padding(
                  padding: const EdgeInsetsDirectional.only(start: 7, end: 4),
                  child: Container(
                    width: 42,
                    height: 42,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: .11),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(widget.prefix, color: accent, size: 20),
                  ),
                ),
          prefixIconConstraints: const BoxConstraints(minWidth: 58),
          labelText: AppLocalizations.of(context).text(widget.label),
          labelStyle: TextStyle(
            color: _focusNode.hasFocus ? accent : colors.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: accent, width: 1.7),
            borderRadius: BorderRadius.circular(radius),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.error, width: 1.7),
            borderRadius: BorderRadius.circular(radius),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colors.error.withValues(alpha: .72)),
            borderRadius: BorderRadius.circular(radius),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: colors.outlineVariant.withValues(alpha: .82),
            ),
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      ),
    );
  }
}

class DefaultButton extends StatelessWidget {
  final double width;
  final double height;
  final Color background;
  final String text;
  final double fontSize;
  final VoidCallback onPress;
  final double borderRadius;
  final Color textColor;
  final bool uppercase;

  const DefaultButton({
    super.key,
    required this.background,
    this.width = double.infinity,
    this.height = 50.0,
    required this.text,
    this.fontSize = 20,
    required this.onPress,
    this.borderRadius = 5,
    this.textColor = Colors.white,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final endColor = Color.lerp(background, const Color(0xFF087B3C), .42)!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [background, endColor],
        ),
        borderRadius: BorderRadius.circular(borderRadius.clamp(14, 24)),
        border: Border.all(color: Colors.white.withValues(alpha: .14)),
        boxShadow: [
          BoxShadow(
            color: background.withValues(alpha: isDark ? .28 : .34),
            blurRadius: 22,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius.clamp(14, 24)),
          onTap: onPress,
          child: Center(
            child: Text(
              uppercase
                  ? AppLocalizations.of(context).text(text).toUpperCase()
                  : AppLocalizations.of(context).text(text),
              style: TextStyle(
                letterSpacing: .2,
                fontWeight: FontWeight.w800,
                color: textColor,
                fontSize: fontSize.clamp(13, 17),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModernRetryButton extends StatefulWidget {
  final FutureOr<void> Function() onRetry;
  final String text;
  final double width;

  const ModernRetryButton({
    super.key,
    required this.onRetry,
    this.text = 'common.retry',
    this.width = 178,
  });

  @override
  State<ModernRetryButton> createState() => _ModernRetryButtonState();
}

class AnimatedPressableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  const AnimatedPressableCard({
    super.key,
    required this.child,
    this.onTap,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  State<AnimatedPressableCard> createState() => _AnimatedPressableCardState();
}

class _AnimatedPressableCardState extends State<AnimatedPressableCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 460),
    curve: Curves.easeOutCubic,
    builder: (context, value, child) => Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - value)),
        child: child,
      ),
    ),
    child: AnimatedScale(
      scale: _pressed ? .975 : 1,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: widget.onTap == null
              ? null
              : (_) => setState(() => _pressed = true),
          onTapCancel: widget.onTap == null
              ? null
              : () => setState(() => _pressed = false),
          onTapUp: widget.onTap == null
              ? null
              : (_) => setState(() => _pressed = false),
          borderRadius: widget.borderRadius,
          child: widget.child,
        ),
      ),
    ),
  );
}

class _ModernRetryButtonState extends State<ModernRetryButton> {
  bool _loading = false;

  Future<void> _retry() async {
    if (_loading) return;
    setState(() => _loading = true);
    final started = DateTime.now();
    try {
      await Future.sync(widget.onRetry);
    } finally {
      final elapsed = DateTime.now().difference(started);
      if (elapsed < const Duration(milliseconds: 650)) {
        await Future<void>.delayed(const Duration(milliseconds: 650) - elapsed);
      }
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: _loading ? .97 : 1,
    duration: const Duration(milliseconds: 180),
    child: SizedBox(
      width: widget.width,
      height: 50,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [HomeColors.brand, HomeColors.purple],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x3529B148),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: FilledButton.icon(
          onPressed: _loading ? null : _retry,
          style: FilledButton.styleFrom(
            disabledBackgroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          icon: _loading
              ? const SizedBox.square(
                  dimension: 19,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.3,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.refresh_rounded, color: Colors.white),
          label: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Text(
              _loading
                  ? context.tr('common.refreshing')
                  : context.tr(widget.text),
              key: ValueKey(_loading),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

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

class DefaultIconButton extends StatefulWidget {
  final Function onPressed;
  final Widget icon;
  final double size;
  final dynamic color;

  const DefaultIconButton({
    super.key,
    required this.onPressed,
    required this.icon,
    this.size = 35,
    this.color,
  });

  @override
  State<DefaultIconButton> createState() => _DefaultIconButtonState();
}

class _DefaultIconButtonState extends State<DefaultIconButton> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        setState(() {
          widget.onPressed();
        });
      },
      icon: widget.icon,
      style: ButtonStyle(
        iconSize: WidgetStatePropertyAll(widget.size),
        iconColor: WidgetStatePropertyAll(widget.color),
      ),
    );
  }
}

class DatePicked extends StatefulWidget {
  const DatePicked({super.key});

  @override
  State<DatePicked> createState() => _DatePickedState();
}

String selectDate = '';

class _DatePickedState extends State<DatePicked> {
  DateTime datePicked = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(15),
      radius: 15,
      onTap: () async {
        datePicked = (await DatePicker.showSimpleDatePicker(
          context,
          backgroundColor: Theme.of(context).datePickerTheme.backgroundColor,
          lastDate: DateTime.now(),
          initialDate: DateTime.now(),
          pickerMode: DateTimePickerMode.date,
          dateFormat: "yyyy-MM-dd",
          locale: DateTimePickerLocale.en_us,
          looping: false,
          titleText: 'Select_Date',
          cancelText: 'Cancel',
          confirmText: 'Ok',
          textColor: Theme.of(context).datePickerTheme.dividerColor,
        ))!;
        print(selectDate);
        setState(() {});
      },
      child: Container(
        padding: EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          border: Border.fromBorderSide(BorderSide(color: primary)),
        ),
        child: DefaultText(
          text: selectDate.isEmpty ? 'birthday' : selectDate.toString(),
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}

class DefaultListTile extends StatelessWidget {
  final String textTitle;
  final dynamic textSubTitle;
  final dynamic subTitle;
  final bool isSubTitle;
  final dynamic overflowSubTitle;
  final dynamic maxLinesSubTitle;
  final dynamic leading;
  final dynamic trailing;
  final dynamic onTap;

  const DefaultListTile({
    super.key,
    required this.textTitle,
    this.textSubTitle,
    this.leading,
    this.trailing,
    this.overflowSubTitle,
    this.maxLinesSubTitle,
    this.onTap,
    this.subTitle,
    required this.isSubTitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 70,

      onTap: onTap,
      shape: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(color: Theme.of(context).cardColor),
      ),
      leading: leading,
      title: DefaultText(
        text: textTitle,
        style: Theme.of(context).textTheme.labelLarge,
      ),
      subtitle: isSubTitle
          ? DefaultText(
              text: textSubTitle,
              style: Theme.of(context).textTheme.labelSmall,
              overflow: overflowSubTitle,
              maxLines: maxLinesSubTitle,
            )
          : subTitle,
      trailing: trailing,
      iconColor: Theme.of(context).iconTheme.color,
    );
  }
}

class DefFlutterRadioGroup extends StatelessWidget {
  final Key radioKey;
  final List<String> titles;
  final String? label;
  final Function(int?)? onChanged;
  final RGOrientation orientation;
  final TextStyle? titleStyle;
  final TextStyle? labelStyle;

  const DefFlutterRadioGroup({
    super.key,
    required this.radioKey,
    required this.titles,
    this.label,
    this.onChanged,
    required this.orientation,
    required this.titleStyle,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: FlutterRadioGroup(
        key: radioKey,
        titles: titles,
        label: label,
        activeColor: secondary,
        orientation: orientation,
        titleStyle: titleStyle ?? Theme.of(context).textTheme.bodyMedium!,
        labelStyle: labelStyle ?? Theme.of(context).textTheme.bodyMedium!,
        onChanged: onChanged,
      ),
    );
  }
}

class DefContainer extends StatelessWidget {
  final Widget child;
  final dynamic color;
  final double? width; // أضفت العرض هنا
  final List<BoxShadow>? boxShadow;
  final dynamic padding;

  const DefContainer({
    super.key,
    required this.child,
    this.color,
    this.boxShadow,
    this.width,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width ?? double.infinity, // استخدام العرض الممرر
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: color,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

/// Constrains wide layouts while preserving comfortable fluid gutters on
/// compact phones, tablets and desktop-sized Flutter surfaces.
class ResponsiveContent extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets? padding;

  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 1120,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final horizontal = width < 360
            ? 14.0
            : width < 700
            ? 20.0
            : 30.0;
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding ?? EdgeInsets.symmetric(horizontal: horizontal),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

/// Shared loading placeholder shaped like the job cards used by Home and
/// Explore, so loading does not cause a large visual layout shift.
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

class Local extends StatelessWidget {
  const Local({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocaleCubit, LocaleState>(
      builder: (context, state) {
        if (state is ChangeLocaleState) {
          return Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton<String>(
              style: Theme.of(context).textTheme.labelMedium,
              dropdownColor: Theme.of(context).colorScheme.surfaceContainer,
              iconEnabledColor: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(15),
              underline: Center(),
              value: state.locale.languageCode,
              icon: Icon(Icons.keyboard_arrow_down),
              items: ['العربية', 'English'].map((String items) {
                return DropdownMenuItem<String>(
                  value: items == 'العربية' ? 'ar' : 'en',
                  child: DefaultText(
                    text: items,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  local = newValue;
                  print(local);
                  BlocProvider.of<LocaleCubit>(
                    context,
                  ).changeLanguage(newValue);
                }
              },
            ),
          );
        } else {
          return SizedBox();
        }
      },
    );
  }
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(fontSize: 16, color: colors.onPrimary),
        ),
      ),
    );
  }
}

class CustomTextField extends StatefulWidget {
  final String hint;
  final String label;
  final IconData icon;
  final bool isPassword;
  final dynamic keyboardType;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          keyboardType: widget.keyboardType,
          controller: widget.controller,
          obscureText: widget.isPassword ? obscure : false,
          cursorColor: colors.primary,
          style: TextStyle(color: colors.onSurface),
          decoration: InputDecoration(
            hintText: widget.hint,

            hintStyle: TextStyle(
              color: colors.onSurfaceVariant.withValues(alpha: .72),
            ),
            prefixIcon: Icon(widget.icon, color: colors.primary),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: colors.onSurfaceVariant,
                    ),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                    },
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 18,
              horizontal: 10,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.outlineVariant, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: colors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
