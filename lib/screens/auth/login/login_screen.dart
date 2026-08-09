import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/layout/layout.dart';
import 'package:work_key/logic/auth_cubit/auth_cubit.dart';
import 'package:work_key/logic/auth_cubit/auth_state.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/utils/constants.dart';
import '../forgot_password/forgot_password_screen.dart';
import '../register/register_screen.dart';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: DefaultText(
                text: state.userModel.message ?? 'Login Successful',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          navigateAndFinish(context, const Layout());
        } else if (state is AuthErrorState) {
          print('--- UI Error: ${state.error} ---');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: DefaultText(
                text: state.error,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
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
                    const SizedBox(height: 30),
                    const LoginHeader(),
                    const SizedBox(height: 40),
                    CustomTextField(
                      controller: emailController,
                      label: "Email Address",
                      hint: "abc@example.com",
                      icon: Icons.alternate_email_rounded,
                    ),
                    CustomTextField(
                      controller: passwordController,
                      label: "Password",
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
                        text: "Forgot Password?",
                        textStyle: TextStyle(
                            color: primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 25),
                    state is AuthLoadingState
                        ? const Center(child: CircularProgressIndicator())
                        : CustomButton(
                            text: "Login",
                            onPressed: () {
                              if (emailController.text.trim().isEmpty ||
                                  passwordController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Please fill all fields'),
                                      backgroundColor: Colors.orange),
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
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: DefaultText(text: "OR", style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                            text: "New here? ",
                            style: TextStyle(color: Colors.grey.shade600)),
                        DefaultTextButton(
                          onPressed: () {
                            navigateTo(context, const RegisterScreen());
                          },
                          text: "Create Account",
                          textStyle: TextStyle(
                              color: primary, fontWeight: FontWeight.w900),
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
