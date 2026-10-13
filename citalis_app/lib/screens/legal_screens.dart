import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class _LegalScreen extends StatelessWidget {
  final String title;
  final String eyebrow;
  final List<Section> sections;

  const _LegalScreen({
    required this.title,
    required this.eyebrow,
    required this.sections,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(title, style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          children: [
            Text(eyebrow, style: AppTheme.eyebrow()),
            const SizedBox(height: 10),
            Text(title,
                style: AppTheme.display(size: 32, weight: FontWeight.w400)),
            const SizedBox(height: 32),
            for (final s in sections) ...[
              Text(s.title.toUpperCase(), style: AppTheme.eyebrow()),
              const SizedBox(height: 8),
              Text(s.body,
                  style: AppTheme.sans(
                      size: 14, color: AppTheme.inkMuted, height: 1.6)),
              const SizedBox(height: 28),
            ],
          ],
        ),
      ),
    );
  }
}

class Section {
  final String title;
  final String body;
  const Section(this.title, this.body);
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalScreen(
      title: 'Privacidad y datos',
      eyebrow: 'CÓMO CUIDAMOS TU INFORMACIÓN',
      sections: [
        Section(
          'Datos que recopilamos',
          'Nombre, correo, teléfono y las reservas que realizas. Opcionalmente tu ubicación aproximada para mostrarte negocios cercanos. No almacenamos datos de tarjeta — se procesan por el gateway correspondiente.',
        ),
        Section(
          'Para qué los usamos',
          'Vincularte con los negocios donde reservas, enviarte recordatorios de citas y mejorar los resultados de búsqueda. Nunca compartimos tus datos con terceros con fines publicitarios.',
        ),
        Section(
          'Tus derechos ARCO',
          'Puedes acceder, rectificar, cancelar u oponerte al tratamiento de tus datos escribiendo a privacidad@citalis.app. Tu solicitud se atiende dentro de los 20 días hábiles.',
        ),
        Section(
          'Retención',
          'Conservamos tu historial mientras tu cuenta esté activa. Si eliminas tu cuenta, los datos personales se purgan en 30 días.',
        ),
      ],
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _LegalScreen(
      title: 'Términos y condiciones',
      eyebrow: 'ACUERDO DE USO',
      sections: [
        Section(
          'Uso de la plataforma',
          'Citalis conecta a clientes con negocios de belleza para gestión de citas. No prestamos servicios directamente — somos un intermediario tecnológico. La relación comercial final es entre el cliente y el negocio.',
        ),
        Section(
          'Reservas y cancelaciones',
          'El cliente puede cancelar una reserva hasta 2 horas antes sin cargo. Después de ese margen, el negocio puede aplicar su política de cancelación. Los negocios se comprometen a honrar las reservas confirmadas.',
        ),
        Section(
          'Responsabilidades del negocio',
          'El propietario garantiza que los datos de su perfil son verídicos, que ofrece los servicios anunciados y que cumple con las normativas sanitarias y fiscales aplicables a su actividad.',
        ),
        Section(
          'Suspensión de cuenta',
          'Podemos suspender cuentas que incumplan estos términos o que generen reportes reiterados de otros usuarios.',
        ),
      ],
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Centro de ayuda', style: AppTheme.serif(size: 16)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
          children: [
            Text('AYUDA Y SOPORTE', style: AppTheme.eyebrow()),
            const SizedBox(height: 10),
            Text('¿En qué te podemos\nayudar?',
                style: AppTheme.display(size: 30, weight: FontWeight.w400)),
            const SizedBox(height: 28),
            _HelpCard(
              icon: Icons.event_repeat_outlined,
              title: '¿Cómo cambio una reserva?',
              body:
                  'Ve a la pestaña Reservas, abre la cita y toca Cancelar. Luego vuelve a reservar en el horario que prefieras. No hay cargo si lo haces con más de 2 horas de anticipación.',
            ),
            _HelpCard(
              icon: Icons.store_outlined,
              title: '¿Cómo registro mi negocio?',
              body:
                  'En tu perfil, toca "Registrar mi negocio". Completas los datos básicos y el perfil queda listo para recibir reservas. Es gratis durante el beta.',
            ),
            _HelpCard(
              icon: Icons.qr_code_rounded,
              title: '¿Para qué sirve el QR de mi negocio?',
              body:
                  'Es un enlace único a tu perfil. Cuando un cliente lo escanea, abre la app directo en tu negocio para reservar en un par de clics.',
            ),
            _HelpCard(
              icon: Icons.wifi_off_rounded,
              title: '¿Qué pasa si pierdo conexión?',
              body:
                  'Verás un aviso en la parte superior. Puedes seguir explorando el contenido ya cargado; las reservas quedarán en cola hasta que vuelva internet.',
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline,
                          size: 16, color: AppTheme.ink),
                      const SizedBox(width: 8),
                      Text('¿No encuentras lo que buscas?',
                          style: AppTheme.sans(
                              size: 14, weight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Escríbenos a soporte@citalis.app y te respondemos en menos de 24 horas.',
                    style: AppTheme.sans(
                        size: 13, color: AppTheme.inkMuted, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _HelpCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.ink),
              const SizedBox(width: 10),
              Expanded(
                child: Text(title,
                    style: AppTheme.serif(size: 16, weight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(body,
              style: AppTheme.sans(
                  size: 13, color: AppTheme.inkMuted, height: 1.5)),
        ],
      ),
    );
  }
}
