import 'package:flutter/material.dart';

import '../services/p2p_service.dart';
import 'chat/chat_screen.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key});

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  final P2PService _p2pService = P2PService.instance;

  bool _scanning = false;

  final List<PeerDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _p2pService.initialize();
  }

  Future<void> _scanDevices() async {
    setState(() {
      _scanning = true;
      _devices.clear();
    });

    try {
      // TODO:
      // Hubungkan discovery dengan
      // flutter_p2p_connection ^3.0.3.
      //
      // Setelah API P2P dipasang, device yang ditemukan
      // akan dimasukkan ke dalam _devices.

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() {
        _scanning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan selesai. P2P discovery siap dihubungkan.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _scanning = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal melakukan scan: $e')));
    }
  }

  Future<void> _connectToDevice(PeerDevice device) async {
    try {
      // TODO:
      // Hubungkan dengan API connection dari
      // flutter_p2p_connection.

      _p2pService.setConnected(device.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(peerName: device.name, peerId: device.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal terhubung ke ${device.name}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text(
              'Nearby Devices',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: _scanning ? null : _scanDevices,
                icon: _scanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.blue.withValues(alpha: 0.10),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.radar, size: 55, color: Colors.blueAccent),
                        SizedBox(height: 12),
                        Text(
                          'Find nearby peers',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Discover devices available for '
                          'a direct P2P connection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: FilledButton.icon(
                      onPressed: _scanning ? null : _scanDevices,
                      icon: _scanning
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.search),
                      label: Text(_scanning ? 'Scanning...' : 'Scan Devices'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_devices.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.devices_other_outlined,
                        size: 65,
                        color: Colors.white24,
                      ),
                      SizedBox(height: 15),
                      Text(
                        'No devices found',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Make sure the other device is '
                        'available for P2P connection.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              sliver: SliverList.builder(
                itemCount: _devices.length,
                itemBuilder: (context, index) {
                  final device = _devices[index];

                  return ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.smartphone)),
                    title: Text(device.name),
                    subtitle: Text(device.id),
                    trailing: FilledButton(
                      onPressed: () => _connectToDevice(device),
                      child: const Text('Connect'),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class PeerDevice {
  final String id;
  final String name;

  const PeerDevice({required this.id, required this.name});
}
