import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/location_service.dart';
import '../theme.dart';
import '../widgets/info_banner.dart';
import 'stations_screen.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _svc = LocationService();
  final _map = MapController();
  final _search = TextEditingController();

  LatLng? _picked;
  String? _label;
  String? _error;
  bool _busy = false;

  // Default map centre (Hyderabad) until a location is chosen.
  static const _fallbackCenter = LatLng(17.385, 78.4867);

  @override
  void dispose() {
    _search.dispose();
    _map.dispose();
    super.dispose();
  }

  Future<void> _select(LatLng p) async {
    setState(() {
      _picked = p;
      _label = 'Looking up address...';
      _error = null;
    });
    _map.move(p, 14);
    final addr = await _svc.addressFor(p);
    if (mounted && _picked == p) setState(() => _label = addr);
  }

  Future<void> _useGps() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _select(await _svc.currentPosition());
    } on LocationException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error =
          'Could not get your location. Try again or pick on the map.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _doSearch() async {
    final q = _search.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    final p = await _svc.search(q);
    if (!mounted) return;
    setState(() => _busy = false);
    if (p == null) {
      setState(() => _error =
          'No place found for "$q". Check the spelling or tap the map.');
    } else {
      await _select(p);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your location')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Select Your Current Location',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navy)),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _busy ? null : _useGps,
                  icon: const Icon(Icons.my_location),
                  label: const Text('Use my current location'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _search,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _doSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search a city, area or address',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _busy ? null : _doSearch,
                    ),
                  ),
                ),
                if (_busy) ...[
                  const SizedBox(height: 10),
                  const LinearProgressIndicator(color: AppColors.green),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  InfoBanner(
                      text: _error!,
                      color: AppColors.red,
                      icon: Icons.error_outline),
                ],
                const SizedBox(height: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: FlutterMap(
                      mapController: _map,
                      options: MapOptions(
                        initialCenter: _picked ?? _fallbackCenter,
                        initialZoom: 12,
                        onTap: (_, point) => _select(point),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.ev_mrew_connector',
                        ),
                        if (_picked != null)
                          MarkerLayer(markers: [
                            Marker(
                              point: _picked!,
                              width: 48,
                              height: 48,
                              alignment: Alignment.topCenter,
                              child: const Icon(Icons.location_on,
                                  size: 48, color: AppColors.red),
                            ),
                          ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _picked == null
                      ? 'Tap the map to drop a pin, or use GPS / search above.'
                      : 'Selected: $_label',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: _picked == null
                      ? null
                      : () => Navigator.of(context).push(fadeSlide(
                            StationsScreen(
                                origin: _picked!, label: _label ?? ''),
                          )),
                  icon: const Icon(Icons.ev_station),
                  label: const Text('Find Nearby Charging Stations'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
