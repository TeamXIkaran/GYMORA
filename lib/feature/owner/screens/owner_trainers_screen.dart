import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';
import 'package:gymora_fitness_management/feature/owner/provider/owner_trainer_provider.dart';
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TrainerProvider>().ensureLoaded();
      }
    });
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  List<OwnerTrainerModel> _getFilteredTrainers(TrainerProvider provider) {
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
                        const Color(0xFFFF3158).withValues(alpha: 0.16),
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
                    const Color(0xFF7C3AED).withValues(alpha: 0.10),
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
    return Consumer<TrainerProvider>(
      builder: (context, provider, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
          child: Row(
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
                    Row(
                      children: [
                        const Text(
                          'Trainers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 8),

                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF42DB82),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '${provider.trainers.length} trainers managing your gym',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () => context.pushNamed('addTrainer'),
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF3158), Color(0xFFB91438)],
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
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
                        'Add Trainer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // OVERVIEW
  // ============================================================

  Widget _buildOverview() {
    return Consumer<TrainerProvider>(
      builder: (context, provider, _) {
        final total = provider.trainers.length;
        final active = provider.trainers
            .where((trainer) => trainer.isActive)
            .length;
        final inactive = total - active;

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 6, 18, 13),
          child: Row(
            children: [
              Expanded(
                child: _overviewCard(
                  icon: Icons.groups_rounded,
                  value: '$total',
                  label: 'TOTAL',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _overviewCard(
                  icon: Icons.bolt_rounded,
                  value: '$active',
                  label: 'ACTIVE',
                  color: const Color(0xFF42DB82),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: _overviewCard(
                  icon: Icons.pause_circle_outline_rounded,
                  value: '$inactive',
                  label: 'INACTIVE',
                  color: const Color(0xFFFF8A00),
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
      height: 82,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.065),
            Colors.white.withValues(alpha: 0.018),
          ],
        ),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.05), blurRadius: 18),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.11),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: color, size: 13),
              ),
              const Spacer(),
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ],
          ),

          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1.0,
              fontWeight: FontWeight.w900,
            ),
          ),

          Text(
            label,
            style: const TextStyle(
              color: Colors.white30,
              fontSize: 7,
              height: 1.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
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
        height: 52,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.055),
              Colors.white.withValues(alpha: 0.025),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _searchQuery.isNotEmpty
                ? AppColors.primary.withValues(alpha: 0.35)
                : Colors.white.withValues(alpha: 0.07),
          ),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() => _searchQuery = value);
          },
          style: const TextStyle(color: Colors.white, fontSize: 12),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Search trainer or specialization...',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
            prefixIcon: Container(
              padding: const EdgeInsets.all(14),
              child: const Icon(
                Icons.search_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  )
                : const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16,
              horizontal: 3,
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
    return Consumer<TrainerProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.trainers.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
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
    final gradients = [
      [const Color(0xFFE62B52), const Color(0xFF761326)],
      [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      [const Color(0xFFFF8A00), const Color(0xFFCC6E00)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
    ];

    final colors = gradients[index % gradients.length];

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
                            gradient: LinearGradient(colors: colors),
                            boxShadow: [
                              BoxShadow(
                                color: colors.first.withValues(alpha: 0.25),
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
                              Icons.mail_outline_rounded,
                              'Contact',
                              'Available',
                              const Color(0xFF60A5FA),
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
    final gradients = [
      [const Color(0xFFE62B52), const Color(0xFF761326)],
      [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      [const Color(0xFFFF8A00), const Color(0xFFCC6E00)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
    ];

    final colors = gradients[index % gradients.length];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) {
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
                        gradient: LinearGradient(colors: colors),
                        boxShadow: [
                          BoxShadow(
                            color: colors.first.withValues(alpha: 0.28),
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
                            color: const Color(0xFF60A5FA),
                          ),
                        ),
                      ],
                    ),

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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
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
