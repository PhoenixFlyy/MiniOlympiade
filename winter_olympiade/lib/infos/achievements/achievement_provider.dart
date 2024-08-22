import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AchievementList.dart';

class AchievementProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];

  AchievementProvider() {
    _loadAchievements();
  }

  List<Achievement> getAchievementList() => _achievements;

  Future<void> _loadAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedAchievements = prefs.getStringList('achievements');

    if (savedAchievements != null) {
      _achievements = savedAchievements
          .map((achievementString) =>
          Achievement.fromJson(Map<String, dynamic>.from(jsonDecode(achievementString))))
          .toList();
    } else {
      _achievements = defaultAchievements;
      _saveAchievements();
    }

    notifyListeners();
  }

  Future<void> _saveAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> achievementsToSave = _achievements.map((achievement) => jsonEncode(achievement.toJson())).toList();
    await prefs.setStringList('achievements', achievementsToSave);
  }

  void completeAchievement(int index) {
    _achievements[index].isCompleted = true;
    _achievements[index].hidden = false;
    _saveAchievements();
    notifyListeners();
  }

  void completeAchievementByTitle(String title) {
    final achievement = _achievements.firstWhere((achievement) => achievement.title == title);
    achievement.isCompleted = true;
    achievement.hidden = false;
    _saveAchievements();
    notifyListeners();
  }

  Future<void> resetAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('achievements');
    notifyListeners();
  }
}