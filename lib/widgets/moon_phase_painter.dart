import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MoonPhasePainter extends CustomPainter {
  final double phase; // 0.0 (new) → 1.0 (back to new)
  final Color moonColor;
  final Color shadowColor;
  final bool realistic; // warm sandy texture vs flat silver

  const MoonPhasePainter({
    required this.phase,
    required this.moonColor,
    required this.shadowColor,
    this.realistic = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.92;

    canvas.save();
    final clip = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    canvas.clipPath(clip);

    if (realistic) {
      _paintRealistic(canvas, center, radius);
    } else {
      _paintFlat(canvas, center, radius);
    }

    canvas.restore();

    // Subtle rim
    final rimPaint = Paint()
      ..color = moonColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawCircle(center, radius, rimPaint);
  }

  void _paintFlat(Canvas canvas, Offset center, double radius) {
    // Base
    canvas.drawCircle(center, radius, Paint()..color = moonColor);
    _drawCraters(canvas, center, radius, moonColor, 0.12);
    _applyShadow(canvas, center, radius);
  }

  void _paintRealistic(Canvas canvas, Offset center, double radius) {
    // Warm gradient base (lit side)
    final basePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.1, -0.1),
        radius: 1.0,
        colors: [
          _lighten(moonColor, 0.15),
          moonColor,
          _darken(moonColor, 0.12),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    _drawCraters(canvas, center, radius, moonColor, 0.18);
    _applyShadow(canvas, center, radius);
    _drawTerminatorGlow(canvas, center, radius);
  }

  void _drawCraters(Canvas canvas, Offset center, double radius, Color base, double opacity) {
    final darkCrater = Paint()..color = _darken(base, 0.2).withValues(alpha: opacity);
    final lightCrater = Paint()..color = _lighten(base, 0.3).withValues(alpha: opacity * 0.5);

    final craters = [
      (center.dx - radius * 0.25, center.dy - radius * 0.15, radius * 0.13),
      (center.dx + radius * 0.28, center.dy + radius * 0.22, radius * 0.09),
      (center.dx - radius * 0.08, center.dy + radius * 0.32, radius * 0.11),
      (center.dx + radius * 0.15, center.dy - radius * 0.35, radius * 0.07),
      (center.dx - radius * 0.40, center.dy + radius * 0.08, radius * 0.08),
      (center.dx + radius * 0.38, center.dy - radius * 0.18, radius * 0.06),
    ];
    for (final (cx, cy, cr) in craters) {
      canvas.drawCircle(Offset(cx, cy), cr, darkCrater);
      canvas.drawCircle(Offset(cx - cr * 0.3, cy - cr * 0.3), cr * 0.4, lightCrater);
    }
  }

  void _applyShadow(Canvas canvas, Offset center, double radius) {
    final p = (phase >= 1.0) ? 0.0 : phase;
    if (p < 0.02 || p > 0.98) {
      canvas.drawCircle(center, radius, Paint()..color = shadowColor);
      return;
    }
    if ((p - 0.5).abs() < 0.015) return; // full moon

    final litPath = _buildLitPath(center, radius, p);
    final fullCircle = Path()..addOval(Rect.fromCircle(center: center, radius: radius));
    final shadowPath = Path.combine(PathOperation.difference, fullCircle, litPath);

    final shadowPaint = Paint()..color = shadowColor;
    canvas.drawPath(shadowPath, shadowPaint);

    if (realistic) {
      // Soft glow at terminator
      final glowPaint = Paint()
        ..color = moonColor.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(litPath, glowPaint);
    }
  }

  void _drawTerminatorGlow(Canvas canvas, Offset center, double radius) {
    final p = (phase >= 1.0) ? 0.0 : phase;
    if (p < 0.02 || p > 0.98 || (p - 0.5).abs() < 0.015) return;
    // Earthshine: very faint glow on shadow side
    final earthshinePaint = Paint()
      ..color = moonColor.withValues(alpha: 0.04)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center, radius, earthshinePaint);
  }

  Path _buildLitPath(Offset center, double radius, double phase) {
    final path = Path();
    if (phase < 0.5) {
      final f = phase * 2; // 0→1 as phase 0→0.5
      final ex = radius * cos(f * pi / 2).abs();
      // Right half (lit in waxing)
      path.moveTo(center.dx, center.dy - radius);
      path.arcTo(Rect.fromCircle(center: center, radius: radius), -pi / 2, pi, false);
      path.close();
      if (f < 0.5) {
        // Crescent: subtract inner ellipse from right half
        final inner = Path()
          ..addOval(Rect.fromCenter(center: center, width: ex * 2, height: radius * 2));
        return Path.combine(PathOperation.difference, path, inner);
      } else {
        // Gibbous: union right half with inner ellipse
        final inner = Path()
          ..addOval(Rect.fromCenter(center: center, width: ex * 2, height: radius * 2));
        return Path.combine(PathOperation.union, path, inner);
      }
    } else {
      final f = (phase - 0.5) * 2; // 0→1 as phase 0.5→1
      final ex = radius * cos(f * pi / 2).abs();
      // Left half (lit in waning)
      path.moveTo(center.dx, center.dy - radius);
      path.arcTo(Rect.fromCircle(center: center, radius: radius), pi / 2, pi, false);
      path.close();
      if (f < 0.5) {
        final inner = Path()
          ..addOval(Rect.fromCenter(center: center, width: ex * 2, height: radius * 2));
        return Path.combine(PathOperation.union, path, inner);
      } else {
        final inner = Path()
          ..addOval(Rect.fromCenter(center: center, width: ex * 2, height: radius * 2));
        return Path.combine(PathOperation.difference, path, inner);
      }
    }
  }

  Color _lighten(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0)).toColor();
  }

  @override
  bool shouldRepaint(MoonPhasePainter old) =>
      old.phase != phase || old.moonColor != moonColor || old.realistic != realistic;
}

class MoonPhaseWidget extends StatelessWidget {
  final double phase;
  final double size;

  const MoonPhaseWidget({super.key, required this.phase, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: MoonPhasePainter(
          phase: phase,
          moonColor: c.moonLight,
          shadowColor: c.moonShadow,
          realistic: c.isDark ? false : true,
        ),
      ),
    );
  }
}
