import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/routes/app_router.dart';
import 'package:gymora_fitness_management/core/widgets/app_shimmer.dart';
import 'package:gymora_fitness_management/core/widgets/shimmer_button_widget.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';
import 'package:gymora_fitness_management/core/model/owner_member_model.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_dashboard_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_trainer_provider.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_member_provider.dart';
import 'package:provider/provider.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/detail_row.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';

class OwnerTrainersScreen extends StatefulWidget {
  final VoidCallback? onBack;

  const OwnerTrainersScreen({super.key, this.onBack});

  @override
  State<OwnerTrainersScreen> createState() => _OwnerTrainersScreenState();
}

class _OwnerTrainersScreenState extends State<OwnerTrainersScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  String _searchQuery = '';

  late final AnimationController _glowController;
  late final AnimationController _particleController;
  late final AnimationController _buttonShimmerController;

  @override
  void initState() {
    super.initState();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
    _buttonShimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OwnerTrainerProvider>().ensureLoaded();
        context.read<OwnerMemberProvider>().ensureLoaded();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    _buttonShimmerController.dispose();
    super.dispose();
  }

  List<OwnerTrainerModel> _getFilteredTrainers(OwnerTrainerProvider provider) {
    List<OwnerTrainerModel> result = provider.filterByStatus(_selectedFilter);

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();

      result = result.where((t) {
        return t.fullName.toLowerCase().contains(q) ||
            t.specialization.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  List<OwnerMemberModel> _membersForTrainer(
    OwnerTrainerModel trainer,
    List<OwnerMemberModel> members,
  ) {
    final ids = {trainer.trainerId, trainer.id}
      ..removeWhere((id) => id.trim().isEmpty);
    return members.where((member) => ids.contains(member.trainerId)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF04060B),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),

          Positioned.fill(
            child: AnimatedBuilder(
              animation: _particleController,
              builder: (_, _) {
                return CustomPaint(
                  painter: TrainersParticlePainter(_particleController.value),
                );
              },
            ),
          ),

          // Top glow
          Positioned(
            top: -130,
            left: -110,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 280 + (_glowController.value * 40);

                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.ownerBright.withValues(alpha: 0.16),
                        AppColors.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom glow
          Positioned(
            bottom: -160,
            right: -120,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.ownerBright.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildOverview(),
                _buildSearchBar(),
                _buildFilters(),
                Expanded(child: _buildTrainerList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Consumer<OwnerTrainerProvider>(
      builder: (context, provider, _) {
        final activeCount = provider.trainers
            .where((trainer) => trainer.isActive)
            .length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: Container(
            clipBehavior: Clip.antiAlias,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.ownerPrimary.withValues(alpha: .18),
                  const Color(0xFF0D1726),
                  const Color(0xFF080D17),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFF632338)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ownerBright.withValues(alpha: .08),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -14,
                  top: -25,
                  child: Transform.rotate(
                    angle: -.35,
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 118,
                      color: AppColors.ownerBright.withValues(alpha: .08),
                    ),
                  ),
                ),
                Row(
                  children: [
                    if (widget.onBack != null || context.canPop()) ...[
                      CircleButton(
                        icon: Icons.arrow_back_rounded,
                        onTap: widget.onBack ?? () => context.pop(),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'GYM TEAM',
                            style: TextStyle(
                              color: AppColors.ownerBright,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.8,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Trainers',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${provider.trainers.length} trainers · $activeCount active',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ShimmerButton(
                      shimmerCtrl: _buttonShimmerController,
                      gradientColors: const [
                        Color(0xFFFF3158),
                        Color(0xFFB91438),
                      ],
                      accentColor: AppColors.ownerBright,
                      width: 82,
                      height: 46,
                      borderRadius: 16,
                      onPressed: () => context.pushNamed('addTrainer'),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_add_alt_1_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Add',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverview() {
    return Consumer2<OwnerTrainerProvider, OwnerMemberProvider>(
      builder: (context, trainerProvider, memberProvider, _) {
        final total = trainerProvider.trainers.length;
        final active = trainerProvider.trainers
            .where((trainer) => trainer.isActive)
            .length;
        final assignedMembers = trainerProvider.trainers
            .expand(
              (trainer) => _membersForTrainer(trainer, memberProvider.members),
            )
            .length;

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 13),
          child: Row(
            children: [
              Expanded(
                child: _overviewCard(
                  icon: Icons.groups_rounded,
                  value: '$total',
                  label: 'TOTAL',
                  color: const Color(0xFFFF3158),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _overviewCard(
                  icon: Icons.bolt_rounded,
                  value: '$active',
                  label: 'ACTIVE',
                  color: const Color(0xFFE62B52),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _overviewCard(
                  icon: Icons.groups_rounded,
                  value: '$assignedMembers',
                  label: 'ASSIGNED MEMBERS',
                  color: const Color(0xFFB91438),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _overviewCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      height: 118,
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 11),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              color.withValues(alpha: .13),
              const Color(0xFF21121B),
            ),
            const Color(0xFF160D14),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: .30)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.09),
            blurRadius: 20,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [color.withValues(alpha: .045), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withValues(alpha: .24),
                      color.withValues(alpha: .08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: .18)),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              height: 1.0,
              fontWeight: FontWeight.w900,
              letterSpacing: -.4,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 9.5,
              height: 1.0,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.55,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.055),
              Colors.white.withValues(alpha: 0.025),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF632338)),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Search trainer or specialization...',
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white38,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 4,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _buildFilters() {
    final filters = [
      ('All', Icons.groups_rounded),
      ('Active', Icons.bolt_rounded),
      ('Inactive', Icons.pause_circle_outline_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 13, 18, 10),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = _selectedFilter == index;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == filters.length - 1 ? 0 : 7,
              ),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedFilter = index;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: selected
                        ? const LinearGradient(
                            colors: [Color(0xFFE62B52), Color(0xFFB91438)],
                          )
                        : null,
                    color: selected
                        ? null
                        : Colors.white.withValues(alpha: 0.035),
                    borderRadius: BorderRadius.circular(11),
                    border: Border.all(
                      color: selected
                          ? AppColors.primary.withValues(alpha: 0.65)
                          : Colors.white.withValues(alpha: 0.07),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.18),
                              blurRadius: 13,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        filters[index].$2,
                        size: 14,
                        color: selected ? Colors.white : Colors.white38,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        filters[index].$1,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white,
                          fontSize: 9,
                          fontWeight: selected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ============================================================
  // TRAINER LIST
  // ============================================================

  Widget _buildTrainerList() {
    return Consumer<OwnerTrainerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.trainers.isEmpty) {
          return const DashboardShimmer(message: 'Loading trainers...');
        }

        if (provider.error != null && provider.trainers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    color: AppColors.primary.withValues(alpha: 0.75),
                    size: 31,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => provider.fetchTrainers(),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => context.go(AppRoutes.roleSelectionRoute),
                  icon: const Icon(Icons.switch_account_rounded),
                  label: const Text('Back to role selection'),
                ),
              ],
            ),
          );
        }

        final trainers = _getFilteredTrainers(provider);

        if (trainers.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: const Color(0xFF0A0D14),
          onRefresh: () => provider.fetchTrainers(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 30),
            itemCount: trainers.length,
            itemBuilder: (context, index) {
              final trainer = trainers[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTrainerCard(trainer, index),
              );
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // TRAINER CARD
  // ============================================================

  Widget _buildTrainerCard(OwnerTrainerModel trainer, int index) {
    final colors = [AppColors.ownerBright, AppColors.ownerPrimary];
    const avatarColors = [AppColors.trainerBright, AppColors.trainerPrimary];
    final assignedMembers = _membersForTrainer(
      trainer,
      context.watch<OwnerMemberProvider>().members,
    );

    final statusColor = trainer.isActive
        ? const Color(0xFF42DB82)
        : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: () => _showTrainerDetails(trainer, index),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.065),
              Colors.white.withValues(alpha: 0.018),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.075)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.20),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Stack(
              children: [
                // Left accent
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: colors,
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Avatar
                          Container(
                            width: 53,
                            height: 53,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: avatarColors,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.trainerBright.withValues(
                                    alpha: 0.25,
                                  ),
                                  blurRadius: 15,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                trainer.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        trainer.fullName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 5),

                                Row(
                                  children: [
                                    Icon(
                                      Icons.fitness_center_rounded,
                                      color: colors.first,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 5),
                                    Expanded(
                                      child: Text(
                                        trainer.specialization,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white38,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(
                                color: statusColor.withValues(alpha: 0.20),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  trainer.status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Information strip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.045),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: _miniInfo(
                                Icons.workspace_premium_rounded,
                                'Experience',
                                trainer.experience,
                                colors.first,
                              ),
                            ),

                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),

                            Expanded(
                              child: _miniInfo(
                                Icons.groups_rounded,
                                'Assigned members',
                                '${assignedMembers.length}',
                                AppColors.ownerBright,
                              ),
                            ),

                            Container(
                              width: 1,
                              height: 28,
                              color: Colors.white.withValues(alpha: 0.07),
                            ),

                            const SizedBox(width: 8),

                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Colors.white24,
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniInfo(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 27,
          height: 27,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 13),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white24, fontSize: 7),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.15),
                    AppColors.primary.withValues(alpha: 0.03),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 25,
                  ),
                ],
              ),
              child: Icon(
                Icons.person_search_rounded,
                color: AppColors.primary.withValues(alpha: 0.75),
                size: 35,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No Trainers Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 7),

            const Text(
              'Try changing your search or filter.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TRAINER DETAILS
  // ============================================================

  void _showTrainerDetails(OwnerTrainerModel trainer, int index) {
    if (trainer.trainerId.isNotEmpty) {
      context.read<OwnerTrainerProvider>().fetchTrainerDetails(
        trainer.trainerId,
      );
    }
    final colors = [AppColors.ownerBright, AppColors.ownerPrimary];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0D15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.40),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 25),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Container(
                      width: 45,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Avatar
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.trainerBright,
                            AppColors.trainerPrimary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.trainerBright.withValues(
                              alpha: 0.28,
                            ),
                            blurRadius: 25,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          trainer.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      trainer.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      trainer.specialization,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 13),

                    // Status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: trainer.isActive
                            ? const Color(0xFF42DB82).withValues(alpha: 0.09)
                            : Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: trainer.isActive
                              ? const Color(0xFF42DB82).withValues(alpha: 0.18)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: trainer.isActive
                                  ? const Color(0xFF42DB82)
                                  : Colors.white38,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            trainer.status,
                            style: TextStyle(
                              color: trainer.isActive
                                  ? const Color(0xFF42DB82)
                                  : Colors.white54,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // Experience card
                    Row(
                      children: [
                        Expanded(
                          child: _detailStatCard(
                            icon: Icons.workspace_premium_rounded,
                            value: trainer.experience,
                            label: 'Experience',
                            color: colors.first,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _detailStatCard(
                            icon: Icons.fitness_center_rounded,
                            value: 'Trainer',
                            label: 'Role',
                            color: AppColors.ownerPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _assignedMembersSection(trainer),

                    const SizedBox(height: 15),

                    // Contact section
                    _sectionTitle(
                      'CONTACT INFORMATION',
                      Icons.contact_page_outlined,
                    ),

                    const SizedBox(height: 8),

                    DetailRow(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      value: trainer.email,
                    ),

                    DetailRow(
                      icon: Icons.phone_outlined,
                      title: 'Phone',
                      value: trainer.phone,
                    ),

                    const SizedBox(height: 10),

                    _sectionTitle('TRAINER INFORMATION', Icons.badge_outlined),

                    const SizedBox(height: 8),

                    DetailRow(
                      icon: Icons.fitness_center_rounded,
                      title: 'Specialization',
                      value: trainer.specialization,
                    ),

                    if (trainer.trainerId.isNotEmpty)
                      DetailRow(
                        icon: Icons.badge_outlined,
                        title: 'Trainer ID',
                        value: trainer.trainerId,
                      ),

                    DetailRow(
                      icon: Icons.circle,
                      title: 'Status',
                      value: trainer.status,
                      isStatus: trainer.isActive,
                    ),

                    const SizedBox(height: 8),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: colors.first.withValues(alpha: 0.055),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colors.first.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: colors.first,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Trainer profile information is managed by the gym owner.',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 9,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _confirmDeleteTrainer(sheetContext, trainer),
                        icon: const Icon(
                          Icons.delete_outline_rounded,
                          size: 18,
                        ),
                        label: const Text('Delete trainer'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFFF647C),
                          side: BorderSide(
                            color: const Color(
                              0xFFFF647C,
                            ).withValues(alpha: 0.4),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _assignedMembersSection(OwnerTrainerModel trainer) {
    return Consumer2<OwnerMemberProvider, OwnerTrainerProvider>(
      builder: (context, provider, trainerProvider, _) {
        final details = trainerProvider.detailsFor(trainer.trainerId);
        final members =
            details?.members ?? _membersForTrainer(trainer, provider.members);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _sectionTitle(
                    'ASSIGNED MEMBERS  ·  ${members.length}',
                    Icons.groups_rounded,
                  ),
                ),
                if (trainer.trainerId.trim().isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      this.context.pushNamed(
                        'addMember',
                        queryParameters: {'trainerId': trainer.trainerId},
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.ownerBright,
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.person_add_alt_1_rounded, size: 15),
                    label: const Text(
                      'Add member',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            if (provider.isLoading && !provider.hasLoaded)
              const LinearProgressIndicator(
                minHeight: 2,
                color: AppColors.ownerBright,
                backgroundColor: Colors.white10,
              )
            else if (members.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .035),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: .07),
                  ),
                ),
                child: const Text(
                  'No members are currently assigned to this trainer.',
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                ),
              )
            else ...[
              for (final member in members.take(6)) _assignedMemberTile(member),
              if (members.length > 6)
                Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    '+ ${members.length - 6} more members',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white38, fontSize: 10),
                  ),
                ),
            ],
          ],
        );
      },
    );
  }

  Widget _assignedMemberTile(OwnerMemberModel member) {
    final active = member.isActive;
    final color = active ? const Color(0xFF42DB82) : const Color(0xFFFFB84D);
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xFF121825),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .06)),
      ),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.ownerBright.withValues(alpha: .14),
              border: Border.all(
                color: AppColors.ownerBright.withValues(alpha: .28),
              ),
            ),
            child: Text(
              member.initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${member.planDisplayName}  ·  ID ${member.clientId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 9),
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              member.displayStatus,
              style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteTrainer(
    BuildContext sheetContext,
    OwnerTrainerModel trainer,
  ) async {
    final confirmed = await showDialog<bool>(
      context: sheetContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111722),
        title: const Text(
          'Delete trainer?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
        content: Text(
          'This permanently removes ${trainer.fullName} from your gym.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFF647C),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<OwnerTrainerProvider>();
    final deleted = await provider.deleteTrainer(trainer.id);
    if (!mounted) return;

    if (deleted) {
      if (sheetContext.mounted) Navigator.of(sheetContext).pop();
      await context.read<OwnerMemberProvider>().fetchMembers();
      if (!mounted) return;
      context.read<OwnerDashboardProvider>().fetchDashboard();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            trainer.clients > 0
                ? '${trainer.fullName} was deleted. Assigned members are now unassigned.'
                : '${trainer.fullName} was deleted.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHigh,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not delete trainer.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.surfaceHigh,
        ),
      );
    }
  }

  Widget _detailStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.025),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 16),
          ),

          const SizedBox(height: 8),

          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 14),
        const SizedBox(width: 7),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
      ],
    );
  }
}
