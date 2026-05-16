import 'package:flutter/foundation.dart';

class Constants {
  // API Configuration
  static const String railwayBaseUrl =
      'https://smartenergycontroller-production.up.railway.app';
  static const String configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: railwayBaseUrl,
  );
  static const String localBaseUrl = configuredBaseUrl;

  static String get baseUrl {
    if (kIsWeb) {
      return configuredBaseUrl;
    }
    if (kDebugMode) {
      return configuredBaseUrl;
    }
    // For production, use Railway
    return railwayBaseUrl;
  }

  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static const Duration timeout = Duration(seconds: 10);

  // App Configuration
  static const String appName = 'Smart Energy Controller';
  static const String appVersion = '1.0.0';

  // Cost Calculation
  static const double costPerUnit = 30.0; // PKR per kWh
  static const double co2PerUnit = 0.4; // kg CO2 per kWh

  // Thresholds
  static const int ldrSunnyThreshold = 1800;
  static const int ldrDarkThreshold = 1200;
  static const double lowVoltageProtection = 170.0;

  // API Endpoints
  static const String endpointStatus = '/api/status';
  static const String endpointDailyStats = '/api/daily-stats';
  static const String endpointHourlyData = '/api/hourly-data';
  static const String endpointEvents = '/api/events';
  static const String endpointAlerts = '/api/alerts';
  static const String endpointCommand = '/api/command';
  static const String endpointClearEvents = '/api/clear-events';
  static const String endpointSystemStatus = '/api/system-status';
  static const String endpointLastSeen = '/api/last-seen';
  static const String endpointUserMode = '/api/user-mode';
}
