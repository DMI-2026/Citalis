import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_views.dart';
import '../../home/widgets/home_screen.dart';
import '../view_models/login_view_model.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewModel(authRepository: context.read()),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _goHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Future<void> _login() async {
    final error = await context.read<LoginViewModel>().login(
      email: _email.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
    } else {
      _goHome();
    }
  }

  Future<void> _forgotPassword() async {
    final error = await context.read<LoginViewModel>().sendPasswordReset(
      _email.text,
    );
    if (!mounted) return;
    if (error != null) {
      showErrorSnackBar(context, error);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Te enviamos un correo para restablecer tu contraseña',
          style: AppTheme.sans(size: 14, color: Colors.white),
        ),
        backgroundColor: AppTheme.ink,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Entrar', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Bienvenido\nde vuelta.',
                style: AppTheme.display(size: 36, weight: FontWeight.w400),
              ),
              const SizedBox(height: 10),
              Text(
                'Reserva tu próxima cita en segundos.',
                style: AppTheme.sans(size: 15, color: AppTheme.inkMuted),
              ),
              const SizedBox(height: 40),
              Text('Correo electrónico', style: AppTheme.eyebrow()),
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
                  hintText: '••••••••',
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
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text('Olvidé mi contraseña'),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: vm.isSubmitting ? null : _login,
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 20),
              Row(
                children: const [
                  Expanded(child: Divider(color: AppTheme.line)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'o',
                      style: TextStyle(color: AppTheme.inkMuted),
                    ),
                  ),
                  Expanded(child: Divider(color: AppTheme.line)),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _goHome,
                icon: const Icon(Icons.apple, size: 20),
                label: const Text('Continuar con Apple'),
              ),
              const SizedBox(height: 28),
              Center(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '¿Nueva en Citalis?  ',
                      style: AppTheme.sans(size: 14, color: AppTheme.inkMuted),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                      child: Text(
                        'Crear cuenta',
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
