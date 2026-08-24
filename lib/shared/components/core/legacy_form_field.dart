part of '../components.dart';

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
