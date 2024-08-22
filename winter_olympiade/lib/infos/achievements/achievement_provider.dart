import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
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
          .map((achievementString) => Achievement.fromJson(
          Map<String, dynamic>.from(jsonDecode(achievementString))))
          .toList();
    } else {
      _achievements = defaultAchievements;
      _saveAchievements();
    }

    notifyListeners();
  }

  Future<void> _ensureAchievementsLoaded() async {
    if (_achievements.isEmpty) {
      await _loadAchievements();
    }
  }

  Future<void> _saveAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> achievementsToSave = _achievements.map((achievement) => jsonEncode(achievement.toJson())).toList();
    await prefs.setStringList('achievements', achievementsToSave);
  }

  Future<void> completeAchievementByIndex(int index) async {
    await _ensureAchievementsLoaded();
    _achievements[index].isCompleted = true;
    _achievements[index].hidden = false;
    _saveAchievements();
    callNotification(_achievements[index].title, _achievements[index].description, _achievements[index].image);
    notifyListeners();
  }

  Future<void> completeAchievementByTitle(String title) async {
    await _ensureAchievementsLoaded();
    try {
      final achievement =
      _achievements.firstWhere((achievement) => achievement.title == title);
      achievement.isCompleted = true;
      achievement.hidden = false;
      _saveAchievements();
      callNotification(achievement.title, achievement.description, achievement.image);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Achievement with title "$title" not found.');
      }
    }
  }

  Future<void> resetAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('achievements');
    notifyListeners();
  }

  void callNotification(String title, String body, String image) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
        channelKey: "achievement_channel",
        actionType: ActionType.Default,
        title: title,
        body: body,
        displayOnForeground: true,
        wakeUpScreen: true,
      )
    );
  }
}