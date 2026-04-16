import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../models/user.dart';
import '../../services/api.dart';
import '../../services/ws.dart';
import '../../theme.dart';
import '../../widgets/avatar.dart';
import '../auth/email_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _user;
  bool _loading = true;
  bool _editing = false;
  bool _saving = false;
  String? _error;
  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _statusCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _bioCtrl = TextEditingController();
    _statusCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _load();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _statusCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await ApiService.getMe();
      if (!mounted) return;
      final user = User.fromJson(data);
      setState(() {
        _user = user;
        _nameCtrl.text = user.displayName;
        _bioCtrl.text = user.bio ?? '';
        _statusCtrl.text = user.statusText ?? '';
        _phoneCtrl.text = user.phone ?? '';
        _loading = false;
      });
    } catch (e, stack) {
      debugPrint('Profile load error: $e\n$stack');
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _uploadAvatar() async {
    final picker = ImagePicker();
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            const Text('Сменить фото', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Камера', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Галерея', style: TextStyle(color: AppColors.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_user?.avatarUrl != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.red),
                title: const Text('Удалить фото', style: TextStyle(color: AppColors.red)),
                onTap: () => Navigator.pop(context, null),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted) return;

    if (source == null && _user?.avatarUrl != null) {
      setState(() => _saving = true);
      try {
        final data = await ApiService.updateProfile(avatarUrl: '');
        if (!mounted) return;
        setState(() { _user = User.fromJson(data); _saving = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Фото удалено'), backgroundColor: AppColors.bg3, behavior: SnackBarBehavior.floating),
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
        );
      }
      return;
    }

    if (source == null) return;

    final XFile? image = await picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 85);
    if (image == null || !mounted) return;

    setState(() => _saving = true);
    try {
      final uploaded = await ApiService.uploadAvatar(File(image.path));
      if (!mounted) return;
      final data = await ApiService.updateProfile(avatarUrl: uploaded);
      if (!mounted) return;
      setState(() { _user = User.fromJson(data); _saving = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото обновлено ✓'), backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      String msg = e.toString();
      if (msg.contains('404')) msg = 'Сервер не поддерживает загрузку фото (404). Обратитесь к разработчику.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final data = await ApiService.updateProfile(
        displayName: _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        avatarUrl: _user?.avatarUrl,
        statusText: _statusCtrl.text.trim().isEmpty ? null : _statusCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _user = User.fromJson(data);
        _editing = false;
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль обновлён'), backgroundColor: AppColors.green, behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bg3,
        title: const Text('Выйти из аккаунта?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Вы будете перенаправлены на экран входа.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Выйти', style: TextStyle(color: AppColors.red))),
        ],
      ),
    );
    if (confirm == true) {
      wsService.disconnect();
      await ApiService.deleteToken();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const EmailScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(
        title: const Text('Профиль'),
        actions: [
          if (_user != null)
            IconButton(
              icon: Icon(_editing ? Icons.close : Icons.edit_outlined, color: AppColors.primary),
              onPressed: () => setState(() { _editing = !_editing; if (!_editing) _load(); }),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: AppColors.red, size: 48),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Повторить'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                        decoration: BoxDecoration(
                          color: AppColors.bg3,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.divider),                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.16), blurRadius: 20, offset: const Offset(0, 8)),
                            ],                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: _saving ? null : _uploadAvatar,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  AppAvatar(name: _user!.displayName, url: _user!.avatarUrl, size: 90),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.bg1, width: 2),
                                      ),
                                      child: _saving
                                          ? const Padding(padding: EdgeInsets.all(6), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (!_editing) ...[
                        Text(_user!.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        Text('@${_user!.username}', style: const TextStyle(color: AppColors.primary, fontSize: 14)),
                        if (_user!.statusText != null && _user!.statusText!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(color: AppColors.bg3, borderRadius: BorderRadius.circular(16)),
                            child: Text(_user!.statusText!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ),
                        ],
                        if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Text(_user!.bio!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4), textAlign: TextAlign.center),
                        ],
                      ] else ...[
                        const SizedBox(height: 8),
                        _Field('Отображаемое имя', _nameCtrl),
                        const SizedBox(height: 12),
                        _Field('Номер телефона', _phoneCtrl, hint: '+71234567890'),
                        const SizedBox(height: 12),
                        _Field('Статус', _statusCtrl, hint: 'Что у вас на уме?'),
                        const SizedBox(height: 12),
                        _Field('О себе', _bioCtrl, maxLines: 4, hint: 'Расскажите о себе'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                              : const Text('Сохранить'),
                        ),
                      ],
                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: AppColors.bg2,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.divider),                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 16, offset: const Offset(0, 6)),
                            ],                        ),
                        child: Column(
                          children: [
                            if (!_editing) ...[
                              _InfoTile(icon: Icons.email_outlined, label: 'Email', value: _user!.email, onTap: () => Clipboard.setData(ClipboardData(text: _user!.email))),
                              _InfoTile(icon: Icons.phone_outlined, label: 'Телефон', value: _user!.phone ?? 'Не указан', onTap: _user!.phone != null ? () => Clipboard.setData(ClipboardData(text: _user!.phone!)) : null),
                              _InfoTile(icon: Icons.alternate_email, label: 'Username', value: '@${_user!.username}', onTap: () => Clipboard.setData(ClipboardData(text: _user!.username))),
                              if (_user!.statusText != null && _user!.statusText!.isNotEmpty)
                                _InfoTile(icon: Icons.mood, label: 'Статус', value: _user!.statusText!),
                              const SizedBox(height: 16),
                            ],
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.security_outlined, color: AppColors.primary),
                              title: const Text('Безопасность', style: TextStyle(color: AppColors.textPrimary)),
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen(initialSection: 'security'))),
                            ),
                            ListTile(
                              leading: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                              title: const Text('Уведомления', style: TextStyle(color: AppColors.textPrimary)),
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen(initialSection: 'notifications'))),
                            ),
                            ListTile(
                              leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                              title: const Text('Оформление', style: TextStyle(color: AppColors.textPrimary)),
                              trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen(initialSection: 'appearance'))),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.logout_rounded, color: AppColors.red),
                              title: const Text('Выйти', style: TextStyle(color: AppColors.red)),
                              onTap: _logout,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final int maxLines;
  final String? hint;
  const _Field(this.label, this.ctrl, {this.maxLines = 1, this.hint});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary),
          maxLines: maxLines,
          minLines: 1,
          decoration: InputDecoration(
            hintText: hint ?? label,
            filled: true,
            fillColor: AppColors.bg4,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _InfoTile({required this.icon, required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bg2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.copy, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}
