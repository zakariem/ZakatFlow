import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/utils/widgets/loader.dart';
import 'package:frontend/utils/widgets/snackbar/error_scanckbar.dart';
import 'package:frontend/view/client/profile/profile_update_view.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/client_navigation_provider.dart';
import '../../../utils/theme/app_color.dart';
import '../../auth/login_screen.dart';
import 'upload_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  static Route route() {
    return MaterialPageRoute(builder: (context) => const ProfileScreen());
  }

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  void _handleLogout() async {
    final authVM = ref.read(authViewModelProvider.notifier);
    final clientNavigator = ref.read(clientNavigationProvider.notifier);
    await authVM.logout();

    if (!mounted) return;

    Navigator.pushReplacement(context, LoginScreen.route());
    await Future.delayed(const Duration(seconds: 2));
    clientNavigator.reset();
  }

  Future<void> _handleDeleteAccount() async {
    try {
      final authVM = ref.read(authViewModelProvider.notifier);
      final clientNavigator = ref.read(clientNavigationProvider.notifier);
      await authVM.deleteAccount();

      if (!mounted) return;
      Navigator.pushReplacement(context, LoginScreen.route());
      await Future.delayed(const Duration(seconds: 2));
      clientNavigator.reset();
    } catch (e) {
      if (!mounted) return;
      ErrorScanckbar.showSnackBar(context, 'Failed to delete account: $e');
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundLight,
            title: Text(
              'Delete Account',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            content: Text(
              'Are you sure you want to delete your account? This action cannot be undone.',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: GoogleFonts.poppins(color: AppColors.primaryGold),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _handleDeleteAccount();
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.buttonWarning,
                ),
                child: Text('Delete', style: GoogleFonts.poppins()),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(
      authViewModelProvider,
    ); // Listening for changes in authState
    final clientNavigator = ref.watch(clientNavigationProvider.notifier);
    final size = MediaQuery.of(context).size;
    final avatarRadius = size.width * 0.20;

    if (authState.isLoading) {
      return const LoaderPage();
    }

    if (authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacement(context, LoginScreen.route());
          clientNavigator.reset();
        }
      });
      return const LoaderPage();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            color: AppColors.backgroundLight,
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout();
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.black54),
                        const SizedBox(width: 10),
                        Text('Logout', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete,
                          color: AppColors.buttonWarning,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Delete Account',
                          style: GoogleFonts.poppins(
                            color: AppColors.buttonWarning,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildProfileImage(avatarRadius, authState),
            const SizedBox(height: 20),
            _buildUserInfoCard(authState),
            const SizedBox(height: 20),
            _buildEditProfileButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(double avatarRadius, dynamic authState) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundImage:
                authState.user!.profileImageUrl.isNotEmpty
                    ? NetworkImage(authState.user!.profileImageUrl)
                    : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
            backgroundColor: AppColors.secondaryGray,
          ),
          CircleAvatar(
            radius: avatarRadius * 0.30,
            backgroundColor: AppColors.accentLightGold,
            child: IconButton(
              icon: Icon(
                Icons.camera_alt,
                size: avatarRadius * 0.3 * 0.8,
                color: AppColors.textWhite,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UploadScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard(dynamic authState) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              authState.user!.fullName,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              authState.user!.email,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditProfileButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.textWhite,
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 4,
      ),
      icon: const Icon(Icons.edit, color: AppColors.textWhite),
      label: Text('Edit Profile', style: GoogleFonts.poppins()),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileUpdateView()),
        );
      },
    );
  }
}
