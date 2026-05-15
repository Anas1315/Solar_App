import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_energy_controller/providers/energy_provider.dart';
import 'package:smart_energy_controller/providers/theme_provider.dart';
import 'package:smart_energy_controller/services/notification_service.dart';
import 'package:smart_energy_controller/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // LDR Settings
  int _sunThreshold = Constants.ldrSunnyThreshold;
  int _darkThreshold = Constants.ldrDarkThreshold;
  bool _ldrControlEnabled = true;

  // Notification Settings
  bool _desktopNotifications = true;
  bool _criticalAlerts = true;
  bool _powerAlerts = true;
  bool _systemAlerts = true;
  bool _dailySummary = true;

  // Display Settings
  bool _showAnimations = true;
  bool _showRealTimeUpdates = true;
  int _refreshInterval = 5;

  // System Settings
  String _localServerUrl = Constants.localBaseUrl;
  String _railwayServerUrl = Constants.railwayBaseUrl;
  bool _useRailway = false;

  // Data Management
  int _dataRetentionDays = 30;
  bool _autoExport = false;

  // About
  final String _appVersion = '1.0.0';
  final String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadSettings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sunThreshold =
          prefs.getInt('sun_threshold') ?? Constants.ldrSunnyThreshold;
      _darkThreshold =
          prefs.getInt('dark_threshold') ?? Constants.ldrDarkThreshold;
      _ldrControlEnabled = prefs.getBool('ldr_control_enabled') ?? true;
      _desktopNotifications = prefs.getBool('desktop_notifications') ?? true;
      _criticalAlerts = prefs.getBool('critical_alerts') ?? true;
      _powerAlerts = prefs.getBool('power_alerts') ?? true;
      _systemAlerts = prefs.getBool('system_alerts') ?? true;
      _dailySummary = prefs.getBool('daily_summary') ?? true;
      _showAnimations = prefs.getBool('show_animations') ?? true;
      _showRealTimeUpdates = prefs.getBool('realtime_updates') ?? true;
      _refreshInterval = prefs.getInt('refresh_interval') ?? 5;
      _localServerUrl =
          prefs.getString('local_server_url') ?? Constants.localBaseUrl;
      _railwayServerUrl =
          prefs.getString('railway_server_url') ?? Constants.railwayBaseUrl;
      _useRailway = prefs.getBool('use_railway') ?? false;
      _dataRetentionDays = prefs.getInt('data_retention_days') ?? 30;
      _autoExport = prefs.getBool('auto_export') ?? false;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) await prefs.setBool(key, value);
    if (value is int) await prefs.setInt(key, value);
    if (value is double) await prefs.setDouble(key, value);
    if (value is String) await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final energyProvider = Provider.of<EnergyProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'General', icon: Icon(Icons.settings, size: 18)),
            Tab(text: 'LDR', icon: Icon(Icons.sunny, size: 18)),
            Tab(
                text: 'Notifications',
                icon: Icon(Icons.notifications, size: 18)),
            Tab(text: 'System', icon: Icon(Icons.dns, size: 18)),
            Tab(text: 'About', icon: Icon(Icons.info, size: 18)),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildGeneralSettings(themeProvider),
          _buildLDRSettings(themeProvider, energyProvider),
          _buildNotificationSettings(themeProvider),
          _buildSystemSettings(themeProvider, energyProvider),
          _buildAboutSettings(themeProvider),
        ],
      ),
    );
  }

  // ========== GENERAL SETTINGS ==========

  Widget _buildGeneralSettings(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSection(
            title: 'Appearance',
            icon: Icons.palette,
            children: [
              _buildThemeSetting(themeProvider),
              const SizedBox(height: 4),
              _buildAmoledSetting(themeProvider),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Display',
            icon: Icons.display_settings,
            children: [
              _buildSwitchTile(
                title: 'Show Animations',
                subtitle: 'Enable weather animations and transitions',
                value: _showAnimations,
                onChanged: (v) {
                  setState(() => _showAnimations = v);
                  _saveSetting('show_animations', v);
                },
              ),
              _buildSwitchTile(
                title: 'Real-time Updates',
                subtitle: 'Enable live data streaming via WebSocket',
                value: _showRealTimeUpdates,
                onChanged: (v) {
                  setState(() => _showRealTimeUpdates = v);
                  _saveSetting('realtime_updates', v);
                },
              ),
              _buildSliderSetting(
                title: 'Refresh Interval',
                subtitle: 'Data refresh rate (seconds)',
                value: _refreshInterval.toDouble(),
                min: 1,
                max: 30,
                divisions: 29,
                onChanged: (v) {
                  setState(() => _refreshInterval = v.toInt());
                  _saveSetting('refresh_interval', _refreshInterval);
                },
                valueText: '${_refreshInterval}s',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Units',
            icon: Icons.straighten,
            children: [
              _buildDropdownSetting(
                title: 'Currency',
                subtitle: 'Currency symbol for costs',
                value: 'PKR (₨)',
                items: ['PKR (₨)', 'USD (\$)', 'EUR (€)', 'GBP (£)'],
                onChanged: (v) {
                  _saveSetting('currency', v);
                  _showSnackBar('Currency changed to $v');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSetting(ThemeProvider themeProvider) {
    return ListTile(
      leading: const Icon(Icons.brightness_medium),
      title: const Text('Theme Mode'),
      subtitle: Text(themeProvider.currentThemeMode.toString().split('.').last),
      trailing: DropdownButton<AppThemeMode>(
        value: themeProvider.currentThemeMode,
        underline: const SizedBox(),
        items: AppThemeMode.values.map((mode) {
          return DropdownMenuItem(
            value: mode,
            child: Text(mode.toString().split('.').last.toUpperCase()),
          );
        }).toList(),
        onChanged: (mode) {
          if (mode != null) {
            themeProvider.setThemeMode(mode);
            _showSnackBar(
                'Theme changed to ${mode.toString().split('.').last}');
          }
        },
      ),
    );
  }

  Widget _buildAmoledSetting(ThemeProvider themeProvider) {
    return SwitchListTile(
      secondary: const Icon(Icons.brightness_1),
      title: const Text('AMOLED Mode'),
      subtitle: const Text('Pure black background for OLED screens'),
      value: themeProvider.useAmoled,
      onChanged: (v) {
        themeProvider.setAmoledMode(v);
        _showSnackBar(v ? 'AMOLED mode enabled' : 'AMOLED mode disabled');
      },
      activeThumbColor: Theme.of(context).primaryColor,
    );
  }

  // ========== LDR SETTINGS ==========

  Widget _buildLDRSettings(
      ThemeProvider themeProvider, EnergyProvider energyProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSection(
            title: 'Light Sensor Control',
            icon: Icons.sunny,
            children: [
              _buildSwitchTile(
                title: 'Enable LDR Control',
                subtitle:
                    'Automatically switch to solar based on light intensity',
                value: _ldrControlEnabled,
                onChanged: (v) {
                  setState(() => _ldrControlEnabled = v);
                  energyProvider.sendCommand('LDR_ENABLED', v ? 1 : 0);
                  _saveSetting('ldr_control_enabled', v);
                  _showSnackBar(
                      v ? 'LDR control enabled' : 'LDR control disabled');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Threshold Settings',
            icon: Icons.tune,
            children: [
              _buildSliderSetting(
                title: 'Sunny Threshold',
                subtitle: 'Above this value = Sunny/Bright',
                value: _sunThreshold.toDouble(),
                min: 500,
                max: 4095,
                divisions: 72,
                onChanged: (v) {
                  setState(() => _sunThreshold = v.toInt());
                  _saveSetting('sun_threshold', _sunThreshold);
                },
                valueText: _sunThreshold.toString(),
                color: Colors.orange,
              ),
              _buildSliderSetting(
                title: 'Dark Threshold',
                subtitle: 'Below this value = Dark/Cloudy',
                value: _darkThreshold.toDouble(),
                min: 0,
                max: 3500,
                divisions: 70,
                onChanged: (v) {
                  setState(() => _darkThreshold = v.toInt());
                  _saveSetting('dark_threshold', _darkThreshold);
                },
                valueText: _darkThreshold.toString(),
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Calibration',
            icon: Icons.science,
            children: [
              _buildButtonTile(
                title: 'Calibrate Light Sensor',
                subtitle: 'Set current light level as reference',
                icon: Icons.brightness_5,
                onTap: () => _calibrateLightSensor(energyProvider),
              ),
              _buildButtonTile(
                title: 'Reset to Defaults',
                subtitle: 'Restore factory threshold values',
                icon: Icons.restore,
                onTap: () => _resetLDRDefaults(energyProvider),
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Current Readings',
            icon: Icons.sensors,
            children: [
              _buildInfoTile(
                title: 'Current LDR Value',
                value: energyProvider.currentData?.ldrValue.toString() ?? '0',
                icon: Icons.light_mode,
              ),
              _buildInfoTile(
                title: 'Sunny Status',
                value: (energyProvider.currentData?.isSunny ?? false)
                    ? 'Sunny ☀️'
                    : 'Not Sunny ☁️',
                icon: Icons.sunny,
              ),
              _buildInfoTile(
                title: 'Day/Night',
                value: (energyProvider.currentData?.isDayTime ?? true)
                    ? 'Day Time'
                    : 'Night Time',
                icon: Icons.brightness_6,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== NOTIFICATION SETTINGS ==========

  Widget _buildNotificationSettings(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSection(
            title: 'Push Notifications',
            icon: Icons.notifications_active,
            children: [
              _buildSwitchTile(
                title: 'Desktop Notifications',
                subtitle: 'Show system notifications on your device',
                value: _desktopNotifications,
                onChanged: (v) {
                  setState(() => _desktopNotifications = v);
                  _saveSetting('desktop_notifications', v);
                  if (v) NotificationService().requestPermission();
                  _showSnackBar(
                      v ? 'Notifications enabled' : 'Notifications disabled');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Alert Types',
            icon: Icons.warning,
            children: [
              _buildSwitchTile(
                title: 'Critical Alerts',
                subtitle: 'Power outages, system failures',
                value: _criticalAlerts,
                onChanged: (v) {
                  setState(() => _criticalAlerts = v);
                  _saveSetting('critical_alerts', v);
                },
              ),
              _buildSwitchTile(
                title: 'Power Alerts',
                subtitle: 'Grid status, solar availability',
                value: _powerAlerts,
                onChanged: (v) {
                  setState(() => _powerAlerts = v);
                  _saveSetting('power_alerts', v);
                },
              ),
              _buildSwitchTile(
                title: 'System Alerts',
                subtitle: 'Updates, maintenance, commands',
                value: _systemAlerts,
                onChanged: (v) {
                  setState(() => _systemAlerts = v);
                  _saveSetting('system_alerts', v);
                },
              ),
              _buildSwitchTile(
                title: 'Daily Summary',
                subtitle: 'Receive daily energy reports',
                value: _dailySummary,
                onChanged: (v) {
                  setState(() => _dailySummary = v);
                  _saveSetting('daily_summary', v);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== SYSTEM SETTINGS ==========

  Widget _buildSystemSettings(
      ThemeProvider themeProvider, EnergyProvider energyProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSection(
            title: 'Server Configuration',
            icon: Icons.dns,
            children: [
              _buildTextFieldTile(
                title: 'Local Server URL',
                subtitle: 'Your PC/Mac IP address',
                value: _localServerUrl,
                icon: Icons.computer,
                onChanged: (v) {
                  setState(() => _localServerUrl = v);
                  _saveSetting('local_server_url', v);
                },
              ),
              _buildTextFieldTile(
                title: 'Railway Server URL',
                subtitle: 'Cloud backup server',
                value: _railwayServerUrl,
                icon: Icons.cloud,
                onChanged: (v) {
                  setState(() => _railwayServerUrl = v);
                  _saveSetting('railway_server_url', v);
                },
              ),
              _buildSwitchTile(
                title: 'Use Railway Backup',
                subtitle: 'Send data to cloud server',
                value: _useRailway,
                onChanged: (v) {
                  setState(() => _useRailway = v);
                  _saveSetting('use_railway', v);
                  _showSnackBar(
                      v ? 'Railway backup enabled' : 'Railway backup disabled');
                },
              ),
              _buildButtonTile(
                title: 'Test Connection',
                subtitle: 'Check server connectivity',
                icon: Icons.network_check,
                onTap: () => _testConnection(energyProvider),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Data Management',
            icon: Icons.storage,
            children: [
              _buildSliderSetting(
                title: 'Data Retention',
                subtitle: 'Keep history for (days)',
                value: _dataRetentionDays.toDouble(),
                min: 7,
                max: 365,
                divisions: 358,
                onChanged: (v) {
                  setState(() => _dataRetentionDays = v.toInt());
                  _saveSetting('data_retention_days', _dataRetentionDays);
                },
                valueText: '$_dataRetentionDays days',
              ),
              _buildSwitchTile(
                title: 'Auto Export',
                subtitle: 'Automatically export data weekly',
                value: _autoExport,
                onChanged: (v) {
                  setState(() => _autoExport = v);
                  _saveSetting('auto_export', v);
                },
              ),
              _buildButtonTile(
                title: 'Export All Data',
                subtitle: 'Save data to JSON file',
                icon: Icons.download,
                onTap: () => _exportAllData(energyProvider),
              ),
              _buildButtonTile(
                title: 'Clear All Data',
                subtitle: 'Delete all history and events',
                icon: Icons.delete_forever,
                onTap: () => _confirmClearData(energyProvider),
                color: Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Advanced',
            icon: Icons.developer_mode,
            children: [
              _buildButtonTile(
                title: 'Debug Mode',
                subtitle: 'Show technical information',
                icon: Icons.bug_report,
                onTap: () => _showDebugInfo(energyProvider),
              ),
              _buildButtonTile(
                title: 'Reset All Settings',
                subtitle: 'Restore factory defaults',
                icon: Icons.settings_backup_restore,
                onTap: () =>
                    _confirmResetSettings(themeProvider, energyProvider),
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== ABOUT SETTINGS ==========

  Widget _buildAboutSettings(ThemeProvider themeProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withValues(alpha: 0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.energy_savings_leaf,
                      size: 48, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  Constants.appName,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version $_appVersion ($_buildNumber)',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  '© 2024 Smart Energy Solutions',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Features',
            icon: Icons.star,
            children: [
              _buildFeatureTile('Real-time Monitoring',
                  'Live voltage, current, and power data'),
              _buildFeatureTile(
                  'Smart Automation', 'Automatic grid/solar switching'),
              _buildFeatureTile(
                  'Cost Analysis', 'Track savings and energy costs'),
              _buildFeatureTile('Historical Data', '24/7 activity logging'),
              _buildFeatureTile(
                  'Remote Control', 'Control relays from anywhere'),
              _buildFeatureTile(
                  'Notifications', 'Instant alerts for critical events'),
            ],
          ),
          const SizedBox(height: 16),
          _buildSection(
            title: 'Credits',
            icon: Icons.people,
            children: [
              const ListTile(
                leading: Icon(Icons.code),
                title: Text('Developed by'),
                subtitle: Text('Smart Energy Team'),
              ),
              const ListTile(
                leading: Icon(Icons.book),
                title: Text('Open Source Libraries'),
                subtitle: Text('Flutter, Provider, fl_chart, socket_io_client'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _shareApp,
              icon: const Icon(Icons.share),
              label: const Text('Share App'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========== HELPER BUILDERS ==========

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required Function(double) onChanged,
    required String valueText,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(subtitle,
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: (color ?? Theme.of(context).primaryColor)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color ?? Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: color ?? Theme.of(context).primaryColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownSetting({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required Function(String) onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(value: item, child: Text(item));
        }).toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }

  Widget _buildButtonTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Theme.of(context).primaryColor),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildTextFieldTile({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Function(String) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle:
          Text(value, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: () => _showEditDialog(title, value, onChanged),
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(title),
      trailing:
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildFeatureTile(String title, String subtitle) {
    return ListTile(
      leading: Icon(Icons.check_circle,
          color: Theme.of(context).primaryColor, size: 20),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      dense: true,
    );
  }

  // ========== ACTIONS ==========

  void _showEditDialog(
      String title, String currentValue, Function(String) onSave) {
    final controller = TextEditingController(text: currentValue);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $title'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(hintText: 'Enter $title'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              onSave(controller.text.trim());
              Navigator.pop(context);
              _showSnackBar('$title updated');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _calibrateLightSensor(EnergyProvider provider) {
    final currentLdr = provider.currentData?.ldrValue ?? 0;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Calibrate Light Sensor'),
        content: Text(
            'Current LDR value: $currentLdr\n\nSet this as the sunny threshold?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _sunThreshold = currentLdr);
              _saveSetting('sun_threshold', currentLdr);
              Navigator.pop(context);
              _showSnackBar(
                  'Calibration complete: threshold set to $currentLdr');
            },
            child: const Text('Calibrate'),
          ),
        ],
      ),
    );
  }

  void _resetLDRDefaults(EnergyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset LDR Defaults'),
        content: const Text('Reset thresholds to factory defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _sunThreshold = Constants.ldrSunnyThreshold;
                _darkThreshold = Constants.ldrDarkThreshold;
              });
              _saveSetting('sun_threshold', Constants.ldrSunnyThreshold);
              _saveSetting('dark_threshold', Constants.ldrDarkThreshold);
              Navigator.pop(context);
              _showSnackBar('LDR thresholds reset to defaults');
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection(EnergyProvider provider) async {
    _showSnackBar('Testing connection...');
    try {
      await provider.loadAllData();
      if (provider.connectionStatus == 'connected') {
        _showSnackBar('Connection successful ✓');
      } else {
        _showSnackBar('Connection failed. Check server URL.');
      }
    } catch (e) {
      _showSnackBar('Connection error: $e');
    }
  }

  void _exportAllData(EnergyProvider provider) {
    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'currentData': provider.currentData?.toJson(),
      'dailyStats': provider.dailyStats?.toJson(),
      'events': provider.events,
      'alerts': provider.alerts,
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    Clipboard.setData(ClipboardData(text: jsonStr));
    _showSnackBar('Data copied to clipboard (${jsonStr.length} bytes)');
  }

  void _confirmClearData(EnergyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
            'This will permanently delete all history and events. This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              provider.clearHistory();
              _showSnackBar('All data cleared');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showDebugInfo(EnergyProvider provider) {
    final info = {
      'Connection': provider.connectionStatus,
      'Mode': provider.userMode,
      'Voltage': provider.currentData?.voltage,
      'Current': provider.currentData?.current,
      'Power': provider.currentData?.power,
      'LDR': provider.currentData?.ldrValue,
      'WAPDA': provider.currentData?.wapdaAvailable,
      'Sunny': provider.currentData?.isSunny,
      'DayTime': provider.currentData?.isDayTime,
      'ESP32 Online': provider.currentData?.esp32Online,
      'Events Count': provider.events.length,
      'Alerts Count': provider.alerts.length,
      'Platform': kIsWeb ? 'Web' : 'Mobile',
      'Debug Mode': kDebugMode,
    };

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: info.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key,
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[600])),
                    Text(e.value?.toString() ?? 'null',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _confirmResetSettings(
      ThemeProvider themeProvider, EnergyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset All Settings'),
        content: const Text('Restore all settings to factory defaults?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              themeProvider.setThemeMode(AppThemeMode.system);
              await _loadSettings();
              _showSnackBar('All settings reset to defaults');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.orange),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    Clipboard.setData(const ClipboardData(
        text:
            'Check out Smart Energy Controller - the best solar energy management app!'));
    _showSnackBar('App link copied to clipboard');
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
