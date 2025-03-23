import 'package:flutter/material.dart';
import 'package:frontend/utils/widgets/snackbar/error_scanckbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/constant/validation_utils.dart';
import '../../utils/theme/app_color.dart';
import '../../utils/widgets/auth/auth_field.dart';
import '../../utils/widgets/loader.dart';
import '../../utils/widgets/auth/custom_button.dart';
import '../admin_main_screen.dart';
import '../client_main_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (context) => const RegisterScreen());
  }

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isObscure = true;
  bool _isConfirmObscure = true;

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final authVM = ref.read(authViewModelProvider.notifier);
      await authVM.register(
        _emailController.text,
        _passwordController.text,
        _fullNameController.text,
      );

      if (!mounted) return;

      final state = ref.read(authViewModelProvider);

      if (state.user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    state.isAdmin
                        ? const AdminMainScreen()
                        : const ClientMainScreen(),
          ),
        );
      } else {
        ErrorScanckbar.showSnackBar(context, state.error.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(backgroundColor: AppColors.backgroundLight, elevation: 0),
      backgroundColor: AppColors.backgroundLight,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
        child:
            authState.isLoading
                ? const Loader()
                : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: size.height * 0.05),
                                Text(
                                  'Create an account',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.07,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),
                                Text(
                                  'Fill your information below to continue',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.036,
                                    color: AppColors.textGray,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: size.height * 0.04),
                                AuthField(
                                  controller: _fullNameController,
                                  hintText: 'Full Name',
                                  validator: ValidationUtils.validateFullName,
                                  keyboardType: TextInputType.name,
                                ),
                                SizedBox(height: size.height * 0.023),
                                AuthField(
                                  controller: _emailController,
                                  hintText: 'Email',
                                  validator: ValidationUtils.validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: size.height * 0.023),
                                AuthField(
                                  controller: _passwordController,
                                  hintText: 'Password',
                                  isPassword: true,
                                  obscureText: _isObscure,
                                  toggleVisibility: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                  validator: ValidationUtils.validatePassword,
                                  keyboardType: TextInputType.visiblePassword,
                                ),
                                SizedBox(height: size.height * 0.023),
                                AuthField(
                                  controller: _confirmPasswordController,
                                  hintText: 'Confirm Password',
                                  isPassword: true,
                                  obscureText: _isConfirmObscure,
                                  toggleVisibility: () {
                                    setState(() {
                                      _isConfirmObscure = !_isConfirmObscure;
                                    });
                                  },
                                  validator: _validateConfirmPassword,
                                  keyboardType: TextInputType.visiblePassword,
                                  textInputAction: TextInputAction.done,
                                ),
                                SizedBox(height: size.height * 0.04),
                                CustomButton(
                                  text: 'Register',
                                  onTap: _register,
                                ),
                                SizedBox(height: size.height * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Already have an account? ",
                                      style: GoogleFonts.poppins(
                                        fontSize: size.width * 0.04,
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => Navigator.pop(context),
                                      child: Text(
                                        'Sign In',
                                        style: GoogleFonts.poppins(
                                          fontSize: size.width * 0.04,
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
                    );
                  },
                ),
      ),
    );
  }
}
