import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:frontend/services/profile_update.dart';

import '../viewmodels/user/profile_update_viewmodel.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final profileUpdateProvider =
    StateNotifierProvider<ProfileUpdateViewmodel, UpdateState>(
      (ref) => ProfileUpdateViewmodel(
        ProfileUpdateService(),
        ref.watch(secureStorageProvider),
      ),
    );
