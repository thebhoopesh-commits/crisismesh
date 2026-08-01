import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/mesh_provider.dart';
import '../services/mesh_service.dart';
import '../models/incident.dart';

class MeshScreen extends ConsumerStatefulWidget {
  const MeshScreen({super.key});

  @override
  ConsumerState<MeshScreen> createState() => _MeshScreenState();
}

class _MeshScreenState extends ConsumerState<MeshScreen> {
  final TextEditingController _msgController = TextEditingController();
  final List<String> _messages = [];
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    // Bind mesh messages directly to this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meshServiceProvider).initialize();
      ref.read(meshServiceProvider).onMessageReceived = (text) {
        if (mounted) {
          setState(() {
            _messages.add("📡 Received: $text");
          });
        }
      };
    });
  }

  void _sendMessage() async {
    if (_msgController.text.trim().isEmpty) return;
    
    final text = _msgController.text.trim();
    setState(() {
      _messages.add("You: $text");
    });
    
    // Broadcast via Mesh
    int sentCount = await ref.read(meshServiceProvider).broadcast(Incident(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: "Mesh Broadcast",
      summary: text,
      priority: TriagePriority.yellow,
      status: IncidentStatus.active,
      locationLabel: "Local Node",
      createdAt: DateTime.now(),
      notes: text,
      supplies: [],
      vitals: {},
      latitude: 0,
      longitude: 0,
    ));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Broadcasted to $sentCount peers'),
          duration: const Duration(seconds: 1),
        ),
      );
    }

    _msgController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final peers = ref.watch(meshProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mesh Network & Chat',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  if (_isScanning)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
            ),
            
            // Connection Status
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: _buildStatusCard(peers.length),
            ),
            
            const SizedBox(height: 16),
            
            // Connected Peers
            if (peers.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Connected Peers',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: peers.length,
                  itemBuilder: (context, index) {
                    final peer = peers[index];
                    return _buildPeerTile(peer.id, peer.callsign);
                  },
                ),
              ),
            ],
            
            const Divider(height: 32),
            
            // Chat Log
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg.startsWith("You:");
                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMe ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: isMe ? null : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        msg,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.text,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Input Box
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.surface,
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _msgController,
                        decoration: InputDecoration(
                          hintText: peers.isEmpty 
                              ? 'Waiting for connection...' 
                              : 'Send message to mesh...',
                          filled: true,
                          fillColor: AppColors.bg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      onPressed: peers.isEmpty ? null : _sendMessage,
                      mini: true,
                      backgroundColor: peers.isEmpty ? Colors.grey : AppColors.primary,
                      elevation: 0,
                      child: const Icon(Icons.send, color: Colors.white, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(int peerCount) {
    bool isConnected = peerCount > 0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isConnected ? AppColors.stable : AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isConnected ? 'Connected ($peerCount peers)' : 'Scanning for Peers...',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Icon(
                isConnected ? Icons.bluetooth : Icons.bluetooth_disabled, 
                color: isConnected ? AppColors.stable : AppColors.textMuted, 
                size: 20
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeerTile(String id, String callsign) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.smartphone, color: AppColors.primary),
          const SizedBox(height: 8),
          Text(
            callsign,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            'ID: $id',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
