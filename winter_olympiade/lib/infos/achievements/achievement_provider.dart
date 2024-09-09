import 'dart:convert';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'achievement_list.dart';

class AchievementProvider extends ChangeNotifier {
  int _confettiTriggerCount = 0;
  final Set<String> _expandedRules = {};
  final Set<String> _playedSoundEffects = {};
  List<Achievement> _achievements = [];

  List<Achievement> getAchievementList() => _achievements;

  final List<String> _allRules = [
    'Allgemeines, Alkohol',
    'Kicker',
    'Darts',
    'Billard',
    'Bierpong',
    'Kubb',
    'Jenga',
    'Bewertung',
  ];

  void markRuleAsExpanded(String ruleName) {
    _expandedRules.add(ruleName);
    _checkAllRulesExpanded();
  }

  void _checkAllRulesExpanded() {
    if (_expandedRules.length == _allRules.length) {
      completeAchievementByTitle('Bücherwurm');
    }
  }

  void incrementConfettiTriggerCount() {
    _confettiTriggerCount++;
    _checkConfettiAchievements();
  }

  void _checkConfettiAchievements() {
    if (_confettiTriggerCount == 3) {
      completeAchievementByTitle('Regenschauer');
    } else if (_confettiTriggerCount == 10) {
      completeAchievementByTitle('Taifun');
    } else if (_confettiTriggerCount == 100) {
      completeAchievementByTitle('Cookie Clicker');
    }
  }

  final List<String> _allSoundEffects = [
    "Start der Runde",
    "Ende der Runde",
    "1 Minute übrig",
    "Pause",
    "SIUUU",
    "Villager",
    "Yeet",
  ];

  void markSoundEffectAsPlayed(String soundEffectName) {
    _playedSoundEffects.add(soundEffectName);
    _checkAllSoundEffectsPlayed();
  }

  void _checkAllSoundEffectsPlayed() {
    if (_playedSoundEffects.length == _allSoundEffects.length) {
      completeAchievementByTitle('Annoying Bastard');
    }
  }

  AchievementProvider() {
    _loadAchievements();
  }

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
    List<String> achievementsToSave = _achievements
        .map((achievement) => jsonEncode(achievement.toJson()))
        .toList();
    await prefs.setStringList('achievements', achievementsToSave);
  }

  Future<void> completeAchievementByIndex(int index) async {
    await _ensureAchievementsLoaded();
    if (!_achievements[index].isCompleted) {
      _achievements[index].isCompleted = true;
      _achievements[index].hidden = false;
      await _saveAchievements();
      callNotification(_achievements[index].title,
          _achievements[index].description, _achievements[index].image);
      notifyListeners();
    }
  }

  Future<void> completeAchievementByTitle(String title) async {
    await _ensureAchievementsLoaded();
    try {
      final achievement =
          _achievements.firstWhere((achievement) => achievement.title == title);
      if (!achievement.isCompleted) {
        achievement.isCompleted = true;
        achievement.hidden = false;
        await _saveAchievements();
        callNotification(
            achievement.title, achievement.description, achievement.image);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Achievement with title "$title" not found.');
      }
    }
  }

  Future<void> resetAchievements() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('achievements');

    _achievements = defaultAchievements.map((achievement) {
      return Achievement(
        title: achievement.title,
        description: achievement.description,
        image: achievement.image,
        isCompleted: achievement.isCompleted,
        hidden: achievement.hidden,
      );
    }).toList();
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
        bigPicture: image.isNotEmpty ? image : null,
      ),
    );
  }
}
