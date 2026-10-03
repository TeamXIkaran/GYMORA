import 'package:flutter/material.dart';

/// Animated shimmer used for first-load placeholders across role dashboards.
class AppShimmer extends StatefulWidget {
  const AppShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final shift = _controller.value * 2 - 1;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(shift - 1, 0),
            end: Alignment(shift + 1, 0),
            colors: const [
              Color(0xFF141A24),
              Color(0xFF283242),
              Color(0xFF141A24),
            ],
            stops: const [0.25, 0.5, 0.75],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

/// A simple rounded placeholder block. Compose into screen-specific layouts.
class ShimmerBlock extends StatelessWidget {
  const ShimmerBlock({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 12,
  });

  final double height;
  final double? width;
  final double radius;

  @override
  Widget build(BuildContext context) => Container(
    height: height,
    width: width,
    decoration: BoxDecoration(
      color: const Color(0xFF202733),
      borderRadius: BorderRadius.circular(radius),
    ),
  );
}

class DashboardShimmer extends StatelessWidget {
  const DashboardShimmer({super.key, this.message = 'Loading your data...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          ShimmerBlock(height: 24, width: 190),
          const SizedBox(height: 10),
          ShimmerBlock(height: 14, width: 240),
          const SizedBox(height: 24),
          ShimmerBlock(height: 150, radius: 24),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var i = 0; i < 2; i++) ...[
                Expanded(child: ShimmerBlock(height: 92, radius: 20)),
                if (i == 0) const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 24),
          ShimmerBlock(height: 18, width: 140),
          const SizedBox(height: 14),
          for (var i = 0; i < 3; i++) ...[
            ShimmerBlock(height: 78, radius: 18),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white38, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
