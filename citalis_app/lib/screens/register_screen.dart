import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Crear cuenta', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text('Comienza\ncon Citalis.',
                  style: AppTheme.display(size: 36, weight: FontWeight.w400)),
              const SizedBox(height: 10),
              Text('Reserva, guarda favoritos y lleva tu historial.',
                  style: AppTheme.sans(size: 15, color: AppTheme.inkMuted)),
              const SizedBox(height: 40),
              Text('Nombre', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: 'Tu nombre completo'),
              ),
              const SizedBox(height: 20),
              Text('Correo', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              const TextField(
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(hintText: 'tu@correo.com'),
              ),
              const SizedBox(height: 20),
              Text('Contraseña', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              TextField(
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Mínimo 8 caracteres',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppTheme.inkMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_box_outlined,
                        size: 18, color: AppTheme.ink),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Acepto los términos y la política de privacidad de Citalis.',
                      style: AppTheme.sans(size: 13, color: AppTheme.inkMuted),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                  (_) => false,
                ),
                child: const Text('Crear cuenta'),
              ),
              const SizedBox(height: 28),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('¿Ya tienes cuenta?  ',
                        style: AppTheme.sans(
                            size: 14, color: AppTheme.inkMuted)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      ),
                      child: Text(
                        'Entrar',
                        style: AppTheme.sans(
                          size: 14,
                          weight: FontWeight.w600,
                        ).copyWith(decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
