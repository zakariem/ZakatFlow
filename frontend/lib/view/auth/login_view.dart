import 'package:flutter/material.dart';
import 'package:frontend/utils/widgets/snackbar/error_scanckbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../utils/constant/validation_utils.dart';
import '../../utils/theme/app_color.dart';
import '../../utils/widgets/auth/auth_field.dart';
import '../../utils/widgets/loader.dart';
import '../../utils/widgets/auth/custom_button.dart';
import '../../viewmodels/auth_view_model.dart';

class LoginView extends HookConsumerWidget {
  const LoginView({super.key});

  static final login = MaterialPageRoute(
    builder: (context) => const LoginView(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVM = ref.read(authProvider.notifier);
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: authState.when(
        data: (_) => _buildLoginForm(context, authVM, ref, screenWidth),
        loading: () => const Loader(),
        error: (error, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            ErrorScanckbar.showSnackBar(context, error.toString());
          });
          return _buildLoginForm(context, authVM, ref, screenWidth);
        },
      ),
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    AuthViewModel authVM,
    WidgetRef ref,
    double screenWidth,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
                child: Form(
                  key: authVM.formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenWidth * 0.1),
                      _buildTitle(screenWidth),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      _buildSubtitle(screenWidth),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      _buildEmailField(authVM),
                      SizedBox(height: constraints.maxHeight * 0.023),
                      _buildPasswordField(authVM),
                      SizedBox(height: constraints.maxHeight * 0.04),
                      _buildSignInButton(context, authVM, ref),
                      SizedBox(height: constraints.maxHeight * 0.04),
                      _buildSignUpPrompt(screenWidth),
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

  Widget _buildTitle(double screenWidth) {
    return Text(
      'Sign In',
      style: GoogleFonts.poppins(
        fontSize: screenWidth * 0.08,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSubtitle(double screenWidth) {
    return Text(
      'Hi, Welcome back, you’ve been missed',
      style: GoogleFonts.poppins(
        fontSize: screenWidth * 0.04,
        color: AppColors.textGray,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildEmailField(AuthViewModel authVM) {
    return AuthField(
      controller: authVM.emailController,
      hintText: 'Email',
      validator: ValidationUtils.validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField(AuthViewModel authVM) {
    return AuthField(
      controller: authVM.passwordController,
      hintText: 'Password',
      isPassword: true,
      obscureText: authVM.isObscure,
      toggleVisibility: authVM.toggleObscure,
      validator: ValidationUtils.validatePassword,
      keyboardType: TextInputType.visiblePassword,
    );
  }

  Widget _buildSignInButton(
    BuildContext context,
    AuthViewModel authVM,
    WidgetRef ref,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(authProvider).isLoading;
        return isLoading
            ? const Loader()
            : CustomButton(
              text: 'Sign In',
              onTap: () async {
                if (authVM.formKey.currentState?.validate() ?? false) {
                  try {
                    await ref
                        .read(authProvider.notifier)
                        .login(
                          authVM.emailController.text,
                          authVM.passwordController.text,
                        );
                  } catch (error) {
                    if (!context.mounted) return;
                    ErrorScanckbar.showSnackBar(context, error.toString());
                    debugPrint("Login error: $error");
                  }
                }
              },
            );
      },
    );
  }

  Widget _buildSignUpPrompt(double screenWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Don\'t have an account? ',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.04,
            color: AppColors.textGray,
          ),
        ),
        InkWell(
          onTap: () {},
          child: Text(
            'Sign Up',
            style: GoogleFonts.poppins(
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
