import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../../../localization/app_localizations.dart';
import '../../../shared/components/app_snackbar.dart';
import '../../../shared/components/components.dart';
import '../../../utils/constants.dart';
import '../login/login_screen.dart';
import 'widgets/new_password_section.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_passwordController.text.length < 8) {
      AppSnackBar.warning(
        context,
        context.tr('reset_password.min_length'),
        title: context.tr('reset_password.too_short'),
      );
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      AppSnackBar.warning(
        context,
        context.tr('reset_password.mismatch'),
        title: context.tr('reset_password.check_password'),
      );
      return;
    }
    AuthCubit.get(context).resetPassword(
      email: widget.email,
      otp: widget.verificationCode,
      password: _passwordController.text,
      passwordConfirmation: _confirmPasswordController.text,
    );
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<AuthCubit, AuthStates>(
    listener: (context, state) {
      if (state is ResetPasswordSuccessState) {
        AppSnackBar.success(
          context,
          state.message,
          title: context.tr('reset_password.updated'),
        );
        navigateAndFinish(context, const LoginScreen());
      } else if (state is AuthErrorState) {
        AppSnackBar.error(
          context,
          state.error,
          title: context.tr('reset_password.failed'),
        );
      }
    },
    builder: (context, state) {
      final loading = state is AuthLoadingState;
      final colors = Theme.of(context).colorScheme;
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: loading ? null : () => Navigator.pop(context),
            icon: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_forward_rounded
                  : Icons.arrow_back_rounded,
            ),
          ),
        ),
        body: SafeArea(
          top: false,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: .75, end: 1),
                      duration: const Duration(milliseconds: 650),
                      curve: Curves.easeOutBack,
                      builder: (_, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [HomeColors.brand, HomeColors.purple],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: HomeColors.brand.withValues(alpha: .22),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    Text(
                      context.tr('reset_password.title'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurface,
                        fontSize: 27,
                        height: 1.2,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.tr('reset_password.subtitle'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 14,
                        height: 1.55,
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colors.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: colors.shadow.withValues(
                              alpha:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? .28
                                  : .08,
                            ),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: NewPasswordSection(
                        passwordController: _passwordController,
                        confirmPasswordController: _confirmPasswordController,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 17,
                          color: HomeColors.accent,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            context.tr('reset_password.security_hint'),
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.primary,
                          foregroundColor: colors.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: loading
                            ? SizedBox(
                                width: 23,
                                height: 23,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: colors.onPrimary,
                                ),
                              )
                            : Text(
                                context.tr('reset_password.save'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
