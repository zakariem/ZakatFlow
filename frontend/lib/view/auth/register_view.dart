import 'package:flutter/material.dart';
import 'package:frontend/utils/widgets/snackbar/error_scanckbar.dart';
import 'package:frontend/viewmodels/auth/register_view_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../utils/constant/validation_utils.dart';
import '../../utils/theme/app_color.dart';
import '../../utils/widgets/auth/auth_field.dart';
import '../../utils/widgets/loader.dart';
import '../../utils/widgets/auth/custom_button.dart';
import '../home/home_view.dart';

class RegisterView extends HookConsumerWidget {
  RegisterView({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (context) => RegisterView());
  }

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registerVM = ref.read(registerProvider.notifier);
    final authState = ref.watch(registerProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.backgroundLight),
      backgroundColor: AppColors.backgroundLight,
      body: authState.when(
        data: (_) => _buildRegisterForm(context, registerVM, ref, screenWidth),
        loading: () => const Loader(),
        error: (error, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            ErrorScanckbar.showSnackBar(context, error.toString());
            ref.read(registerProvider.notifier).clearError();
          });
          return _buildRegisterForm(context, registerVM, ref, screenWidth);
        },
      ),
    );
  }

  Widget _buildRegisterForm(
    BuildContext context,
    RegisterViewModel registerVM,
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
                      _buildFullNameField(registerVM),
                      SizedBox(height: constraints.maxHeight * 0.023),
                      _buildEmailField(registerVM),
                      SizedBox(height: constraints.maxHeight * 0.023),
                      _buildPasswordField(registerVM),
                      SizedBox(height: constraints.maxHeight * 0.04),
                      _buildConfirmPasswordField(registerVM),
                      SizedBox(height: constraints.maxHeight * 0.04),
                      _buildSignUpButton(context, registerVM, ref),
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
      'Create Account',
      style: GoogleFonts.poppins(
        fontSize: screenWidth * 0.08,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSubtitle(double screenWidth) {
    return Text(
      'Fill your information below to continue',
      style: GoogleFonts.poppins(
        fontSize: screenWidth * 0.04,
        color: AppColors.textGray,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildFullNameField(RegisterViewModel registerVM) {
    return AuthField(
      controller: registerVM.fullNameController,
      hintText: 'Full Name',
      validator: ValidationUtils.validateFullName,
    );
  }

  Widget _buildEmailField(RegisterViewModel registerVM) {
    return AuthField(
      controller: registerVM.emailController,
      hintText: 'Email',
      validator: ValidationUtils.validateEmail,
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildPasswordField(RegisterViewModel registerVM) {
    return AuthField(
      controller: registerVM.passwordController,
      hintText: 'Password',
      isPassword: true,
      obscureText: registerVM.isObscure,
      toggleVisibility: registerVM.toggleObscure,
      validator: ValidationUtils.validatePassword,
      keyboardType: TextInputType.visiblePassword,
    );
  }

  Widget _buildConfirmPasswordField(RegisterViewModel registerVM) {
    return AuthField(
      controller: registerVM.confirmPasswordController,
      hintText: 'Confirm Password',
      isPassword: true,
      obscureText: registerVM.isObscure,
      toggleVisibility: registerVM.toggleObscure,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value != registerVM.passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildSignUpButton(
    BuildContext context,
    RegisterViewModel registerVM,
    WidgetRef ref,
  ) {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(registerProvider).isLoading;
        return isLoading
            ? const Loader()
            : CustomButton(
              text: 'Register',
              onTap: () async {
                if (formKey.currentState?.validate() ?? false) {
                  try {
                    final error = await ref
                        .read(registerProvider.notifier)
                        .register(context);
                    if (error != null) {
                      if (!context.mounted) return;
                      ErrorScanckbar.showSnackBar(context, error.toString());
                    } else {
                      if (!context.mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeView(),
                        ),
                        (route) => false,
                      );
                    }
                  } catch (error) {
                    if (!context.mounted) return;
                    ErrorScanckbar.showSnackBar(context, error.toString());
                    debugPrint("Register error: $error");
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
          'Already have an account? ',
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.04,
            color: AppColors.textGray,
          ),
        ),
        InkWell(
          onTap: () => Navigator.pop(context),
          child: Text(
            'Sign In',
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
