import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/logic/auth_cubit/auth_cubit.dart';
import 'package:work_key/logic/auth_cubit/auth_state.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/shared/components/app_snackbar.dart';
import '../verification/verification_screen.dart';
import 'widgets/forgot_password_header.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccessState) {
          print(
            '--- UI: Forgot Password Success. Code Sent to ${emailController.text} ---',
          );
          AppSnackBar.success(context, state.message, title: 'Code sent');
          navigateTo(
            context,
            VerificationCodeScreen(email: emailController.text.trim()),
          );
        } else if (state is AuthErrorState) {
          print(
            '--- UI ERROR: Forgot Password Flow Failed: ${state.error} ---',
          );
          AppSnackBar.error(context, state.error, title: 'Could not send code');
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.surfaceContainer,
                      child: DefaultIconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Center(
                      child: Image.asset(
                        "assets/images/forget_passemail.png",
                        height: 220,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const ForgotPasswordHeader(),
                    const SizedBox(height: 40),
                    CustomTextField(
                      controller: emailController,
                      label: "Email Address",
                      hint: "abc@example.com",
                      icon: Icons.alternate_email_rounded,
                    ),
                    const SizedBox(height: 25),

                    state is AuthLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: "Send Verification Code",
                            onPressed: () {
                              print('--- UI: Send Code Button Pressed ---');
                              if (emailController.text.trim().isEmpty) {
                                print(
                                  '--- UI VALIDATION: Email field is empty ---',
                                );
                                AppSnackBar.warning(
                                  context,
                                  'Please enter your email address',
                                  title: 'Email required',
                                );
                              } else {
                                print(
                                  '--- UI: Valid Email. Calling forgotPassword API ---',
                                );
                                AuthCubit.get(context).forgotPassword(
                                  email: emailController.text.trim(),
                                );
                              }
                            },
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
