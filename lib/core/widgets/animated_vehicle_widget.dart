import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:koogwe/core/constants/app_colors.dart';
import 'package:koogwe/core/constants/app_spacing.dart';

enum VehicleType {
  economy,
  comfort,
  premium,
  suv,
  motorcycle,
  taxi,
  electric,
  minibus,
  luxury,
}

class AnimatedVehicleWidget extends StatefulWidget {
  final VehicleType vehicleType;
  final double height;
  final bool showRoad;

  const AnimatedVehicleWidget({
    super.key,
    this.vehicleType = VehicleType.economy,
    this.height = 200,
    this.showRoad = true,
  });

  @override
  State<AnimatedVehicleWidget> createState() => _AnimatedVehicleWidgetState();
}

class _AnimatedVehicleWidgetState extends State<AnimatedVehicleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _roadAnimation;
  late Animation<double> _vehicleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _roadAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    _vehicleAnimation = Tween<double>(begin: -50, end: 50).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getVehicleColor() {
    switch (widget.vehicleType) {
      case VehicleType.economy:
        return KoogweColors.success;
      case VehicleType.comfort:
        return KoogweColors.secondary;
      case VehicleType.premium:
        return KoogweColors.primary;
      case VehicleType.suv:
        return KoogweColors.accent;
      case VehicleType.motorcycle:
        return KoogweColors.warning;
      case VehicleType.taxi:
        return Colors.yellow.shade700;
      case VehicleType.electric:
        return Colors.green.shade400;
      case VehicleType.minibus:
        return KoogweColors.info;
      case VehicleType.luxury:
        return Colors.purple.shade300;
    }
  }

  IconData _getVehicleIcon() {
    switch (widget.vehicleType) {
      case VehicleType.economy:
      case VehicleType.comfort:
      case VehicleType.premium:
        return Icons.directions_car;
      case VehicleType.suv:
        return Icons.airport_shuttle;
      case VehicleType.motorcycle:
        return Icons.two_wheeler;
      case VehicleType.taxi:
        return Icons.local_taxi;
      case VehicleType.electric:
        return Icons.electric_car;
      case VehicleType.minibus:
        return Icons.directions_bus;
      case VehicleType.luxury:
        return Icons.sports_motorsports;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final vehicleColor = _getVehicleColor();

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  KoogweColors.darkBackground,
                  KoogweColors.darkBackground.withValues(alpha: 0.8),
                ]
              : [
                  KoogweColors.lightBackground,
                  KoogweColors.lightBackground.withValues(alpha: 0.8),
                ],
        ),
        borderRadius: KoogweRadius.lgRadius,
      ),
      child: ClipRRect(
        borderRadius: KoogweRadius.lgRadius,
        child: Stack(
          children: [
            // Road animation
            if (widget.showRoad)
              AnimatedBuilder(
                animation: _roadAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: _RoadPainter(
                      progress: _roadAnimation.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),

            // Glow effect
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.8,
                    colors: [
                      vehicleColor.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Vehicle
            Center(
              child: AnimatedBuilder(
                animation: _vehicleAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(_vehicleAnimation.value * 0.3, 0),
                    child: Transform.scale(
                      scale: 1.0 + math.sin(_controller.value * 2 * math.pi) * 0.05,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: vehicleColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: vehicleColor.withValues(alpha: 0.6),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _getVehicleIcon(),
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Moving particles/effects
            ...List.generate(5, (index) {
              return Positioned(
                left: (_roadAnimation.value * 100 + index * 20) % 100,
                top: 40 + index * 30.0,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: vehicleColor.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _RoadPainter extends CustomPainter {
  final double progress;
  final bool isDark;

  _RoadPainter({required this.progress, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? KoogweColors.darkSurfaceVariant
          : KoogweColors.lightSurfaceVariant
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Road lines moving
    final centerY = size.height / 2;
    final lineSpacing = 40.0;
    final offsetY = (progress * lineSpacing * 2) % (lineSpacing * 2);

    // Center line
    for (double y = -offsetY; y < size.height; y += lineSpacing * 2) {
      canvas.drawLine(
        Offset(size.width / 2 - 30, y),
        Offset(size.width / 2 - 30, y + lineSpacing),
        paint,
      );
      canvas.drawLine(
        Offset(size.width / 2 + 30, y),
        Offset(size.width / 2 + 30, y + lineSpacing),
        paint,
      );
    }

    // Road boundaries
    final boundaryPaint = Paint()
      ..color = isDark
          ? KoogweColors.darkBorder
          : KoogweColors.lightBorder
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(0, centerY - 60),
      Offset(size.width, centerY - 60),
      boundaryPaint,
    );
    canvas.drawLine(
      Offset(0, centerY + 60),
      Offset(size.width, centerY + 60),
      boundaryPaint,
    );
  }

  @override
  bool shouldRepaint(_RoadPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.isDark != isDark;
  }
}

