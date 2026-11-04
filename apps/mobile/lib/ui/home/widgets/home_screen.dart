import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../explore/widgets/explore_tab.dart';
import '../../favorites/widgets/favorites_screen.dart';
import '../../profile/widgets/profile_screen.dart';
import '../../reservations/widgets/reservations_screen.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _selectedTab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const ExploreTab(),
      const ReservationsScreen(),
      const FavoritesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(bottom: false, child: tabs[_selectedTab]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.line)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedTab,
          onDestinationSelected: (i) => setState(() => _selectedTab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded),
              label: 'Explorar',
            ),
            NavigationDestination(
              icon: Icon(Icons.event_available_outlined),
              selectedIcon: Icon(Icons.event_available_rounded),
              label: 'Reservas',
            ),
            NavigationDestination(
              icon: Icon(Icons.bookmark_outline_rounded),
              selectedIcon: Icon(Icons.bookmark_rounded),
              label: 'Guardados',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
