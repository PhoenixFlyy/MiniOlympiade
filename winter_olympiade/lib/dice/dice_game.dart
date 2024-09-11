import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shake/shake.dart';

class DiceGame extends StatefulWidget {
  const DiceGame({super.key});

  @override
  State<DiceGame> createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> {
  final List<String> diceImages = [
    'assets/dice/dice-1.png',
    'assets/dice/dice-2.png',
    'assets/dice/dice-3.png',
    'assets/dice/dice-4.png',
    'assets/dice/dice-5.png',
    'assets/dice/dice-6.png',
  ];
  String currentDiceImage = 'assets/dice/dice-1.png';
  late ShakeDetector shakeDetector;
  
  @override
  void initState() {
    super.initState();
    shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 2,
      onPhoneShake: () {
        if (mounted) {
          rollDice();
        }
      },
    );
  }

  @override
  void dispose() {
    shakeDetector.stopListening();
    super.dispose();
  }

  void rollDice() {
    setState(() {
      currentDiceImage = diceImages[Random().nextInt(6)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dice Game'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(currentDiceImage, width: 100, height: 100),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: rollDice,
              child: const Text('Roll Dice'),
            ),
          ],
        ),
      ),
    );
  }
}
