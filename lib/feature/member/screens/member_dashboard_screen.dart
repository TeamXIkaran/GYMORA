import 'package:flutter/material.dart';
import 'package:gymora_fitness_management/config/theme/gym_colors.dart';
import 'package:gymora_fitness_management/feature/member/repository/member_repository.dart';
import 'package:gymora_fitness_management/feature/member/screens/member_home_screen.dart';
import 'package:gymora_fitness_management/feature/member/screens/member_nutrition_screen.dart';
import 'package:gymora_fitness_management/feature/member/screens/member_profile_screen.dart';
import 'package:gymora_fitness_management/feature/member/screens/member_progress_screen.dart';
import 'package:gymora_fitness_management/feature/member/screens/member_workout_screen.dart';
import 'package:gymora_fitness_management/feature/member/state/member_state.dart';
import 'package:gymora_fitness_management/feature/member/widgets/member_widgets.dart';

/// Entry point for the GYMORA member experience.
///
/// Drop-in replacement for the old single-file `MemberDashboardScreen`:
///
/// ```dart
/// MaterialApp(home: const MemberDashboardScreen());
/// ```
///
/// Pass your own [repository] once the member API exists, and [onLogout] to
/// return to your auth flow.
class MemberDashboardScreen extends StatefulWidget {
  const MemberDashboardScreen({super.key, this.repository, this.onLogout});

  final MemberRepository? repository;
  final VoidCallback? onLogout;

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  late final MemberController _controller = MemberController(
    repository: widget.repository,
  );

  @override
  void initState() {
    super.initState();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MemberScope(
      controller: _controller,
      child: _MemberShell(onLogout: widget.onLogout),
    );
  }
}

class _MemberShell extends StatelessWidget {
  const _MemberShell({this.onLogout});

  final VoidCallback? onLogout;

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
      body = IndexedStack(
        index: controller.selectedTab,
        children: [
          const MemberHomeScreen(),
          const MemberWorkoutScreen(),
          const MemberProgressScreen(),
          const MemberNutritionScreen(),
          MemberProfileScreen(onLogout: onLogout),
        ],
      );
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
                selectedIndex: controller.selectedTab,
                onChanged: controller.selectTab,
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
