import 'package:flutter/material.dart';
import 'package:olympiade/games/Dart/DartConstants.dart';

class DartsKeyboard extends StatefulWidget {
  final Function(int score, Multiplier multiplier) onScoreSelected;

  const DartsKeyboard({super.key, required this.onScoreSelected});

  @override
  State<DartsKeyboard> createState() => _DartsKeyboardState();
}

class _DartsKeyboardState extends State<DartsKeyboard> {
  double textSize = 18;
  double borderRadius = 5;
  double spacing = 2;
  Color? backgroundColor = Colors.grey[800];
  Size size = const Size(35, 75);
  Multiplier selectedMultiplier = Multiplier.single;

  void _onScorePressed(int score) {
    widget.onScoreSelected(score, selectedMultiplier);
    setState(() => selectedMultiplier = Multiplier.single);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 8,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(5, (rowIndex) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: spacing),
                child: Row(
                  children: List.generate(4, (colIndex) {
                    int buttonNumber = rowIndex * 4 + colIndex + 1;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: spacing),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: backgroundColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(borderRadius),
                            ),
                            minimumSize: size
                          ),
                          onPressed: () => _onScorePressed(buttonNumber),
                          child: Text(
                            buttonNumber.toString(),
                            style: TextStyle(color: Colors.white, fontSize: textSize),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.only(left: 2),
            child: Column(
              children: [
                _buildSideButton("0", backgroundColor, () => _onScorePressed(0)),
                _buildSideButton("SB", Colors.red[700], () => _onScorePressed(25)),
                _buildSideButton("D", Colors.orange, () => setState(() => selectedMultiplier = Multiplier.double)),
                _buildSideButton("T", Colors.orange[700], () => setState(() => selectedMultiplier = Multiplier.triple)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton(String label, Color? buttonColor, VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          minimumSize: Size.fromHeight((size.height * 5) / 4),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: textSize),
        ),
      ),
    );
  }
}