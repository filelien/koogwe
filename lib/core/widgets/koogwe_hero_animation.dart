import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:koogwe/core/constants/app_colors.dart';

/// A 10-second, smooth 60-fps hero animation used on Home and Onboarding.
class KoogweHeroAnimation extends StatefulWidget {
  final double? height;
  final bool loop; // if true, loops every duration
  final int durationSeconds;
  /// When false, the scene renders without the car to create a calmer header.
  final bool showVehicle;

  const KoogweHeroAnimation({
    super.key,
    this.height,
    this.loop = true,
    this.durationSeconds = 10,
    this.showVehicle = false,
  });

  @override
  State<KoogweHeroAnimation> createState() => _KoogweHeroAnimationState();
}

class _KoogweHeroAnimationState extends State<KoogweHeroAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _drive;
  late final Animation<double> _wheelRotation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    );
    _drive = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _wheelRotation = Tween<double>(begin: 0, end: 2 * math.pi)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.linear));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ??
          View.maybeOf(context)?.platformDispatcher.accessibilityFeatures.disableAnimations ??
              false;
      if (reduceMotion) {
        _controller.value = 0.5; // Respect accessibility
      } else {
        if (widget.loop) {
          _controller.repeat();
        } else {
          _controller.forward();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final height = widget.height ?? 240;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _ScenePainter(
              t: _drive.value,
              wheelRotation: _wheelRotation.value,
              dark: isDark,
              showVehicle: widget.showVehicle,
            ),
          );
        },
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final double t; // 0..1 across the scene
  final double wheelRotation;
  final bool dark;
  final bool showVehicle;

  _ScenePainter({required this.t, required this.wheelRotation, required this.dark, required this.showVehicle});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: dark
            ? [const Color(0xFF0B0B0C), const Color(0xFF141416)]
            : [const Color(0xFFF8FAFF), const Color(0xFFEFF4FF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, bg);

    // Distant skyline
    final skylineY = size.height * 0.45;
    final skyline = Path()
      ..moveTo(0, skylineY)
      ..lineTo(size.width * 0.15, skylineY - 12)
      ..lineTo(size.width * 0.18, skylineY - 24)
      ..lineTo(size.width * 0.22, skylineY - 24)
      ..lineTo(size.width * 0.22, skylineY)
      ..lineTo(size.width * 0.35, skylineY - 18)
      ..lineTo(size.width * 0.44, skylineY - 10)
      ..lineTo(size.width * 0.6, skylineY - 28)
      ..lineTo(size.width * 0.68, skylineY - 12)
      ..lineTo(size.width * 0.74, skylineY - 20)
      ..lineTo(size.width, skylineY)
      ..lineTo(size.width, skylineY + 60)
      ..lineTo(0, skylineY + 60)
      ..close();
    final skylinePaint = Paint()
      ..color = (dark ? Colors.white : Colors.black).withValues(alpha: 0.05);
    canvas.drawPath(skyline, skylinePaint);

    // Road
    final roadTop = size.height * 0.65;
    final road = Rect.fromLTWH(0, roadTop, size.width, size.height - roadTop);
    final roadShader = LinearGradient(
        colors: dark
            ? [const Color(0xFF141416), const Color(0xFF0E0E0F)]
            : [const Color(0xFFE3E7EE), const Color(0xFFD6DBE6)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(road);
    canvas.drawRect(road, Paint()..shader = roadShader);

    // Lane marks
    final markPaint = Paint()
      ..color = (dark ? Colors.white : Colors.black).withValues(alpha: 0.2)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final segment = size.width / 10;
    for (var i = 0; i < 10; i++) {
      final x = i * segment + (t * segment);
      canvas.drawLine(Offset(x % size.width, roadTop + 20),
          Offset((x % size.width) + segment * 0.4, roadTop + 20), markPaint);
    }

    if (showVehicle) {
      // Car
      final carWidth = size.width * 0.36;
      final carHeight = carWidth * 0.42;
      final carY = roadTop - carHeight * 0.3;
      final startX = -carWidth;
      final endX = size.width + carWidth * 0.2;
      final carX = startX + (endX - startX) * t;

      // Shadow
      final shadowRect = Rect.fromLTWH(carX + 12, carY + carHeight - 6, carWidth * 0.7, 12);
      final shadowPaint = Paint()
        ..shader = RadialGradient(
          colors: [Colors.black.withValues(alpha: 0.25), Colors.transparent],
        ).createShader(shadowRect);
      canvas.drawOval(shadowRect, shadowPaint);

      // Body
      final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(carX, carY, carWidth, carHeight),
        const Radius.circular(14),
      );
      canvas.drawRRect(body, Paint()..color = KoogweColors.primary);

      // Windows
      final window = RRect.fromRectAndRadius(
        Rect.fromLTWH(carX + carWidth * 0.18, carY + carHeight * 0.18, carWidth * 0.6, carHeight * 0.35),
        const Radius.circular(10),
      );
      canvas.drawRRect(window, Paint()..color = Colors.white.withValues(alpha: 0.85));

      // Wheels
      void drawWheel(double cx, double cy) {
        final wheelR = carHeight * 0.22;
        final center = Offset(cx, cy);
        canvas.drawCircle(center, wheelR, Paint()..color = Colors.black.withValues(alpha: 0.9));
        canvas.drawCircle(center, wheelR * 0.7, Paint()..color = Colors.grey.shade300);
        final spokePaint = Paint()
          ..color = KoogweColors.accent
          ..strokeWidth = 3;
        for (var i = 0; i < 6; i++) {
          final a = wheelRotation + i * (math.pi / 3);
          final dx = math.cos(a) * (wheelR * 0.7);
          final dy = math.sin(a) * (wheelR * 0.7);
          canvas.drawLine(center, center + Offset(dx, dy), spokePaint);
        }
      }

      drawWheel(carX + carWidth * 0.26, carY + carHeight - 2);
      drawWheel(carX + carWidth * 0.74, carY + carHeight - 2);
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.wheelRotation != wheelRotation ||
        oldDelegate.dark != dark;
  }
}
