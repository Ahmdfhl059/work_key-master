import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/layout/layout.dart';
import 'package:work_key/logic/auth_cubit/auth_cubit.dart';
import 'package:work_key/logic/auth_cubit/auth_state.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/shared/components/app_snackbar.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../register/register_screen.dart';
import '../verification/verification_screen.dart';
import 'widgets/login_header.dart';
import '../widgets/guest_access_button.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var passwordController = TextEditingController();

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthSuccessState) {
          print('--- UI Success: User Logged In ---');
          if (!state.userModel.emailVerified) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => VerificationCodeScreen(
                  email: emailController.text.trim(),
                  flow: VerificationFlow.account,
                  loginPassword: passwordController.text,
                  sendAccountCodeOnOpen: true,
                ),
              ),
            );
            return;
          }
          AppSnackBar.success(
            context,
            context.tr('auth.login_success_message'),
            title: context.tr('auth.welcome_back'),
          );
          navigateAndFinish(context, const Layout());
        } else if (state is AuthErrorState) {
          print('--- UI Error: ${state.error} ---');
          if (_requiresEmailVerification(state.error)) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => VerificationCodeScreen(
                  email: emailController.text.trim(),
                  flow: VerificationFlow.account,
                  loginPassword: passwordController.text,
                  sendAccountCodeOnOpen: true,
                ),
              ),
            );
          } else {
            AppSnackBar.error(
              context,
              state.error,
              title: context.tr('auth.login_failed'),
            );
          }
        }
      },
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: ResponsiveContent(
              maxWidth: 520,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 30),
                    const LoginHeader(),
                    const SizedBox(height: 40),
                    CustomTextField(
                      controller: emailController,
                      label: context.tr('auth.email'),
                      hint: "abc@example.com",
                      icon: Icons.alternate_email_rounded,
                    ),
                    CustomTextField(
                      controller: passwordController,
                      label: context.tr('auth.password'),
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: DefaultTextButton(
                        onPressed: () {
                          navigateTo(context, const ForgotPasswordScreen());
                        },
                        text: context.tr('auth.forgot_password'),
                        textStyle: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    state is AuthLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: context.tr('auth.login'),
                            onPressed: () {
                              if (emailController.text.trim().isEmpty ||
                                  passwordController.text.isEmpty) {
                                AppSnackBar.warning(
                                  context,
                                  context.tr('auth.fill_all_fields'),
                                  title: context.tr('auth.missing_information'),
                                );
                              } else {
                                AuthCubit.get(context).login(
                                  email: emailController.text.trim(),
                                  password: passwordController.text,
                                );
                              }
                            },
                          ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: DefaultText(
                            text: context.tr('auth.or'),
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const GuestAccessButton(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DefaultText(
                          text: context.tr('auth.new_here'),
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        DefaultTextButton(
                          onPressed: () {
                            navigateTo(context, const RegisterScreen());
                          },
                          text: context.tr('auth.create_account'),
                          textStyle: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

bool _requiresEmailVerification(String message) {
  final value = message.toLowerCase();
  return value.contains('email not verified') ||
      value.contains('email_not_verified') ||
      value.contains('email is not verified') ||
      value.contains('email must be verified') ||
      value.contains('email verification') ||
      value.contains('verify your email') ||
      value.contains('verification required') ||
      value.contains('unverified') ||
      value.contains('غير متحقق') ||
      value.contains('غير موثق') ||
      value.contains('غير مفعّل') ||
      value.contains('البريد الإلكتروني غير مؤكد') ||
      value.contains('البريد غير مؤكد') ||
      value.contains('البريد غير مفعل') ||
      value.contains('تفعيل البريد') ||
      value.contains('تحقق من بريدك');
}
