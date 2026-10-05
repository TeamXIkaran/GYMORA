import 'package:flutter/material.dart';

/// A short, clipped light sweep used by Material buttons and InkWells.
class ShimmerInkSplash extends InteractiveInkFeature {
  ShimmerInkSplash({
    required super.controller,
    required super.referenceBox,
    required super.color,
    required bool containedInkWell,
    required RectCallback? rectCallback,
    required BorderRadius? borderRadius,
    required super.customBorder,
    required super.onRemoved,
  }) : _containedInkWell = containedInkWell,
       _rectCallback = rectCallback,
       _borderRadius = borderRadius ?? BorderRadius.zero {
    _controller =
        AnimationController(
            vsync: controller.vsync,
            duration: const Duration(milliseconds: 520),
          )
          ..addListener(controller.markNeedsPaint)
          ..addStatusListener(_handleStatusChanged);
    controller.addInkFeature(this);
    _controller.forward();
  }

  static const InteractiveInkFeatureFactory splashFactory =
      _ShimmerInkSplashFactory();

  final bool _containedInkWell;
  final RectCallback? _rectCallback;
  final BorderRadius _borderRadius;
  late final AnimationController _controller;
  bool _removed = false;

  @override
  void confirm() {}

  @override
  void cancel() {
    _controller.reverse().whenComplete(_remove);
  }

  void _remove() {
    if (_removed) return;
    _removed = true;
    dispose();
  }

  void _handleStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _remove();
    }
  }

  @override
  void paintFeature(Canvas canvas, Matrix4 transform) {
    final bounds = _containedInkWell
        ? (_rectCallback?.call() ?? Offset.zero & referenceBox.size)
        : Offset.zero & referenceBox.size;
    final travel = bounds.width * 1.5;
    final left = bounds.left - bounds.width * .25 + travel * _controller.value;
    final sweep = Rect.fromLTWH(
      left,
      bounds.top,
      bounds.width * .35,
      bounds.height,
    );
    final shader = LinearGradient(
      colors: [
        Colors.transparent,
        Colors.white.withValues(alpha: .08),
        Colors.white.withValues(alpha: .22),
        Colors.white.withValues(alpha: .08),
        Colors.transparent,
      ],
      stops: const [0, .3, .5, .7, 1],
    ).createShader(sweep);

    canvas.save();
    canvas.transform(transform.storage);
    if (_containedInkWell) {
      if (customBorder != null) {
        canvas.clipPath(customBorder!.getOuterPath(bounds));
      } else if (_borderRadius != BorderRadius.zero) {
        canvas.clipRRect(_borderRadius.toRRect(bounds));
      } else {
        canvas.clipRect(bounds);
      }
    }
    canvas.drawRect(bounds, Paint()..shader = shader);
    canvas.restore();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(controller.markNeedsPaint)
      ..removeStatusListener(_handleStatusChanged)
      ..dispose();
    super.dispose();
  }
}

class _ShimmerInkSplashFactory extends InteractiveInkFeatureFactory {
  const _ShimmerInkSplashFactory();

  @override
  InteractiveInkFeature create({
    required MaterialInkController controller,
    required RenderBox referenceBox,
    required Offset position,
    required Color color,
    required TextDirection textDirection,
    bool containedInkWell = false,
    RectCallback? rectCallback,
    BorderRadius? borderRadius,
    ShapeBorder? customBorder,
    double? radius,
    VoidCallback? onRemoved,
  }) {
    return ShimmerInkSplash(
      controller: controller,
      referenceBox: referenceBox,
      color: color,
      containedInkWell: containedInkWell,
      rectCallback: rectCallback,
      borderRadius: borderRadius,
      customBorder: customBorder,
      onRemoved: onRemoved,
    );
  }
}
