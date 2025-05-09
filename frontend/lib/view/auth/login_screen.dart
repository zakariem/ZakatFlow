import 'package:flutter/material.dart';
import 'package:frontend/utils/widgets/snackbar/error_scanckbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../utils/constant/validation_utils.dart';
import '../../utils/theme/app_color.dart';
import '../../utils/widgets/custom/custom_field.dart';
import '../../utils/widgets/loader.dart';
import '../../utils/widgets/custom/custom_button.dart';
import '../admin_main_screen.dart';
import '../client_main_screen.dart';
import 'register_view.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (context) => const LoginScreen());
  }

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isObscure = true;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final authVM = ref.read(authViewModelProvider.notifier);
      await authVM.login(_emailController.text, _passwordController.text);

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
                                  'Soo gal',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.08,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: size.height * 0.02),
                                Text(
                                  'Salaan, ku soo dhawoow mar kale, waan kuu xiiseynay',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.04,
                                    color: AppColors.textGray,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: size.height * 0.05),
                                CustomField(
                                  controller: _emailController,
                                  hintText: 'Email',
                                  validator: ValidationUtils.validateEmail,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                SizedBox(height: size.height * 0.023),
                                CustomField(
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
                                  textInputAction: TextInputAction.done,
                                ),
                                SizedBox(height: size.height * 0.04),
                                CustomButton(text: 'Soo gal', onTap: _login),
                                SizedBox(height: size.height * 0.02),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Ma lihid akoonto? ",
                                      style: GoogleFonts.poppins(
                                        fontSize: size.width * 0.04,
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                    InkWell(
                                      onTap:
                                          () => Navigator.push(
                                            context,
                                            RegisterScreen.route(),
                                          ),
                                      child: Text(
                                        'Isdiiwaangeli',
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
