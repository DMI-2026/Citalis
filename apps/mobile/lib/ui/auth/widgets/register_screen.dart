import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_views.dart';
import '../../home/widgets/home_screen.dart';
import '../view_models/register_view_model.dart';
import 'login_screen.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => RegisterViewModel(authRepository: context.read()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final error = await context.read<RegisterViewModel>().register(
      name: _name.text,
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();
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
              Text(
                'Comienza\ncon Citalis.',
                style: AppTheme.display(size: 36, weight: FontWeight.w400),
              ),
              const SizedBox(height: 10),
              Text(
                'Reserva, guarda favoritos y lleva tu historial.',
                style: AppTheme.sans(size: 15, color: AppTheme.inkMuted),
              ),
              const SizedBox(height: 40),
              Text('Nombre', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  hintText: 'Tu nombre completo',
                ),
              ),
              const SizedBox(height: 20),
              Text('Correo', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'tu@correo.com'),
              ),
              const SizedBox(height: 20),
              Text('Contraseña', style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              TextField(
                controller: _password,
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
                    child: Icon(
                      Icons.check_box_outlined,
                      size: 18,
                      color: AppTheme.ink,
                    ),
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
                onPressed: vm.isSubmitting ? null : _register,
                child: const Text('Crear cuenta'),
              ),
              const SizedBox(height: 28),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta?  ',
                      style: AppTheme.sans(size: 14, color: AppTheme.inkMuted),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
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
