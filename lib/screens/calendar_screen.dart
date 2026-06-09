import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/events_provider.dart';
import '../utils/lunar_converter.dart';
import '../widgets/moon_phase_painter.dart';
import '../widgets/event_card.dart';
import '../theme/app_theme.dart';
import 'add_event_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  DateTime? _selectedDay;
  bool _slideForward = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 8),
          _buildMonthHeader(c),
          _buildWeekdayRow(c),
          Divider(height: 1, color: c.border),
          _buildCalendarGrid(c),
          if (_selectedDay != null) _buildSelectedDayEvents(c),
        ],
      ),
    );
  }

  Widget _buildMonthHeader(AppColorScheme c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: AppSpace.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: _prevMonth,
            icon: Icon(Icons.chevron_left, color: c.textSecondary),
          ),
          Column(
            children: [
              Text(
                _monthName(_currentMonth.month),
                style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.3),
              ),
              const SizedBox(height: 2),
              Text('${_currentMonth.year}', style: TextStyle(color: c.textDim, fontSize: 12, letterSpacing: 1)),
            ],
          ),
          IconButton(
            onPressed: _nextMonth,
            icon: Icon(Icons.chevron_right, color: c.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow(AppColorScheme c) {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpace.sm, vertical: AppSpace.sm),
      child: Row(
        children: days
            .map((d) => Expanded(
                  child: Center(
                    child: Text(
                      d,
                      style: TextStyle(color: c.textDim, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(AppColorScheme c) {
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        final eventMap = provider.getEventsForMonth(_currentMonth.year, _currentMonth.month);
        final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
        final startOffset = firstDay.weekday % 7;
        final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
        final rows = ((startOffset + daysInMonth) / 7).ceil();

        const cellH = 66.0;
        return AnimatedSwitcher(
          duration: AppMotion.base,
          switchInCurve: AppMotion.curve,
          switchOutCurve: AppMotion.curve,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: Offset(_slideForward ? 0.08 : -0.08, 0),
              end: Offset.zero,
            ).animate(animation);
            return FadeTransition(opacity: animation, child: SlideTransition(position: slide, child: child));
          },
          child: SizedBox(
            key: ValueKey('${_currentMonth.year}-${_currentMonth.month}'),
            height: rows * cellH,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.xs),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 2,
                crossAxisSpacing: 2,
                childAspectRatio: 0.78,
              ),
              itemCount: rows * 7,
              itemBuilder: (context, i) {
                final dayNum = i - startOffset + 1;
                if (dayNum < 1 || dayNum > daysInMonth) return const SizedBox.shrink();
                final date = DateTime(_currentMonth.year, _currentMonth.month, dayNum);
                final lunar = LunarConverter.solarToLunar(date);
                final phase = LunarConverter.getMoonPhase(date);
                final isToday = _isToday(date);
                final isSelected = _selectedDay != null && _sameDay(_selectedDay!, date);
                final events = eventMap[DateTime(date.year, date.month, date.day)] ?? [];
                return _buildDayCell(context, c, date, lunar, phase, isToday, isSelected, events);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    AppColorScheme c,
    DateTime date,
    LunarDate lunar,
    double phase,
    bool isToday,
    bool isSelected,
    List events,
  ) {
    final isSpecial = lunar.day == 1 || lunar.day == 15;

    return GestureDetector(
      onTap: () => setState(() => _selectedDay = date),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.curve,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: isSelected ? c.accentGlow : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isToday ? Border.all(color: c.accent, width: 1.5) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MoonPhaseWidget(phase: phase, size: 22),
            const SizedBox(height: 3),
            Text(
              '${date.day}',
              style: TextStyle(
                color: isToday ? c.accent : c.textPrimary,
                fontSize: 12,
                fontWeight: isToday ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
            Text(
              '${lunar.day}',
              style: TextStyle(
                color: isSpecial ? c.eventGold : c.textDim,
                fontSize: 9,
                fontWeight: isSpecial ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            if (events.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int i = 0; i < events.length.clamp(0, 3); i++)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          color: c.eventColors[events[i].colorIndex % c.eventColors.length],
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDayEvents(AppColorScheme c) {
    if (_selectedDay == null) return const SizedBox.shrink();
    final lunar = LunarConverter.solarToLunar(_selectedDay!);
    final isSpecial = LunarConverter.isSpecialDay(lunar);

    return Expanded(
      child: Consumer<EventsProvider>(
        builder: (context, provider, _) {
          final events = provider.getEventsForLunarDate(lunar.day, lunar.month);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.md, AppSpace.lg, AppSpace.sm),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mùng ${lunar.day} tháng ${lunar.month}${lunar.isLeapMonth ? " nhuận" : ""}',
                          style: TextStyle(color: c.textSecondary, fontSize: 13),
                        ),
                        if (isSpecial)
                          Text(
                            LunarConverter.getSpecialDayName(lunar),
                            style: TextStyle(color: c.eventGold, fontSize: 12),
                          ),
                      ],
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddEventScreen(
                            prefilledLunarDay: lunar.day,
                            prefilledLunarMonth: lunar.month,
                          ),
                        ),
                      ),
                      icon: Icon(Icons.add, size: 16, color: c.accent),
                      label: Text('Thêm', style: TextStyle(color: c.accent, fontSize: 13)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: c.border),
              if (events.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text('Không có sự kiện', style: TextStyle(color: c.textDim, fontSize: 13)),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: events.length,
                    itemBuilder: (context, i) {
                      final event = events[i];
                      return EventCard(
                        event: event,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEventScreen(event: event))),
                        onEdit: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEventScreen(event: event))),
                        onDelete: () async {
                          final ok = await _confirmDelete(context, c);
                          if (ok && context.mounted) provider.deleteEvent(event.id!);
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, AppColorScheme c) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: c.surface,
            title: Text('Xóa sự kiện', style: TextStyle(color: c.textPrimary)),
            content: Text('Bạn có chắc muốn xóa?', style: TextStyle(color: c.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Hủy', style: TextStyle(color: c.accent))),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Xóa', style: TextStyle(color: c.eventRed))),
            ],
          ),
        ) ??
        false;
  }

  void _prevMonth() => setState(() {
        _slideForward = false;
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
      });
  void _nextMonth() => setState(() {
        _slideForward = true;
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
      });

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  bool _sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _monthName(int month) {
    const months = ['', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6',
        'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
    return months[month];
  }
}
