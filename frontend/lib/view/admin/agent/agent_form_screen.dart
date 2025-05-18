import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/utils/widgets/loader.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../models/agent_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../utils/constant/validation_utils.dart';
import '../../../utils/theme/app_color.dart';
import '../../../utils/widgets/custom/custom_button.dart';
import '../../../utils/widgets/custom/custom_field.dart';
import '../../../utils/widgets/snackbar/error_scanckbar.dart';
import '../../../utils/widgets/snackbar/success_snackbar.dart';
import '../../../viewmodels/agent_view_model.dart';

class AgentFormScreen extends ConsumerStatefulWidget {
  final Agent? agent;
  const AgentFormScreen({super.key, this.agent});
  @override
  ConsumerState<AgentFormScreen> createState() => _AgentFormScreenState();
}

class _AgentFormScreenState extends ConsumerState<AgentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  bool _isEdit = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _initialized = false;

  XFile? _pickedImage;
  String? _existingImageUrl;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(agentViewModelProvider).clearMessages();
    });
    if (widget.agent != null) {
      _isEdit = true;
      _fullNameController.text = widget.agent!.fullName;
      _emailController.text = widget.agent!.email;
      _phoneNumberController.text = widget.agent!.phoneNumber;
      _addressController.text = widget.agent!.address;
      _existingImageUrl = widget.agent!.profileImageUrl;
    }
    _initialized = true;
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
      'phoneNumber': _phoneNumberController.text,
      'address': _addressController.text,
    };

    // Only add password for new agents
    if (!_isEdit) {
      data['password'] = _passwordController.text;
    }

    setState(() => _loading = true);

    try {
      if (_isEdit) {
        await viewModel.editAgent(
          widget.agent!.id, // Use the agent's id from the Agent object
          data,
          _pickedImage,
          authState.user!.token,
        );
      } else {
        await viewModel.addAgent(data, _pickedImage, authState.user!.token);
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ErrorScanckbar.showSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: Text(_isEdit ? 'Edit Agent' : 'Create Agent'),
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.textWhite,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(agentViewModelProvider);
      if (viewModel.successMessage != null) {
        SuccessSnackbar.showSnackBar(context, viewModel.successMessage!);
        viewModel.clearMessages();
      }
      if (viewModel.error != null) {
        ErrorScanckbar.showSnackBar(context, viewModel.error!);
        viewModel.clearMessages();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_isEdit ? 'Wax ka beddel Hay\'ada' : 'Hay\'ad diiwan gali'),
        foregroundColor: AppColors.textWhite,
      ),
      body:
          _loading
              ? const Center(child: Loader())
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
                      CustomButton(
                        onTap: _submit,
                        text:
                            _isEdit
                                ? 'Wax ka beddel Hay\'ada'
                                : 'Hay\'ad diiwan gali',
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
