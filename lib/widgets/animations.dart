import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 24,
  });

  final Widget child;
  final Duration delay;
  final double offset;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, _controller.forward);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _curve,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
      ),
    );
  }
}

class Pulse extends StatefulWidget {
  const Pulse({
    super.key,
    required this.child,
    this.minScale = 0.9,
    this.maxScale = 1.1,
    this.duration = const Duration(milliseconds: 900),
  });

  final Widget child;
  final double minScale;
  final double maxScale;
  final Duration duration;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: widget.minScale, end: widget.maxScale).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

class Floating extends StatefulWidget {
  const Floating({
    super.key,
    required this.child,
    this.amplitude = 12,
    this.tilt = 0.06,
    this.duration = const Duration(seconds: 5),
    this.phase = 0,
  });

  final Widget child;
  final double amplitude;
  final double tilt;
  final Duration duration;
  final double phase;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
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
        final wave = math.sin((_controller.value + widget.phase) * 2 * math.pi);
        return Transform.translate(
          offset: Offset(0, wave * widget.amplitude),
          child: Transform.rotate(angle: wave * widget.tilt, child: child),
        );
      },
    );
  }
}

class GlossySphere extends StatelessWidget {
  const GlossySphere({super.key, required this.size, this.chrome = false, this.child});

  final double size;

  final bool chrome;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = chrome
        ? const [Colors.white, Color(0xFFE4E4E4), Color(0xFFA9A9A9), Color(0xFF5F5F5F)]
        : const [Color(0xFFFFF4F8), AppColors.pinkSoft, AppColors.pink, AppColors.pinkDeep];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 0.95,
          colors: colors,
          stops: const [0.0, 0.25, 0.65, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: (chrome ? Colors.black : AppColors.pinkDeep).withValues(alpha: 0.25),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SphereLoader extends StatelessWidget {
  const SphereLoader({super.key, this.label, this.light = false});

  final String? label;

  final bool light;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Pulse(minScale: 0.8, maxScale: 1.1, child: GlossySphere(size: 48)),
        if (label != null) ...[
          const SizedBox(height: 20),
          Text(
            label!.toUpperCase(),
            style: AppFonts.display(
              size: 11,
              letterSpacing: 1.5,
              color: light ? Colors.white : AppColors.grey,
            ),
          ),
        ],
      ],
    );
  }
}

Route<T> softRoute<T>(Widget page) {
  return PageRouteBuilder<T>(
    transitionDuration: const Duration(milliseconds: 450),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, 0.04), end: Offset.zero).animate(curved),
          child: child,
        ),
      );
    },
  );
}
