import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/lunar_event.dart';
import '../providers/events_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import 'add_event_screen.dart';

/// Màn "Soạn & Gửi nhắc nhở": chọn sự kiện → soạn nội dung →
/// gửi qua email và/hoặc SMS cho nhiều người nhận cùng lúc.
class ComposeSendScreen extends StatefulWidget {
  final LunarEvent? initialEvent;
  const ComposeSendScreen({super.key, this.initialEvent});

  @override
  State<ComposeSendScreen> createState() => _ComposeSendScreenState();
}

class _ComposeSendScreenState extends State<ComposeSendScreen> {
  LunarEvent? _event;
  bool _useEmail = true;
  bool _useSms = false;
  final List<TextEditingController> _emails = [];
  final List<TextEditingController> _phones = [];
  final _subjectCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialEvent != null) {
      _applyEvent(widget.initialEvent!);
    } else {
      _emails.add(TextEditingController());
    }
  }

  @override
  void dispose() {
    for (final c in _emails) {
      c.dispose();
    }
    for (final c in _phones) {
      c.dispose();
    }
    _subjectCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  void _applyEvent(LunarEvent e) {
    _event = e;
    for (final c in _emails) {
      c.dispose();
    }
    for (final c in _phones) {
      c.dispose();
    }
    _emails.clear();
    _phones.clear();
    for (final r in e.recipients) {
      if (r.channel == RecipientChannel.email) {
        _emails.add(TextEditingController(text: r.address));
      } else {
        _phones.add(TextEditingController(text: r.address));
      }
    }
    if (_emails.isEmpty) _emails.add(TextEditingController());
    if (_phones.isEmpty) _phones.add(TextEditingController());
    final hasEmail = e.recipients.any((r) => r.channel == RecipientChannel.email);
    final hasSms = e.recipients.any((r) => r.channel == RecipientChannel.sms);
    _useEmail = hasEmail || !hasSms; // mặc định bật email nếu không có gì
    _useSms = hasSms;
    _subjectCtrl.text = 'Nhắc: ${e.title}';
    _bodyCtrl.text = _defaultBody(e);
  }

  String _defaultBody(LunarEvent e) {
    final solar = context.read<EventsProvider>().getNextOccurrence(e, DateTime.now());
    final b = StringBuffer();
    b.writeln('Xin nhắc về sự kiện: ${e.title}');
    b.writeln('Ngày âm: ${e.lunarDateString}');
    if (solar != null) b.writeln('Nhằm ngày dương: ${DateFormat('dd/MM/yyyy').format(solar)}');
    if (e.description != null && e.description!.isNotEmpty) b.writeln('Ghi chú: ${e.description}');
    return b.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    final hasEvents = context.watch<EventsProvider>().events.isNotEmpty;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        title: Text('Soạn & gửi nhắc nhở', style: TextStyle(color: c.textPrimary)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: !hasEvents
          ? EmptyState(
              title: 'Chưa có sự kiện để gửi',
              subtitle: 'Hãy tạo một sự kiện trước, rồi quay lại đây để soạn và gửi nhắc cho nhiều người qua email hoặc SMS.',
              action: ElevatedButton.icon(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AddEventScreen()),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Thêm sự kiện'),
              ),
            )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _label(c, 'CHỌN SỰ KIỆN'),
          _buildEventSelector(c),
          const SizedBox(height: 20),
          _label(c, 'GỬI QUA'),
          _buildChannelToggle(c),
          if (_useEmail) ...[
            const SizedBox(height: 20),
            _label(c, 'NGƯỜI NHẬN EMAIL'),
            _buildAddressList(c, _emails, isEmail: true),
          ],
          if (_useSms) ...[
            const SizedBox(height: 20),
            _label(c, 'NGƯỜI NHẬN SMS'),
            _buildAddressList(c, _phones, isEmail: false),
          ],
          const SizedBox(height: 20),
          _label(c, 'NỘI DUNG'),
          if (_useEmail) ...[
            TextField(
              controller: _subjectCtrl,
              style: TextStyle(color: c.textPrimary, fontSize: 14),
              decoration: const InputDecoration(labelText: 'Tiêu đề email'),
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            controller: _bodyCtrl,
            style: TextStyle(color: c.textPrimary, fontSize: 14, height: 1.4),
            maxLines: 6,
            minLines: 4,
            decoration: const InputDecoration(
              labelText: 'Nội dung tin nhắn',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 28),
          _buildSendButtons(c),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _label(AppColorScheme c, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: TextStyle(color: c.textDim, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5)),
    );
  }

  Widget _buildEventSelector(AppColorScheme c) {
    final e = _event;
    return InkWell(
      onTap: _pickEvent,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: e == null ? c.border : c.accent, width: e == null ? 0.5 : 1),
        ),
        child: Row(
          children: [
            Icon(Icons.brightness_2_outlined, size: 20, color: c.primaryDim),
            const SizedBox(width: 14),
            Expanded(
              child: e == null
                  ? Text('Chọn sự kiện để gửi nhắc...', style: TextStyle(color: c.textDim, fontSize: 14))
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title, style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text('Mùng ${e.lunarDay} tháng ${e.lunarMonth}${e.isLeapMonth ? " (nhuận)" : ""}',
                            style: TextStyle(color: c.textDim, fontSize: 12)),
                      ],
                    ),
            ),
            Icon(Icons.expand_more, color: c.textDim),
          ],
        ),
      ),
    );
  }

  Future<void> _pickEvent() async {
    final c = AppColorScheme.of(context);
    final events = context.read<EventsProvider>().events;
    if (events.isEmpty) {
      _toast('Chưa có sự kiện nào. Hãy thêm sự kiện trước.');
      return;
    }
    final selected = await showModalBottomSheet<LunarEvent>(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text('Chọn sự kiện', style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...events.map((e) => ListTile(
                  leading: Icon(Icons.brightness_2_outlined, color: c.primaryDim, size: 20),
                  title: Text(e.title, style: TextStyle(color: c.textPrimary)),
                  subtitle: Text('Mùng ${e.lunarDay} tháng ${e.lunarMonth}'
                      '${e.recipients.isNotEmpty ? " · ${e.recipients.length} người nhận" : ""}',
                      style: TextStyle(color: c.textDim, fontSize: 12)),
                  onTap: () => Navigator.pop(ctx, e),
                )),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _applyEvent(selected));
  }

  Widget _buildChannelToggle(AppColorScheme c) {
    return Row(
      children: [
        Expanded(
          child: _channelChip(c, icon: Icons.email_outlined, label: 'Email', selected: _useEmail, onTap: () {
            setState(() {
              _useEmail = !_useEmail;
              if (_useEmail && _emails.isEmpty) _emails.add(TextEditingController());
            });
          }),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _channelChip(c, icon: Icons.sms_outlined, label: 'SMS', selected: _useSms, onTap: () {
            setState(() {
              _useSms = !_useSms;
              if (_useSms && _phones.isEmpty) _phones.add(TextEditingController());
            });
          }),
        ),
      ],
    );
  }

  Widget _channelChip(AppColorScheme c, {required IconData icon, required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? c.accentGlow : c.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: selected ? c.accent : c.border, width: selected ? 1 : 0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? Icons.check_circle : icon, size: 18, color: selected ? c.primary : c.textDim),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: selected ? c.primary : c.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressList(AppColorScheme c, List<TextEditingController> list, {required bool isEmail}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...list.asMap().entries.map((entry) {
          final i = entry.key;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: entry.value,
                    style: TextStyle(color: c.textPrimary, fontSize: 14),
                    keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: isEmail ? 'example@gmail.com' : '09xx xxx xxx',
                      prefixIcon: Icon(isEmail ? Icons.alternate_email : Icons.phone_outlined, size: 18, color: c.textDim),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle_outline, color: c.textDim, size: 20),
                  onPressed: list.length == 1
                      ? null
                      : () => setState(() {
                            list[i].dispose();
                            list.removeAt(i);
                          }),
                ),
              ],
            ),
          );
        }),
        TextButton.icon(
          onPressed: () => setState(() => list.add(TextEditingController())),
          icon: Icon(Icons.add_circle_outline, size: 18, color: c.accent),
          label: Text(isEmail ? 'Thêm email' : 'Thêm SĐT', style: TextStyle(color: c.accent)),
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 8)),
        ),
      ],
    );
  }

  Widget _buildSendButtons(AppColorScheme c) {
    final emailCount = _emails.where((e) => e.text.trim().isNotEmpty).length;
    final smsCount = _phones.where((e) => e.text.trim().isNotEmpty).length;
    return Column(
      children: [
        if (_useEmail)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendEmail,
              icon: const Icon(Icons.email_outlined, size: 18),
              label: Text('Gửi Email${emailCount > 0 ? " ($emailCount người)" : ""}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                elevation: 0,
              ),
            ),
          ),
        if (_useEmail && _useSms) const SizedBox(height: 12),
        if (_useSms)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendSms,
              icon: const Icon(Icons.sms_outlined, size: 18),
              label: Text('Gửi SMS${smsCount > 0 ? " ($smsCount người)" : ""}'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _useEmail ? c.surfaceVariant : c.accent,
                foregroundColor: _useEmail ? c.primary : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: _useEmail ? BorderSide(color: c.border) : BorderSide.none,
                ),
                elevation: 0,
              ),
            ),
          ),
        if (!_useEmail && !_useSms)
          Text('Chọn ít nhất một kênh gửi (Email hoặc SMS)', style: TextStyle(color: c.textDim, fontSize: 13)),
      ],
    );
  }

  Future<void> _sendEmail() async {
    final to = _emails.map((e) => e.text.trim()).where((s) => s.isNotEmpty).toList();
    if (to.isEmpty) {
      _toast('Chưa nhập email người nhận');
      return;
    }
    final ok = await NotificationService.instance.composeEmail(
      to: to,
      subject: _subjectCtrl.text,
      body: _bodyCtrl.text,
    );
    if (!ok && mounted) _toast('Không mở được ứng dụng email trên máy này');
  }

  Future<void> _sendSms() async {
    final to = _phones.map((e) => e.text.trim()).where((s) => s.isNotEmpty).toList();
    if (to.isEmpty) {
      _toast('Chưa nhập số điện thoại');
      return;
    }
    final ok = await NotificationService.instance.composeSms(
      to: to,
      body: _bodyCtrl.text,
    );
    if (!ok && mounted) _toast('Không mở được ứng dụng tin nhắn trên máy này');
  }

  void _toast(String msg) {
    final c = AppColorScheme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: c.surfaceVariant),
    );
  }
}
