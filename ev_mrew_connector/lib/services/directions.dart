import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/station.dart';

Future<void> openDirections(BuildContext context, Station s) async {
  final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${s.lat},${s.lng}');
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {}
  if (!ok && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open a maps app for directions.')),
    );
  }
}
