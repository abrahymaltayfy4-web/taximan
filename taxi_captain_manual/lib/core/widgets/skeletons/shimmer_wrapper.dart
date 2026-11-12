import 'package:flutter/material.dart';

/// عنصر Shimmer أساسي يُغلّف أي widget بتأثير لمعان متحرك.
/// - يحترم إعداد `disableAnimations` (prefers-reduced-motion)
/// - يدعم ألوان Light/Dark theme تلقائياً
class ShimmerWrapper extends StatefulWidget {
  final Widget child;

  const ShimmerWrapper({super.key, required this.child});

  @override
  State<ShimmerWrapper> createState() => _ShimmerWrapperState();
}

class _ShimmerWrapperState extends State<ShimmerWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // احترام إعداد تقليل الحركة
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) return widget.child;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE8E4DF);
    final shimmerColor = isDark ? const Color(0xFF3D3D3D) : const Color(0xFFF5F2ED);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [baseColor, shimmerColor, baseColor],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value,
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
