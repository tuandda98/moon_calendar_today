import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/lunar_event.dart';
import '../providers/events_provider.dart';
import '../theme/app_theme.dart';
import '../utils/lunar_converter.dart';

class AddEventScreen extends StatefulWidget {
  final LunarEvent? event;
  final int? prefilledLunarDay;
  final int? prefilledLunarMonth;

  const AddEventScreen({
    super.key,
    this.event,
    this.prefilledLunarDay,
    this.prefilledLunarMonth,
  });

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  int _lunarDay = 1;
  int _lunarMonth = 1;
  bool _isLeapMonth = false;
  RecurrenceType _recurrence = RecurrenceType.yearly;
  int _colorIndex = 0;
  List<_ReminderDraft> _reminders = [];
  List<_RecipientDraft> _recipients = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.event;
    if (e != null) {
      _titleController.text = e.title;
      _descController.text = e.description ?? '';
      _lunarDay = e.lunarDay;
      _lunarMonth = e.lunarMonth;
      _isLeapMonth = e.isLeapMonth;
      _recurrence = e.recurrence;
      _colorIndex = e.colorIndex;
      _reminders = e.reminders.map((r) => _ReminderDraft(
        type: r.type,
        offset: r.offset,
        contactInfo: r.contactInfo ?? '',
        hour: r.hour,
        minute: r.minute,
      )).toList();
      _recipients = e.recipients.map((r) => _RecipientDraft(
        channel: r.channel,
        address: r.address,
      )).toList();
    } else {
      final todayLunar = LunarConverter.solarToLunar(DateTime.now());
      _lunarDay = widget.prefilledLunarDay ?? todayLunar.day;
      _lunarMonth = widget.prefilledLunarMonth ?? todayLunar.month;
      _reminders = [_ReminderDraft()];
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    final isEdit = widget.event != null;
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        title: Text(isEdit ? 'Sửa sự kiện' : 'Thêm sự kiện', style: TextStyle(color: c.textPrimary)),
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        actions: [
          if (isEdit)
            IconButton(
              icon: Icon(Icons.delete_outline, color: c.eventRed),
              onPressed: () => _deleteEvent(context, c),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTitleField(c),
            const SizedBox(height: 16),
            _buildDescField(c),
            const SizedBox(height: 20),
            _buildSectionLabel(c, 'NGÀY ÂM LỊCH'),
            _buildLunarDatePicker(c),
            const SizedBox(height: 20),
            _buildSectionLabel(c, 'LẶP LẠI'),
            _buildRecurrencePicker(c),
            const SizedBox(height: 20),
            _buildSectionLabel(c, 'MÀU SẮC'),
            _buildColorPicker(c),
            const SizedBox(height: 20),
            _buildSectionLabel(c, 'NHẮC NHỞ'),
            ..._reminders.asMap().entries.map((e) => _buildReminderItem(c, e.key, e.value)),
            _buildAddReminderButton(c),
            const SizedBox(height: 20),
            _buildSectionLabel(c, 'NGƯỜI NHẬN (NHẮC NHIỀU NGƯỜI)'),
            _buildRecipients(c),
            const SizedBox(height: 32),
            _buildSaveButton(context, c),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleField(AppColorScheme c) {
    return TextFormField(
      controller: _titleController,
      style: TextStyle(color: c.textPrimary),
      decoration: const InputDecoration(
        labelText: 'Tên sự kiện *',
        hintText: 'VD: Giỗ ông nội, Rằm tháng 7...',
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Vui lòng nhập tên sự kiện' : null,
    );
  }

  Widget _buildDescField(AppColorScheme c) {
    return TextFormField(
      controller: _descController,
      style: TextStyle(color: c.textPrimary),
      maxLines: 2,
      decoration: const InputDecoration(
        labelText: 'Ghi chú (tùy chọn)',
        hintText: 'VD: Chuẩn bị mâm cúng...',
      ),
    );
  }

  Widget _buildSectionLabel(AppColorScheme c, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        text,
        style: TextStyle(color: c.textDim, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildLunarDatePicker(AppColorScheme c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ngày', style: TextStyle(color: c.textDim, fontSize: 11)),
                    const SizedBox(height: 6),
                    _buildNumberPicker(c, value: _lunarDay, min: 1, max: 30, onChanged: (v) => setState(() => _lunarDay = v)),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tháng', style: TextStyle(color: c.textDim, fontSize: 11)),
                    const SizedBox(height: 6),
                    _buildNumberPicker(c, value: _lunarMonth, min: 1, max: 12, onChanged: (v) => setState(() => _lunarMonth = v)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _isLeapMonth,
                onChanged: (v) => setState(() => _isLeapMonth = v ?? false),
                activeColor: c.accent,
                side: BorderSide(color: c.border),
              ),
              Text('Tháng nhuận', style: TextStyle(color: c.textSecondary, fontSize: 14)),
              const Spacer(),
              Text(
                'Âm: ${_lunarDay.toString().padLeft(2, '0')}/${_lunarMonth.toString().padLeft(2, '0')}${_isLeapMonth ? " (nhuận)" : ""}',
                style: TextStyle(color: c.primaryDim, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberPicker(AppColorScheme c, {required int value, required int min, required int max, required ValueChanged<int> onChanged}) {
    return Container(
      decoration: BoxDecoration(
        color: c.surfaceVariant,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: c.border),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove, size: 16),
            color: c.textSecondary,
            disabledColor: c.textDim,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Text(
              value.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add, size: 16),
            color: c.textSecondary,
            disabledColor: c.textDim,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecurrencePicker(AppColorScheme c) {
    return Row(
      children: RecurrenceType.values.map((type) {
        final selected = _recurrence == type;
        final label = type == RecurrenceType.yearly ? 'Hàng năm' : 'Một lần';
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _recurrence = type),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? c.accentGlow : c.surface,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: selected ? c.accent : c.border, width: selected ? 1 : 0.5),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: selected ? c.primary : c.textSecondary,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildColorPicker(AppColorScheme c) {
    final eventColors = c.eventColors;
    return Row(
      children: List.generate(eventColors.length, (i) {
        final selected = _colorIndex == i;
        return GestureDetector(
          onTap: () => setState(() => _colorIndex = i),
          child: Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: eventColors[i],
              shape: BoxShape.circle,
              border: Border.all(color: selected ? c.textPrimary : Colors.transparent, width: 2),
              boxShadow: selected ? [BoxShadow(color: eventColors[i].withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 1)] : null,
            ),
            child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
          ),
        );
      }),
    );
  }

  Widget _buildReminderItem(AppColorScheme c, int index, _ReminderDraft draft) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<ReminderOffset>(
                    value: draft.offset,
                    dropdownColor: c.surfaceVariant,
                    style: TextStyle(color: c.textPrimary, fontSize: 14),
                    icon: Icon(Icons.expand_more, color: c.textDim),
                    onChanged: (v) => setState(() => draft.offset = v ?? draft.offset),
                    items: ReminderOffset.values.map((o) => DropdownMenuItem(
                      value: o,
                      child: Text(o.label),
                    )).toList(),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: c.textDim, size: 18),
                onPressed: () => setState(() => _reminders.removeAt(index)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.notifications_outlined, size: 14, color: c.textDim),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Thông báo trên máy', style: TextStyle(color: c.textSecondary, fontSize: 13)),
              ),
              _buildTimePicker(c, draft),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipients(AppColorScheme c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._recipients.asMap().entries.map((e) => _buildRecipientItem(c, e.key, e.value)),
        if (_recipients.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Thêm email hoặc số điện thoại của người thân để nhắc nhiều người cùng lúc.',
              style: TextStyle(color: c.textDim, fontSize: 12, height: 1.4),
            ),
          ),
        Row(
          children: [
            TextButton.icon(
              onPressed: () => setState(() => _recipients.add(_RecipientDraft(channel: RecipientChannel.email))),
              icon: Icon(Icons.email_outlined, size: 18, color: c.accent),
              label: Text('Thêm email', style: TextStyle(color: c.accent)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => setState(() => _recipients.add(_RecipientDraft(channel: RecipientChannel.sms))),
              icon: Icon(Icons.sms_outlined, size: 18, color: c.accent),
              label: Text('Thêm SĐT', style: TextStyle(color: c.accent)),
              style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecipientItem(AppColorScheme c, int index, _RecipientDraft draft) {
    final isEmail = draft.channel == RecipientChannel.email;
    return Container(
      key: ValueKey(draft),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _typeChip(c, icon: Icons.email_outlined, label: 'Email', selected: isEmail, onTap: () => setState(() => draft.channel = RecipientChannel.email)),
                    const SizedBox(width: 8),
                    _typeChip(c, icon: Icons.sms_outlined, label: 'SMS', selected: !isEmail, onTap: () => setState(() => draft.channel = RecipientChannel.sms)),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.delete_outline, color: c.textDim, size: 18),
                onPressed: () => setState(() => _recipients.removeAt(index)),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: draft.address,
            style: TextStyle(color: c.textPrimary, fontSize: 14),
            keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.phone,
            decoration: InputDecoration(
              labelText: isEmail ? 'Địa chỉ email' : 'Số điện thoại',
              hintText: isEmail ? 'example@gmail.com' : '09xx xxx xxx',
              prefixIcon: Icon(isEmail ? Icons.alternate_email : Icons.phone_outlined, size: 18, color: c.textDim),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            onChanged: (v) => draft.address = v,
          ),
        ],
      ),
    );
  }

  Widget _typeChip(AppColorScheme c, {required IconData icon, required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.accentGlow : c.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: selected ? c.accent : c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? c.primary : c.textDim),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: selected ? c.primary : c.textSecondary, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(AppColorScheme c, _ReminderDraft draft) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay(hour: draft.hour, minute: draft.minute),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(context).colorScheme.copyWith(primary: c.accent),
            ),
            child: child!,
          ),
        );
        if (time != null) setState(() { draft.hour = time.hour; draft.minute = time.minute; });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: c.surfaceVariant,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, size: 14, color: c.textDim),
            const SizedBox(width: 6),
            Text(
              '${draft.hour.toString().padLeft(2, '0')}:${draft.minute.toString().padLeft(2, '0')}',
              style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddReminderButton(AppColorScheme c) {
    return TextButton.icon(
      onPressed: () => setState(() => _reminders.add(_ReminderDraft())),
      icon: Icon(Icons.add_circle_outline, size: 18, color: c.accent),
      label: Text('Thêm nhắc nhở', style: TextStyle(color: c.accent)),
      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
    );
  }

  Widget _buildSaveButton(BuildContext context, AppColorScheme c) {
    return ElevatedButton(
      onPressed: _saving ? null : () => _save(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: c.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        elevation: 0,
      ),
      child: _saving
          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : Text(
              widget.event != null ? 'Cập nhật' : 'Lưu sự kiện',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
    );
  }

  Future<void> _save(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final reminders = _reminders.map((d) => EventReminder(
      eventId: widget.event?.id ?? 0,
      type: ReminderType.push,
      offset: d.offset,
      hour: d.hour,
      minute: d.minute,
    )).toList();
    final recipients = _recipients
        .where((r) => r.address.trim().isNotEmpty)
        .map((r) => EventRecipient(
              eventId: widget.event?.id ?? 0,
              channel: r.channel,
              address: r.address.trim(),
            ))
        .toList();
    final event = LunarEvent(
      id: widget.event?.id,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      lunarDay: _lunarDay,
      lunarMonth: _lunarMonth,
      isLeapMonth: _isLeapMonth,
      recurrence: _recurrence,
      colorIndex: _colorIndex,
      reminders: reminders,
      recipients: recipients,
    );
    final provider = context.read<EventsProvider>();
    if (widget.event != null) {
      await provider.updateEvent(event);
    } else {
      await provider.addEvent(event);
    }
    if (context.mounted) Navigator.pop(context);
  }

  Future<void> _deleteEvent(BuildContext context, AppColorScheme c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Xóa sự kiện', style: TextStyle(color: c.textPrimary)),
        content: Text('Bạn có chắc muốn xóa sự kiện này?', style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Hủy', style: TextStyle(color: c.accent))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Xóa', style: TextStyle(color: c.eventRed))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<EventsProvider>().deleteEvent(widget.event!.id!);
      if (context.mounted) Navigator.pop(context);
    }
  }
}

class _ReminderDraft {
  ReminderType type;
  ReminderOffset offset;
  String contactInfo;
  int hour;
  int minute;

  _ReminderDraft({
    this.type = ReminderType.push,
    this.offset = ReminderOffset.oneDayBefore,
    this.contactInfo = '',
    this.hour = 8,
    this.minute = 0,
  });
}

class _RecipientDraft {
  RecipientChannel channel;
  String address;

  _RecipientDraft({
    this.channel = RecipientChannel.email,
    this.address = '',
  });
}
