import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/events_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/empty_state.dart';
import '../theme/app_theme.dart';
import '../utils/lunar_converter.dart';
import 'add_event_screen.dart';
import 'compose_send_screen.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  String _search = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(c),
            _buildSearchBar(c),
            Expanded(child: _buildList(c)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEventScreen())),
        backgroundColor: c.accent,
        child: Icon(Icons.add, color: c.onAccent),
      ),
    );
  }

  Widget _buildHeader(AppColorScheme c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Text(
            'Sự kiện',
            style: TextStyle(
              color: c.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w300,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          TextButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComposeSendScreen())),
            icon: Icon(Icons.send_outlined, size: 18, color: c.accent),
            label: Text('Soạn & gửi', style: TextStyle(color: c.accent, fontSize: 13)),
            style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppColorScheme c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _search = v.toLowerCase()),
        style: TextStyle(color: c.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Tìm sự kiện...',
          prefixIcon: Icon(Icons.search, color: c.textDim, size: 18),
          suffixIcon: _search.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: c.textDim, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _search = '');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
        ),
      ),
    );
  }

  Widget _buildList(AppColorScheme c) {
    return Consumer<EventsProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return Center(child: CircularProgressIndicator(color: c.accent));
        }
        final filtered = provider.events.where((e) {
          if (_search.isEmpty) return true;
          return e.title.toLowerCase().contains(_search) ||
              (e.description?.toLowerCase().contains(_search) ?? false);
        }).toList();

        if (filtered.isEmpty) {
          if (_search.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, color: c.textDim, size: 44),
                  const SizedBox(height: AppSpace.md),
                  Text('Không tìm thấy "$_search"', style: TextStyle(color: c.textSecondary, fontSize: 15)),
                ],
              ),
            );
          }
          return EmptyState(
            title: 'Chưa có sự kiện nào',
            subtitle: 'Thêm ngày giỗ, ngày lễ, rằm hay sinh nhật theo lịch âm để được nhắc đúng hẹn.',
            action: ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEventScreen())),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Thêm sự kiện'),
            ),
          );
        }

        final grouped = <int, List<int>>{};
        for (int i = 0; i < filtered.length; i++) {
          final m = filtered[i].lunarMonth;
          grouped[m] = [...(grouped[m] ?? []), i];
        }
        final months = grouped.keys.toList()..sort();

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: months.fold<int>(0, (sum, m) => sum + 1 + (grouped[m]?.length ?? 0)),
          itemBuilder: (context, idx) {
            int cur = 0;
            for (final m in months) {
              if (idx == cur) return _buildMonthHeader(c, m);
              cur++;
              final items = grouped[m]!;
              if (idx < cur + items.length) {
                final event = filtered[items[idx - cur]];
                final solar = provider.getNextOccurrence(event, DateTime.now());
                return EventCard(
                  event: event,
                  nextSolarDate: solar,
                  onTap: () => _editEvent(context, event),
                  onEdit: () => _editEvent(context, event),
                  onSend: () => _sendEvent(context, event),
                  onDelete: () => _confirmDelete(context, c, provider, event.id!),
                );
              }
              cur += items.length;
            }
            return null;
          },
        );
      },
    );
  }

  Widget _buildMonthHeader(AppColorScheme c, int month) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Row(
        children: [
          Text(
            LunarConverter.getMonthName(month).toUpperCase(),
            style: TextStyle(
              color: c.textDim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: c.border)),
        ],
      ),
    );
  }

  void _editEvent(BuildContext context, event) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => AddEventScreen(event: event)));
  }

  void _sendEvent(BuildContext context, event) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => ComposeSendScreen(initialEvent: event)));
  }

  Future<void> _confirmDelete(BuildContext context, AppColorScheme c, EventsProvider provider, int id) async {
    final ok = await showDialog<bool>(
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
    );
    if (ok == true && context.mounted) await provider.deleteEvent(id);
  }
}
