import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/events_provider.dart';
import '../utils/lunar_converter.dart';
import '../widgets/moon_phase_painter.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_state.dart';
import '../theme/app_theme.dart';
import 'add_event_screen.dart';
import 'compose_send_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late DateTime _today;
  late LunarDate _todayLunar;
  late double _moonPhase;
  late final AnimationController _phaseCtrl;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _todayLunar = LunarConverter.solarToLunar(_today);
    _moonPhase = LunarConverter.getMoonPhase(_today);
    _phaseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
  }

  @override
  void dispose() {
    _phaseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeader(c)),
          SliverToBoxAdapter(child: _buildMoonCard(c)),
          SliverToBoxAdapter(child: _buildSpecialDays(c)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                children: [
                  Text(
                    'SẮP ĐẾN',
                    style: TextStyle(
                      color: c.textDim,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _goToAddEvent(context),
                    style: TextButton.styleFrom(
                      foregroundColor: c.accent,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 16, color: c.accent),
                        const SizedBox(width: 2),
                        Text('Thêm sự kiện', style: TextStyle(color: c.accent, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildUpcomingEvents(c),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader(AppColorScheme c) {
    return Padding(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 8,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _weekdayVi(_today.weekday),
                style: TextStyle(color: c.textDim, fontSize: 13, letterSpacing: 1),
              ),
              Text(
                '${_today.day} tháng ${_today.month}, ${_today.year}',
                style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: c.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              LunarConverter.getCanChiYear(_todayLunar.year),
              style: TextStyle(color: c.primaryDim, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoonCard(AppColorScheme c) {
    return AnimatedBuilder(
      animation: _phaseCtrl,
      builder: (context, _) {
        final p = _moonPhase * Curves.easeOutCubic.transform(_phaseCtrl.value);
        return Container(
      margin: const EdgeInsets.fromLTRB(AppSpace.lg, AppSpace.sm, AppSpace.lg, 0),
      padding: const EdgeInsets.all(AppSpace.xxl),
      decoration: BoxDecoration(
        color: c.surfaceBright,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: c.border, width: 0.5),
        boxShadow: c.isDark
            ? null
            : [BoxShadow(color: c.border.withValues(alpha: 0.5), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        c.primary.withValues(alpha: c.isDark ? 0.22 : 0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                MoonPhaseWidget(phase: p, size: 84),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LunarConverter.getMoonPhaseName(_moonPhase),
                  style: TextStyle(
                    color: c.primary,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.brightness_2_outlined, size: 14, color: c.textDim),
                    const SizedBox(width: 6),
                    Text(
                      'Mùng ${_todayLunar.day} tháng ${_todayLunar.month}',
                      style: TextStyle(color: c.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
                if (_todayLunar.isLeapMonth) ...[
                  const SizedBox(height: 2),
                  Text('(tháng nhuận)', style: TextStyle(color: c.textDim, fontSize: 12)),
                ],
                const SizedBox(height: 10),
                _buildPhaseBar(c, p),
              ],
            ),
          ),
        ],
      ),
        );
      },
    );
  }

  Widget _buildPhaseBar(AppColorScheme c, double phase) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: phase,
            backgroundColor: c.border,
            valueColor: AlwaysStoppedAnimation<Color>(c.primaryDim),
            minHeight: 3,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Trăng mới', style: TextStyle(color: c.textDim, fontSize: 10)),
            Text('Trăng tròn', style: TextStyle(color: c.textDim, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialDays(AppColorScheme c) {
    final isSpecial = LunarConverter.isSpecialDay(_todayLunar);
    if (!isSpecial) {
      final upcoming = <String>[];
      for (int i = 1; i <= 7; i++) {
        final d = _today.add(Duration(days: i));
        final l = LunarConverter.solarToLunar(d);
        if (l.day == 1 || l.day == 15) {
          upcoming.add('${l.day == 1 ? "Mùng 1" : "Rằm"} tháng ${l.month} (${i == 1 ? "ngày mai" : "còn $i ngày"})');
          break;
        }
      }
      if (upcoming.isEmpty) return const SizedBox.shrink();
      return _buildInfoBanner(c, Icons.info_outline, upcoming.first, c.accent);
    }
    return _buildInfoBanner(
      c,
      _todayLunar.day == 15 ? Icons.brightness_1 : Icons.brightness_2_outlined,
      LunarConverter.getSpecialDayName(_todayLunar),
      _todayLunar.day == 15 ? c.eventGold : c.accent,
    );
  }

  Widget _buildInfoBanner(AppColorScheme c, IconData icon, String text, Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildUpcomingEvents(AppColorScheme c) {
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: CircularProgressIndicator(color: c.accent),
              ),
            ),
          );
        }
        final upcoming = provider.getUpcomingEvents(_today);
        if (upcoming.isEmpty) {
          return const SliverToBoxAdapter(
            child: EmptyState(
              title: 'Chưa có sự kiện nào',
              subtitle: 'Thêm ngày giỗ, ngày lễ, sự kiện theo lịch âm của bạn.',
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final event = upcoming[i];
              final solar = provider.getNextOccurrence(event, _today);
              return EventCard(
                event: event,
                nextSolarDate: solar,
                onTap: () => _editEvent(context, event),
                onEdit: () => _editEvent(context, event),
                onSend: () => _sendEvent(context, event),
                onDelete: () => _confirmDelete(context, provider, event.id!),
              );
            },
            childCount: upcoming.length,
          ),
        );
      },
    );
  }

  void _goToAddEvent(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEventScreen()));
  }

  void _editEvent(BuildContext context, event) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddEventScreen(event: event)));
  }

  void _sendEvent(BuildContext context, event) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ComposeSendScreen(initialEvent: event)));
  }

  Future<void> _confirmDelete(BuildContext context, EventsProvider provider, int id) async {
    final c = AppColorScheme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Xóa sự kiện', style: TextStyle(color: c.textPrimary)),
        content: Text('Bạn có chắc muốn xóa sự kiện này?', style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Hủy', style: TextStyle(color: c.accent))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Xóa', style: TextStyle(color: c.eventRed)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) await provider.deleteEvent(id);
  }

  String _weekdayVi(int weekday) {
    const days = ['', 'Thứ Hai', 'Thứ Ba', 'Thứ Tư', 'Thứ Năm', 'Thứ Sáu', 'Thứ Bảy', 'Chủ Nhật'];
    return days[weekday];
  }
}
