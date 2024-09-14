import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DiceModel extends ChangeNotifier {
  final int range;
  int currentDiceNumber = -1;
  String currentDiceImage = 'assets/dice/dice-1.png';

  DiceModel({required this.range});

  final List<String> diceImages = [
    'assets/dice/dice-1.png',
    'assets/dice/dice-2.png',
    'assets/dice/dice-3.png',
    'assets/dice/dice-4.png',
    'assets/dice/dice-5.png',
    'assets/dice/dice-6.png',
  ];

  Future<void> roll() async {
    currentDiceNumber = -1;
    notifyListeners();

    for (int loop = 0; loop < 3; loop++) {
      for (int i = 0; i < diceImages.length; i++) {
        currentDiceImage = diceImages[Random().nextInt(6)];
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
    currentDiceNumber = Random().nextInt(range) + 1;
    currentDiceImage = diceImages[0];
    notifyListeners();
  }
}

class DiceWidget extends StatelessWidget {
  final DiceModel dice;
  final VoidCallback onRemove;
  final double diceSize;

  const DiceWidget({super.key, required this.dice, required this.onRemove, required this.diceSize});

  Color getTintForRange(int range) {
    switch (range) {
      case 4:
        return Colors.green;
      case 6:
        return Colors.blue;
      case 8:
        return Colors.purple;
      case 10:
        return Colors.pink;
      case 12:
        return Colors.red;
      case 20:
        return Colors.orange;
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRemove,
      child: ChangeNotifierProvider<DiceModel>.value(
        value: dice,
        child: Consumer<DiceModel>(
          builder: (context, dice, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    getTintForRange(dice.range).withOpacity(0.5),
                    BlendMode.srcATop,
                  ),
                  child: Image.asset(dice.currentDiceImage, width: 125, height: 125),
                ),
                if (dice.currentDiceNumber != -1)
                  Text(
                    dice.currentDiceNumber.toString(),
                    style: TextStyle(
                      fontSize: diceSize * 0.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}