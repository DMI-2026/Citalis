import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../home_screen.dart';
import 'business_agenda_tab.dart';
import 'business_clients_tab.dart';
import 'business_profile_tab.dart';
import 'business_services_tab.dart';

class BusinessHomeScreen extends StatefulWidget {
  const BusinessHomeScreen({super.key});

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  final AppState _state = AppState.instance;
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    _state.addListener(_onChange);
  }

  @override
  void dispose() {
    _state.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => mounted ? setState(() {}) : null;

  void _switchToClient() {
    _state.switchMode(AppMode.client);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = _state.myBusiness;
    if (b == null) {
      return const Scaffold(
        body: Center(child: Text('Aún no has registrado un negocio.')),
      );
    }

    final tabs = const [
      BusinessAgendaTab(),
      BusinessServicesTab(),
      BusinessClientsTab(),
      BusinessProfileTab(),
    ];

    final titles = const ['Agenda', 'Servicios', 'Clientes', 'Mi negocio'];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _BusinessHeader(
              name: b.name,
              category: b.category,
              currentTab: titles[_tab],
              onSwitchToClient: _switchToClient,
            ),
            Expanded(child: tabs[_tab]),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.line)),
        ),
        child: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded),
              label: 'Agenda',
            ),
            NavigationDestination(
              icon: Icon(Icons.layers_outlined),
              selectedIcon: Icon(Icons.layers_rounded),
              label: 'Servicios',
            ),
            NavigationDestination(
              icon: Icon(Icons.people_outline_rounded),
              selectedIcon: Icon(Icons.people_rounded),
              label: 'Clientes',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Negocio',
            ),
          ],
        ),
      ),
    );
  }
}

class _BusinessHeader extends StatelessWidget {
  final String name;
  final String category;
  final String currentTab;
  final VoidCallback onSwitchToClient;

  const _BusinessHeader({
    required this.name,
    required this.category,
    required this.currentTab,
    required this.onSwitchToClient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: const BoxDecoration(
        color: AppTheme.background,
        border: Border(bottom: BorderSide(color: AppTheme.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.ink,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('MODO EMPRESA',
                          style: AppTheme.sans(
                              size: 9,
                              weight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 1.2)),
                    ),
                    const SizedBox(width: 8),
                    Text(category.toUpperCase(), style: AppTheme.eyebrow()),
                  ],
                ),
                const SizedBox(height: 6),
                Text(name,
                    style: AppTheme.serif(size: 22, weight: FontWeight.w500)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSwitchToClient,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppTheme.line),
              ),
              child: Row(
                children: [
                  const Icon(Icons.swap_horiz_rounded,
                      size: 16, color: AppTheme.ink),
                  const SizedBox(width: 6),
                  Text('Cliente',
                      style: AppTheme.sans(
                          size: 12, weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
