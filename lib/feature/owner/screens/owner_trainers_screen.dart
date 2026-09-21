import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/core/model/owner_trainer_model.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/circule_button.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/detail_row.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/owner_partcial_painter.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/trainer_avatar.dart';
import 'package:gymora_fitness_management/feature/owner/widgets/trainer_card.dart';

class OwnerTrainersScreen extends StatefulWidget {
  const OwnerTrainersScreen({super.key});

  @override
  State<OwnerTrainersScreen> createState() => _OwnerTrainersScreenState();
}

class _OwnerTrainersScreenState extends State<OwnerTrainersScreen>
    with TickerProviderStateMixin {
  int _selectedFilter = 0;
  String _searchQuery = '';

  late final AnimationController _glowController;
  late final AnimationController _particleController;

  final List<OwnerTrainerModel> _trainers = const [
    OwnerTrainerModel(
      name: 'Amit Verma',
      initials: 'AV',
      specialization: 'Strength & Conditioning',
      clients: 24,
      rating: 4.9,
      status: 'Active',
      experience: '5 Years',
      phone: '+91 98765 11111',
      email: 'amit@gmail.com',
    ),
    OwnerTrainerModel(
      name: 'Rakesh Yadav',
      initials: 'RY',
      specialization: 'Weight Training',
      clients: 19,
      rating: 4.8,
      status: 'Active',
      experience: '4 Years',
      phone: '+91 98765 22222',
      email: 'rakesh@gmail.com',
    ),
    OwnerTrainerModel(
      name: 'Sneha Joshi',
      initials: 'SJ',
      specialization: 'Yoga & Mobility',
      clients: 16,
      rating: 4.9,
      status: 'Active',
      experience: '6 Years',
      phone: '+91 98765 33333',
      email: 'sneha@gmail.com',
    ),
    OwnerTrainerModel(
      name: 'Vikram Singh',
      initials: 'VS',
      specialization: 'HIIT & Cardio',
      clients: 21,
      rating: 4.7,
      status: 'Active',
      experience: '3 Years',
      phone: '+91 98765 44444',
      email: 'vikram@gmail.com',
    ),
    OwnerTrainerModel(
      name: 'Karan Malhotra',
      initials: 'KM',
      specialization: 'Functional Training',
      clients: 12,
      rating: 4.6,
      status: 'Inactive',
      experience: '2 Years',
      phone: '+91 98765 55555',
      email: 'karan@gmail.com',
    ),
  ];

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
  }

  @override
  void dispose() {
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  List<OwnerTrainerModel> get _filteredTrainers {
    List<OwnerTrainerModel> result = List.from(_trainers);

    if (_selectedFilter == 1) {
      result = result.where((trainer) => trainer.status == 'Active').toList();
    } else if (_selectedFilter == 2) {
      result = result.where((trainer) => trainer.status == 'Inactive').toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase();

      result = result.where((trainer) {
        return trainer.name.toLowerCase().contains(query) ||
            trainer.specialization.toLowerCase().contains(query);
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF05070C),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(gradient: AppColors.darkGradient),
            ),
          ),

          // Animated particles
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

          // Orange/red glow
          Positioned(
            top: -100,
            left: -100,
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (_, _) {
                final size = 270 + (_glowController.value * 35);

                return Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFFF8A00).withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Row(
        children: [
          CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () {
              context.pushNamed('ownerDashboard');
            },
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trainers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_trainers.length} trainers in your gym',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ),

          // Add Trainer
          GestureDetector(
            onTap: _showAddTrainerMessage,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF3158), Color(0xFFB91438)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 5),
                  Text(
                    'Add Trainer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
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
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.045),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          style: const TextStyle(color: Colors.white, fontSize: 12),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            hintText: 'Search trainers...',
            hintStyle: const TextStyle(color: Colors.white30, fontSize: 11),
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: Colors.white38,
              size: 20,
            ),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white38,
                      size: 18,
                    ),
                  )
                : const Icon(
                    Icons.tune_rounded,
                    color: Colors.white30,
                    size: 18,
                  ),
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
    final filters = ['All', 'Active', 'Inactive'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 15, 18, 10),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = _selectedFilter == index;

          return Padding(
            padding: EdgeInsets.only(
              right: index == filters.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.07),
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 14,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: selected ? Colors.white : Colors.white54,
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
    final trainers = _filteredTrainers;

    if (trainers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 5, 18, 25),
      itemCount: trainers.length,
      itemBuilder: (context, index) {
        final trainer = trainers[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TrainerCard(
            trainer: trainer,
            index: index,
            onTap: () {
              _showTrainerDetails(trainer);
            },
          ),
        );
      },
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Icon(
                Icons.person_search_rounded,
                color: AppColors.primary.withValues(alpha: 0.7),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Trainers Found',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Try changing your search or filter.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ADD TRAINER
  // ============================================================

  void _showAddTrainerMessage() {
    context.pushNamed('addTrainer');
  }

  // ============================================================
  // TRAINER DETAILS
  // ============================================================

  void _showTrainerDetails(OwnerTrainerModel trainer) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B0E16),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 22),

                // REPLACE with just:
                TrainerAvatar(
                  initials: trainer.initials,
                  index: _trainers.indexOf(trainer),
                  size: 68,
                ),

                const SizedBox(height: 12),

                Text(
                  trainer.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  trainer.specialization,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: _statBox(
                        icon: Icons.people_alt_rounded,
                        value: '${trainer.clients}',
                        label: 'Clients',
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _statBox(
                        icon: Icons.star_rounded,
                        value: '${trainer.rating}',
                        label: 'Rating',
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: _statBox(
                        icon: Icons.workspace_premium_rounded,
                        value: trainer.experience,
                        label: 'Experience',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

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
                DetailRow(
                  icon: Icons.fitness_center_rounded,
                  title: 'Specialization',
                  value: trainer.specialization,
                ),
                DetailRow(
                  icon: Icons.circle,
                  title: 'Status',
                  value: trainer.status,
                  isStatus: true,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

Widget _statBox({
  required IconData icon,
  required String value,
  required String label,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.035),
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    ),
    child: Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(height: 6),
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
        Text(label, style: const TextStyle(color: Colors.white30, fontSize: 8)),
      ],
    ),
  );
}
