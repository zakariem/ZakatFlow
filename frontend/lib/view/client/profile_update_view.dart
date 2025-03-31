import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/auth_providers.dart';
import '../../providers/profile_update_provider.dart';
import '../../utils/constant/validation_utils.dart';
import '../../utils/widgets/auth/auth_field.dart';
import '../../utils/widgets/auth/custom_button.dart';
import '../../utils/widgets/loader.dart';
import '../../utils/widgets/snackbar/error_scanckbar.dart';

class ProfileUpdateView extends ConsumerStatefulWidget {
  const ProfileUpdateView({super.key});

  @override
  ProfileUpdateViewState createState() => ProfileUpdateViewState();
}

class ProfileUpdateViewState extends ConsumerState<ProfileUpdateView> {
  late TextEditingController fullNameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(authViewModelProvider);
    fullNameController = TextEditingController(
      text: authState.user?.fullName ?? '',
    );
    emailController = TextEditingController(text: authState.user?.email ?? '');
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final updateProfileState = ref.watch(profileUpdateProvider);
    final uploadNotifier = ref.read(profileUpdateProvider.notifier);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double horizontalPadding = screenWidth * 0.08;
    double verticalPadding = screenHeight * 0.02;

    // Show error snack bar only when there is a new message
    if (updateProfileState.message.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ErrorScanckbar.showSnackBar(context, updateProfileState.message);
        debugPrint(
          'Upload message: ${updateProfileState.message} ***************',
        );
        uploadNotifier
            .clearMessage(); // Clear the message after showing the snackbar
      });
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile'), centerTitle: true),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: verticalPadding),
              AuthField(
                controller: fullNameController,
                hintText: 'Full Name',
                validator: ValidationUtils.validateFullName,
                keyboardType: TextInputType.name,
              ),
              SizedBox(height: verticalPadding * 2),
              AuthField(
                controller: emailController,
                hintText: 'Email',
                validator: ValidationUtils.validateEmail,
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: verticalPadding),
              updateProfileState.isUploading
                  ? const Loader()
                  : CustomButton(
                    text: 'Update Profile',
                    onTap: () {
                      final updatedEmail = emailController.text;
                      final updatedFullName = fullNameController.text;

                      // Pass values to the updateProfile method
                      uploadNotifier.updateProfile(
                        updatedFullName,
                        updatedEmail,
                        authState.user?.id ?? '',
                        authState.user?.token ?? '',
                        context,
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
