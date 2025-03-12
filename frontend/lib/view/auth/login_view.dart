import 'package:flutter/material.dart';
import 'package:frontend/utils/widgets/snackbar/error_scanckbar.dart';
import 'package:frontend/view/auth/register_view.dart';
import 'package:frontend/viewmodels/auth/login_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../utils/constant/validation_utils.dart';
import '../../utils/theme/app_color.dart';
import '../../utils/widgets/auth/auth_field.dart';
import '../../utils/widgets/loader.dart';
import '../../utils/widgets/auth/custom_button.dart';

class LoginView extends HookConsumerWidget {
  LoginView({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (context) => LoginView());
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loginVM = ref.read(loginProvider.notifier);
    final authState = ref.watch(loginProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: authState.when(
        data: (_) => _buildLoginForm(context, loginVM, ref, screenWidth),
        loading: () => const Loader(),
        error: (error, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            Future.delayed(const Duration(milliseconds: 200), () {
              ErrorScanckbar.showSnackBar(context, error.toString());
              ref.read(loginProvider.notifier).clearError();
            });
          });
          return _buildLoginForm(context, loginVM, ref, screenWidth);
        },
      ),
    );
  }

  Widget _buildLoginForm(
    BuildContext context,
    LoginViewModel loginVM,
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
                  key: formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: screenWidth * 0.1),
                      _buildTitle(screenWidth),
                      SizedBox(height: constraints.maxHeight * 0.02),
                      _buildSubtitle(screenWidth),
                      SizedBox(height: constraints.maxHeight * 0.05),
                      _buildEmailField(loginVM),
                      SizedBox(height: constraints.maxHeight * 0.023),
                      _buildPasswordField(loginVM),
                      SizedBox(height: constraints.maxHeight * 0.04),
                      _buildSignInButton(context, loginVM, ref),
                      SizedBox(height: constraints.maxHeight * 0.04),
                      _buildSignUpPrompt(screenWidth, context),
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

  Widget _buildEmailField(LoginViewModel loginVM) {
    return AuthField(
      controller: loginVM.emailController,
      hintText: 'Email',
      validator: ValidationUtils.validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField(LoginViewModel loginVM) {
    return AuthField(
      controller: loginVM.passwordController,
      hintText: 'Password',
      isPassword: true,
      obscureText: loginVM.isObscure,
      toggleVisibility: loginVM.toggleObscure,
      validator: ValidationUtils.validatePassword,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildSignInButton(
    BuildContext context,
    LoginViewModel loginVM,
    WidgetRef ref,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(loginProvider).isLoading;
        return isLoading
            ? const Loader()
            : CustomButton(
              text: 'Sign In',
              onTap: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    await ref.read(loginProvider.notifier).login(context);
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

  Widget _buildSignUpPrompt(double screenWidth, BuildContext context) {
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
          onTap: () => Navigator.push(context, RegisterView.route()),
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
