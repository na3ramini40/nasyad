import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/app_logo.dart';
import 'package:nasyad/presentation/splash/bloc/splash_cubit.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashReady) {
          context.go(state.showIntro ? '/intro' : '/');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(height: 72, variant: AppLogoVariant.wordmark),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: theme.colorScheme.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
