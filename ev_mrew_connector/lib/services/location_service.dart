import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationException implements Exception {
  final String message;
  LocationException(this.message);
  @override
  String toString() => message;
}

class LocationService {
  /// Requests permission if needed and returns the GPS position.
  Future<LatLng> currentPosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw LocationException(
          'Location services are turned off. Turn on GPS, or pick a spot on the map.');
    }
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied) {
      throw LocationException(
          'Location permission was denied. Search for a place or tap the map instead.');
    }
    if (perm == LocationPermission.deniedForever) {
      throw LocationException(
          'Location permission is blocked. Enable it in your phone settings, or choose a place manually.');
    }
    final pos = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LatLng(pos.latitude, pos.longitude);
  }

  /// Coordinates -> readable address (falls back to coordinates).
  Future<String> addressFor(LatLng p) async {
    final fallback =
        '${p.latitude.toStringAsFixed(4)}, ${p.longitude.toStringAsFixed(4)}';
    try {
      final marks = await placemarkFromCoordinates(p.latitude, p.longitude);
      if (marks.isEmpty) return fallback;
      final m = marks.first;
      final parts = <String>[
        for (final s in [m.street, m.subLocality, m.locality, m.administrativeArea])
          if (s != null && s.trim().isNotEmpty) s,
      ];
      return parts.isEmpty ? fallback : parts.join(', ');
    } catch (_) {
      return fallback;
    }
  }

  /// Place name -> coordinates, or null if not found.
  Future<LatLng?> search(String query) async {
    try {
      final r = await locationFromAddress(query);
      if (r.isEmpty) return null;
      return LatLng(r.first.latitude, r.first.longitude);
    } catch (_) {
      return null;
    }
  }
}
