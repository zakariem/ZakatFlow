import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';

import '../../../providers/auth_providers.dart';
import '../../../providers/upload_provider.dart';
import '../../../utils/widgets/snackbar/error_scanckbar.dart';

class UploadScreen extends ConsumerWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uploadState = ref.watch(uploadViewModelProvider);
    final authState = ref.watch(authViewModelProvider);
    final uploadNotifier = ref.read(uploadViewModelProvider.notifier);

    // Handle post-upload logic (error/snackbar or success/navigation)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If upload completed successfully, and we have an updated user, go back
      if (!uploadState.isUploading &&
          uploadState.updatedUser != null &&
          uploadState.message.isEmpty) {
        Navigator.pop(context);
      }

      // If there's an error message, show snackbar
      if (!uploadState.isUploading &&
          uploadState.message.isNotEmpty &&
          uploadState.updatedUser == null) {
        ErrorScanckbar.showSnackBar(context, uploadState.message);
        uploadNotifier.clearMessage();
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Update Profile Image')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (authState.user != null)
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    uploadState.updatedUser?.profileImageUrl ??
                        authState.user!.profileImageUrl,
                  ),
                ),
              const SizedBox(height: 20),

              uploadState.isUploading
                  ? const Loader()
                  : ElevatedButton(
                    onPressed: () async {
                      if (authState.user == null) return;

                      final file = await uploadNotifier.pickImage();
                      if (file != null) {
                        await uploadNotifier.uploadImage(
                          file,
                          authState.user!.id,
                          authState.user!.token,
                        );
                      }
                    },
                    child: const Text('Pick & Upload New Image'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
