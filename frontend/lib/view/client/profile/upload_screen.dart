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

    // Show snackbar when there's an error or success message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (uploadState.message.isNotEmpty) {
        ErrorScanckbar.showSnackBar(context, uploadState.message);
        debugPrint('Upload message: ${uploadState.message}');
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

              if (uploadState.isUploading) Loader(),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (authState.user == null) return;

                  final file = await uploadNotifier.pickImage();
                  if (file != null) {
                    debugPrint(
                      'Picked image: ${uploadState.message} ***************',
                    );
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
