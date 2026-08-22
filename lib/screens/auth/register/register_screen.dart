import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:work_key/logic/auth_cubit/auth_cubit.dart';
import 'package:work_key/logic/auth_cubit/auth_state.dart';
import 'package:work_key/localization/app_localizations.dart';
import 'package:work_key/screens/auth/verification/verification_screen.dart';
import 'package:work_key/shared/components/components.dart';
import 'package:work_key/shared/components/app_snackbar.dart';
import '../login/login_screen.dart';
import 'widgets/register_header.dart';
import '../widgets/guest_access_button.dart';
import '../../../data/models/city_model.dart';
import '../../../data/repo/reference_repo.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  late final Future<List<CityModel>> cities = ReferenceRepo().getCities();
  int? selectedCityId;

  @override
  void dispose() {
    for (final controller in [
      emailController,
      nameController,
      phoneController,
      locationController,
      passwordController,
      confirmPasswordController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is AuthSuccessState) {
          print('--- UI Success: Account Created ---');
          AppSnackBar.success(
            context,
            state.userModel.message ?? 'Success',
            title: 'Account created',
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => VerificationCodeScreen(
                email: emailController.text.trim(),
                flow: VerificationFlow.account,
                loginPassword: passwordController.text,
              ),
            ),
          );
        } else if (state is AuthErrorState) {
          print('--- UI Error: Registration Failed: ${state.error} ---');
          AppSnackBar.error(context, state.error, title: 'Registration failed');
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
                      keyboardType: TextInputType.phone,
                      label: "Phone Number",
                      hint: "+963 9xx xxx xxx",
                      icon: Icons.phone_android_rounded,
                    ),

                    FutureBuilder<List<CityModel>>(
                      future: cities,
                      builder: (context, snapshot) {
                        final options = snapshot.data ?? const <CityModel>[];
                        return DropdownButtonFormField<int>(
                          initialValue: selectedCityId,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: context.tr('profile.city'),
                            prefixIcon: const Icon(Icons.location_city_rounded),
                            suffixIcon:
                                snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? const Padding(
                                    padding: EdgeInsets.all(14),
                                    child: SizedBox.square(
                                      dimension: 17,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          items: options
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city.id,
                                  child: Text(city.name),
                                ),
                              )
                              .toList(),
                          onChanged: options.isEmpty
                              ? null
                              : (value) =>
                                    setState(() => selectedCityId = value),
                        );
                      },
                    ),
                    SizedBox(height: 16,),
                    CustomTextField(
                      controller: locationController,
                      label: context.tr('profile.location_details'),
                      hint: context.tr('profile.location_hint'),
                      icon: Icons.pin_drop_outlined,
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
                                AppSnackBar.warning(
                                  context,
                                  'Please fill in all fields',
                                  title: 'Missing information',
                                );
                                return;
                              }

                              // 2. التحقق من تطابق كلمة المرور
                              if (passwordController.text !=
                                  confirmPasswordController.text) {
                                print(
                                  '--- UI Validation Failed: Password Mismatch ---',
                                );
                                AppSnackBar.warning(
                                  context,
                                  'Passwords do not match',
                                  title: 'Check your password',
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
                                location: locationController.text,
                                cityId: selectedCityId,
                              );
                            },
                          ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: DefaultText(
                            text: "OR",
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
                          text: "Do you have an account?",
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                        DefaultTextButton(
                          onPressed: () {
                            navigateTo(context, const LoginScreen());
                          },
                          text: "Login",
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
