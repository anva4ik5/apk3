import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/chat.dart';
import '../../services/api.dart';
import '../../services/ws.dart';
import '../../theme.dart';
import '../../widgets/avatar.dart';
import 'chat_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});
  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  List<Chat> _chats = [];
  List<Chat> _filtered = [];
  bool _loading = true;
  String _search = '';
  StreamSubscription? _wsSub;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('ru', timeago.RuMessages());
    _load();
    _wsSub = wsService.messages.listen(_onWsMsg);
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await ApiService.getChats();
      if (!mounted) return;
      setState(() {
        _chats = data.map((j) => Chat.fromJson(j as Map<String, dynamic>)).toList();
        _applyFilter();
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onWsMsg(Map<String, dynamic> msg) {
    final type = msg['type'];
    if (type == 'new_message') {
      _load();
    } else if (type == 'user_status') {
      final userId = msg['userId'] as String;
      final isOnline = msg['isOnline'] as bool;
      setState(() {
        _chats = _chats.map((c) {
          if (c.otherUserId == userId) return c.copyWith(otherUserOnline: isOnline);
          return c;
        }).toList();
        _applyFilter();
      });
    }
  }

  void _applyFilter() {
    final q = _search.toLowerCase();
    _filtered = q.isEmpty
        ? List.from(_chats)
        : _chats.where((c) => c.displayName.toLowerCase().contains(q)).toList();
  }

  void _onSearch(String q) {
    setState(() { _search = q; _applyFilter(); });
  }

  void _openNewChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bg2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.textMuted.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('Новый чат', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.person_outline, color: AppColors.primary),
              ),
              title: const Text('Личный чат', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              subtitle: const Text('Написать пользователю', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.bg2,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  isScrollControlled: true,
                  builder: (_) => _NewChatSheet(onStart: (userId) async {
                    final result = await ApiService.openDirectChat(userId);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: result['chatId'])));
                    _load();
                  }),
                );
              },
            ),
            ListTile(
              leading: Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: AppColors.green.withOpacity(0.15), shape: BoxShape.circle),
                child: const Icon(Icons.group_outlined, color: AppColors.green),
              ),
              title: const Text('Создать группу', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
              subtitle: const Text('Группа для общения', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  context: context,
                  backgroundColor: AppColors.bg2,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  isScrollControlled: true,
                  builder: (_) => _CreateGroupSheet(onCreate: (chatId) {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatId: chatId)));
                    _load();
                  }),
                );
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg1,
      appBar: AppBar(
        title: const Text('Сообщения'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square, color: AppColors.primary),
            onPressed: () => _openNewChat(context),
            tooltip: 'Новый чат',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              onChanged: _onSearch,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Поиск чатов...',
                fillColor: AppColors.bg3,
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
                suffixIcon: _search.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.close, color: AppColors.textMuted, size: 18), onPressed: () { setState(() { _search = ''; _applyFilter(); }); })
                    : null,
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filtered.isEmpty
                    ? _EmptyState(hasSearch: _search.isNotEmpty)
                    : RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.bg2,
                        onRefresh: _load,
                        child: ListView.builder(
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) => _ChatTile(chat: _filtered[i], onTap: () async {
                            await Navigator.push(context, MaterialPageRoute(
                              builder: (_) => ChatScreen(chatId: _filtered[i].id),
                            ));
                            _load();
                          }),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;
  const _ChatTile({required this.chat, required this.onTap});

  String get _preview {
    if (chat.lastMessage == null) return 'Нет сообщений';
    if (chat.lastMessageType == 'image') return '📷 Изображение';
    if (chat.lastMessageType == 'file') return '📎 Файл';
    if (chat.lastMessageType == 'ai') return '🤖 ${chat.lastMessage!}';
    return chat.lastMessage!;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            AppAvatar(
              name: chat.displayName,
              url: chat.displayAvatar,
              size: 52,
              showOnline: chat.type == 'direct',
              isOnline: chat.otherUserOnline,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          chat.displayName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.lastMessageAt != null)
                        Text(
                          timeago.format(chat.lastMessageAt!, locale: 'ru'),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (chat.isMuted)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.volume_off, size: 13, color: AppColors.textMuted),
                        ),
                      Expanded(
                        child: Text(
                          _preview,
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: chat.isMuted ? AppColors.textMuted : AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            chat.unreadCount > 99 ? '99+' : '${chat.unreadCount}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
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

class _EmptyState extends StatelessWidget {
  final bool hasSearch;
  const _EmptyState({required this.hasSearch});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(hasSearch ? Icons.search_off : Icons.chat_bubble_outline_rounded,
              size: 64, color: AppColors.textMuted.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            hasSearch ? 'Ничего не найдено' : 'Нет чатов\nНажмите ✏️ чтобы начать',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _NewChatSheet extends StatefulWidget {
  final Future<void> Function(String userId) onStart;
  const _NewChatSheet({required this.onStart});
  @override
  State<_NewChatSheet> createState() => _NewChatSheetState();
}

class _NewChatSheetState extends State<_NewChatSheet> {
  List<dynamic> _results = [];
  bool _loading = false;
  Timer? _debounce;

  void _search(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) { setState(() => _results = []); return; }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _loading = true);
      try {
        final r = await ApiService.searchUsersGlobal(q.trim());
        if (mounted) setState(() { _results = r; _loading = false; });
      } catch (_) {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.textMuted.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          const Text('Новый чат', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              onChanged: _search,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Поиск по имени, @username или телефону',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    controller: ctrl,
                    itemCount: _results.length,
                    itemBuilder: (_, i) {
                      final u = _results[i];
                      return ListTile(
                        leading: AppAvatar(
                          name: u['display_name'] ?? u['username'],
                          url: u['avatar_url'],
                          size: 44,
                          showOnline: true,
                          isOnline: u['is_online'] ?? false,
                        ),
                        title: Text(u['display_name'] ?? u['username'], style: const TextStyle(color: AppColors.textPrimary)),
                        subtitle: Text('@${u['username']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        onTap: () => widget.onStart(u['id']),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _CreateGroupSheet extends StatefulWidget {
  final void Function(String chatId) onCreate;
  const _CreateGroupSheet({required this.onCreate});
  @override
  State<_CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<_CreateGroupSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<dynamic> _searchResults = [];
  final List<Map<String, dynamic>> _selected = [];
  bool _searching = false;
  bool _creating = false;
  Timer? _debounce;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearch(String q) {
    _debounce?.cancel();
    if (q.trim().length < 2) { setState(() => _searchResults = []); return; }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _searching = true);
      try {
        final r = await ApiService.searchUsersGlobal(q.trim());
        if (mounted) setState(() { _searchResults = r; _searching = false; });
      } catch (_) {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  void _toggleUser(Map<String, dynamic> u) {
    final id = u['id'] as String;
    setState(() {
      if (_selected.any((s) => s['id'] == id)) {
        _selected.removeWhere((s) => s['id'] == id);
      } else {
        _selected.add(u);
      }
    });
  }

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите название группы'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Добавьте хотя бы одного участника'), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _creating = true);
    try {
      final memberIds = _selected.map((u) => u['id'] as String).toList();
      final result = await ApiService.createGroup(
        _nameCtrl.text.trim(),
        memberIds,
        description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      );
      if (!mounted) return;
      widget.onCreate(result['chatId'] ?? result['id']);
    } catch (e) {
      if (mounted) {
        setState(() => _creating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red, behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.textMuted.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Expanded(child: Text('Создать группу', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                TextButton(
                  onPressed: _creating ? null : _create,
                  child: _creating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                      : const Text('Создать', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Название группы', prefixIcon: Icon(Icons.group, color: AppColors.textMuted, size: 20)),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _descCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(hintText: 'Описание (необязательно)', prefixIcon: Icon(Icons.info_outline, color: AppColors.textMuted, size: 20)),
            ),
          ),
          const SizedBox(height: 8),
          if (_selected.isNotEmpty)
            SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _selected.length,
                itemBuilder: (_, i) {
                  final u = _selected[i];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            AppAvatar(name: u['display_name'] ?? u['username'], url: u['avatar_url'], size: 40),
                            Positioned(
                              right: 0, top: 0,
                              child: GestureDetector(
                                onTap: () => _toggleUser(u),
                                child: Container(
                                  width: 16, height: 16,
                                  decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                                  child: const Icon(Icons.close, size: 10, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(u['display_name'] ?? u['username'], style: const TextStyle(color: AppColors.textSecondary, fontSize: 10), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              onChanged: _onSearch,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Добавить участников...',
                prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 20),
              ),
            ),
          ),
          Expanded(
            child: _searching
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : ListView.builder(
                    controller: ctrl,
                    itemCount: _searchResults.length,
                    itemBuilder: (_, i) {
                      final u = _searchResults[i];
                      final isSelected = _selected.any((s) => s['id'] == u['id']);
                      return ListTile(
                        leading: AppAvatar(name: u['display_name'] ?? u['username'], url: u['avatar_url'], size: 44),
                        title: Text(u['display_name'] ?? u['username'], style: const TextStyle(color: AppColors.textPrimary)),
                        subtitle: Text('@${u['username']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: AppColors.primary)
                            : const Icon(Icons.radio_button_unchecked, color: AppColors.textMuted),
                        onTap: () => _toggleUser(u as Map<String, dynamic>),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
