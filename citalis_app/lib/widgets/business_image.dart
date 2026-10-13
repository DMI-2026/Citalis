import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

class BusinessImage extends StatelessWidget {
  final String url;
  final String fallbackLetter;
  final BoxFit fit;

  const BusinessImage({
    super.key,
    required this.url,
    required this.fallbackLetter,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: fit,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _Placeholder(letter: fallbackLetter);
      },
      errorBuilder: (context, error, stack) =>
          _Placeholder(letter: fallbackLetter),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String letter;
  const _Placeholder({required this.letter});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.surfaceAlt, Color(0xFFE2DDD4)],
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: AppTheme.serif(
          size: 56,
          weight: FontWeight.w400,
          color: AppTheme.inkMuted,
        ),
      ),
    );
  }
}

Future<void> openInMaps({String? query, double? lat, double? lng}) async {
  Uri uri;
  if (lat != null && lng != null) {
    uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
  } else {
    final q = Uri.encodeComponent(query ?? '');
    uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$q');
  }
  await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );
}

Future<void> openUrl(String url) async {
  await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
    webOnlyWindowName: '_blank',
  );
}
