import 'package:flutter/material.dart';
import '../../theme.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(
        title: const Text('Звонки'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {},
            tooltip: 'Поиск звонков',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('История звонков будет здесь', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
                SizedBox(height: 10),
                Text('Telegram-style звонки пока не реализованы на сервере, но здесь можно показывать входящие и исходящие вызовы.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _CallPreview(
            name: 'Анна',
            direction: 'Входящий',
            time: 'Сегодня, 18:24',
            icon: Icons.call_received,
          ),
          _CallPreview(
            name: 'Группа друзей',
            direction: 'Исходящий',
            time: 'Вчера, 21:05',
            icon: Icons.call_made,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_call),
              label: const Text('Новый звонок'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CallPreview extends StatelessWidget {
  final String name;
  final String direction;
  final String time;
  final IconData icon;

  const _CallPreview({required this.name, required this.direction, required this.time, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bg3,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          const _CallAvatar(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(direction, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 2),
                Text(time, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Icon(icon, color: AppColors.primary, size: 22),
        ],
      ),
    );
  }
}

class _CallAvatar extends StatelessWidget {
  const _CallAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.18),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.call, color: AppColors.primary),
    );
  }
}
