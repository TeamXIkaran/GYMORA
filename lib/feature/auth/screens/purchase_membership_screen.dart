import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gymora_fitness_management/config/theme/app_colors.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/glass_sheet_widget.dart';
import 'package:gymora_fitness_management/feature/auth/widgets/gradient_button_widget.dart';


// ═══════════════════════════════════════════════════════════════════════════
// PLAN MODEL
// ═══════════════════════════════════════════════════════════════════════════

class _Plan {
  final String name;
  final String price;
  final String duration;
  final Color color;
  final String? badge;

  const _Plan({
    required this.name,
    required this.price,
    required this.duration,
    required this.color,
    this.badge,
  });
}

// ═══════════════════════════════════════════════════════════════════════════
// PURCHASE MEMBERSHIP SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class PurchaseMembershipScreen extends StatefulWidget {
  const PurchaseMembershipScreen({super.key});

  @override
  State<PurchaseMembershipScreen> createState() =>
      _PurchaseMembershipScreenState();
}

class _PurchaseMembershipScreenState extends State<PurchaseMembershipScreen> {
  static const Color _accent = AppColors.primary;

  // ═══════════════════════════════════════════════════════════════════════
  // PLANS
  // ═══════════════════════════════════════════════════════════════════════

  static const List<_Plan> _plans = [
    _Plan(
      name: 'STARTER',
      price: '5,000',
      duration: '1 Month',
      color: Color(0xFF9C27B0),
    ),
    _Plan(
      name: 'PRO',
      price: '10,000',
      duration: '3 Months',
      color: Color(0xFFE62B52),
      badge: 'POPULAR',
    ),
    _Plan(
      name: 'ELITE',
      price: '15,000',
      duration: '6 Months',
      color: Color(0xFFFFB31A),
    ),
  ];

  int _selectedPlan = 1;

  // ═══════════════════════════════════════════════════════════════════════
  // BUILD
  // ═══════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      _buildTitle(),

                      const SizedBox(height: 24),

                      _buildPlanCards(),

                      const SizedBox(height: 32),

                      _buildContinueButton(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // APP BAR
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),

          const Spacer(),

          const Text(
            'Purchase Membership',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(),

          const SizedBox(width: 40),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TITLE
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildTitle() {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [_accent, _accent.withValues(alpha: 0.7)],
            ).createShader(bounds);
          },
          child: const Text(
            'Choose Your Plan',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Start your fitness journey today',
          style: TextStyle(color: AppColors.textMuted, fontSize: 14),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PLAN CARDS
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildPlanCards() {
    return Column(
      children: List.generate(_plans.length, (i) {
        final plan = _plans[i];
        final selected = _selectedPlan == i;

        return Padding(
          padding: EdgeInsets.only(bottom: i < _plans.length - 1 ? 14 : 0),
          child: _PlanCard(
            plan: plan,
            selected: selected,
            onTap: () {
              setState(() {
                _selectedPlan = i;
              });
            },
          ),
        );
      }),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // CONTINUE BUTTON
  // ═══════════════════════════════════════════════════════════════════════

  Widget _buildContinueButton() {
    final plan = _plans[_selectedPlan];

    return GradientButton(
      label: 'Continue',
      color: _accent,
      onPressed: () {
        // IMPORTANT:
        // Same keys are used by GymDetails and QRPayment screens.

        final Map<String, dynamic> planData = {
          'name': plan.name,
          'price': plan.price,
          'duration': plan.duration,
          'color': plan.color.toARGB32(),
          'badge': plan.badge,
        };

        context.pushNamed('gymDetailed', extra: planData);
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PLAN CARD
// ═══════════════════════════════════════════════════════════════════════════

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool selected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),

          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? [
                    plan.color.withValues(alpha: 0.18),
                    plan.color.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0.025),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.055),
                    Colors.white.withValues(alpha: 0.018),
                  ],
          ),

          border: Border.all(
            color: selected
                ? plan.color.withValues(alpha: 0.75)
                : Colors.white.withValues(alpha: 0.09),
            width: selected ? 1.4 : 1,
          ),

          boxShadow: [
            if (selected)
              BoxShadow(
                color: plan.color.withValues(alpha: 0.20),
                blurRadius: 28,
                spreadRadius: -4,
                offset: const Offset(0, 8),
              ),

            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 18,
              spreadRadius: -8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // PLAN ICON
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    plan.color.withValues(alpha: selected ? 0.35 : 0.16),
                    plan.color.withValues(alpha: selected ? 0.10 : 0.04),
                  ],
                ),
                border: Border.all(
                  color: plan.color.withValues(alpha: selected ? 0.45 : 0.15),
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: plan.color.withValues(alpha: 0.22),
                          blurRadius: 16,
                          spreadRadius: -4,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                plan.name == 'STARTER'
                    ? Icons.fitness_center_rounded
                    : plan.name == 'PRO'
                    ? Icons.bolt_rounded
                    : Icons.workspace_premium_rounded,
                color: plan.color,
                size: 25,
              ),
            ),

            const SizedBox(width: 14),

            // PLAN INFORMATION
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          plan.name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: plan.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),

                      if (plan.badge != null) ...[
                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                plan.color.withValues(alpha: 0.30),
                                plan.color.withValues(alpha: 0.10),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: plan.color.withValues(alpha: 0.35),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                color: plan.color,
                                size: 10,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                plan.badge!,
                                style: TextStyle(
                                  color: plan.color,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Icon(
                        Icons.schedule_rounded,
                        color: Colors.white.withValues(alpha: 0.35),
                        size: 14,
                      ),

                      const SizedBox(width: 5),

                      Text(
                        plan.duration,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.50),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // PRICE
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${plan.price}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '/${plan.duration.split(' ').last.toLowerCase()}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.38),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            // SELECTION
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: selected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          plan.color,
                          plan.color.withValues(alpha: 0.65),
                        ],
                      )
                    : null,
                color: selected ? null : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? plan.color
                      : Colors.white.withValues(alpha: 0.20),
                  width: 1.5,
                ),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: plan.color.withValues(alpha: 0.35),
                          blurRadius: 10,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: selected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY SHEET
// ═══════════════════════════════════════════════════════════════════════════

class SummarySheet extends StatelessWidget {
  final _Plan plan;
  final VoidCallback onContinue;

  const SummarySheet({super.key, required this.plan, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return GlassSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _SectionLabel(label: 'Order Summary'),

          const SizedBox(height: 16),

          _SummaryRow(label: 'Plan', value: plan.name),

          _SummaryRow(label: 'Duration', value: plan.duration),

          _SummaryRow(label: 'Price', value: '₹${plan.price}', bold: true),

          const SizedBox(height: 24),

          GradientButton(
            label: 'Continue to Details',
            color: plan.color,
            onPressed: onContinue,
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SECTION LABEL
// ═══════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SUMMARY ROW
// ═══════════════════════════════════════════════════════════════════════════

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: bold ? 18 : 14,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
