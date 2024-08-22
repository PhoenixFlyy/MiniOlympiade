import 'package:flutter/material.dart';
import 'AchievementList.dart';

class AchievementProvider extends ChangeNotifier {
  final List<Achievement> _achievements = achievements;

  List<Achievement> getAchievementList() => _achievements;

  void completeAchievement(int index) {
    _achievements[index].isCompleted = true;
    notifyListeners();
  }

  void completeAchievementByTitle(String title) {
    final achievement = _achievements.firstWhere((achievement) => achievement.title == title);
    achievement.isCompleted = true;
    notifyListeners();
  }
}
