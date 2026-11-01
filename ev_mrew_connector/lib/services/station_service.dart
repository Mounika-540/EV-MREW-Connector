import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/station.dart';

class StationResult {
  final List<Station> stations;
  final String? notice;
  const StationResult(this.stations, {this.notice});
}

class StationService {
  /// Pass with: flutter run --dart-define=OCM_API_KEY=your_key
  static const _ocmKey = String.fromEnvironment('OCM_API_KEY');

  Future<StationResult> fetch(LatLng origin) async {
    String? notice;
    if (_ocmKey.isEmpty) {
      notice = 'No Open Charge Map API key set, so these are SAMPLE stations '
          'for demonstration. See README to add a key.';
    } else {
      try {
        final list = await _fromOcm(origin);
        if (list.isNotEmpty) {
          return StationResult(
            list,
            notice: 'Stations are real (Open Charge Map). Available/occupied '
                'counts are ESTIMATES, not live data.',
          );
        }
        notice = 'No real stations found within 15 km. Showing SAMPLE stations.';
      } catch (_) {
        notice = 'Could not reach Open Charge Map. Showing SAMPLE stations.';
      }
    }
    return StationResult(_sample(origin), notice: notice);
  }

  double _km(LatLng a, double lat, double lng) =>
      Geolocator.distanceBetween(a.latitude, a.longitude, lat, lng) / 1000;

  Future<List<Station>> _fromOcm(LatLng o) async {
    final uri = Uri.https('api.openchargemap.io', '/v3/poi/', {
      'output': 'json',
      'latitude': '${o.latitude}',
      'longitude': '${o.longitude}',
      'distance': '15',
      'distanceunit': 'KM',
      'maxresults': '30',
      'compact': 'false',
      'verbose': 'false',
      'key': _ocmKey,
    });
    final res = await http.get(uri).timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('OCM ${res.statusCode}');
    final data = jsonDecode(res.body) as List;

    final out = <Station>[];
    for (final raw in data) {
      final poi = raw as Map<String, dynamic>;
      final addr = (poi['AddressInfo'] ?? {}) as Map<String, dynamic>;
      final lat = (addr['Latitude'] as num?)?.toDouble();
      final lng = (addr['Longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) continue;

      final id = '${poi['ID']}';
      final isOpen = (poi['StatusType']?['IsOperational']) != false;
      final ports = <Port>[];
      var n = 0;
      for (final c in (poi['Connections'] as List? ?? [])) {
        final conn = c as Map<String, dynamic>;
        final qty = ((conn['Quantity'] as num?)?.toInt() ?? 1).clamp(1, 6);
        final broken = conn['StatusType']?['IsOperational'] == false;
        for (var i = 0; i < qty; i++) {
          n++;
          ports.add(Port(
            id: 'P$n',
            connector: (conn['ConnectionType']?['Title'] ?? 'Unknown') as String,
            kw: (conn['PowerKW'] as num?)?.toDouble() ?? 0,
            status: !isOpen || broken ? PortStatus.outOfService : _estimate(id, n),
          ));
        }
      }
      if (ports.isEmpty) {
        final pts = ((poi['NumberOfPoints'] as num?)?.toInt() ?? 1).clamp(1, 6);
        for (var i = 0; i < pts; i++) {
          ports.add(Port(
            id: 'P${i + 1}',
            connector: 'Unknown',
            kw: 0,
            status: isOpen ? _estimate(id, i) : PortStatus.outOfService,
          ));
        }
      }

      final line = [addr['AddressLine1'], addr['Town'], addr['StateOrProvince'], addr['Postcode']]
          .where((s) => s != null && '$s'.trim().isNotEmpty)
          .join(', ');
      out.add(Station(
        id: id,
        name: (addr['Title'] ?? 'Charging station') as String,
        address: line.isEmpty ? 'Address not listed' : line,
        lat: lat,
        lng: lng,
        distanceKm: _km(o, lat, lng),
        isOpen: isOpen,
        ports: ports,
        source: DataSource.estimated,
      ));
    }
    out.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return out;
  }

  /// Stable pseudo-random estimate so the UI doesn't flicker on refresh.
  PortStatus _estimate(String id, int i) {
    final v = (id.hashCode ^ (i * 7919)).abs() % 10;
    return v < 6 ? PortStatus.available : PortStatus.occupied;
  }

  List<Station> _sample(LatLng o) {
    const defs = <(String, double, double, List<String>, double, bool)>[
      ('GreenVolt Hub', 0.008, 0.004, ['CCS2', 'Type 2', 'CHAdeMO'], 60.0, true),
      ('City Mall Fast Charge', -0.012, 0.009, ['CCS2', 'CCS2'], 120.0, true),
      ('Lakeside Charge Point', 0.018, -0.011, ['Type 2', 'Type 2', 'Type 2'], 22.0, true),
      ('Highway Plaza EV', -0.025, -0.02, ['CCS2', 'CHAdeMO'], 50.0, false),
      ('Metro Station Charger', 0.03, 0.025, ['Type 2', 'CCS2'], 30.0, true),
      ('Tech Park Supercharge', -0.04, 0.03, ['CCS2', 'CCS2', 'Type 2'], 150.0, true),
    ];
    final list = <Station>[];
    for (var i = 0; i < defs.length; i++) {
      final d = defs[i];
      final lat = o.latitude + d.$2;
      final lng = o.longitude + d.$3;
      final km = _km(o, lat, lng);
      final ports = <Port>[
        for (var j = 0; j < d.$4.length; j++)
          Port(
            id: 'P${j + 1}',
            connector: d.$4[j],
            kw: d.$4[j] == 'Type 2' ? 22 : d.$5,
            status: !d.$6
                ? PortStatus.outOfService
                : (j == 2 && i == 0)
                    ? PortStatus.outOfService
                    : _estimate('s$i', j),
          ),
      ];
      list.add(Station(
        id: 'sample$i',
        name: d.$1,
        address: 'Sample location, ${km.toStringAsFixed(1)} km from you',
        lat: lat,
        lng: lng,
        distanceKm: km,
        isOpen: d.$6,
        ports: ports,
        source: DataSource.sample,
      ));
    }
    list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return list;
  }
}
