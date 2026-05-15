// import 'package:flutter/material.dart';
// import 'package:smart_energy_controller/models/energy_data.dart';
// import 'package:intl/intl.dart';

// class EnergyFlowWidget extends StatelessWidget {
//   final EnergyData? data;
//   const EnergyFlowWidget({super.key, this.data});

//   String _fmt(double? v) => '${((v ?? 0) / 1000).toStringAsFixed(0)} kW';

//   @override
//   Widget build(BuildContext context) {
//     final isOnline = data?.esp32Online ?? false;
//     final hasAlert = !(data?.wapdaAvailable ?? true);
//     final lastUpdate = data?.lastUpdate ?? DateTime.now();
//     final isSunny = data?.isSunny ?? true;
//     final temp = ((data?.ldrValue ?? 500) / 50).round();

//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//               color: Colors.black.withValues(alpha: 0.08),
//               blurRadius: 16,
//               offset: const Offset(0, 4))
//         ],
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildStatusBar(isOnline, hasAlert, isSunny, temp),
//           Expanded(child: _buildScene(context)),
//           _buildLastUpdate(lastUpdate),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusBar(bool isOnline, bool hasAlert, bool isSunny, int temp) {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//       child: Row(
//         children: [
//           Icon(Icons.wifi,
//               size: 16, color: isOnline ? Colors.teal : Colors.grey),
//           const SizedBox(width: 4),
//           Text(
//             isOnline ? 'Communication succeeded' : 'Disconnected',
//             style: TextStyle(
//                 fontSize: 11, color: isOnline ? Colors.black87 : Colors.red),
//           ),
//           const SizedBox(width: 12),
//           Icon(Icons.notifications,
//               size: 16, color: hasAlert ? Colors.red : Colors.orange),
//           const SizedBox(width: 2),
//           Text('Alert',
//               style: TextStyle(
//                   fontSize: 11, color: hasAlert ? Colors.red : Colors.orange)),
//           const Spacer(),
//           Icon(isSunny ? Icons.wb_sunny : Icons.cloud,
//               size: 20, color: isSunny ? Colors.orange : Colors.blueGrey),
//           const SizedBox(width: 4),
//           Text('$temp°C',
//               style:
//                   const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }

//   Widget _buildScene(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       final w = constraints.maxWidth;
//       final h = constraints.maxHeight;
//       return Stack(
//         clipBehavior: Clip.none,
//         children: [
//           // Sky
//           Positioned.fill(
//             child: CustomPaint(painter: _SkyPainter()),
//           ),
//           // Ground
//           Positioned(
//             left: 0,
//             right: 0,
//             bottom: 0,
//             height: h * 0.22,
//             child: Container(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [const Color(0xFF8BC34A), const Color(0xFF689F38)],
//                 ),
//                 borderRadius: const BorderRadius.only(
//                   bottomLeft: Radius.circular(16),
//                   bottomRight: Radius.circular(16),
//                 ),
//               ),
//             ),
//           ),
//           // Flow lines
//           Positioned.fill(
//             child: CustomPaint(painter: _FlowLinesPainter(w: w, h: h)),
//           ),
//           // Solar Panel
//           Positioned(
//             left: w * 0.02,
//             bottom: h * 0.18,
//             child: _buildSolarPanel(h),
//           ),
//           // Production label
//           Positioned(
//             left: w * 0.02,
//             bottom: h * 0.50,
//             child: _buildLabel(_fmt(data?.power), 'Production', Colors.black87),
//           ),
//           // House
//           Positioned(
//             left: w * 0.28,
//             bottom: h * 0.18,
//             child: _buildHouse(w * 0.40, h * 0.42),
//           ),
//           // Consumption label
//           Positioned(
//             left: w * 0.30,
//             top: h * 0.08,
//             child:
//                 _buildLabel(_fmt(data?.power), 'Consumption', Colors.black87),
//           ),
//           // Battery
//           Positioned(
//             right: w * 0.28,
//             bottom: h * 0.18,
//             child: _buildBattery(h),
//           ),
//           // Battery label
//           Positioned(
//             right: w * 0.22,
//             bottom: h * 0.50,
//             child: _buildLabel(_fmt(data?.power), 'Battery', Colors.black87),
//           ),
//           // Grid Tower
//           Positioned(
//             right: w * 0.02,
//             bottom: h * 0.18,
//             child: _buildGridTower(h),
//           ),
//           // Grid label
//           Positioned(
//             right: w * 0.01,
//             top: h * 0.12,
//             child: _buildLabel(_fmt(data?.power), 'Grid', Colors.black87),
//           ),
//           // Inverter
//           Positioned(
//             left: w * 0.38,
//             bottom: h * 0.02,
//             child: _buildInverter(w * 0.24),
//           ),
//         ],
//       );
//     });
//   }

//   Widget _buildLabel(String value, String label, Color c) {
//     return Column(
//       children: [
//         Text(value,
//             style:
//                 TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: c)),
//         Text(label, style: TextStyle(fontSize: 11, color: c.withValues(alpha: 0.7))),
//       ],
//     );
//   }

//   Widget _buildSolarPanel(double h) {
//     return SizedBox(
//       width: 56,
//       height: h * 0.22,
//       child: CustomPaint(painter: _SolarPanelPainter()),
//     );
//   }

//   Widget _buildHouse(double w, double h) {
//     return SizedBox(
//       width: w,
//       height: h,
//       child: CustomPaint(painter: _HousePainter()),
//     );
//   }

//   Widget _buildBattery(double h) {
//     return SizedBox(
//       width: 44,
//       height: h * 0.14,
//       child: CustomPaint(painter: _BatteryPainter()),
//     );
//   }

//   Widget _buildGridTower(double h) {
//     return SizedBox(
//       width: 50,
//       height: h * 0.30,
//       child: CustomPaint(painter: _GridTowerPainter()),
//     );
//   }

//   Widget _buildInverter(double w) {
//     return Container(
//       width: w,
//       height: w * 0.7,
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         border: Border.all(color: const Color(0xFF1A237E), width: 2.5),
//         color: Colors.white,
//       ),
//       child: Center(
//         child: Container(
//           width: w * 0.38,
//           height: w * 0.30,
//           decoration: BoxDecoration(
//             color: const Color(0xFFFFC107),
//             borderRadius: BorderRadius.circular(3),
//           ),
//           child: const Center(
//             child: Text('SOLAR',
//                 style: TextStyle(
//                     fontSize: 5,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black54)),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLastUpdate(DateTime dt) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Text(
//         'Last update:  ${DateFormat('yyyy/MM/dd HH:mm:ss').format(dt)}',
//         style: const TextStyle(fontSize: 11, color: Colors.black54),
//       ),
//     );
//   }
// }

// // --- Custom Painters ---

// class _SkyPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final rect = Rect.fromLTWH(0, 0, size.width, size.height * 0.8);
//     final gradient = LinearGradient(
//       begin: Alignment.topCenter,
//       end: Alignment.bottomCenter,
//       colors: [
//         const Color(0xFFE3F2FD),
//         const Color(0xFFBBDEFB),
//         const Color(0xFFE8F5E9)
//       ],
//     );
//     canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));
//     // Clouds
//     final cp = Paint()..color = Colors.white.withValues(alpha: 0.7);
//     _drawCloud(canvas, Offset(size.width * 0.2, size.height * 0.15), 30, cp);
//     _drawCloud(canvas, Offset(size.width * 0.7, size.height * 0.10), 22, cp);
//   }

//   void _drawCloud(Canvas canvas, Offset pos, double r, Paint p) {
//     canvas.drawCircle(pos, r, p);
//     canvas.drawCircle(pos + Offset(-r * 0.7, r * 0.2), r * 0.7, p);
//     canvas.drawCircle(pos + Offset(r * 0.7, r * 0.15), r * 0.8, p);
//     canvas.drawCircle(pos + Offset(0, r * 0.3), r * 0.6, p);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _FlowLinesPainter extends CustomPainter {
//   final double w, h;
//   _FlowLinesPainter({required this.w, required this.h});

//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = const Color(0xFF4CAF50)
//       ..strokeWidth = 2.5
//       ..style = PaintingStyle.stroke;

//     final groundY = h * 0.80;
//     final inverterX = w * 0.50;
//     final inverterY = groundY + h * 0.02;

//     // Solar -> Inverter (along ground)
//     final solarX = w * 0.08;
//     canvas.drawLine(Offset(solarX, groundY), Offset(solarX, inverterY), paint);
//     canvas.drawLine(
//         Offset(solarX, inverterY), Offset(inverterX - 20, inverterY), paint);
//     _drawArrow(canvas, Offset(solarX, groundY - 4), true, paint);

//     // House <- Inverter (up from inverter)
//     final houseX = w * 0.48;
//     final houseY = groundY - h * 0.02;
//     canvas.drawLine(
//         Offset(houseX, inverterY - 15), Offset(houseX, houseY), paint);
//     _drawArrow(canvas, Offset(houseX, houseY), true, paint);

//     // Battery -> from inverter line
//     final batX = w * 0.64;
//     canvas.drawLine(
//         Offset(inverterX + 20, inverterY), Offset(batX, inverterY), paint);
//     canvas.drawLine(Offset(batX, inverterY), Offset(batX, groundY), paint);
//     _drawArrow(canvas, Offset(batX, groundY), true, paint);

//     // Grid -> from battery line
//     final gridX = w * 0.92;
//     canvas.drawLine(Offset(batX, inverterY), Offset(gridX, inverterY), paint);
//     canvas.drawLine(Offset(gridX, inverterY), Offset(gridX, groundY), paint);
//     _drawArrow(canvas, Offset(gridX, groundY), true, paint);
//   }

//   void _drawArrow(Canvas canvas, Offset tip, bool up, Paint paint) {
//     final dir = up ? 1.0 : -1.0;
//     final path = Path()
//       ..moveTo(tip.dx - 5, tip.dy + 8 * dir)
//       ..lineTo(tip.dx, tip.dy)
//       ..lineTo(tip.dx + 5, tip.dy + 8 * dir);
//     canvas.drawPath(path, paint..style = PaintingStyle.stroke);
//     paint.style = PaintingStyle.stroke;
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _SolarPanelPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final w = size.width, h = size.height;
//     // Pole
//     canvas.drawRect(
//       Rect.fromLTWH(w * 0.42, h * 0.55, w * 0.16, h * 0.45),
//       Paint()..color = const Color(0xFF9E9E9E),
//     );
//     // Panel body (tilted look)
//     final panelPath = Path()
//       ..moveTo(0, h * 0.15)
//       ..lineTo(w, h * 0.05)
//       ..lineTo(w, h * 0.55)
//       ..lineTo(0, h * 0.55)
//       ..close();
//     canvas.drawPath(panelPath, Paint()..color = const Color(0xFF1565C0));
//     canvas.drawPath(
//         panelPath,
//         Paint()
//           ..color = Colors.black
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 1);
//     // Grid lines on panel
//     final gridPaint = Paint()
//       ..color = Colors.white.withValues(alpha: 0.3)
//       ..strokeWidth = 0.8;
//     for (var i = 1; i < 3; i++) {
//       final y = h * 0.15 + (h * 0.40 / 3) * i;
//       canvas.drawLine(Offset(0, y), Offset(w, y - 3), gridPaint);
//     }
//     for (var i = 1; i < 4; i++) {
//       final x = w / 4 * i;
//       canvas.drawLine(Offset(x, h * 0.08), Offset(x, h * 0.55), gridPaint);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _HousePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final w = size.width, h = size.height;
//     // Roof
//     final roofPath = Path()
//       ..moveTo(w * 0.5, 0)
//       ..lineTo(w * 1.05, h * 0.40)
//       ..lineTo(-w * 0.05, h * 0.40)
//       ..close();
//     canvas.drawPath(roofPath, Paint()..color = const Color(0xFF80CBC4));
//     canvas.drawPath(
//         roofPath,
//         Paint()
//           ..color = const Color(0xFF4DB6AC)
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 1.5);
//     // Wall
//     canvas.drawRect(
//       Rect.fromLTWH(w * 0.08, h * 0.40, w * 0.84, h * 0.58),
//       Paint()..color = const Color(0xFFF5F5F5),
//     );
//     canvas.drawRect(
//       Rect.fromLTWH(w * 0.08, h * 0.40, w * 0.84, h * 0.58),
//       Paint()
//         ..color = const Color(0xFFBDBDBD)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1,
//     );
//     // Windows
//     final winPaint = Paint()..color = const Color(0xFFFFC107);
//     final winBorder = Paint()
//       ..color = const Color(0xFFFF8F00)
//       ..style = PaintingStyle.stroke
//       ..strokeWidth = 1.5;
//     // Left window
//     canvas.drawRect(
//         Rect.fromLTWH(w * 0.15, h * 0.50, w * 0.18, h * 0.22), winPaint);
//     canvas.drawRect(
//         Rect.fromLTWH(w * 0.15, h * 0.50, w * 0.18, h * 0.22), winBorder);
//     canvas.drawLine(
//         Offset(w * 0.24, h * 0.50), Offset(w * 0.24, h * 0.72), winBorder);
//     canvas.drawLine(
//         Offset(w * 0.15, h * 0.61), Offset(w * 0.33, h * 0.61), winBorder);
//     // Right window
//     canvas.drawRect(
//         Rect.fromLTWH(w * 0.60, h * 0.50, w * 0.18, h * 0.22), winPaint);
//     canvas.drawRect(
//         Rect.fromLTWH(w * 0.60, h * 0.50, w * 0.18, h * 0.22), winBorder);
//     canvas.drawLine(
//         Offset(w * 0.69, h * 0.50), Offset(w * 0.69, h * 0.72), winBorder);
//     canvas.drawLine(
//         Offset(w * 0.60, h * 0.61), Offset(w * 0.78, h * 0.61), winBorder);
//     // Door
//     canvas.drawRect(Rect.fromLTWH(w * 0.40, h * 0.60, w * 0.15, h * 0.38),
//         Paint()..color = const Color(0xFF8D6E63));
//     canvas.drawRect(
//       Rect.fromLTWH(w * 0.40, h * 0.60, w * 0.15, h * 0.38),
//       Paint()
//         ..color = const Color(0xFF6D4C41)
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 1,
//     );
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _BatteryPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final w = size.width, h = size.height;
//     // Body
//     final body = RRect.fromRectAndRadius(
//         Rect.fromLTWH(0, h * 0.1, w, h * 0.9), const Radius.circular(3));
//     canvas.drawRRect(body, Paint()..color = const Color(0xFF424242));
//     canvas.drawRRect(
//         body,
//         Paint()
//           ..color = Colors.black
//           ..style = PaintingStyle.stroke
//           ..strokeWidth = 1);
//     // Terminal
//     canvas.drawRect(Rect.fromLTWH(w * 0.15, 0, w * 0.15, h * 0.12),
//         Paint()..color = const Color(0xFF9E9E9E));
//     canvas.drawRect(Rect.fromLTWH(w * 0.60, 0, w * 0.15, h * 0.12),
//         Paint()..color = const Color(0xFFEF5350));
//     // Label
//     final tp = TextPainter(
//       text: const TextSpan(
//           text: '12V',
//           style: TextStyle(
//               color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
//       //textDirection: TextDirection.ltr,
//     )..layout();
//     tp.paint(canvas, Offset((w - tp.width) / 2, h * 0.45));
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }

// class _GridTowerPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final w = size.width, h = size.height;
//     final paint = Paint()
//       ..color = const Color(0xFF616161)
//       ..strokeWidth = 2.5
//       ..style = PaintingStyle.stroke;
//     // Main pole
//     canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.5, h), paint);
//     // Cross arms
//     canvas.drawLine(
//         Offset(w * 0.1, h * 0.10), Offset(w * 0.9, h * 0.10), paint);
//     canvas.drawLine(
//         Offset(w * 0.2, h * 0.25), Offset(w * 0.8, h * 0.25), paint);
//     // Wires drooping
//     final wirePaint = Paint()
//       ..color = const Color(0xFF424242)
//       ..strokeWidth = 1
//       ..style = PaintingStyle.stroke;
//     final lWire = Path()
//       ..moveTo(w * 0.1, h * 0.10)
//       ..quadraticBezierTo(0, h * 0.20, w * 0.1, h * 0.25);
//     canvas.drawPath(lWire, wirePaint);
//     final rWire = Path()
//       ..moveTo(w * 0.9, h * 0.10)
//       ..quadraticBezierTo(w, h * 0.20, w * 0.9, h * 0.25);
//     canvas.drawPath(rWire, wirePaint);
//     // Support braces
//     canvas.drawLine(Offset(w * 0.35, h * 0.4), Offset(w * 0.5, h * 0.6),
//         paint..strokeWidth = 1.5);
//     canvas.drawLine(Offset(w * 0.65, h * 0.4), Offset(w * 0.5, h * 0.6), paint);
//     // Base - small green bushes
//     final bushPaint = Paint()..color = const Color(0xFF66BB6A);
//     canvas.drawCircle(Offset(w * 0.3, h * 0.98), 6, bushPaint);
//     canvas.drawCircle(Offset(w * 0.7, h * 0.98), 5, bushPaint);
//     canvas.drawCircle(Offset(w * 0.5, h * 0.96), 7, bushPaint);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
import 'package:flutter/material.dart';
import 'package:smart_energy_controller/models/energy_data.dart';

class EnergyFlowWidget extends StatelessWidget {
  final EnergyData? data;

  const EnergyFlowWidget({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    const consumption = 456.0;
    const production = 456.0;
    const battery = 456.0;
    const grid = 456.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          // Alert row
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFFF6B6B), size: 16),
                    SizedBox(width: 6),
                    Text(
                      'Alert',
                      style: TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thermostat, color: Colors.black54, size: 16),
                  SizedBox(width: 4),
                  Text(
                    '9°C',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Center circle (Inverter/Hub)
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.electrical_services,
                    color: Colors.white, size: 40),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Flow arrows and values - Row 1: Production (left arrow to center)
          Row(
            children: [
              // Production box (left side)
              Expanded(
                child: _buildFlowCard(
                  icon: Icons.solar_power,
                  iconColor: const Color(0xFFFFB74D),
                  label: 'Production',
                  value: '${production.toInt()} kW',
                  arrowDirection: ArrowDirection.right,
                ),
              ),
              const SizedBox(width: 12),
              // Center spacer
              const SizedBox(width: 100),
              const SizedBox(width: 12),
              // Empty for symmetry
              const Expanded(child: SizedBox()),
            ],
          ),

          const SizedBox(height: 12),

          // Row 2: Battery (left) and Consumption (right)
          Row(
            children: [
              // Battery box
              Expanded(
                child: _buildFlowCard(
                  icon: Icons.battery_5_bar,
                  iconColor: const Color(0xFF4CAF50),
                  label: 'Battery',
                  value: '${battery.toInt()} kW',
                  arrowDirection: ArrowDirection.right,
                ),
              ),
              const SizedBox(width: 12),
              // Center icon
              Container(
                width: 100,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8ECF1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(
                  child: Icon(Icons.sync_alt, color: Colors.black54, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              // Consumption box
              Expanded(
                child: _buildFlowCard(
                  icon: Icons.home,
                  iconColor: const Color(0xFF2196F3),
                  label: 'Consumption',
                  value: '${consumption.toInt()} kW',
                  arrowDirection: ArrowDirection.left,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Row 3: Grid (left arrow to center)
          Row(
            children: [
              // Grid box
              Expanded(
                child: _buildFlowCard(
                  icon: Icons.electrical_services,
                  iconColor: const Color(0xFF9C27B0),
                  label: 'Grid',
                  value: '${grid.toInt()} kW',
                  arrowDirection: ArrowDirection.right,
                ),
              ),
              const SizedBox(width: 12),
              // Center spacer
              const SizedBox(width: 100),
              const SizedBox(width: 12),
              // Empty for symmetry
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFlowCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required ArrowDirection arrowDirection,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              if (arrowDirection == ArrowDirection.right)
                const Icon(Icons.arrow_forward, color: Colors.black54, size: 20)
              else if (arrowDirection == ArrowDirection.left)
                const Icon(Icons.arrow_back, color: Colors.black54, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

enum ArrowDirection {
  left,
  right,
}
