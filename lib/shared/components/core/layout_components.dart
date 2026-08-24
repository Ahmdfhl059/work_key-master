part of '../components.dart';

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
