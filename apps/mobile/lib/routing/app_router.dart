import 'package:flutter/material.dart';

import '../ui/auth/widgets/login_screen.dart';
import '../ui/auth/widgets/register_screen.dart';
import '../ui/auth/widgets/welcome_screen.dart';
import '../ui/booking/widgets/booking_confirmation_screen.dart';
import '../ui/booking/widgets/booking_screen.dart';
import '../ui/business_detail/widgets/business_detail_screen.dart';
import '../ui/business_owner/widgets/business_home_screen.dart';
import '../ui/business_owner/widgets/register_business_screen.dart';
import '../ui/favorites/widgets/favorites_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/legal/widgets/legal_screens.dart';
import '../ui/reservations/widgets/reservations_screen.dart';
import '../ui/settings/widgets/settings_screens.dart';

/// Rutas por URL (deep links y web). La navegación interna entre pantallas
/// usa `Navigator.push` directamente.
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final uri = Uri.parse(settings.name ?? '/');
  final q = uri.queryParameters;
  final id = q['id'];
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
    case '/business' when id != null:
      page = BusinessDetailScreen(businessId: id);
    case '/booking' when id != null && q['service'] != null:
      page = BookingScreen(businessId: id, serviceId: q['service']!);
    case '/confirmation' when id != null:
      page = BookingConfirmationScreen(reservationId: id);
    default:
      page = const WelcomeScreen();
  }

  return MaterialPageRoute(builder: (_) => page, settings: settings);
}
