import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  void _toggleMultiplier(Multiplier multiplier) {
    setState(() {
      if (selectedMultiplier == multiplier) {
        selectedMultiplier = Multiplier.single;
      } else {
        selectedMultiplier = multiplier;
      }
    });
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
                                side: selectedMultiplier != Multiplier.single ?
                                const BorderSide(color: Colors.white) :
                                BorderSide.none,
                                borderRadius: BorderRadius.circular(
                                    borderRadius),
                              ),
                              minimumSize: size
                          ),
                          onPressed: () {
                            _onScorePressed(buttonNumber);
                            HapticFeedback.lightImpact();
                          },
                          child: Text(
                            buttonNumber.toString(),
                            style: TextStyle(
                                color: Colors.white, fontSize: textSize),
                            softWrap: false,
                            overflow: TextOverflow.visible,
                            textAlign: TextAlign.center,
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
                _buildSideButton(
                    "0", backgroundColor, () => _onScorePressed(0)),
                _buildSideButton(
                    "SB", Colors.red[700], () => _onScorePressed(25)),
                _buildSideButton("D", Colors.orange, () =>
                    _toggleMultiplier(Multiplier.double)),
                _buildSideButton("T", Colors.orange[700], () =>
                    _toggleMultiplier(Multiplier.triple)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSideButton(String label, Color? buttonColor,
      VoidCallback onPressed) {
    bool isSelected = (label == "D" &&
        selectedMultiplier == Multiplier.double) ||
        (label == "T" && selectedMultiplier == Multiplier.triple);

    bool isDisabled = label == "SB" && selectedMultiplier == Multiplier.triple;
    bool multiplierBorder = selectedMultiplier == Multiplier.double && label == "SB";

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey : buttonColor,
          shape: RoundedRectangleBorder(
            side: multiplierBorder ?
            const BorderSide(color: Colors.white) :
            BorderSide.none,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          minimumSize: Size.fromHeight((size.height * 5) / 4),
          shadowColor: isSelected ? Colors.yellowAccent : Colors.transparent,
          elevation: isSelected ? 10 : 0,
        ),
        onPressed: isDisabled
            ? () => HapticFeedback.lightImpact()
            : () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        child: Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: textSize),
          softWrap: false,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
        ),
      ),
    );

  }
}