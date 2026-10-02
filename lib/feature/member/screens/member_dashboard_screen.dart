import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';
import 'package:gymora_fitness_management/core/api/network/member_service.dart';

import 'package:gymora_fitness_management/feature/member/providers/member_provider.dart';
import 'package:gymora_fitness_management/feature/member/widgets/member_widgets.dart';
import 'package:provider/provider.dart';

/// Entry point for the GYMORA member experience.
///
/// Drop-in replacement for the old single-file `MemberDashboardScreen`:
///
/// ```dart
/// MaterialApp(home: const MemberDashboardScreen());
/// ```
///
/// [onLogout] returns the member to the authentication flow.
class MemberDashboardScreen extends StatelessWidget {
  const MemberDashboardScreen({
    super.key,
    required this.child,
    required this.location,
    this.service,
  });

  final Widget child;
  final String location;
  final MemberService? service;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<MemberController>(
      create: (_) => MemberController(service: service)..load(),
      child: Builder(
        builder: (context) => MemberScope(
          controller: context.read<MemberController>(),
          child: _MemberShell(child: child, location: location),
        ),
      ),
    );
  }
}

class _MemberShell extends StatelessWidget {
  const _MemberShell({required this.child, required this.location});

  final Widget child;
  final String location;

  @override
  Widget build(BuildContext context) {
    final controller = MemberScope.of(context);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    final Widget body;
    if (!controller.hasData && controller.isLoading) {
      body = const MemberLoadingView();
    } else if (!controller.hasData) {
      body = MemberErrorView(
        message: controller.error ?? 'Something went wrong.',
        onRetry: controller.load,
      );
    } else {
      body = child;
    }

    return Scaffold(
      backgroundColor: GymColors.background,
      extendBody: true,
      body: Stack(
        children: [
          const AmbientBackground(),
          SafeArea(
            bottom: false,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: KeyedSubtree(
                key: ValueKey<bool>(controller.hasData),
                child: body,
              ),
            ),
          ),
          if (controller.hasData)
            Positioned(
              left: 16,
              right: 16,
              bottom: 12 + bottomInset,
              child: MemberBottomNav(
                selectedIndex: _memberTabForLocation(location),
                onChanged: (index) => context.goNamed(_memberRouteName(index)),
              ),
            ),
          if (controller.isRefreshing)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: LinearProgressIndicator(
                  minHeight: 2,
                  color: GymColors.cyan,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

int _memberTabForLocation(String location) {
  if (location == AppRoutes.memberWorkoutRoute) return MemberTabs.workout;
  if (location == AppRoutes.memberProgressRoute) return MemberTabs.progress;
  if (location == AppRoutes.memberNutritionRoute) return MemberTabs.nutrition;
  if (location == AppRoutes.memberProfileRoute) return MemberTabs.profile;
  return MemberTabs.home;
}

String _memberRouteName(int index) {
  switch (index) {
    case MemberTabs.workout:
      return AppRoutes.memberWorkoutName;
    case MemberTabs.progress:
      return AppRoutes.memberProgressName;
    case MemberTabs.nutrition:
      return AppRoutes.memberNutritionName;
    case MemberTabs.profile:
      return AppRoutes.memberProfileName;
    default:
      return AppRoutes.memberHomeName;
  }
}