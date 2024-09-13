import 'package:flutter/material.dart';
import 'package:olympiade/dice/DiceModel.dart';
import 'package:shake/shake.dart';

class DiceGame extends StatefulWidget {
  const DiceGame({super.key});

  @override
  State<DiceGame> createState() => _DiceGameState();
}

class _DiceGameState extends State<DiceGame> {
  late ShakeDetector shakeDetector;
  final List<DiceModel> diceModels = [];
  final List<int> diceRanges = [4, 6, 8, 10, 12, 20];

  final List<String> diceSelectImages = [
    'assets/dice/diceSelect4.png',
    'assets/dice/diceSelect6.png',
    'assets/dice/diceSelect8.png',
    'assets/dice/diceSelect10.png',
    'assets/dice/diceSelect12.png',
    'assets/dice/diceSelect20.png',
  ];

  final Map<int, Color> diceColors = {
    4: Colors.green,
    6: Colors.blue,
    8: Colors.purple,
    10: Colors.pink,
    12: Colors.red,
    20: Colors.orange,
  };

  @override
  void initState() {
    super.initState();
    shakeDetector = ShakeDetector.autoStart(
      shakeThresholdGravity: 2,
      onPhoneShake: () {
        if (mounted) {
          rollDices();
        }
      },
    );
  }

  @override
  void dispose() {
    shakeDetector.stopListening();
    super.dispose();
  }

  void addDice(int range) {
    setState(() => diceModels.add(DiceModel(range: range)));
  }

  void removeDice(DiceModel dice) {
    setState(() => diceModels.remove(dice));
  }

  void rollDices() async {
    await Future.wait(diceModels.map((dice) => dice.roll()));
  }

  double getDiceSize() {
    int diceCount = diceModels.length;
    double baseSize = 125.0;
    return diceCount <= 4 ? baseSize : baseSize * (4 / diceCount);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Würfel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: diceModels.map((dice) {
                  return SizedBox(
                    key: ValueKey<DiceModel>(dice),
                    width: getDiceSize(),
                    height: getDiceSize(),
                    child: DiceWidget(
                      dice: dice,
                      diceSize: getDiceSize(),
                      onRemove: () => removeDice(dice),
                    ),
                  );
                }).toList(),
              ),
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: diceSelectImages.sublist(0, 3).map((image) {
                      return GestureDetector(
                        onTap: () => addDice(diceRanges[diceSelectImages.indexOf(image)]),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              diceColors[diceRanges[diceSelectImages.indexOf(image)]]!.withOpacity(0.5),
                              BlendMode.srcATop,
                            ),
                            child: Image.asset(
                              image,
                              width: 75,
                              height: 75,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: diceSelectImages.sublist(3, 6).map((image) {
                      return GestureDetector(
                        onTap: () => addDice(diceRanges[diceSelectImages.indexOf(image)]),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              diceColors[diceRanges[diceSelectImages.indexOf(image)]]!.withOpacity(0.5),
                              BlendMode.srcATop,
                            ),
                            child: Image.asset(
                              image,
                              width: 75,
                              height: 75,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ElevatedButton(
                      style: ButtonStyle(
                        minimumSize: WidgetStateProperty.all(const Size(150, 50)),
                        backgroundColor: WidgetStateProperty.all(Colors.blue),
                        shape: WidgetStateProperty.all(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)
                          ),
                        ),
                      ),
                      onPressed: rollDices,
                      child: const Text('Würfeln', style: TextStyle(color: Colors.white, fontSize: 18)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}