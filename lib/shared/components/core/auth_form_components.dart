part of '../components.dart';

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
