import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_holo_date_picker/date_picker.dart';
import 'package:flutter_holo_date_picker/i18n/date_picker_i18n.dart';
import 'package:flutter_radio_group/flutter_radio_group.dart';

import '../../logic/local_cubit/local_cubit.dart';
import '../../logic/local_cubit/local_state.dart';
import '../../utils/constants.dart';
import '../../utils/constants.dart' as AppColors;

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

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: widget.readOnly,
      controller: widget.controller,
      keyboardType: widget.type,
      onFieldSubmitted: widget.onSubmit,
      onChanged: widget.onChange,
      onTap: widget.onTap,
      validator: widget.validate,
      obscureText: _obscureText,
      cursorColor: widget.borderColor,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: widget.isPassword
            ? GestureDetector(
                onTap: _togglePasswordVisibility,
                child: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              )
            : null,
        prefixIcon: Icon(widget.prefix),
        labelText: widget.label,
        prefixIconColor: widget.iconColor,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor),
          borderRadius: BorderRadius.all(Radius.circular(widget.circularSize)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor),
          borderRadius: BorderRadius.all(Radius.circular(widget.circularSize)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
          borderRadius: BorderRadius.all(Radius.circular(widget.circularSize)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: widget.borderColor),
          borderRadius: BorderRadius.all(Radius.circular(widget.circularSize)),
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
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: MaterialButton(
        shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(style: BorderStyle.none),
        ),
        onPressed: onPress,
        child: Text(
          uppercase ? text.toUpperCase() : text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: fontSize,
          ),
        ),
      ),
    );
  }
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
    return Text(
      text,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      style: style ?? Theme.of(context).textTheme.bodyMedium,
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
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      child: Text(
        text,
        overflow: overflow,
        maxLines: maxLines,
        style: textStyle,
      ),
    );
  }
}

Future navigateTo(BuildContext context, Widget screen) {
  return Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) {
        return screen;
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
      MaterialPageRoute(
        builder: (BuildContext context) {
          return screen;
        },
      ),
      (route) => false,
    );

class DefaultIconButton extends StatefulWidget {
  final Function onPressed;
  final Icon icon;
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
        final horizontal = width < 360 ? 14.0 : width < 700 ? 20.0 : 30.0;
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: HomeColors.divider),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              SkeletonBox(width: 52, height: 52, radius: 26),
              SizedBox(width: 13),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SkeletonBox(width: 210, height: 16),
                SizedBox(height: 9),
                SkeletonBox(width: 125, height: 11),
              ])),
            ]),
            SizedBox(height: 17),
            Wrap(spacing: 7, runSpacing: 7, children: [
              SkeletonBox(width: 88, height: 27, radius: 9),
              SkeletonBox(width: 74, height: 27, radius: 9),
              SkeletonBox(width: 105, height: 27, radius: 9),
            ]),
            SizedBox(height: 13),
            Row(children: [
              SkeletonBox(width: 62, height: 24, radius: 8),
              SizedBox(width: 6),
              SkeletonBox(width: 76, height: 24, radius: 8),
              Spacer(),
              SkeletonBox(width: 20, height: 12),
            ]),
          ],
        ),
      );
}

class SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({super.key, required this.width, required this.height, this.radius = 6});

  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: const Color(0xFFE9EDF4),
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
              dropdownColor: Colors.white,
              iconEnabledColor: primary,
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
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, color: Colors.white),
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
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hint,
    required this.label,
    required this.icon,
    this.isPassword = false,
    this.controller,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: const TextStyle(fontSize: 14)),

        const SizedBox(height: 8),

        TextField(
          controller: widget.controller,
          obscureText: widget.isPassword ? obscure : false,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Colors.black38),
            prefixIcon: Icon(widget.icon, color: AppColors.primary),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.black45,
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
              borderSide: BorderSide(color: AppColors.border, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }
}
