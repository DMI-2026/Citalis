import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Estado "cargando" estándar (F6).
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.ink),
        ),
      ),
    );
  }
}

/// Estado "error" estándar con botón de reintento (F6, F7).
class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppTheme.inkMuted),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTheme.sans(size: 14, color: AppTheme.inkMuted),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

/// Muestra un error de una acción (guardar, cancelar…) en un SnackBar.
void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: AppTheme.sans(size: 14, color: Colors.white),
      ),
      backgroundColor: AppTheme.danger,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
