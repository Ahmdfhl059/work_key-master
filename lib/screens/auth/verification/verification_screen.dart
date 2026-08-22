import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../../../logic/auth_cubit/auth_cubit.dart';
import '../../../logic/auth_cubit/auth_state.dart';
import '../../../layout/layout.dart';
import '../../../localization/app_localizations.dart';
import '../../../shared/components/components.dart';
import '../../../shared/components/app_snackbar.dart';
import '../../../utils/constants.dart';
import 'reset_password_screen.dart';

enum VerificationFlow { account, resetPassword }

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final VerificationFlow flow;
  final String? loginPassword;
  final bool sendAccountCodeOnOpen;

  const VerificationCodeScreen({
    super.key,
    required this.email,
    this.flow = VerificationFlow.resetPassword,
    this.loginPassword,
    this.sendAccountCodeOnOpen = false,
  });

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final _codeController = TextEditingController();
  late final PinInputController _pinController;
  Timer? _timer;
  int _remainingSeconds = 60;

  bool get _isReset => widget.flow == VerificationFlow.resetPassword;

  @override
  void initState() {
    super.initState();
    _pinController = PinInputController(textController: _codeController);
    _startTimer();
    if (widget.flow == VerificationFlow.account &&
        widget.sendAccountCodeOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _sendAccountCode();
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _remainingSeconds = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String get _maskedEmail {
    final parts = widget.email.split('@');
    if (parts.length != 2 || parts.first.isEmpty) return widget.email;
    final name = parts.first;
    final shownLength = name.length.clamp(1, 2);
    final shown = name.substring(0, shownLength);
    final hiddenLength = (name.length - shown.length).clamp(2, 8);
    return '$shown${List.filled(hiddenLength, '•').join()}@${parts.last}';
  }

  void _showMessage(String message, {bool error = false}) {
    if (error) {
      AppSnackBar.error(context, message);
    } else {
      AppSnackBar.success(context, message);
    }
  }

  void _resend() {
    if (_remainingSeconds > 0) return;
    if (!_isReset) {
      _sendAccountCode();
      _startTimer();
      return;
    }
    AuthCubit.get(context).forgotPassword(email: widget.email);
    _startTimer();
  }

  void _sendAccountCode() {
    final password = widget.loginPassword;
    if (password == null || password.isEmpty) {
      _showMessage(context.tr('verification.sign_in_resend'), error: true);
      return;
    }
    AuthCubit.get(
      context,
    ).resendAccountVerification(email: widget.email, password: password);
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_codeController.text.length != 6) {
      _showMessage(context.tr('verification.enter_six_digits'), error: true);
      return;
    }

    if (!_isReset) {
      final password = widget.loginPassword;
      if (password == null || password.isEmpty) {
        _showMessage(context.tr('verification.sign_in_complete'), error: true);
        return;
      }
      AuthCubit.get(context).verifyAccountEmail(
        email: widget.email,
        password: password,
        otp: _codeController.text,
      );
      return;
    }

    navigateTo(
      context,
      ResetPasswordScreen(
        email: widget.email,
        verificationCode: _codeController.text,
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
      listener: (context, state) {
        if (state is ForgotPasswordSuccessState) {
          _showMessage(context.tr('verification.new_code_sent'));
        } else if (state is AccountVerificationCodeSentState) {
          _showMessage(state.message);
        } else if (state is AuthSuccessState && !_isReset) {
          if (state.userModel.emailVerified) {
            _showMessage(context.tr('verification.email_verified'));
            navigateAndFinish(context, const Layout());
          } else {
            _showMessage(context.tr('verification.invalid_code'), error: true);
          }
        } else if (state is AuthErrorState) {
          _showMessage(state.error, error: true);
        }
      },
      builder: (context, state) {
        final loading = state is AuthLoadingState;
        final colors = Theme.of(context).colorScheme;
        return PopScope(
          canPop: _isReset && !loading,
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: _isReset,
              leading: _isReset
                  ? IconButton(
                      onPressed: loading ? null : () => Navigator.pop(context),
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                      ),
                    )
                  : null,
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
                        const _VerificationIllustration(),
                        const SizedBox(height: 26),
                        Text(
                          context.tr(
                            _isReset
                                ? 'verification.reset_title'
                                : 'verification.email_title',
                          ),
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
                          context.tr(
                            'verification.sent_to',
                            values: {'email': _maskedEmail},
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.onSurfaceVariant,
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: MaterialPinField(
                            length: 6,
                            pinController: _pinController,
                            enabled: !loading,
                            autoFocus: true,
                            autoDismissKeyboard: true,
                            keyboardType: TextInputType.number,
                            theme: MaterialPinTheme(
                              shape: MaterialPinShape.outlined,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(14),
                              ),
                              cellSize: const Size(46, 54),
                              borderWidth: 1.3,
                              fillColor: colors.surfaceContainer,
                              followingFillColor: colors.surfaceContainer,
                              focusedFillColor: colors.primaryContainer
                                  .withValues(alpha: .55),
                              filledFillColor: colors.surfaceContainer,
                              borderColor: colors.outlineVariant,
                              focusedBorderColor: colors.primary,
                              filledBorderColor: colors.primary,
                              errorBorderColor: Colors.red.shade400,
                              cursorColor: colors.primary,
                              textStyle: TextStyle(
                                color: colors.onSurface,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                              entryAnimation: MaterialPinAnimation.scale,
                              animationDuration: const Duration(
                                milliseconds: 220,
                              ),
                            ),
                            onCompleted: (_) {
                              if (!_isReset) _submit();
                            },
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _remainingSeconds > 0
                              ? Text(
                                  context.tr(
                                    'verification.resend_in',
                                    values: {
                                      'time':
                                          '00:${_remainingSeconds.toString().padLeft(2, '0')}',
                                    },
                                  ),
                                  key: ValueKey(_remainingSeconds),
                                  style: TextStyle(
                                    color: colors.onSurfaceVariant,
                                    fontSize: 13,
                                  ),
                                )
                              : TextButton.icon(
                                  key: const ValueKey('resend'),
                                  onPressed: loading ? null : _resend,
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 18,
                                  ),
                                  label: Text(
                                    context.tr('verification.resend_new'),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 26),
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
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: loading
                                  ? SizedBox(
                                      key: ValueKey('loading'),
                                      width: 23,
                                      height: 23,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: colors.onPrimary,
                                      ),
                                    )
                                  : Text(
                                      context.tr(
                                        _isReset
                                            ? 'common.continue'
                                            : 'verification.verify_account',
                                      ),
                                      key: const ValueKey('label'),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
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
          ),
        );
      },
    );
  }
}

class _VerificationIllustration extends StatelessWidget {
  const _VerificationIllustration();

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: .75, end: 1),
    duration: const Duration(milliseconds: 650),
    curve: Curves.easeOutBack,
    builder: (_, value, child) => Transform.scale(scale: value, child: child),
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
        Icons.mark_email_read_rounded,
        color: Colors.white,
        size: 42,
      ),
    ),
  );
}
