import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NavBarItem {
  final IconData icon;
  final String label;
  const NavBarItem({required this.icon, required this.label});
}

/// Thanh điều hướng dạng "pill nổi": capsule tối, tab đang chọn là viên pill
/// trắng có icon + nhãn (mở rộng mượt), các tab khác chỉ hiện icon.
class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    final capsule = c.isDark ? const Color(0xFF2A2531) : const Color(0xFF2A2520);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpace.md, AppSpace.sm, AppSpace.md, AppSpace.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: 7),
          decoration: BoxDecoration(
            color: capsule,
            borderRadius: BorderRadius.circular(AppRadius.full),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: c.isDark ? 0.45 : 0.20),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (int i = 0; i < items.length; i++) _item(i, items[i]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(int i, NavBarItem item) {
    return _NavItem(item: item, selected: i == currentIndex, onTap: () => onTap(i));
  }
}

class _NavItem extends StatefulWidget {
  final NavBarItem item;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.item, required this.selected, required this.onTap});

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _pressed = false;

  void _setPressed(bool v) => setState(() => _pressed = v);

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    const dark = Color(0xFF2A2520);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.86 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: AppMotion.base,
          curve: AppMotion.emphasized,
          padding: EdgeInsets.symmetric(horizontal: selected ? 20 : 16, vertical: 15),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFBF7EF) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.item.icon,
                size: 26,
                color: selected ? dark : const Color(0xFFEDE6D6).withValues(alpha: 0.55),
              ),
              AnimatedSize(
                duration: AppMotion.base,
                curve: AppMotion.emphasized,
                child: selected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 9),
                        child: Text(
                          widget.item.label,
                          style: const TextStyle(color: dark, fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
