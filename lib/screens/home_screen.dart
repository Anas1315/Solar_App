import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_energy_controller/providers/energy_provider.dart';
import 'package:smart_energy_controller/utils/theme.dart';
import 'package:smart_energy_controller/widgets/energy_flow_widget.dart';

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
      backgroundColor: isDark ? AppTheme.darkBg : const Color(0xFFEAF6FB),
      body: SafeArea(
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
                offset: const Offset(0, -15),
                child: EnergyFlowWidget(values: values),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
              child: Text(
                'Last update:   ${values.lastUpdateText}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: values.isDayTime
                      ? const Color(0xFF8EA1AA)
                      : Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
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
              valueColor: const Color(0xFF111827),
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
    return Container(
      constraints: const BoxConstraints(minHeight: 112),
      padding: const EdgeInsets.fromLTRB(22, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
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

class _TopStatusBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final textColor = isDayTime ? const Color(0xFF607D8B) : Colors.white70;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      child: Row(
        children: [
          Icon(
            Icons.wifi,
            color: isOnline ? AppTheme.primary : const Color(0xFF9E9E9E),
            size: 20,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              isOnline ? 'Connected' : 'Disconnected',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: isOnline ? AppTheme.primaryDark : textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          _WeatherChip(
            isDayTime: isDayTime,
            isSunny: isSunny,
            isStormy: isStormy,
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
            ? const Color(0xFF5C6BC0)
            : isSunny
                ? const Color(0xFFFFB300)
                : const Color(0xFF64B5F6);

    return Container(
      constraints: const BoxConstraints(minWidth: 74),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isDayTime ? 0.76 : 0.16),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
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
              color: isDayTime ? Colors.black87 : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
