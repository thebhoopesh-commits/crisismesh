import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chat/chat_screen.dart';
import '../map/map_screen.dart';
import '../mesh/mesh_screen.dart';
import 'app_header.dart';

final tabIndexProvider = StateProvider<int>((ref) => 1);

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int tabIndex = ref.watch(tabIndexProvider);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppHeader(),
      ),
      body: IndexedStack(
        index: tabIndex,
        children: const [
          ChatScreen(),
          MapScreen(),
          MeshScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabIndex,
        onTap: (i) => ref.read(tabIndexProvider.notifier).state = i,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'AI Triage',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined),
            activeIcon: Icon(Icons.location_on),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hub_outlined),
            activeIcon: Icon(Icons.hub),
            label: 'Mesh',
          ),
        ],
      ),
    );
  }
}
