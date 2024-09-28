import 'package:flutter/material.dart';
import 'package:olympiade/utils/wave_painter.dart';
import 'package:provider/provider.dart';

import '../infos/achievements/achievement_provider.dart';

class SoundButton extends StatefulWidget {
  final String buttonText;
  final IconData icon;
  final VoidCallback onPressed;

  const SoundButton({
    super.key,
    required this.buttonText,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<SoundButton> createState() => _SoundButtonState();
}

class _SoundButtonState extends State<SoundButton> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.85,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnimation = CurvedAnimation(parent: _scaleController, curve: Curves.easeOut);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _waveAnimation = CurvedAnimation(parent: _waveController, curve: Curves.easeOut);
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.forward();
    _waveController.forward(from: 0.0);
    context.read<AchievementProvider>().markSoundEffectAsPlayed(widget.buttonText);
    context.read<AchievementProvider>().completeAchievementByTitle('Gomme Mode');
    widget.onPressed();
  }

  void _onTapCancel() {
    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            painter: WavePainter(
              animation: _waveAnimation,
              color: Colors.white.withOpacity(0.3),
            ),
            child: const SizedBox(
              width: 120,
              height: 120,
            ),
          ),
          ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(2, 2)),
                    ],
                  ),
                  child: Center(
                    child: Icon(widget.icon, size: 40, color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.buttonText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 2, offset: Offset(1, 1))],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}