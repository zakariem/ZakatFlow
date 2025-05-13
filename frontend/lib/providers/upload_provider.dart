import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../services/upload_service.dart';
import '../viewmodels/user/upload_viewmodel.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final uploadViewModelProvider =
    StateNotifierProvider<UploadViewModel, UploadState>(
      (ref) => UploadViewModel(
        UploadService(),
        ref.watch(secureStorageProvider),
        ref,
      ),
    );
