import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/user_profile.dart';
import 'package:nasyad/presentation/profile/bloc/profile_bloc.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: AppContent(
        child: BlocConsumer<ProfileBloc, ProfileState>(
          listenWhen: (previous, current) =>
              previous.errorMessage != current.errorMessage &&
              current.errorMessage != null,
          listener: (context, state) {
            final message = state.errorMessage;
            if (message == null) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          },
          builder: (context, state) {
            if (state.status == ProfileStatus.loading && state.isGuest) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.isGuest) {
              return _GuestProfile(
                l10n: l10n,
                signingOut: state.status == ProfileStatus.signingOut,
              );
            }
            final profile = state.session.profile!;
            return _SignedInProfile(
              l10n: l10n,
              profile: profile,
              busy: state.status == ProfileStatus.signingOut,
            );
          },
        ),
      ),
    );
  }
}

class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.l10n, required this.signingOut});

  final AppLocalizations l10n;
  final bool signingOut;

  @override
  Widget build(BuildContext context) {
    if (signingOut) {
      return const Center(child: CircularProgressIndicator());
    }
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.profileGuestTitle,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.profileGuestBody,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.introSignInWithPhone,
            icon: Icons.phone_android_outlined,
            onPressed: () => context.push('/auth/phone'),
          ),
        ],
      ),
    );
  }
}

class _SignedInProfile extends StatelessWidget {
  const _SignedInProfile({
    required this.l10n,
    required this.profile,
    required this.busy,
  });

  final AppLocalizations l10n;
  final UserProfile profile;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = (profile.name == null || profile.name!.trim().isEmpty)
        ? l10n.profileNameEmpty
        : profile.name!;

    return ListView(
      children: [
        const SizedBox(height: AppSpacing.md),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundImage: profile.imageUrl != null
                ? NetworkImage(profile.imageUrl!)
                : null,
            child: profile.imageUrl == null
                ? const Icon(Icons.person_outline, size: 40)
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          profile.phone,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.profileIdLabel),
          subtitle: SelectableText(profile.id),
        ),
        const SizedBox(height: AppSpacing.md),
        AppButton(
          label: l10n.edit,
          icon: Icons.edit_outlined,
          variant: AppButtonVariant.secondary,
          onPressed: busy ? null : () => context.push('/profile/edit'),
        ),
        const SizedBox(height: AppSpacing.sm),
        AppButton(
          label: l10n.authSignOut,
          variant: AppButtonVariant.danger,
          isLoading: busy,
          onPressed: busy
              ? null
              : () {
                  context.read<ProfileBloc>().add(
                    const ProfileSignOutRequested(),
                  );
                },
        ),
      ],
    );
  }
}
