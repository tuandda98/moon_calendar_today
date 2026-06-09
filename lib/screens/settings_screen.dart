import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/theme_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifEnabled = true;
  bool _remRam = true;
  bool _remMung1 = true;
  String _defaultEmail = '';
  final _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifEnabled = prefs.getBool('notif_enabled') ?? true;
      _remRam = prefs.getBool('remind_ram') ?? true;
      _remMung1 = prefs.getBool('remind_mung1') ?? true;
      _defaultEmail = prefs.getString('default_email') ?? '';
      _emailCtrl.text = _defaultEmail;
    });
  }

  Future<void> _savePref(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColorScheme.of(context);
    return Scaffold(
      backgroundColor: c.background,
      body: SafeArea(
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Text(
                'Cài đặt',
                style: TextStyle(color: c.textPrimary, fontSize: 26, fontWeight: FontWeight.w300, letterSpacing: 1),
              ),
            ),
            _buildSectionLabel(c, 'GIAO DIỆN'),
            _buildThemeTile(c),
            const SizedBox(height: 8),
            _buildSectionLabel(c, 'THÔNG BÁO'),
            _buildSwitchTile(
              c,
              icon: Icons.notifications_outlined,
              title: 'Thông báo đẩy',
              subtitle: 'Nhận thông báo push cho sự kiện',
              value: _notifEnabled,
              onChanged: (v) async {
                if (v) await NotificationService.instance.requestPermission();
                setState(() => _notifEnabled = v);
                _savePref('notif_enabled', v);
              },
            ),
            _buildSwitchTile(
              c,
              icon: Icons.brightness_1,
              title: 'Nhắc ngày Rằm',
              subtitle: 'Tự động nhắc ngày 15 âm lịch',
              value: _remRam,
              onChanged: (v) { setState(() => _remRam = v); _savePref('remind_ram', v); },
            ),
            _buildSwitchTile(
              c,
              icon: Icons.brightness_2_outlined,
              title: 'Nhắc Mùng 1',
              subtitle: 'Tự động nhắc đầu tháng âm lịch',
              value: _remMung1,
              onChanged: (v) { setState(() => _remMung1 = v); _savePref('remind_mung1', v); },
            ),
            const SizedBox(height: 8),
            _buildSectionLabel(c, 'EMAIL'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.border, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email mặc định để nhận nhắc nhở', style: TextStyle(color: c.textSecondary, fontSize: 13)),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailCtrl,
                      style: TextStyle(color: c.textPrimary, fontSize: 14),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'your@email.com',
                        prefixIcon: Icon(Icons.email_outlined, size: 18, color: c.textDim),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onSubmitted: (v) { _savePref('default_email', v); setState(() => _defaultEmail = v); },
                    ),
                    const SizedBox(height: 8),
                    Text('App sẽ mở ứng dụng mail để gửi nhắc nhở', style: TextStyle(color: c.textDim, fontSize: 11)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            _buildSectionLabel(c, 'THÔNG TIN'),
            _buildInfoTile(c, icon: Icons.brightness_2_outlined, title: 'Múi giờ', subtitle: 'Việt Nam (UTC+7)'),
            _buildInfoTile(c, icon: Icons.info_outline, title: 'Phiên bản', subtitle: '1.0.0'),
            _buildActionTile(
              c,
              icon: Icons.notifications_off_outlined,
              title: 'Hủy tất cả thông báo',
              subtitle: 'Xóa tất cả thông báo đã lên lịch',
              color: c.eventRed,
              onTap: () => _cancelAllNotifs(context, c),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTile(AppColorScheme c) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.border, width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  themeProvider.isLight ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  color: c.primaryDim,
                  size: 20,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giao diện', style: TextStyle(color: c.textPrimary, fontSize: 14)),
                      Text(
                        themeProvider.isLight ? 'Sáng' : 'Tối',
                        style: TextStyle(color: c.textDim, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    _themeOption(
                      c,
                      icon: Icons.dark_mode_outlined,
                      label: 'Tối',
                      selected: !themeProvider.isLight,
                      onTap: () => themeProvider.setMode(ThemeMode.dark),
                    ),
                    const SizedBox(width: 8),
                    _themeOption(
                      c,
                      icon: Icons.light_mode_outlined,
                      label: 'Sáng',
                      selected: themeProvider.isLight,
                      onTap: () => themeProvider.setMode(ThemeMode.light),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _themeOption(AppColorScheme c, {required IconData icon, required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? c.accentGlow : c.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? c.accent : c.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? c.primary : c.textDim),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: selected ? c.primary : c.textSecondary, fontSize: 12, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(AppColorScheme c, String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        text,
        style: TextStyle(color: c.textDim, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSwitchTile(AppColorScheme c, {required IconData icon, required String title, required String subtitle, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: c.primaryDim, size: 20),
        title: Text(title, style: TextStyle(color: c.textPrimary, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: c.textDim, fontSize: 12)),
        value: value,
        onChanged: onChanged,
        activeThumbColor: c.accent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildInfoTile(AppColorScheme c, {required IconData icon, required String title, required String subtitle}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: c.primaryDim, size: 20),
        title: Text(title, style: TextStyle(color: c.textPrimary, fontSize: 14)),
        trailing: Text(subtitle, style: TextStyle(color: c.textSecondary, fontSize: 13)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildActionTile(AppColorScheme c, {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.border, width: 0.5),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color, size: 20),
        title: Text(title, style: TextStyle(color: color, fontSize: 14)),
        subtitle: Text(subtitle, style: TextStyle(color: c.textDim, fontSize: 12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  Future<void> _cancelAllNotifs(BuildContext context, AppColorScheme c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.surface,
        title: Text('Hủy thông báo', style: TextStyle(color: c.textPrimary)),
        content: Text('Hủy tất cả thông báo đã lên lịch?', style: TextStyle(color: c.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Hủy bỏ', style: TextStyle(color: c.accent))),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text('Đồng ý', style: TextStyle(color: c.eventRed))),
        ],
      ),
    );
    if (ok == true) {
      await NotificationService.instance.cancelAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đã hủy tất cả thông báo'),
            backgroundColor: c.surfaceVariant,
          ),
        );
      }
    }
  }
}
