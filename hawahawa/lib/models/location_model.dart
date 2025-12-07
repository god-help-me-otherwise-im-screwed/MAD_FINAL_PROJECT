import 'package:latlong2/latlong.dart' as osm;

class AppLatLng {
  final double latitude;
  final double longitude;

  const AppLatLng(this.latitude, this.longitude);

  osm.LatLng toOsm() => osm.LatLng(latitude, longitude);

  @override
  String toString() => '$latitude, $longitude';
}

class LocationResult {
  final double lat;
  final double lon;
  final String displayName;

  LocationResult({
    required this.lat,
    required this.lon,
    required this.displayName,
  });

  factory LocationResult.fromNominatim(Map<String, dynamic> json) {
    return LocationResult(
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      displayName: json['display_name'] ?? 'Unknown',
    );
  }

  @override
  String toString() => '$displayName ($lat, $lon)';
}
