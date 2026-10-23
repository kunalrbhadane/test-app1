import 'package:flutter/material.dart';

/// A sleek pulsating / breathing dot widget for indicating live status.
class BreathingDot extends StatefulWidget {
  final Color color;
  final double size;
  final Duration duration;

  const BreathingDot({
    super.key,
    this.color = const Color(0xFFEF4444), // Bright red
    this.size = 4.0,
    this.duration = const Duration(milliseconds: 1300),
  });

  @override
  State<BreathingDot> createState() => _BreathingDotState();
}

class _BreathingDotState extends State<BreathingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final outerMaxSize = widget.size * 2.5;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final progress = _animation.value; // 0.0 -> 1.0 -> 0.0
        final haloSize = widget.size + (outerMaxSize - widget.size) * progress;
        final haloOpacity = (0.45 * (1.0 - progress * 0.7)).clamp(0.0, 1.0);

        return SizedBox(
          width: outerMaxSize,
          height: outerMaxSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer breathing halo
              Container(
                width: haloSize,
                height: haloSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: haloOpacity),
                ),
              ),
              // Inner glowing core
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(
                        alpha: 0.6 + 0.3 * progress,
                      ),
                      blurRadius: 4.0 + 3.0 * progress,
                      spreadRadius: 0.5 + 1.0 * progress,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
