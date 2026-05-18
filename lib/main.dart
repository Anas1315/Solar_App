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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppTheme.cardDark : Colors.white,
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppTheme.primaryLight.withValues(alpha: 0.08)
                  : AppTheme.primary.withValues(alpha: 0.10),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppTheme.primaryDark)
                  .withValues(alpha: isDark ? 0.32 : 0.12),
              blurRadius: 28,
              offset: const Offset(0, -8),
            ),
            if (!isDark)
              BoxShadow(
                color: AppTheme.sunGlow.withValues(alpha: 0.14),
                blurRadius: 26,
                offset: const Offset(0, -6),
              ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home,
                    label: 'Home',
                    index: 0,
                    current: _currentIndex,
                    onTap: _selectTab),
                _NavItem(
                    icon: Icons.tune_outlined,
                    activeIcon: Icons.tune,
                    label: 'Controls',
                    index: 1,
                    current: _currentIndex,
                    onTap: _selectTab),
                _NavItem(
                    icon: Icons.bar_chart_outlined,
                    activeIcon: Icons.bar_chart,
                    label: 'Analytics',
                    index: 2,
                    current: _currentIndex,
                    onTap: _selectTab),
                _NavItem(
                    icon: Icons.notifications_none_outlined,
                    activeIcon: Icons.notifications,
                    label: 'Alerts',
                    index: 3,
                    current: _currentIndex,
                    onTap: _selectTab),
                _NavItem(
                    icon: Icons.settings_outlined,
                    activeIcon: Icons.settings,
                    label: 'Settings',
                    index: 4,
                    current: _currentIndex,
                    onTap: _selectTab),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? AppTheme.primaryLight : AppTheme.primaryDark;
    final inactiveColor =
        isDark ? const Color(0xFF86A4AD) : const Color(0xFF78909C);

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppTheme.primaryLight : AppTheme.primary)
                  .withValues(alpha: isDark ? 0.16 : 0.11)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: isActive
              ? Border.all(
                  color: activeColor.withValues(alpha: isDark ? 0.20 : 0.10),
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: activeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
