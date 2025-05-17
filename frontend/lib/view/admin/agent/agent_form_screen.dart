import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../providers/auth_providers.dart';
import '../../../utils/constant/validation_utils.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/custom/custom_field.dart';
import '../../../utils/widgets/snackbar/error_scanckbar.dart';
import '../../../utils/widgets/snackbar/success_snackbar.dart';
import '../../../viewmodels/agent_view_model.dart';

class AgentFormScreen extends ConsumerStatefulWidget {
  final String? agentId;
  const AgentFormScreen({super.key, this.agentId});

  @override
  ConsumerState<AgentFormScreen> createState() => _AgentFormScreenState();
}

class _AgentFormScreenState extends ConsumerState<AgentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isEdit = false;
  bool _loading = false;
  bool _obscurePassword = true;

  XFile? _pickedImage;
  String? _existingImageUrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.agentId != null) {
      _isEdit = true;
      _loadAgentData();
    }
  }

  Future<void> _loadAgentData() async {
    setState(() => _loading = true);
    final viewModel = ref.read(agentViewModelProvider);
    await viewModel.selectAgent(widget.agentId!, '');
    final agent = viewModel.selectedAgent;
    if (agent != null) {
      _fullNameController.text = agent.fullName;
      _emailController.text = agent.email;
      _phoneNumberController.text = agent.phoneNumber;
      _addressController.text = agent.address;
      _existingImageUrl = agent.profileImageUrl;
    }
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = ref.read(authViewModelProvider);
    final viewModel = ref.read(agentViewModelProvider);
    final data = {
      'fullName': _fullNameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'phoneNumber': _phoneNumberController.text,
      'address': _addressController.text,
    };

    setState(() => _loading = true);

    try {
      if (_isEdit) {
        await viewModel.editAgent(
          widget.agentId!,
          data,
          _pickedImage,
          authState.user!.token,
        );
      } else {
        await viewModel.addAgent(data, _pickedImage, authState.user!.token);
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(agentViewModelProvider);

    // Show error/success snackbar after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.error != null && viewModel.error!.isNotEmpty) {
        ErrorScanckbar.showSnackBar(context, viewModel.error!);
        ref.read(agentViewModelProvider).clearMessages();
      } else if (viewModel.successMessage != null &&
          viewModel.successMessage!.isNotEmpty) {
        SuccessSnackbar.showSnackBar(context, viewModel.successMessage!);
        ref.read(agentViewModelProvider).clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Agent' : 'Create Agent'),
        backgroundColor: AppColors.primaryGold,
        foregroundColor: AppColors.textWhite,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage: _getProfileImage(),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: AppColors.primaryGold,
                                  child: const Icon(
                                    Icons.camera_alt,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomField(
                        controller: _fullNameController,
                        labelText: 'Full Name',
                        validator: ValidationUtils.validateFullName,
                      ),
                      const SizedBox(height: 12),
                      CustomField(
                        controller: _emailController,
                        labelText: 'Email',
                        keyboardType: TextInputType.emailAddress,
                        validator: ValidationUtils.validateEmail,
                      ),
                      const SizedBox(height: 12),
                      CustomField(
                        controller: _phoneNumberController,
                        labelText: 'Phone Number',
                        hintText: 'Gali Numberka hay\'ada',
                        keyboardType: TextInputType.phone,
                        validator: ValidationUtils.validatePhoneNumber,
                      ),
                      const SizedBox(height: 12),
                      CustomField(
                        controller: _addressController,
                        labelText: 'Address',
                        hintText: 'Xagee Kutalaa',
                        validator: ValidationUtils.validateFullName,
                      ),
                      const SizedBox(height: 12),
                      if (!_isEdit) ...[
                        CustomField(
                          controller: _passwordController,
                          labelText: 'Password',
                          isPassword: true,
                          obscureText: _obscurePassword,
                          toggleVisibility: _togglePasswordVisibility,
                          validator: ValidationUtils.validatePassword,
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGold,
                          foregroundColor: AppColors.textWhite,
                        ),
                        onPressed: _submit,
                        child: Text(_isEdit ? 'Update Agent' : 'Create Agent'),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  ImageProvider _getProfileImage() {
    if (_pickedImage != null) {
      if (kIsWeb) {
        return NetworkImage(_pickedImage!.path);
      } else {
        return FileImage(File(_pickedImage!.path));
      }
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return NetworkImage(_existingImageUrl!);
    }
    return const AssetImage('assets/images/default_avatar.png');
  }
}
