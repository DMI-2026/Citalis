import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_views.dart';
import '../../home/widgets/home_screen.dart';
import '../view_models/business_home_view_model.dart';
import 'business_agenda_tab.dart';
import 'business_clients_tab.dart';
import 'business_profile_tab.dart';
import 'business_services_tab.dart';

class BusinessHomeScreen extends StatelessWidget {
  const BusinessHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          BusinessHomeViewModel(myBusinessRepository: context.read())..load(),
      child: const _BusinessHomeView(),
    );
  }
}

class _BusinessHomeView extends StatelessWidget {
  const _BusinessHomeView();

  void _switchToClient(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BusinessHomeViewModel>();
    final b = vm.business;
    if (b == null) {
      if (vm.isLoading) return const Scaffold(body: LoadingView());
      if (vm.errorMessage != null) {
        return Scaffold(
          body: ErrorView(message: vm.errorMessage!, onRetry: vm.load),
        );
      }
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
              currentTab: titles[vm.tab],
              onSwitchToClient: () => _switchToClient(context),
            ),
            Expanded(child: tabs[vm.tab]),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.line)),
        ),
        child: NavigationBar(
          selectedIndex: vm.tab,
          onDestinationSelected: vm.selectTab,
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
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.ink,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'MODO EMPRESA',
                        style: AppTheme.sans(
                          size: 9,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(category.toUpperCase(), style: AppTheme.eyebrow()),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: AppTheme.serif(size: 22, weight: FontWeight.w500),
                ),
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
                  const Icon(
                    Icons.swap_horiz_rounded,
                    size: 16,
                    color: AppTheme.ink,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cliente',
                    style: AppTheme.sans(size: 12, weight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
