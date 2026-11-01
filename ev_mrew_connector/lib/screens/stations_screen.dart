import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../services/station_service.dart';
import '../theme.dart';
import '../widgets/info_banner.dart';
import '../widgets/station_card.dart';
import 'availability_screen.dart';

class StationsScreen extends StatefulWidget {
  final LatLng origin;
  final String label;
  const StationsScreen({super.key, required this.origin, required this.label});

  @override
  State<StationsScreen> createState() => _StationsScreenState();
}

class _StationsScreenState extends State<StationsScreen> {
  final _svc = StationService();
  late Future<StationResult> _future;

  @override
  void initState() {
    super.initState();
    _future = _svc.fetch(widget.origin);
  }

  void _reload() => setState(() => _future = _svc.fetch(widget.origin));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby stations')),
      body: FutureBuilder<StationResult>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.green));
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 56, color: AppColors.grey),
                    const SizedBox(height: 12),
                    const Text('Could not load charging stations.',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    FilledButton(
                        onPressed: _reload, child: const Text('Try again')),
                  ],
                ),
              ),
            );
          }
          final result = snap.data!;
          final stations = result.stations;
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 700),
              child: RefreshIndicator(
                onRefresh: () async => _reload(),
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Near ${widget.label}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    Text('${stations.length} stations, closest first',
                        style: TextStyle(color: Colors.grey.shade700)),
                    const SizedBox(height: 10),
                    if (result.notice != null) InfoBanner(text: result.notice!),
                    const SizedBox(height: 14),
                    if (stations.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(
                            child: Text(
                                'No charging stations found here. Try another location.')),
                      ),
                    for (final s in stations)
                      StationCard(
                        station: s,
                        onViewAvailability: () => Navigator.of(context)
                            .push(fadeSlide(AvailabilityScreen(station: s))),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
