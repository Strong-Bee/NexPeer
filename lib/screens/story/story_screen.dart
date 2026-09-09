import 'package:flutter/material.dart';

class StoryScreen extends StatefulWidget {
  const StoryScreen({super.key});

  @override
  State<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final List<StoryItem> stories = [
    const StoryItem(name: 'Alex', icon: Icons.person, hasStory: true),
    const StoryItem(name: 'John', icon: Icons.person, hasStory: true),
    const StoryItem(name: 'Sarah', icon: Icons.person, hasStory: true),
  ];

  void _addStory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur tambah story segera tersedia')),
    );
  }

  void _openStory(StoryItem story) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            height: 500,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2563EB), Color(0xFF0B1020)],
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 55,
                    child: Icon(story.icon, size: 55),
                  ),
                ),

                Positioned(
                  top: 20,
                  left: 20,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        child: Icon(story.icon, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        story.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: 15,
                  right: 10,
                  child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ),

                const Positioned(
                  bottom: 25,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'Story dari peer',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Story',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.camera_alt_outlined),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert)),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'My Story',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 115,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                StoryAvatar(
                  name: 'My Story',
                  icon: Icons.add,
                  isAdd: true,
                  onTap: _addStory,
                ),

                ...stories.map(
                  (story) => StoryAvatar(
                    name: story.name,
                    icon: story.icon,
                    hasStory: story.hasStory,
                    onTap: () => _openStory(story),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          const Text(
            'Recent Stories',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          if (stories.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Belum ada story baru',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...stories.map(
              (story) => ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: StoryRing(icon: story.icon),
                title: Text(
                  story.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: const Text('Story tersedia'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openStory(story),
              ),
            ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addStory,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class StoryItem {
  final String name;
  final IconData icon;
  final bool hasStory;

  const StoryItem({
    required this.name,
    required this.icon,
    required this.hasStory,
  });
}

class StoryAvatar extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isAdd;
  final bool hasStory;
  final VoidCallback? onTap;

  const StoryAvatar({
    super.key,
    required this.name,
    required this.icon,
    this.isAdd = false,
    this.hasStory = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isAdd || !hasStory
                    ? null
                    : const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                      ),
                border: isAdd ? Border.all(color: Colors.grey, width: 2) : null,
              ),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: isAdd
                    ? Colors.white.withValues(alpha: 0.08)
                    : null,
                child: Icon(icon, size: isAdd ? 30 : 32),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class StoryRing extends StatelessWidget {
  final IconData icon;

  const StoryRing({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
        ),
      ),
      child: CircleAvatar(radius: 27, child: Icon(icon, size: 27)),
    );
  }
}
