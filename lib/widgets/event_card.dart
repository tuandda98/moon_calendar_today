import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/lunar_event.dart';
import '../theme/app_theme.dart';

class EventCard extends StatelessWidget {
  final LunarEvent event;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onSend;
  final DateTime? nextSolarDate;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onDelete,
    this.onEdit,
    this.onSend,
    this.nextSolarDate,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    final eventColors = c.eventColors;
    final color = eventColors[event.colorIndex % eventColors.length];

    return Slidable(
      key: ValueKey(event.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: onSend != null ? 0.6 : 0.4,
        children: [
          if (onSend != null)
            SlidableAction(
              onPressed: (_) => onSend?.call(),
              backgroundColor: c.accentGlow,
              foregroundColor: Colors.white,
              icon: Icons.send_outlined,
              label: 'Gửi',
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          if (onEdit != null)
            SlidableAction(
              onPressed: (_) => onEdit?.call(),
              backgroundColor: c.accent,
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: 'Sửa',
              borderRadius: onSend == null
                  ? const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12))
                  : BorderRadius.zero,
            ),
          if (onDelete != null)
            SlidableAction(
              onPressed: (_) => onDelete?.call(),
              backgroundColor: c.eventRed,
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Xóa',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: AppSpace.xs + 2),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: c.border, width: 0.5),
            boxShadow: c.isDark
                ? null
                : [BoxShadow(color: c.border.withValues(alpha: 0.5), blurRadius: 4, offset: const Offset(0, 1))],
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 40,
                margin: const EdgeInsets.only(left: AppSpace.sm),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.brightness_2_outlined, size: 12, color: c.textDim),
                          const SizedBox(width: 4),
                          Text(
                            _lunarLabel(),
                            style: TextStyle(color: c.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (nextSolarDate != null) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _daysUntilLabel(),
                      style: TextStyle(
                        color: _daysUntilColor(c),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${nextSolarDate!.day}/${nextSolarDate!.month}',
                      style: TextStyle(color: c.textDim, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(Icons.chevron_right, color: c.textDim, size: 18),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _lunarLabel() {
    final day = event.lunarDay.toString().padLeft(2, '0');
    final month = event.lunarMonth.toString().padLeft(2, '0');
    String s = 'Mùng $day tháng $month';
    if (event.isLeapMonth) s += ' nhuận';
    if (event.recurrence == RecurrenceType.yearly) s += ' (hàng năm)';
    return s;
  }

  String _daysUntilLabel() {
    if (nextSolarDate == null) return '';
    final today = DateTime.now();
    final diff = nextSolarDate!.difference(DateTime(today.year, today.month, today.day)).inDays;
    if (diff == 0) return 'Hôm nay';
    if (diff == 1) return 'Ngày mai';
    if (diff < 0) return 'Đã qua';
    return 'Còn $diff ngày';
  }

  Color _daysUntilColor(AppColorScheme c) {
    if (nextSolarDate == null) return c.textDim;
    final today = DateTime.now();
    final diff = nextSolarDate!.difference(DateTime(today.year, today.month, today.day)).inDays;
    if (diff <= 0) return c.textDim;
    if (diff <= 3) return c.eventRed;
    if (diff <= 7) return c.eventGold;
    return c.textSecondary;
  }
}
