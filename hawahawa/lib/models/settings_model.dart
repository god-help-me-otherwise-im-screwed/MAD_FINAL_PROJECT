class AppSettings {
  final int tempUnit; // 0 = C, 1 = F
  final int timeFormat; // 0 = 24h, 1 = 12h
  final int backgroundMode; // 0 realtime,1 custom,2 static

  const AppSettings({
    this.tempUnit = 0,
    this.timeFormat = 0,
    this.backgroundMode = 0,
  });

  AppSettings copyWith({int? tempUnit, int? timeFormat, int? backgroundMode}) {
    return AppSettings(
      tempUnit: tempUnit ?? this.tempUnit,
      timeFormat: timeFormat ?? this.timeFormat,
      backgroundMode: backgroundMode ?? this.backgroundMode,
    );
  }
}
