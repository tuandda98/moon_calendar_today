import 'package:flutter/material.dart';

/// Nút chuyển theme ngày/đêm dạng cảnh thiên thể:
/// trời chuyển từ xanh ngày → navy đêm, thumb mặt trời ↔ mặt trăng trượt,
/// sao + trăng lưỡi liềm hiện dần về đêm, núi silhouette ở đáy.
class ThemeToggle extends StatefulWidget {
  final bool isDark;
  final ValueChanged<bool> onChanged; // true = dark
  final double width;

  const ThemeToggle({
    super.key,
    required this.isDark,
    required this.onChanged,
    this.width = 72,
  });

  @override
  State<ThemeToggle> createState() => _ThemeToggleState();
}

class _ThemeToggleState extends State<ThemeToggle> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _t;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      value: widget.isDark ? 1 : 0,
    );
    _t = CurvedAnimation(parent: _c, curve: Curves.easeInOutCubic);
  }

  @override
  void didUpdateWidget(ThemeToggle old) {
    super.didUpdateWidget(old);
    if (widget.isDark != old.isDark) {
      widget.isDark ? _c.forward() : _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width;
    final h = w * 0.5;
    final pad = h * 0.12;
    final thumb = h - pad * 2;

    return GestureDetector(
      onTap: () => widget.onChanged(!widget.isDark),
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final t = _t.value;
          final skyTop = Color.lerp(const Color(0xFF8FC3E8), const Color(0xFF1A2240), t)!;
          final skyBottom = Color.lerp(const Color(0xFFC2E0F2), const Color(0xFF2E3A5C), t)!;
          return Container(
            width: w,
            height: h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [skyTop, skyBottom],
              ),
              borderRadius: BorderRadius.circular(h),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.22),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(h),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(child: CustomPaint(painter: _ScenePainter(t))),
                  Positioned(
                    top: pad,
                    left: pad + t * (w - thumb - pad * 2),
                    width: thumb,
                    height: thumb,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(const Color(0xFFF4C24E), const Color(0xFFEDE6D6), t),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.22), blurRadius: 4, offset: const Offset(0, 1)),
                        ],
                      ),
                      child: CustomPaint(painter: _CraterPainter(t)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ScenePainter extends CustomPainter {
  final double t;
  _ScenePainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Núi (luôn hiện) — 2 lớp xanh xám ấm
    final back = Paint()..color = const Color(0xFF8290AC);
    final front = Paint()..color = const Color(0xFF566182);
    final pb = Path()
      ..moveTo(w * 0.40, h)
      ..lineTo(w * 0.58, h * 0.52)
      ..lineTo(w * 0.74, h)
      ..close();
    final pb2 = Path()
      ..moveTo(w * 0.70, h)
      ..lineTo(w * 0.84, h * 0.60)
      ..lineTo(w, h * 0.95)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(pb, back);
    canvas.drawPath(pb2, back);
    final pf = Path()
      ..moveTo(w * 0.48, h)
      ..lineTo(w * 0.70, h * 0.44)
      ..lineTo(w * 0.96, h)
      ..close();
    canvas.drawPath(pf, front);

    // Sao (hiện dần về đêm)
    if (t > 0.01) {
      final star = Paint()..color = Colors.white.withValues(alpha: t * 0.95);
      final r = w * 0.011;
      for (final s in const [
        Offset(0.40, 0.30), Offset(0.47, 0.55), Offset(0.55, 0.24),
        Offset(0.60, 0.45), Offset(0.66, 0.30), Offset(0.50, 0.40),
      ]) {
        canvas.drawCircle(Offset(s.dx * w, s.dy * h), r, star);
      }
    }

    // Trăng lưỡi liềm trang trí (góc trên phải, hiện về đêm)
    if (t > 0.01) {
      final cx = w * 0.80, cy = h * 0.34, rad = h * 0.16;
      final moon = Paint()..color = Colors.white.withValues(alpha: t);
      final cut = Path()..addOval(Rect.fromCircle(center: Offset(cx + rad * 0.55, cy - rad * 0.2), radius: rad));
      final full = Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: rad));
      canvas.drawPath(Path.combine(PathOperation.difference, full, cut), moon);
    }
  }

  @override
  bool shouldRepaint(_ScenePainter old) => old.t != t;
}

/// Hố trên mặt trăng (thumb) — hiện dần khi về đêm.
class _CraterPainter extends CustomPainter {
  final double t;
  _CraterPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    if (t < 0.4) return;
    final a = ((t - 0.4) / 0.6).clamp(0.0, 1.0);
    final p = Paint()..color = const Color(0xFFC2C2D4).withValues(alpha: a);
    final w = size.width, h = size.height;
    canvas.drawCircle(Offset(w * 0.34, h * 0.36), w * 0.12, p);
    canvas.drawCircle(Offset(w * 0.64, h * 0.55), w * 0.16, p);
    canvas.drawCircle(Offset(w * 0.48, h * 0.72), w * 0.09, p);
  }

  @override
  bool shouldRepaint(_CraterPainter old) => old.t != t;
}
