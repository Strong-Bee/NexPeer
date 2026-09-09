import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/p2p_service.dart';

class ChatScreen extends StatefulWidget {
  final String peerName;
  final String? peerId;

  const ChatScreen({super.key, required this.peerName, this.peerId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final P2PService _p2pService = P2PService.instance;

  final TextEditingController _messageController = TextEditingController();

  final TextEditingController _searchController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  StreamSubscription<String>? _messageSubscription;

  final List<ChatMessage> _messages = [];

  bool _searching = false;
  bool _sending = false;

  @override
  void initState() {
    super.initState();

    _messageSubscription = _p2pService.messages.listen(_handleIncomingMessage);
  }

  // ============================================================
  // INCOMING MESSAGE
  // ============================================================

  void _handleIncomingMessage(String message) {
    if (!mounted || message.trim().isEmpty) return;

    final shouldScroll = _isNearBottom;

    setState(() {
      _messages.add(
        ChatMessage(
          text: message,
          isMe: false,
          time: _currentTime(),
          status: MessageStatus.delivered,
        ),
      );
    });

    if (shouldScroll) {
      _scrollToBottom();
    }
  }

  // ============================================================
  // SEND MESSAGE
  // ============================================================

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty || _sending) return;

    if (!_p2pService.isConnected) {
      _showMessage('Belum terhubung ke peer.');
      return;
    }

    setState(() {
      _sending = true;
    });

    try {
      await _p2pService.sendMessage(text);

      if (!mounted) return;

      setState(() {
        _messages.add(
          ChatMessage(
            text: text,
            isMe: true,
            time: _currentTime(),
            status: MessageStatus.sent,
          ),
        );
      });

      _messageController.clear();

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      _showMessage('Gagal mengirim pesan: $e');
    } finally {
      if (mounted) {
        setState(() {
          _sending = false;
        });
      }
    }
  }

  // ============================================================
  // SCROLL
  // ============================================================

  bool get _isNearBottom {
    if (!_scrollController.hasClients) {
      return true;
    }

    final position = _scrollController.position;

    return position.maxScrollExtent - position.pixels < 150;
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      final target = _scrollController.position.maxScrollExtent;

      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  // ============================================================
  // TIME
  // ============================================================

  String _currentTime() {
    return TimeOfDay.now().format(context);
  }

  // ============================================================
  // MESSAGE ACTION
  // ============================================================

  void _showMessageMenu(int index, ChatMessage message) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('Copy'),
                onTap: () {
                  Navigator.pop(context);
                  _copyMessage(message);
                },
              ),
              ListTile(
                leading: const Icon(Icons.reply),
                title: const Text('Reply'),
                onTap: () {
                  Navigator.pop(context);

                  _messageController.text = '> ${message.text}\n';

                  FocusScope.of(context).requestFocus(FocusNode());
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);

                  setState(() {
                    _messages.removeAt(index);
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyMessage(ChatMessage message) {
    // Clipboard akan kita tambahkan menggunakan
    // package:flutter/services.dart jika diperlukan.
    _showMessage('Pesan disalin: ${message.text}');
  }

  // ============================================================
  // ATTACHMENT
  // ============================================================

  void _showAttachmentMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _AttachmentButton(
                  icon: Icons.photo,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage(
                      'Gallery akan dihubungkan ke P2P file transfer.',
                    );
                  },
                ),
                _AttachmentButton(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage(
                      'Camera akan dihubungkan ke P2P file transfer.',
                    );
                  },
                ),
                _AttachmentButton(
                  icon: Icons.insert_drive_file,
                  label: 'File',
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage(
                      'File picker akan dihubungkan ke P2P transfer.',
                    );
                  },
                ),
                _AttachmentButton(
                  icon: Icons.location_on,
                  label: 'Location',
                  onTap: () {
                    Navigator.pop(context);
                    _showMessage('Location sharing akan ditambahkan.');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  void _startSearch() {
    setState(() {
      _searching = true;
    });
  }

  void _stopSearch() {
    _searchController.clear();

    setState(() {
      _searching = false;
    });
  }

  List<ChatMessage> get _filteredMessages {
    final query = _searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return _messages;
    }

    return _messages.where((message) {
      return message.text.toLowerCase().contains(query);
    }).toList();
  }

  // ============================================================
  // CHAT MENU
  // ============================================================

  void _showChatMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search messages'),
                onTap: () {
                  Navigator.pop(context);
                  _startSearch();
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications_off),
                title: const Text('Mute notifications'),
                onTap: () {
                  Navigator.pop(context);
                  _showMessage('Notifications dimatikan.');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep),
                title: const Text('Clear chat'),
                onTap: () {
                  Navigator.pop(context);
                  _confirmClearChat();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CLEAR CHAT
  // ============================================================

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear chat?'),
          content: const Text(
            'Semua pesan lokal dalam percakapan ini akan dihapus.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  _messages.clear();
                });
              },
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // CALL
  // ============================================================

  void _startVoiceCall() {
    _showMessage('Voice call P2P akan dihubungkan ke call service.');
  }

  void _startVideoCall() {
    _showMessage('Video call P2P akan dihubungkan ke call service.');
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageController.dispose();
    _searchController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,

        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (_) {
                  setState(() {});
                },
                decoration: const InputDecoration(
                  hintText: 'Search messages...',
                  border: InputBorder.none,
                ),
              )
            : Row(
                children: [
                  const CircleAvatar(
                    radius: 19,
                    child: Icon(Icons.person, size: 19),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.peerName,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        StreamBuilder<bool>(
                          stream: _p2pService.connectionStatus,
                          initialData: _p2pService.isConnected,
                          builder: (context, snapshot) {
                            final connected = snapshot.data ?? false;

                            return Text(
                              connected ? 'P2P Connected' : 'Disconnected',
                              style: TextStyle(
                                fontSize: 11,
                                color: connected
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

        actions: _searching
            ? [
                IconButton(
                  onPressed: _stopSearch,
                  icon: const Icon(Icons.close),
                ),
              ]
            : [
                IconButton(
                  onPressed: _startVoiceCall,
                  icon: const Icon(Icons.call_outlined),
                ),
                IconButton(
                  onPressed: _startVideoCall,
                  icon: const Icon(Icons.videocam_outlined),
                ),
                IconButton(
                  onPressed: _showChatMenu,
                  icon: const Icon(Icons.more_vert),
                ),
              ],
      ),

      body: Column(
        children: [
          Expanded(
            child: _filteredMessages.isEmpty
                ? const _EmptyChat()
                : ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                    itemCount: _filteredMessages.length,
                    itemBuilder: (context, index) {
                      final message = _filteredMessages[index];

                      final originalIndex = _messages.indexOf(message);

                      return GestureDetector(
                        onLongPress: () {
                          _showMessageMenu(originalIndex, message);
                        },
                        child: MessageBubble(message: message),
                      );
                    },
                  ),
          ),

          _MessageInput(
            controller: _messageController,
            onSend: _sendMessage,
            onAttachment: _showAttachmentMenu,
            sending: _sending,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHAT MESSAGE
// ============================================================

enum MessageStatus { sending, sent, delivered, read }

class ChatMessage {
  final String text;
  final bool isMe;
  final String time;
  final MessageStatus status;

  const ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
    this.status = MessageStatus.sent,
  });
}

// ============================================================
// MESSAGE BUBBLE
// ============================================================

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  IconData get _statusIcon {
    switch (message.status) {
      case MessageStatus.sending:
        return Icons.access_time;

      case MessageStatus.sent:
        return Icons.check;

      case MessageStatus.delivered:
        return Icons.done_all;

      case MessageStatus.read:
        return Icons.done_all;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(15, 10, 12, 7),
        decoration: BoxDecoration(
          color: message.isMe
              ? Colors.blue
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(message.isMe ? 18 : 4),
            bottomRight: Radius.circular(message.isMe ? 4 : 18),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.text,
                style: const TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.time,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.55),
                  ),
                ),

                if (message.isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    _statusIcon,
                    size: 14,
                    color: message.status == MessageStatus.read
                        ? Colors.lightBlueAccent
                        : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// MESSAGE INPUT
// ============================================================

class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttachment;
  final bool sending;

  const _MessageInput({
    required this.controller,
    required this.onSend,
    required this.onAttachment,
    required this.sending,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 7, 10, 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: onAttachment,
              icon: const Icon(Icons.attach_file),
            ),

            Expanded(
              child: TextField(
                controller: controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Message...',
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 7),

            CircleAvatar(
              radius: 23,
              backgroundColor: Colors.blue,
              child: sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : IconButton(
                      onPressed: onSend,
                      icon: const Icon(Icons.send, size: 19),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ATTACHMENT BUTTON
// ============================================================

class _AttachmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachmentButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(radius: 27, child: Icon(icon)),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY CHAT
// ============================================================

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 50, color: Colors.white24),
            SizedBox(height: 15),
            Text(
              'Private P2P Chat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6),
            Text(
              'Messages will be exchanged directly '
              'between connected devices.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
