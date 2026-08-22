import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract final class AppThemeData {
  static const _seed = Color(0xFF18A949);

  static ThemeData light() => _theme(Brightness.light);
  static ThemeData dark() => _theme(Brightness.dark);

  static ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final colors =
        ColorScheme.fromSeed(
          seedColor: _seed,
          brightness: brightness,
          surface: dark ? const Color(0xFF091217) : const Color(0xFFF4F7F6),
        ).copyWith(
          primary: dark ? const Color(0xFF5DE27F) : const Color(0xFF0F9F43),
          secondary: dark ? const Color(0xFF71D8C1) : const Color(0xFF087D68),
          tertiary: dark ? const Color(0xFFFFC867) : const Color(0xFFE88C19),
          surfaceContainer: dark
              ? const Color(0xFF111E24)
              : const Color(0xFFFFFFFF),
          surfaceContainerHighest: dark
              ? const Color(0xFF1A2A31)
              : const Color(0xFFEAF2EE),
        );
    final text = Typography.material2021().black.apply(
      bodyColor: colors.onSurface,
      displayColor: colors.onSurface,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colors,
      scaffoldBackgroundColor: colors.surface,
      canvasColor: colors.surface,
      cardColor: colors.surfaceContainer,
      textTheme: text,
      iconTheme: IconThemeData(color: colors.onSurfaceVariant),
      dividerColor: colors.outlineVariant,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 3,
        backgroundColor: colors.surface,
        foregroundColor: colors.onSurface,
        surfaceTintColor: colors.surface,
        shadowColor: dark ? Colors.black54 : const Color(0x1A1B2831),
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: colors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 6,
        shadowColor: colors.primary.withValues(alpha: dark ? .18 : .14),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: colors.primary.withValues(alpha: .16)),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Colors.black.withValues(alpha: .55),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        showDragHandle: true,
        dragHandleColor: colors.primary.withValues(alpha: .5),
        dragHandleSize: const Size(48, 5),
        elevation: 18,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceContainer,
        indicatorColor: colors.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          text.labelSmall?.copyWith(color: colors.onSurface),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF14242B) : const Color(0xFFFFFFFF),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        floatingLabelStyle: TextStyle(
          color: colors.primary,
          fontWeight: FontWeight.w800,
        ),
        labelStyle: TextStyle(
          color: colors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: TextStyle(color: colors.onSurfaceVariant),
        prefixIconColor: colors.primary,
        suffixIconColor: colors.primary,
        iconColor: colors.onSurfaceVariant,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: colors.outlineVariant.withValues(alpha: .75),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.error.withValues(alpha: .7)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: colors.error, width: 2),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: colors.primary,
        selectionColor: colors.primary.withValues(alpha: .28),
        selectionHandleColor: colors.primary,
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: text.bodyLarge?.copyWith(color: colors.onSurface),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: colors.surfaceContainer,
          hintStyle: TextStyle(color: colors.onSurfaceVariant),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(colors.surfaceContainer),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: colors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: colors.primaryContainer,
        headerForegroundColor: colors.onPrimaryContainer,
        dayForegroundColor: WidgetStatePropertyAll(colors.onSurface),
        weekdayStyle: TextStyle(color: colors.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: colors.surfaceContainer,
        dialBackgroundColor: colors.surfaceContainerHighest,
        dialHandColor: colors.primary,
        hourMinuteColor: colors.primaryContainer,
        hourMinuteTextColor: colors.onPrimaryContainer,
        entryModeIconColor: colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 20,
        shadowColor: Colors.black.withValues(alpha: .3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
        titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w900),
      ),
      listTileTheme: ListTileThemeData(
        textColor: colors.onSurface,
        iconColor: colors.onSurfaceVariant,
        tileColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: colors.primary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          foregroundColor: colors.onPrimary,
          backgroundColor: colors.primary,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors.onPrimary,
          backgroundColor: colors.primary,
          elevation: 6,
          shadowColor: colors.primary.withValues(alpha: .35),
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(0, 50),
          side: BorderSide(color: colors.primary.withValues(alpha: .55)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colors.primary,
          backgroundColor: colors.primaryContainer.withValues(alpha: .45),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.primaryContainer.withValues(alpha: .55),
        selectedColor: colors.primary,
        secondarySelectedColor: colors.secondary,
        labelStyle: text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        side: BorderSide(color: colors.primary.withValues(alpha: .15)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : Colors.transparent,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.onPrimary
              : colors.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? colors.primary
              : colors.surfaceContainerHighest,
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceContainer,
        textStyle: text.bodyMedium?.copyWith(color: colors.onSurface),
        surfaceTintColor: Colors.transparent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        elevation: 8,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        backgroundColor: colors.surfaceContainerHighest,
        contentTextStyle: TextStyle(
          color: colors.onSurface,
          fontSize: 13.5,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: colors.primary,
        closeIconColor: colors.onSurfaceVariant,
        showCloseIcon: true,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }
}
