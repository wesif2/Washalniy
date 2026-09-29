import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 88});

  final double size;

  @override
  Widget build(BuildContext context) {
    final inner = size * 0.64;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: SizedBox(
          width: inner,
          height: inner,
          child: Stack(
            children: [
              CustomPaint(size: Size(inner, inner), painter: _RoutePainter()),
              Positioned(
                left: inner * 0.42,
                top: 0,
                child: Icon(
                  Icons.location_on_rounded,
                  size: inner * 0.6,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  static const _dotsCount = 7;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final dotPaint = Paint()..color = AppColors.primary.withValues(alpha: 0.45);
    final startPaint = Paint()..color = AppColors.dark;

    final start = Offset(w * 0.16, h * 0.86);
    final end = Offset(w * 0.72, h * 0.62);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(w * 0.30, h * 0.58, end.dx, end.dy);

    for (final metric in path.computeMetrics()) {
      for (var i = 1; i < _dotsCount; i++) {
        final pos = metric
            .getTangentForOffset(metric.length * i / _dotsCount)!
            .position;
        canvas.drawCircle(pos, w * 0.04, dotPaint);
      }
    }

    canvas.drawCircle(start, w * 0.075, startPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
