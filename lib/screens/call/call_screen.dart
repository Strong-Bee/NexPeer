import 'package:flutter/material.dart';

class CallScreen extends StatelessWidget {
  const CallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final calls = [
      const CallItem(
        name: 'Peer User',
        type: CallType.outgoing,
        time: '10:30',
        duration: '2 min 15 sec',
      ),
      const CallItem(
        name: 'Alex',
        type: CallType.incoming,
        time: '09:45',
        duration: '5 min 42 sec',
      ),
      const CallItem(
        name: 'John',
        type: CallType.missed,
        time: 'Yesterday',
        duration: '',
      ),
      const CallItem(
        name: 'Sarah',
        type: CallType.outgoing,
        time: 'Yesterday',
        duration: '1 min 20 sec',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calls',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: calls.length,
        itemBuilder: (context, index) {
          return _CallTile(call: calls[index]);
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_call),
      ),
    );
  }
}

enum CallType {
  incoming,
  outgoing,
  missed,
}

class CallItem {
  final String name;
  final CallType type;
  final String time;
  final String duration;

  const CallItem({
    required this.name,
    required this.type,
    required this.time,
    required this.duration,
  });
}

class _CallTile extends StatelessWidget {
  final CallItem call;

  const _CallTile({
    required this.call,
  });

  Color get _color {
    switch (call.type) {
      case CallType.incoming:
        return Colors.green;

      case CallType.outgoing:
        return Colors.blue;

      case CallType.missed:
        return Colors.red;
    }
  }

  IconData get _icon {
    switch (call.type) {
      case CallType.incoming:
        return Icons.call_received;

      case CallType.outgoing:
        return Icons.call_made;

      case CallType.missed:
        return Icons.call_missed;
    }
  }

  String get _label {
    switch (call.type) {
      case CallType.incoming:
        return 'Incoming call';

      case CallType.outgoing:
        return 'Outgoing call';

      case CallType.missed:
        return 'Missed call';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),

        // PROFILE
        leading: Stack(
          children: [
            const CircleAvatar(
              radius: 27,
              child: Icon(Icons.person),
            ),

            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0B1020),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _icon,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),

        // NAME + CALL TYPE
        title: Text(
          call.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        subtitle: Row(
          children: [
            Icon(
              _icon,
              size: 15,
              color: _color,
            ),
            const SizedBox(width: 5),
            Text(
              _label,
              style: TextStyle(
                color: _color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (call.duration.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                '• ${call.duration}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),

        // TIME + CALL BUTTON
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              call.time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 5),
            Icon(
              Icons.phone,
              size: 19,
              color: _color,
            ),
          ],
        ),

        onTap: () {
          // TODO:
          // Mulai voice call ke peer.
        },
      ),
    );
  }
}
