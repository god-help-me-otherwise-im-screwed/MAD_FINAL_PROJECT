class AppSettings {
  final int tempUnit; // 0 = C, 1 = F
  final int timeFormat; // 0 = 24h, 1 = 12h
  final int backgroundMode; // 0 realtime, 1 custom, 2 static
  final int pressureUnit; // 0 = mbar, 1 = hPa, 2 = inHg, 3 = mmHg
  final String locationMode; // 'Auto' or 'Manual'
  final String manualLocation; // Stores manually entered location

  const AppSettings({
    this.tempUnit = 0,
    this.timeFormat = 0,
    this.backgroundMode = 0,
    this.pressureUnit = 0,
    this.locationMode = 'Auto',
    this.manualLocation = '',
  });

  AppSettings copyWith({
    int? tempUnit,
    int? timeFormat,
    int? backgroundMode,
    int? pressureUnit,
    String? locationMode,
    String? manualLocation,
  }) {
    return AppSettings(
      tempUnit: tempUnit ?? this.tempUnit,
      timeFormat: timeFormat ?? this.timeFormat,
      backgroundMode: backgroundMode ?? this.backgroundMode,
      pressureUnit: pressureUnit ?? this.pressureUnit,
      locationMode: locationMode ?? this.locationMode,
      manualLocation: manualLocation ?? this.manualLocation,
    );
  }

  String getPressureUnitString() {
    switch (pressureUnit) {
      case 0:
        return 'mbar';
      case 1:
        return 'hPa';
      case 2:
        return 'inHg';
      case 3:
        return 'mmHg';
      default:
        return 'mbar';
    }
  }
}