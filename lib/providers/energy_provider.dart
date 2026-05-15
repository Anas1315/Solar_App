import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_energy_controller/models/energy_data.dart';
import 'package:smart_energy_controller/models/daily_stats.dart';
import 'package:smart_energy_controller/models/alert_model.dart';
import 'package:smart_energy_controller/services/api_service.dart';
import 'package:smart_energy_controller/services/socket_service.dart';
import 'package:smart_energy_controller/services/notification_service.dart';

class EnergyProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SocketService _socketService = SocketService();

  EnergyData? _currentData;
  DailyStats? _dailyStats;
  List<HourlyData> _hourlyData = [];
  List<dynamic> _events = [];
  List<dynamic> _alerts = [];
  bool _isLoading = true;
  String _connectionStatus = 'connecting';
  String _systemStatusMessage = 'System Normal';
  String _userMode = 'HOME';

  EnergyData? get currentData => _currentData;
  DailyStats? get dailyStats => _dailyStats;
  List<HourlyData> get hourlyData => _hourlyData;
  List<dynamic> get events => _events;
  List<dynamic> get alerts => _alerts;
  bool get isLoading => _isLoading;
  String get connectionStatus => _connectionStatus;
  String get systemStatusMessage => _systemStatusMessage;
  String get userMode => _userMode;

  EnergyProvider({bool autoConnect = true}) {
    _currentData = _fallbackData();
    _dailyStats = DailyStats.empty();
    _isLoading = false;
    if (autoConnect) {
      Future<void>.microtask(_init);
    }
  }

  Future<void> _init() async {
    _registerSocketListeners();
    await Future.wait([
      loadAllData(showLoading: false),
      _socketService.initialize().catchError((error) {
        debugPrint('Socket initialization failed: $error');
      }),
    ]);
  }

  Future<void> loadAllData({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final results = await Future.wait([
        _apiService.getStatus(),
        _apiService.getDailyStats(),
        _apiService.getHourlyData(),
        _apiService.getEvents(),
        _apiService.getAlerts(),
      ]);

      _currentData = results[0] as EnergyData;
      _dailyStats = results[1] as DailyStats;
      _hourlyData = results[2] as List<HourlyData>;
      _events = results[3] as List<dynamic>;
      _alerts = results[4] as List<dynamic>;
      _connectionStatus = 'connected';
    } catch (e) {
      _connectionStatus = 'error';
      debugPrint('Error loading data: $e');
      _currentData ??= _fallbackData();
      _dailyStats ??= DailyStats.empty();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendCommand(String type, int value) async {
    _applyCommandState(type, value);
    final success = await _apiService.sendCommand(type, value);
    return success;
  }

  Future<bool> sendCommandPayload(String type, Object value) async {
    final success = await _apiService.sendCommandPayload(type, value);
    return success;
  }

  void _applyCommandState(String type, int value) {
    if (type == 'WAPDA_RELAY' && _currentData != null) {
      _currentData = _currentData!.copyWith(wapdaRelayState: value == 1);
    } else if (type == 'HEAVY_LOAD' && _currentData != null) {
      _currentData = _currentData!.copyWith(heavyLoadState: value == 1);
    } else if (type == 'WAPDA_MODE' && _currentData != null) {
      final automatic = value == 1;
      _currentData = _currentData!.copyWith(
        wapdaAutoMode: automatic,
        wapdaRelayState: automatic
            ? _currentData!.wapdaAvailable
            : _currentData!.wapdaRelayState,
      );
    } else if (type == 'HEAVY_LOAD_MODE' && _currentData != null) {
      final automatic = value == 1;
      _currentData = _currentData!.copyWith(
        heavyLoadAutoMode: automatic,
        heavyLoadState: automatic ? true : _currentData!.heavyLoadState,
      );
    } else if (type == 'USER_MODE') {
      _userMode = _getModeName(value);
    }
    notifyListeners();
  }

  String _getModeName(int value) {
    switch (value) {
      case 1:
        return 'HOME';
      case 2:
        return 'SAVING';
      case 3:
        return 'PERFORMANCE';
      default:
        return 'HOME';
    }
  }

  Future<bool> clearHistory() async {
    final success = await _apiService.clearEvents();
    if (success) {
      _events = [];
      _alerts = [];
      notifyListeners();
    }
    return success;
  }

  void markAlertRead(String id) {
    _alerts = _alerts.map((alert) {
      if (alert is! Map) return alert;
      final copy = Map<String, dynamic>.from(alert);
      if (copy['id']?.toString() == id) {
        copy['isRead'] = true;
      }
      return copy;
    }).toList();
    notifyListeners();
  }

  void dismissAlert(String id) {
    _alerts = _alerts.where((alert) {
      if (alert is! Map) return true;
      return alert['id']?.toString() != id;
    }).toList();
    notifyListeners();
  }

  void clearAlerts() {
    _alerts = [];
    notifyListeners();
  }

  void refresh() {
    loadAllData();
  }

  void _registerSocketListeners() {
    _socketService.on('data-update', (data) {
      if (data is Map) {
        _currentData = EnergyData.fromJson(Map<String, dynamic>.from(data));
        _isLoading = false;
        notifyListeners();
      }
    });

    _socketService.on('daily-stats', (data) {
      if (data is Map) {
        _dailyStats = DailyStats.fromJson(Map<String, dynamic>.from(data));
        notifyListeners();
      }
    });

    _socketService.on('hourly-data', (data) {
      if (data is List) {
        _hourlyData = data
            .whereType<Map>()
            .map((item) => HourlyData.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        notifyListeners();
      }
    });

    _socketService.on('system-status', (data) {
      if (data is Map) {
        _systemStatusMessage = data['message'] ?? 'System Normal';
        notifyListeners();
      }
    });

    _socketService.on('new-event', (data) {
      if (data != null) {
        _events.insert(0, data);
        if (_events.length > 100) _events.removeLast();
        notifyListeners();

        if (data is Map && data['type'] == 'danger') {
          NotificationService().showCriticalAlert(
            title: 'Alert',
            body: data['message']?.toString() ?? 'System alert',
          );
        }
      }
    });

    _socketService.on('new-alert', (data) {
      if (data != null) {
        _alerts.insert(0, data);
        if (_alerts.length > 50) _alerts.removeLast();
        notifyListeners();

        if (data is Map) {
          final alert = AlertModel.fromJson(Map<String, dynamic>.from(data));
          alert.showAsNotification();
        }
      }
    });

    _socketService.on('connect', (_) {
      _connectionStatus = 'connected';
      notifyListeners();
    });

    _socketService.on('disconnect', (_) {
      _connectionStatus = 'disconnected';
      notifyListeners();
    });
  }

  EnergyData _fallbackData() {
    return EnergyData(
      voltage: 220,
      current: 2.1,
      power: 456000,
      ldrValue: 2200,
      wapdaAvailable: true,
      isSunny: true,
      isDayTime: true,
      wapdaRelayState: true,
      heavyLoadState: true,
      wapdaAutoMode: true,
      heavyLoadAutoMode: true,
      currentHour: DateTime.now().hour,
      lastUpdate: DateTime.now(),
      esp32Online: false,
    );
  }

  @override
  void dispose() {
    _socketService.disconnect();
    super.dispose();
  }
}
