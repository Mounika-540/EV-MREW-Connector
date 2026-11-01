import 'package:flutter/material.dart';
import '../theme.dart';

enum PortStatus { available, occupied, outOfService }

extension PortStatusX on PortStatus {
  String get label => switch (this) {
        PortStatus.available => 'Available',
        PortStatus.occupied => 'Occupied',
        PortStatus.outOfService => 'Out of service',
      };
  Color get color => switch (this) {
        PortStatus.available => AppColors.green,
        PortStatus.occupied => AppColors.red,
        PortStatus.outOfService => AppColors.grey,
      };
}

/// Where the port status came from. No free public API gives real-time
/// occupancy, so the app labels every status honestly.
enum DataSource {
  /// Station is real (Open Charge Map). Out-of-service flag is real,
  /// available/occupied split is an ESTIMATE.
  estimated,

  /// Station and statuses are generated demo data.
  sample,
}

class Port {
  final String id;
  final String connector;
  final double kw;
  final PortStatus status;
  const Port({
    required this.id,
    required this.connector,
    required this.kw,
    required this.status,
  });
}

class Station {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final double distanceKm;
  final bool isOpen;
  final List<Port> ports;
  final DataSource source;

  const Station({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    required this.isOpen,
    required this.ports,
    required this.source,
  });

  int count(PortStatus s) => ports.where((p) => p.status == s).length;
  Set<String> get connectors => ports.map((p) => p.connector).toSet();
}
