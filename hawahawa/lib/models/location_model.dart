class AppLatLng {
  final double lat;
  final double lon;

  const AppLatLng(this.lat, this.lon);

  @override
  String toString() => 'AppLatLng($lat, $lon)';
}

class LocationResult {
  final String name;
  final AppLatLng coords;

  const LocationResult({required this.name, required this.coords});

  @override
  String toString() => 'LocationResult($name, ${coords.toString()})';
}