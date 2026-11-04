import 'package:url_launcher/url_launcher.dart';

Future<void> openInMaps({String? query, double? lat, double? lng}) async {
  Uri uri;
  if (lat != null && lng != null) {
    uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
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
