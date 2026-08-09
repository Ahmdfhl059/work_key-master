import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/logic/auth_cubit/auth_cubit.dart';
import 'package:work_key/logic/auth_cubit/auth_state.dart';
import 'package:work_key/screens/auth/verification/verification_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import '../login/login_screen.dart';
import 'widgets/register_header.dart';
import '../widgets/guest_access_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var emailController = TextEditingController();
    var nameController = TextEditingController();
    var phoneController = TextEditingController();
    var passwordController = TextEditingController();
    var confirmPasswordController = TextEditingController();

    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthSuccessState) {
          print('--- UI Success: Account Created ---');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.userModel.message ?? 'Success'),
              backgroundColor: Colors.green,
            ),
          );
          navigateTo(
            context,
            VerificationCodeScreen(email: emailController.text.trim()),
          );
        } else if (state is AuthErrorState) {
          print('--- UI Error: Registration Failed: ${state.error} ---');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FD),
          body: SafeArea(
            child: ResponsiveContent(
              maxWidth: 520,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    const RegisterHeader(),

                    const SizedBox(height: 30),

                    CustomTextField(
                      controller: nameController,
                      label: "Full Name",
                      hint: "Ex. Jane Doe",
                      icon: Icons.person_outline_rounded,
                    ),

                    CustomTextField(
                      controller: emailController,
                      label: "Email Address",
                      hint: "abc@example.com",
                      icon: Icons.alternate_email_rounded,
                    ),

                    CustomTextField(
                      controller: phoneController,
                      label: "Phone Number",
                      hint: "+963 9xx xxx xxx",
                      icon: Icons.phone_android_rounded,
                    ),

                    CustomTextField(
                      controller: passwordController,
                      label: "Password",
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),

                    CustomTextField(
                      controller: confirmPasswordController,
                      label: "Confirm Password",
                      hint: "••••••••",
                      icon: Icons.lock_outline_rounded,
                      isPassword: true,
                    ),

                    const SizedBox(height: 20),

                    state is AuthLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: "Register",
                            onPressed: () {
                              print(
                                '--- UI Action: Register Button Pressed ---',
                              );
                              // 1. التحقق من ملئ كافة الحقول
                              if (nameController.text.isEmpty ||
                                  emailController.text.isEmpty ||
                                  phoneController.text.isEmpty ||
                                  passwordController.text.isEmpty) {
                                print(
                                  '--- UI Validation Failed: Empty Fields ---',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill in all fields'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              // 2. التحقق من تطابق كلمة المرور
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                print(
                                  '--- UI Validation Failed: Password Mismatch ---',
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Passwords do not match'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                                return;
                              }

                              print(
                                '--- UI: Validation Passed. Calling Cubit ---',
                              );
                              AuthCubit.get(context).registerJobSeeker(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                phone: phoneController.text.trim(),
                                password: passwordController.text,
                                passwordConfirmation:
                                    confirmPasswordController.text,
                              );
                            },
                          ),
                    const SizedBox(height: 30),
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: DefaultText(
                            text: "OR",
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const GuestAccessButton(),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DefaultText(
                          text: "Do you have an account?",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        DefaultTextButton(
                          onPressed: () {
                            navigateTo(context, const LoginScreen());
                          },
                          text: "Login",
                          textStyle: TextStyle(
                            color: primary,
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
