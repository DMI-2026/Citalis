import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/business_image.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  static const _hero =
      'https://images.unsplash.com/photo-1600948836101-f9ffda59d250?w=1200&q=80&auto=format&fit=crop';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ink,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BusinessImage(url: _hero, fallbackLetter: 'C'),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x33000000),
                  Color(0x66000000),
                  Color(0xCC000000),
                ],
                stops: [0.0, 0.45, 1.0],
              ),
            ),
            child: SizedBox.expand(),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('CITALIS',
                          style: AppTheme.eyebrow(color: Colors.white)
                              .copyWith(letterSpacing: 3)),
                      const Spacer(),
                      Text('EST. 2026',
                          style: AppTheme.eyebrow(color: Colors.white70)),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    'Belleza,\nreservada\ncon calma.',
                    style: AppTheme.display(
                      size: 52,
                      weight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 280,
                    child: Text(
                      'Encuentra salones, spas y estudios curados cerca de ti. Reserva en segundos.',
                      style: AppTheme.sans(
                        size: 15,
                        color: Colors.white.withValues(alpha: 0.85),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppTheme.ink,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterScreen()),
                      ),
                      child: const Text('Crear cuenta'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        textStyle: AppTheme.sans(
                          size: 14,
                          color: Colors.white,
                          weight: FontWeight.w500,
                        ),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
                      child: const Text('Ya tengo una cuenta'),
                    ),
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
