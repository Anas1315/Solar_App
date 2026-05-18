import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:smart_energy_controller/providers/energy_provider.dart';
import 'package:smart_energy_controller/providers/auth_provider.dart';
import 'package:smart_energy_controller/providers/theme_provider.dart';
import 'package:smart_energy_controller/screens/login_screen.dart';
import 'package:smart_energy_controller/screens/setup_screen.dart';
import 'package:smart_energy_controller/screens/home_screen.dart';
import 'package:smart_energy_controller/screens/controls_screen.dart';
import 'package:smart_energy_controller/screens/analytics_screen.dart';
import 'package:smart_energy_controller/screens/alerts_screen.dart';
import 'package:smart_energy_controller/screens/settings_screen.dart';
import 'package:smart_energy_controller/services/notification_service.dart';
import 'package:smart_energy_controller/utils/theme.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const SmartEnergyApp());
  Future<void>.microtask(() async {
    await NotificationService().initialize();
  });
}

class SmartEnergyApp extends StatelessWidget {
  final bool autoConnect;

  const SmartEnergyApp({super.key, this.autoConnect = true});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (_) => AuthProvider(checkSetup: autoConnect)),
        ChangeNotifierProvider(
          create: (_) => EnergyProvider(autoConnect: autoConnect),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Smart Energy Controller',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                if (authProvider.isLoading) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (authProvider.needsSetup) {
                  return const SetupScreen();
                }
                return authProvider.isAuthenticated
                    ? const MainNavigation()
                    : const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  late final List<Widget?> _screens = <Widget?>[
    const HomeScreen(),
    null,
    null,
    null,
    null,
  ];

  Widget _screenForIndex(int index) {
    return _screens[index] ??= switch (index) {
      1 => const ControlsScreen(),
      2 => const AnalyticsScreen(),
      3 => const AlertsScreen(),
      4 => const SettingsScreen(),
      _ => const HomeScreen(),
    };
  }

  void _selectTab(int index) {
    setState(() {
      _currentIndex = index;
      _screenForIndex(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: _screenForIndex(_currentIndex),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        height: 60.0,
        items: <Widget>[
          Icon(_currentIndex == 0 ? Icons.home : Icons.home_outlined,
              size: 30, color: _currentIndex == 0 ? Colors.white : Colors.grey),
          Icon(_currentIndex == 1 ? Icons.tune : Icons.tune_outlined,
              size: 30, color: _currentIndex == 1 ? Colors.white : Colors.grey),
          Icon(_currentIndex == 2 ? Icons.bar_chart : Icons.bar_chart_outlined,
              size: 30, color: _currentIndex == 2 ? Colors.white : Colors.grey),
          Icon(
              _currentIndex == 3
                  ? Icons.notifications
                  : Icons.notifications_none_outlined,
              size: 30,
              color: _currentIndex == 3 ? Colors.white : Colors.grey),
          Icon(_currentIndex == 4 ? Icons.settings : Icons.settings_outlined,
              size: 30, color: _currentIndex == 4 ? Colors.white : Colors.grey),
        ],
        color: isDark ? AppTheme.cardDark : Colors.white,
        buttonBackgroundColor: AppTheme.primary,
        backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFF5F7FA),
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: _selectTab,
      ),
    );
  }
}
