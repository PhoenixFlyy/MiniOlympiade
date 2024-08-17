import 'package:flutter/widgets.dart';

enum GameEndRule { singleOut, doubleOut }

class DartConstants {
  static const List<int> gameTypes = [201, 301, 501, 701];

  static String gameEndRuleToString(GameEndRule rule) {
    switch (rule) {
      case GameEndRule.singleOut:
        return 'Single Out';
      case GameEndRule.doubleOut:
        return 'Double Out';
      default:
        return '';
    }
  }
}

class Player {
  final String name;
  final ImageProvider<Object> image;

  Player({required this.name, required this.image});
}