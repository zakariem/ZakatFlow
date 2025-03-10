import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../utils/constant/validation_utils.dart';
import '../../utils/theme/app_color.dart';
import '../../utils/widgets/auth/auth_field.dart';
import '../../utils/widgets/loader.dart';
import '../../utils/widgets/auth/custom_button.dart';
import '../../viewmodels/auth_view_model.dart';

class RegisterView extends HookConsumerWidget {
  const RegisterView({super.key});
  static final register = MaterialPageRoute(
    builder: (context) => RegisterView(),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authVM = ref.watch(authProvider.notifier);
    final authState = ref.watch(authProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: authState.when(
        data: (user) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(screenWidth * 0.1),
                      child: Form(
                        key: authVM.formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: screenWidth * 0.1),
                            Text(
                              'Create Account',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.08,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: constraints.maxHeight * 0.02),
                            Text(
                              'Fill your information below or register \nwith your social account',
                              style: GoogleFonts.poppins(
                                fontSize: screenWidth * 0.04,
                                color: AppColors.textGray,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.05),
                            AuthField(
                              controller: authVM.fullNameController,
                              hintText: 'Full Name',
                              validator: ValidationUtils.validateFullName,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.023),
                            AuthField(
                              controller: authVM.emailController,
                              hintText: 'Email',
                              validator: ValidationUtils.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.023),
                            AuthField(
                              controller: authVM.passwordController,
                              hintText: 'Password',
                              toggleVisibility: authVM.toggleObscure,
                              isPassword: true,
                              obscureText: authVM.isObscure,
                              validator: ValidationUtils.validatePassword,
                              keyboardType: TextInputType.visiblePassword,
                            ),
                            SizedBox(height: constraints.maxHeight * 0.04),
                            authState.isLoading
                                ? Loader()
                                : CustomButton(
                                  text: 'Sign In',
                                  onTap: () async {
                                    final email = authVM.emailController.text;
                                    final password =
                                        authVM.passwordController.text;

                                    if (authVM.formKey.currentState!
                                        .validate()) {
                                      try {
                                        await ref
                                            .read(authProvider.notifier)
                                            .login(email, password);
                                      } catch (e) {
                                        SnackBar(
                                          content: Text(
                                            e.toString(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          backgroundColor:
                                              AppColors.accentDarkGold,
                                          duration: const Duration(seconds: 3),
                                          behavior: SnackBarBehavior.floating,
                                          margin: const EdgeInsets.all(16.0),
                                        );
                                        debugPrint("Login error: $e");
                                      }
                                    }
                                  },
                                ),

                            SizedBox(height: constraints.maxHeight * 0.04),
                            Row(
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
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => Loader(),
        error:
            (error, _) => Center(
              child: Text(
                error.toString(),
                style: TextStyle(
                  color: AppColors.accentDarkGold,
                  fontSize: 16.0,
                ),
              ),
            ),
      ),
    );
  }
}
