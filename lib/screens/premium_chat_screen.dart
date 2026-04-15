import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';

/// Premium Chat Message Bubble with Glassmorphism effect
class PremiumChatBubble extends StatefulWidget {
  final String message;
  final String timestamp;
  final bool isOwn;
  final bool isRead;
  final VoidCallback? onLongPress;
  final Function(String)? onReply;
  final List<String>? reactions;
  final bool isEncrypted;

  const PremiumChatBubble({
    required this.message,
    required this.timestamp,
    required this.isOwn,
    this.isRead = false,
    this.onLongPress,
    this.onReply,
    this.reactions,
    this.isEncrypted = true,
  });

  @override
  State<PremiumChatBubble> createState() => _PremiumChatBubbleState();
}

class _PremiumChatBubbleState extends State<PremiumChatBubble> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _fadeAnimation]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: ScaleTransition(
            scale: _scaleAnimation,
            alignment: widget.isOwn ? Alignment.centerRight : Alignment.centerLeft,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          mainAxisAlignment: widget.isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!widget.isOwn) ...[
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, color: Colors.grey[700]),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: MouseRegion(
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onLongPress: widget.onLongPress,
                  child: _buildBubble(context),
                ),
              ),
            ),
            if (widget.isOwn) ...[
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (widget.isEncrypted)
                    Icon(Icons.lock_outline, size: 14, color: Colors.blue),
                  const SizedBox(height: 2),
                  Icon(
                    widget.isRead ? Icons.done_all : Icons.done,
                    size: 14,
                    color: widget.isRead ? Colors.blue : Colors.grey,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context) {
    return Stack(
      children: [
        // Glassmorphism Background
        ClipRRect(
          borderRadius: _getBorderRadius(),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isOwn
                    ? Colors.blue.withOpacity(0.15)
                    : Colors.white.withOpacity(0.08),
                border: Border.all(
                  color: widget.isOwn
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                borderRadius: _getBorderRadius(),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.isOwn
                              ? Colors.blue.withOpacity(0.2)
                              : Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Column(
                  crossAxisAlignment: widget.isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    // Message text with gradient effect
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: widget.isOwn
                            ? [Colors.blue[900]!, Colors.blue[600]!]
                            : [Colors.grey[900]!, Colors.grey[700]!],
                      ).createShader(bounds),
                      child: Text(
                        widget.message,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                        maxLines: null,
                        softWrap: true,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Timestamp with animation
                    Text(
                      DateFormat('HH:mm').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.isOwn
                            ? Colors.blue[300]?.withOpacity(0.7)
                            : Colors.grey[500]?.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        // Animated border glow on hover
        if (_isHovered)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: _getBorderRadius(),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: widget.isOwn
                        ? Colors.blue.withOpacity(0.5)
                        : Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: _getBorderRadius(),
                ),
              ),
            ),
          ),
      ],
    );
  }

  BorderRadius _getBorderRadius() {
    if (widget.isOwn) {
      return const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      );
    }
  }
}

/// Premium Chat Screen with Full Features
class PremiumChatScreen extends StatefulWidget {
  final String chatTitle;
  final String chatDescription;
  final String avatarUrl;

  const PremiumChatScreen({
    required this.chatTitle,
    required this.chatDescription,
    required this.avatarUrl,
  });

  @override
  State<PremiumChatScreen> createState() => _PremiumChatScreenState();
}

class _PremiumChatScreenState extends State<PremiumChatScreen>
    with TickerProviderStateMixin {
  late TextEditingController _messageController;
  late AnimationController _sendButtonController;
  late AnimationController _inputFocusController;
  
  final List<Map<String, dynamic>> _messages = [
    {
      'message': 'Hey! This is a premium messenger built with Flutter & C++',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'isOwn': false,
      'isRead': true,
      'reactions': ['❤️', '👍'],
    },
    {
      'message': 'All messages are E2E encrypted with ChaCha20-Poly1305',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
      'isOwn': true,
      'isRead': true,
    },
    {
      'message': 'Supports reactions, typing indicators, and more!',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
      'isOwn': false,
      'isRead': true,
    },
  ];

  bool _isTyping = false;
  bool _isOnline = true;
  
  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _sendButtonController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _inputFocusController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _sendButtonController.dispose();
    _inputFocusController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    _sendButtonController.forward().then((_) {
      _sendButtonController.reverse();
    });

    setState(() {
      _messages.add({
        'message': _messageController.text,
        'timestamp': DateTime.now(),
        'isOwn': true,
        'isRead': true,
      });
      _messageController.clear();
      _isTyping = false;
    });

    // Simulate delivery confirmation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Message encrypted & sent'),
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.green.withOpacity(0.8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildGlassAppBar(),
      body: _buildChatBody(),
      bottomNavigationBar: _buildMessageInputBar(),
    );
  }

  PreferredSizeWidget _buildGlassAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.blue.withOpacity(0.1),
            elevation: 0,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.chatTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isOnline ? Colors.green : Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isOnline ? 'online' : 'offline',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.call),
                onPressed: () => _showFeatureDialog('Call', 'WebRTC voice call will start'),
              ),
              IconButton(
                icon: const Icon(Icons.videocam),
                onPressed: () => _showFeatureDialog('Video Call', 'WebRTC video call will start'),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showFeatureDialog('Info', 'Chat details and settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChatBody() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blue.withOpacity(0.05),
            Colors.purple.withOpacity(0.02),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: kToolbarHeight + 10),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              itemCount: _messages.length,
              reverse: false,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return PremiumChatBubble(
                  message: msg['message'],
                  timestamp: DateFormat('HH:mm').format(msg['timestamp']),
                  isOwn: msg['isOwn'],
                  isRead: msg['isRead'] ?? false,
                  isEncrypted: msg['isOwn'] ?? true,
                  onLongPress: () => _showMessageOptions(msg),
                  reactions: msg['reactions'],
                );
              },
            ),
          ),
          // Typing indicator
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const CircleAvatar(radius: 12),
                  const SizedBox(width: 8),
                  Text(
                    'is typing',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildTypingAnimation(),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingAnimation() {
    return Row(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1000),
            builder: (context, value, child) {
              final animValue = (value + i * 0.15).clamp(0, 1).toDouble();
              return Transform.scale(
                scale: 0.7 + (animValue * 0.3),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildMessageInputBar() {
    return BackdropFilter(
      filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        padding: EdgeInsets.only(
          left: 12,
          right: 12,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: () => _showFeatureDialog('Attachments', 'Share photos, videos, files'),
              color: Colors.blue,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _messageController,
                  maxLines: null,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isTyping = value.isNotEmpty;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(width: 8),
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 0.9).animate(_sendButtonController),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blue[900]!],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white),
                  onPressed: _sendMessage,
                  splashRadius: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessageOptions(Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(color: Colors.white.withOpacity(0.2)),
                ListTile(
                  leading: const Icon(Icons.reply),
                  title: const Text('Reply'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.emoji_emotions),
                  title: const Text('React'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Save'),
                  onTap: () => Navigator.pop(context),
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Delete', style: TextStyle(color: Colors.red)),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFeatureDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
