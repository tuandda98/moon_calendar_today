import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'moon_phase_painter.dart';

/// Reusable empty state with a celestial illustration (crescent + sparkles),
/// title, subtitle and an optional primary action.
class EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpace.xxxl, vertical: AppSpace.huge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _CelestialIllustration(size: 132),
            const SizedBox(height: AppSpace.xl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpace.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textDim, fontSize: 13, height: 1.5),
            ),
            if (action != null) ...[
              const SizedBox(height: AppSpace.xxl),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class _CelestialIllustration extends StatelessWidget {
  final double size;
  const _CelestialIllustration({required this.size});

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // soft moonlight glow
          Container(
            width: size * 0.82,
            height: size * 0.82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  c.primary.withValues(alpha: c.isDark ? 0.18 : 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          MoonPhaseWidget(phase: 0.16, size: size * 0.58),
          _sparkle(c, top: size * 0.10, right: size * 0.18, s: 18, dim: false),
          _sparkle(c, bottom: size * 0.20, left: size * 0.14, s: 13, dim: true),
          _sparkle(c, top: size * 0.34, left: size * 0.06, s: 10, dim: true),
          _sparkle(c, bottom: size * 0.12, right: size * 0.26, s: 9, dim: true),
        ],
      ),
    );
  }

  Widget _sparkle(AppColorScheme c, {double? top, double? bottom, double? left, double? right, required double s, required bool dim}) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Icon(
        Icons.auto_awesome,
        size: s,
        color: (dim ? c.textDim : c.primaryDim).withValues(alpha: dim ? 0.5 : 0.8),
      ),
    );
  }
}
