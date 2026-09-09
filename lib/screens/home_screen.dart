import 'package:flutter/material.dart';

import 'call/call_screen.dart';
import 'chat/chat_screen.dart';
import 'profile/profile_screen.dart';
import 'story/story_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ChatHomeScreen(),
    StoryScreen(),
    CallScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_stories_outlined),
            selectedIcon: Icon(Icons.auto_stories_rounded),
            label: 'Story',
          ),
          NavigationDestination(
            icon: Icon(Icons.call_outlined),
            selectedIcon: Icon(Icons.call_rounded),
            label: 'Call',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class ChatHomeScreen extends StatefulWidget {
  const ChatHomeScreen({super.key});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _chats = [
    {
      'name': 'Peer User',
      'message': 'Tap untuk mulai chat',
      'time': 'Now',
      'online': true,
      'unread': 0,
      'avatar': Icons.person_rounded,
    },
    {
      'name': 'Alex',
      'message': 'Hello 👋',
      'time': '10:30',
      'online': true,
      'unread': 2,
      'avatar': Icons.person_rounded,
    },
    {
      'name': 'John',
      'message': 'See you later',
      'time': '09:15',
      'online': false,
      'unread': 0,
      'avatar': Icons.person_rounded,
    },
    {
      'name': 'Sarah',
      'message': 'Okay 👍',
      'time': 'Yesterday',
      'online': false,
      'unread': 4,
      'avatar': Icons.person_rounded,
    },
  ];

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text.trim().toLowerCase();
    });
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_onSearchChanged)
      ..dispose();

    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredChats {
    if (_searchQuery.isEmpty) {
      return _chats;
    }

    return _chats.where((chat) {
      final name = chat['name'].toString().toLowerCase();

      final message = chat['message'].toString().toLowerCase();

      return name.contains(_searchQuery) || message.contains(_searchQuery);
    }).toList();
  }

  void _openChat(Map<String, dynamic> chat) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          peerName: chat['name'].toString(),
          peerId: chat['name'].toString(),
        ),
      ),
    );
  }

  void _newChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151D33),
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'New chat',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person_add_alt_1_rounded),
                  ),
                  title: const Text('Add new peer'),
                  subtitle: const Text('Connect dengan perangkat lain'),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showMessage('Fitur Add Peer akan segera tersedia.');
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.qr_code_scanner_rounded),
                  ),
                  title: const Text('Scan QR'),
                  subtitle: const Text('Scan QR untuk terhubung dengan peer'),
                  onTap: () {
                    Navigator.pop(sheetContext);

                    _showMessage('QR scanner akan segera tersedia.');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChatMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151D33),
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.devices_rounded),
                title: const Text('Connected devices'),
                onTap: () {
                  Navigator.pop(sheetContext);

                  _showMessage('Device manager akan segera tersedia.');
                },
              ),
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archived chats'),
                onTap: () {
                  Navigator.pop(sheetContext);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_outlined),
                title: const Text('Chat settings'),
                onTap: () {
                  Navigator.pop(sheetContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chats = _filteredChats;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'NexPeer',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              FocusScope.of(context).requestFocus();
            },
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            tooltip: 'More',
            onPressed: _showChatMenu,
            icon: const Icon(Icons.more_vert_rounded),
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search chats...',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF151D33),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),

          Expanded(
            child: chats.isEmpty
                ? const _EmptyChatSearch()
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: chats.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 84,
                    ),
                    itemBuilder: (context, index) {
                      final chat = chats[index];

                      return _ChatItem(
                        name: chat['name'].toString(),
                        message: chat['message'].toString(),
                        time: chat['time'].toString(),
                        online: chat['online'] as bool,
                        unread: chat['unread'] as int,
                        avatar: chat['avatar'] as IconData,
                        onTap: () => _openChat(chat),
                      );
                    },
                  ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _newChat,
        tooltip: 'New chat',
        child: const Icon(Icons.chat_rounded),
      ),
    );
  }
}

class _ChatItem extends StatelessWidget {
  final String name;
  final String message;
  final String time;
  final bool online;
  final int unread;
  final IconData avatar;
  final VoidCallback onTap;

  const _ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.online,
    required this.unread,
    required this.avatar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFF1E293B),
            child: Icon(avatar, size: 28),
          ),

          if (online)
            Positioned(
              right: -1,
              bottom: 0,
              child: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2.5,
                  ),
                ),
              ),
            ),
        ],
      ),

      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ),

          const SizedBox(width: 8),

          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: unread > 0
                  ? const Color(0xFF60A5FA)
                  : Colors.grey.shade500,
              fontWeight: unread > 0 ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),

      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            Expanded(
              child: Text(
                message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: unread > 0 ? Colors.white : Colors.grey.shade400,
                  fontWeight: unread > 0 ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),

            if (unread > 0) ...[
              const SizedBox(width: 8),

              Container(
                constraints: const BoxConstraints(minWidth: 22),
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 6),
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  unread > 99 ? '99+' : unread.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyChatSearch extends StatelessWidget {
  const _EmptyChatSearch();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFF151D33),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.search_off_rounded,
                size: 38,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'No chats found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 8),

            Text(
              'Tidak ada percakapan yang cocok '
              'dengan pencarian Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
