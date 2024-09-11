import 'package:flutter/material.dart';

class MainMenuButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool bottomPadding;
  final bool rightPadding;
  final double fontSize;
  final String? heroTag;

  const MainMenuButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.bottomPadding = true,
    this.rightPadding = false,
    this.fontSize = 20,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding ? 10 : 0, right: rightPadding ? 10 : 0),
      child: FilledButton.tonal(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.all(16.0),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(width: 10),
            if (heroTag != null)
              Hero(
                tag: heroTag!,
                child: Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSize,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    wordSpacing: 0.0,
                    decoration: TextDecoration.none,
                    decorationColor: Colors.transparent,
                    decorationStyle: TextDecorationStyle.solid,
                    fontFamily: null,
                    height: 1.0,
                  ),
                ),
              )
            else
              Text(
                text,
                style: TextStyle(fontSize: fontSize, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
