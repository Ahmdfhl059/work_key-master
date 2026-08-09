import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/logic/auth_cubit/auth_cubit.dart';
import 'package:work_key/logic/auth_cubit/auth_state.dart';
import 'package:work_key/screens/auth/login/login_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'widgets/new_password_section.dart';
import 'widgets/pin_code_section.dart';
import 'widgets/resend_code_section.dart';
import 'widgets/verification_header.dart';

class VerificationCodeScreen extends StatelessWidget {
  final String email;

  const VerificationCodeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    var codeController = TextEditingController();
    var passwordController = TextEditingController();
    var confirmPasswordController = TextEditingController();

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is ResetPasswordSuccessState) {
          print('--- UI: Password Reset Successful for $email ---');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: DefaultText(text: state.message, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.green,
            ),
          );
          navigateAndFinish(context, const LoginScreen());
        } else if (state is AuthErrorState) {
          print('--- UI ERROR: Reset Password Flow Failed: ${state.error} ---');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: DefaultText(text: state.error, style: const TextStyle(color: Colors.white)),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
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
                      backgroundColor: Colors.white,
                      child: DefaultIconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 18),
                      ),
                    ),
                    const SizedBox(height: 40),
                    const VerificationHeader(),
                    const SizedBox(height: 40),

                    // Pin Code Input Widgets
                    PinCodeSection(controller: codeController),

                    const SizedBox(height: 10),

                    // Resend Logic
                    ResendCodeSection(onResend: () {
                      print('--- UI: Resend Code Pressed for $email ---');
                      AuthCubit.get(context).forgotPassword(email: email);
                    }),

                    const SizedBox(height: 25),

                    // New Password Widgets
                    NewPasswordSection(
                      passwordController: passwordController,
                      confirmPasswordController: confirmPasswordController,
                    ),

                    const SizedBox(height: 30),

                    // Action Button with Validation
                    state is AuthLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: "Verify & Reset Password",
                            onPressed: () {
                              print('--- UI: Reset Password Button Pressed ---');
                              
                              if (codeController.text.length < 6) {
                                print('--- UI VALIDATION: Code is incomplete ---');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter the 6-digit code'), backgroundColor: Colors.orange),
                                );
                                return;
                              }

                              if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
                                print('--- UI VALIDATION: Password fields are empty ---');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please enter and confirm your new password'), backgroundColor: Colors.orange),
                                );
                                return;
                              }

                              if (passwordController.text != confirmPasswordController.text) {
                                print('--- UI VALIDATION: Passwords do not match ---');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.orange),
                                );
                                return;
                              }

                              print('--- UI: All Valid. Calling resetPassword API ---');
                              AuthCubit.get(context).resetPassword(
                                email: email,
                                token: codeController.text,
                                password: passwordController.text,
                                passwordConfirmation: confirmPasswordController.text,
                              );
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
