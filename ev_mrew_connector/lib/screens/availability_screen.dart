import 'package:flutter/material.dart';
import '../models/station.dart';
import '../services/directions.dart';
import '../theme.dart';
import '../widgets/info_banner.dart';

class AvailabilityScreen extends StatelessWidget {
  final Station station;
  const AvailabilityScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final s = station;
    final sample = s.source == DataSource.sample;
    return Scaffold(
      appBar: AppBar(title: const Text('Port availability')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(s.name,
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navy)),
              const SizedBox(height: 4),
              Text(s.address, style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 14),
              InfoBanner(
                text: sample
                    ? 'SAMPLE data: ports on this screen are made up for demonstration.'
                    : 'ESTIMATED availability: out-of-service ports come from the network '
                        'listing, but available/occupied is not live.',
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _Count('Total', s.ports.length, AppColors.navy),
                  _Count('Available', s.count(PortStatus.available), AppColors.green),
                  _Count('Occupied', s.count(PortStatus.occupied), AppColors.red),
                  _Count('Out of service', s.count(PortStatus.outOfService), AppColors.grey),
                ],
              ),
              const SizedBox(height: 14),
              Text('Connectors: ${s.connectors.join(', ')}',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              for (var i = 0; i < s.ports.length; i++) _PortTile(s.ports[i], i + 1),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: () => openDirections(context, s),
                icon: const Icon(Icons.directions),
                label: const Text('Get Directions'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to Stations'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Count(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Text('$value',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w800, color: color)),
              const SizedBox(height: 2),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );
}

class _PortTile extends StatelessWidget {
  final Port port;
  final int number;
  const _PortTile(this.port, this.number);

  @override
  Widget build(BuildContext context) {
    final c = port.status.color;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: c, width: 6)),
      ),
      child: Row(
        children: [
          Icon(Icons.ev_station, color: c),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Port $number  -  ${port.connector}',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                    port.kw > 0
                        ? '${port.kw.toStringAsFixed(0)} kW'
                        : 'Speed not listed',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(port.status.label,
                style: TextStyle(
                    color: c == AppColors.grey ? Colors.grey.shade700 : c,
                    fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
