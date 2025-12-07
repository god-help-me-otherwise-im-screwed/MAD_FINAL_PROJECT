const double kMinWidthHeightAspect = 9.0 / 16.0;
const double kMaxWidthHeightAspect = 3.0 / 4.0;

const double kLargePadding = 24.0;
const double kMediumPadding = 16.0;
const double kSmallPadding = 8.0;
const double kIconSizeLarge = 48.0;
const double kIconSizeMedium = 32.0;
const double kIconSizeSmall = 24.0;

const Map<String, int> kUnitOptions = {'C': 0, 'F': 1};
const Map<String, int> kTimeFormatOptions = {'24 Hour': 0, '12 Hour': 1};
const Map<String, int> kBackgroundModeOptions = {
  'Realtime Weather': 0,
  'Custom Gradient': 1,
  'Static Location': 2
};

const String kApiBaseUrl = 'https://api.tomorrow.io/v4';
const String kTomorrowIoApiKey = 'tacR72uW5okh26wVgIplyAxSC1aOS6xd';
const Duration kDebounceDuration = Duration(milliseconds: 500);
const Duration kApiRefreshInterval = Duration(minutes: 15);