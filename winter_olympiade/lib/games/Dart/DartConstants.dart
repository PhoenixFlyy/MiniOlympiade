import 'dart:io';
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
  final ImageProvider<Object>? image;

  Player({required this.name, this.image});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'imagePath': (image as FileImage).file.path
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      image: FileImage(File(json['imagePath'])),
    );
  }
}

class Throw {
  final int score;
  final Multiplier multiplier;

  Throw({required this.score, this.multiplier = Multiplier.single});

  int calculateScore() => score * (multiplier.index + 1);
}

enum Multiplier {
  single,
  double,
  triple,
}

class PlayerTurn {
  final Player player;
  final List<Throw> throws;
  bool overthrown;

  PlayerTurn({
    required this.player,
    required this.throws,
    this.overthrown = false,
  });

  int get turnSum => throws.fold(0, (sum, t) => sum + t.calculateScore());
}

class AvgScoreResult {
  final double avgScore;
  final int totalThrows;

  AvgScoreResult(this.avgScore, this.totalThrows);
}