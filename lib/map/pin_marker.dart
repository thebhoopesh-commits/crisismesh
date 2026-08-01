import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'help_request.dart';

class PinMarker extends StatefulWidget {
  final Severity severity;
  final VoidCallback onTap;

  const PinMarker({super.key, required this.severity, required this.onTap});

  @override
  State<PinMarker> createState() => _PinMarkerState();
}

class _PinMarkerState extends State<PinMarker> with SingleTickerProviderStateMixin {
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (widget.severity) {
      case Severity.critical: color = AppColors.critical; break;
      case Severity.urgent: color = AppColors.urgent; break;
      case Severity.stable: color = AppColors.stable; break;
    }

    final child = GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.location_on, color: color, size: 40),
          Positioned(
            top: 8,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          )
        ],
      ),
    );

    if (widget.severity == Severity.critical) {
      return AnimatedBuilder(
        animation: _glow,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(_glow.value * 0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ],
            ),
            child: child,
          );
        }
      );
    }
    
    return child;
  }
}
