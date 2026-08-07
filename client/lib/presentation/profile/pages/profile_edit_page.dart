import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/presentation/profile/bloc/profile_edit_bloc.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({super.key});

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _idController;
  late final TextEditingController _phoneController;
  var _hydrated = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _idController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    context.read<ProfileEditBloc>().add(ProfileEditImagePicked(file.path));
  }

  void _hydrate(ProfileEditState state) {
    if (_hydrated || state.status == ProfileEditStatus.loading) return;
    _hydrated = true;
    _nameController.text = state.name;
    _idController.text = state.userId;
    _phoneController.text = state.phone;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileEditTitle)),
      body: AppContent(
        child: BlocConsumer<ProfileEditBloc, ProfileEditState>(
          listenWhen: (previous, current) =>
              previous.status != current.status &&
              (current.status == ProfileEditStatus.success ||
                  (current.status == ProfileEditStatus.failure &&
                      current.errorMessage != null)),
          listener: (context, state) {
            if (state.status == ProfileEditStatus.success) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(l10n.profileSaved)));
              context.pop();
              return;
            }
            final message = state.errorMessage;
            if (message == null) return;
            final text = message == 'not_signed_in'
                ? l10n.authGenericError
                : message;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(text)));
          },
          builder: (context, state) {
            _hydrate(state);
            if (state.status == ProfileEditStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            final saving = state.status == ProfileEditStatus.saving;
            ImageProvider? avatar;
            if (state.localImagePath != null) {
              avatar = FileImage(File(state.localImagePath!));
            } else if (state.imageUrl != null) {
              avatar = NetworkImage(state.imageUrl!);
            }

            return ListView(
              children: [
                Center(
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: avatar,
                        child: avatar == null
                            ? const Icon(Icons.person_outline, size: 40)
                            : null,
                      ),
                      IconButton.filledTonal(
                        onPressed: saving ? null : _pickImage,
                        tooltip: l10n.profileChangePhoto,
                        icon: const Icon(Icons.photo_camera_outlined),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: l10n.profileNameLabel,
                  hintText: l10n.profileNameHint,
                  controller: _nameController,
                  enabled: !saving,
                  onChanged: (value) {
                    context.read<ProfileEditBloc>().add(
                      ProfileEditNameChanged(value),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.profileIdLabel,
                  controller: _idController,
                  readOnly: true,
                  enabled: false,
                  helperText: l10n.profileIdHint,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.authPhoneLabel,
                  controller: _phoneController,
                  readOnly: true,
                  enabled: false,
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  label: l10n.save,
                  isLoading: saving,
                  onPressed: saving
                      ? null
                      : () {
                          context.read<ProfileEditBloc>().add(
                            const ProfileEditSaveRequested(),
                          );
                        },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
