import 'package:flutter/material.dart';

import 'data/mock_data.dart';
import 'screens/booking_confirmation_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/business/business_home_screen.dart';
import 'screens/business_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/home_screen.dart';
import 'screens/legal_screens.dart';
import 'screens/login_screen.dart';
import 'screens/register_business_screen.dart';
import 'screens/register_screen.dart';
import 'screens/reservations_screen.dart';
import 'screens/settings_screens.dart';
import 'screens/welcome_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const CitalisApp());
}

class CitalisApp extends StatelessWidget {
  const CitalisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Citalis',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: '/',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '/');
    final q = uri.queryParameters;
    Widget page;

    switch (uri.path) {
      case '/':
      case '/welcome':
        page = const WelcomeScreen();
      case '/login':
        page = const LoginScreen();
      case '/register':
        page = const RegisterScreen();
      case '/home':
        page = const HomeScreen();
      case '/reservations':
        page = const Scaffold(body: SafeArea(child: ReservationsScreen()));
      case '/favorites':
        page = const Scaffold(body: SafeArea(child: FavoritesScreen()));
      case '/profile':
        page = const HomeScreen(initialTab: 3);
      case '/register-business':
        page = const RegisterBusinessScreen();
      case '/business-home':
        page = const BusinessHomeScreen();
      case '/edit-profile':
        page = const EditProfileScreen();
      case '/change-password':
        page = const ChangePasswordScreen();
      case '/notifications':
        page = const NotificationsScreen();
      case '/payments':
        page = const PaymentMethodsScreen();
      case '/location':
        page = const LocationScreen();
      case '/privacy':
        page = const PrivacyScreen();
      case '/terms':
        page = const TermsScreen();
      case '/help':
        page = const HelpScreen();
      case '/business':
        page = BusinessDetailScreen(
          business: businessById(q['id'] ?? 'b1'),
        );
      case '/booking':
        final b = businessById(q['id'] ?? 'b1');
        final s = int.tryParse(q['s'] ?? '0') ?? 0;
        page = BookingScreen(business: b, service: b.services[s]);
      case '/confirmation':
        final b = businessById(q['id'] ?? 'b1');
        final seed = Reservation(
          id: 'demo',
          business: b,
          service: b.services[0],
          when: DateTime.now().add(const Duration(days: 2, hours: 3)),
          status: ReservationStatus.upcoming,
        );
        page = BookingConfirmationScreen(reservation: seed);
      default:
        page = const WelcomeScreen();
    }

    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}
