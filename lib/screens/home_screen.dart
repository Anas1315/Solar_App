import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_energy_controller/providers/auth_provider.dart';
import 'package:smart_energy_controller/providers/energy_provider.dart';
import 'package:smart_energy_controller/utils/theme.dart';
import 'package:smart_energy_controller/widgets/energy_flow_widget.dart';
import 'package:smart_energy_controller/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EnergyProvider>();
    final data = provider.currentData;
    final isOnline = provider.connectionStatus == 'connected' &&
        (data?.esp32Online ?? false);
    final values = EnergyValues.fromData(data);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isGridConnected =
        data?.wapdaAvailable == true && data?.wapdaRelayState == true;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.lightBg,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    AppTheme.darkerBg,
                    AppTheme.darkBg,
                    AppTheme.cardDarkAlt,
                  ]
                : const [
                    AppTheme.lightCream,
                    AppTheme.lightBg,
                    AppTheme.lightSky,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopStatusBar(
                isOnline: isOnline,
                isDayTime: values.isDayTime,
                isSunny: values.isSunny,
                isStormy: values.isStormy,
              ),
              Expanded(
                child: Transform.translate(
                  offset: const Offset(0, -5),
                  child: EnergyFlowWidget(values: values),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 6, 20, 9),
                child: Text(
                  'Last update:   ${values.lastUpdateText}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppTheme.textLight
                        : AppTheme.textMuted.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _BottomSummaryCards(
                gridStatus: isGridConnected ? 'ON' : 'OFF',
                gridConnected: isGridConnected,
                powerKw: values.powerKw,
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSummaryCards extends StatelessWidget {
  final String gridStatus;
  final bool gridConnected;
  final double powerKw;

  const _BottomSummaryCards({
    required this.gridStatus,
    required this.gridConnected,
    required this.powerKw,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              title: 'WAPDA:',
              value: gridStatus,
              valueColor: gridConnected ? AppTheme.success : AppTheme.error,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: _SummaryCard(
              title: 'Power Today:',
              value: '${powerKw.toStringAsFixed(2)} kW',
              valueColor: isDark ? AppTheme.sunGlow : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : AppTheme.textDark;
    final cardGradient = isDark
        ? const [AppTheme.cardDarkAlt, AppTheme.cardDark]
        : const [Colors.white, AppTheme.lightSurfaceTint];

    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: cardGradient,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? AppTheme.primaryLight.withValues(alpha: 0.10)
              : AppTheme.primary.withValues(alpha: 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppTheme.primaryDark)
                .withValues(alpha: isDark ? 0.30 : 0.13),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          if (!isDark)
            BoxShadow(
              color: AppTheme.sunGlow.withValues(alpha: 0.16),
              blurRadius: 26,
              offset: const Offset(-10, -8),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: valueColor,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopStatusBar extends StatefulWidget {
  final bool isOnline;
  final bool isDayTime;
  final bool isSunny;
  final bool isStormy;

  const _TopStatusBar({
    required this.isOnline,
    required this.isDayTime,
    required this.isSunny,
    required this.isStormy,
  });

  @override
  State<_TopStatusBar> createState() => _TopStatusBarState();
}

class _TopStatusBarState extends State<_TopStatusBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _profileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? AppTheme.textLight : AppTheme.textMuted;
    final authProvider = context.watch<AuthProvider>();
    final email = authProvider.user?.email ?? 'U';
    final firstLetter = email.isNotEmpty ? email[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Wifi Status
          Expanded(
            flex: 2,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wifi,
                  color: widget.isOnline
                      ? AppTheme.primary
                      : const Color(0xFF9E9E9E),
                  size: 20,
                ),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    widget.isOnline ? 'Connected' : 'Disconnected',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: widget.isOnline
                          ? (isDark
                              ? AppTheme.primaryLight
                              : AppTheme.primaryDark)
                          : textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Center: Weather Chip
          Expanded(
            flex: 3,
            child: Center(
              child: _WeatherChip(
                isDayTime: widget.isDayTime,
                isSunny: widget.isSunny,
                isStormy: widget.isStormy,
              ),
            ),
          ),

          // Right: Animated Profile Icon
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.15).animate(
                    CurvedAnimation(
                      parent: _profileController,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        firstLetter,
                        style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  final bool isDayTime;
  final bool isSunny;
  final bool isStormy;

  const _WeatherChip({
    required this.isDayTime,
    required this.isSunny,
    required this.isStormy,
  });

  @override
  Widget build(BuildContext context) {
    final temp = context.watch<EnergyProvider>().currentTemp;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = !isDayTime
        ? Icons.nightlight_round
        : isStormy
            ? Icons.thunderstorm
            : isSunny
                ? Icons.wb_sunny
                : Icons.cloud;
    final iconColor = !isDayTime
        ? const Color(0xFFFFF8E1)
        : isStormy
            ? AppTheme.secondary
            : isSunny
                ? AppTheme.accent
                : AppTheme.info;

    return Container(
      constraints: const BoxConstraints(minWidth: 74),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.primaryLight.withValues(alpha: 0.10)
            : Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppTheme.primaryLight.withValues(alpha: 0.18)
              : AppTheme.sunGlow.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 6),
          Text(
            isStormy ? 'Storm' : temp,
            style: TextStyle(
              fontSize: isStormy ? 13 : 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
