import 'package:flutter/material.dart';
import 'package:frontend/utils/widgets/snackbar/error_scanckbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../providers/auth_providers.dart';
import '../../providers/client_navigation_provider.dart';
import '../../utils/constant/validation_utils.dart';
import '../../utils/theme/app_color.dart';
import '../../utils/widgets/custom/custom_field.dart';
import '../../utils/widgets/loader.dart';
import '../../utils/widgets/custom/custom_button.dart';
import '../agent_main_screen.dart';
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
  // Add this in your LoginScreen's build method or initState
  @override
  void initState() {
    super.initState();
    // Reset navigation when login screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clientNavigator = ref.read(clientNavigationProvider.notifier);
      clientNavigator.reset();
    });
  }

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
        final role = state.user?.role.toLowerCase();
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    (role == 'agent'
                        ? const AgentMainScreen()
                        : const ClientMainScreen()),
          ),
        );
      }
      // Error handling is done in the build method via WidgetsBinding.instance.addPostFrameCallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final size = MediaQuery.of(context).size;

    // Show error snackbar if error is set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.error.isNotEmpty) {
        ErrorScanckbar.showSnackBar(context, authState.error);
        // Clear the error after showing
        // ignore: invalid_use_of_protected_member
        ref.read(authViewModelProvider.notifier).state = authState.copyWith(
          error: '',
          isAdminError: false,
        );
      }
    });

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF7F1E3), // Light beige
              Color(0xFFFFFFFF), // White
              Color(0xFFF9F9F9), // Light gray
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child:
              authState.isLoading
                  ? const Loader()
                  : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.08,
                              vertical: size.height * 0.02,
                            ),
                            child: Column(
                              children: [
                                // App Logo Section
                                Container(
                                  margin: EdgeInsets.only(
                                    top: size.height * 0.06,
                                    bottom: size.height * 0.04,
                                  ),
                                  child: Column(
                                    children: [
                                      // Logo with shadow and animation
                                      Container(
                                        width: size.width * 0.25,
                                        height: size.width * 0.25,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primaryGold
                                                  .withOpacity(0.3),
                                              blurRadius: 20,
                                              offset: const Offset(0, 10),
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          child: Image.asset(
                                            'assets/images/app.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: size.height * 0.02),
                                      // App name with gradient text
                                      ShaderMask(
                                        shaderCallback:
                                            (bounds) => const LinearGradient(
                                              colors: [
                                                AppColors.primaryGold,
                                                AppColors.accentDarkGold,
                                              ],
                                            ).createShader(bounds),
                                        child: Text(
                                          'ZakatFlow',
                                          style: GoogleFonts.poppins(
                                            fontSize: size.width * 0.07,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Login Form Card
                                Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(
                                    horizontal: size.width * 0.02,
                                  ),
                                  padding: EdgeInsets.all(size.width * 0.08),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.08),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                        spreadRadius: 0,
                                      ),
                                      BoxShadow(
                                        color: AppColors.primaryGold
                                            .withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 5),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Welcome Text
                                        Center(
                                          child: Column(
                                            children: [
                                              Text(
                                                'Soo gal',
                                                style: GoogleFonts.poppins(
                                                  fontSize: size.width * 0.08,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              SizedBox(
                                                height: size.height * 0.01,
                                              ),
                                              Text(
                                                'Salaan, ku soo dhawoow mar kale, waan kuu xiiseynay',
                                                style: GoogleFonts.poppins(
                                                  fontSize: size.width * 0.035,
                                                  color: AppColors.textGray,
                                                  height: 1.4,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: size.height * 0.04),

                                        // Email Field
                                        Text(
                                          'Email',
                                          style: GoogleFonts.poppins(
                                            fontSize: size.width * 0.04,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: size.height * 0.01),
                                        CustomField(
                                          controller: _emailController,
                                          hintText: 'Gali email-kaaga',
                                          validator:
                                              ValidationUtils.validateEmail,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                        SizedBox(height: size.height * 0.025),

                                        // Password Field
                                        Text(
                                          'Password',
                                          style: GoogleFonts.poppins(
                                            fontSize: size.width * 0.04,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        SizedBox(height: size.height * 0.01),
                                        CustomField(
                                          controller: _passwordController,
                                          hintText: 'Gali password-kaaga',
                                          isPassword: true,
                                          obscureText: _isObscure,
                                          toggleVisibility: () {
                                            setState(() {
                                              _isObscure = !_isObscure;
                                            });
                                          },
                                          validator:
                                              ValidationUtils.validatePassword,
                                          keyboardType:
                                              TextInputType.visiblePassword,
                                          textInputAction: TextInputAction.done,
                                        ),

                                        SizedBox(height: size.height * 0.04),

                                        // Login Button
                                        CustomButton(
                                          text: 'Soo gal',
                                          onTap: _login,
                                        ),

                                        SizedBox(height: size.height * 0.03),

                                        // Register Link
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                "Ma lihid akoonto? ",
                                                style: GoogleFonts.poppins(
                                                  fontSize: size.width * 0.038,
                                                  color: AppColors.textGray,
                                                ),
                                              ),
                                              InkWell(
                                                onTap:
                                                    () => Navigator.push(
                                                      context,
                                                      RegisterScreen.route(),
                                                    ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 4,
                                                        vertical: 2,
                                                      ),
                                                  child: Text(
                                                    'Isdiiwaangeli',
                                                    style: GoogleFonts.poppins(
                                                      fontSize:
                                                          size.width * 0.038,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          AppColors.primaryGold,
                                                      decoration:
                                                          TextDecoration
                                                              .underline,
                                                      decorationColor:
                                                          AppColors.primaryGold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                SizedBox(height: size.height * 0.04),

                                // Footer
                                Text(
                                  '© ${DateTime.now().year} ZakatFlow. Dhammaan xuquuqda way dhowran yihiin.',
                                  style: GoogleFonts.poppins(
                                    fontSize: size.width * 0.03,
                                    color: AppColors.textGray.withOpacity(0.7),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
