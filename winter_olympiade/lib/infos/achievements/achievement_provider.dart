import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'AchievementList.dart';

class AchievementProvider extends ChangeNotifier {
  // Track expanded rules
  final Set<String> _expandedRules = {};

  // List of all rule names
  final List<String> _allRules = [
    'Allgemeines, Alkohol',
    'Kicker',
    'Darts',
    'Billard',
    'Bierpong',
    'Kubb',
    'Jenga',
    'Bewertung',
    // Add other rule names here
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

  // Variablen für Konfetti-Auslösungen
  int _confettiTriggerCount = 0;

  // Methode zur Erhöhung der Konfetti-Auslösungen
  void incrementConfettiTriggerCount() {
    _confettiTriggerCount++;
    _checkConfettiAchievements();
  }

  // Methode zur Überprüfung, ob Konfetti-Achievements ausgelöst werden sollen
  void _checkConfettiAchievements() {
    if (_confettiTriggerCount == 3) {
      completeAchievementByTitle('Regenschauer');
    } else if (_confettiTriggerCount == 10) {
      completeAchievementByTitle('Taifun');
    } else if (_confettiTriggerCount == 100) {
      completeAchievementByTitle('Cookie Clicker');
    }
  }

  // Set to keep track of played sound effects
  final Set<String> _playedSoundEffects = {};

  // List of all sound effect names
  final List<String> _allSoundEffects = [
    "Start der Runde",
    "Ende der Runde",
    "1 Minute übrig",
    "Pause",
    "SIUUU",
    "Villager",
    "Yeet",
    // Add more sound effects here if needed
  ];

  // Method to mark a sound effect as played
  void markSoundEffectAsPlayed(String soundEffectName) {
    _playedSoundEffects.add(soundEffectName);
    _checkAllSoundEffectsPlayed();
  }

  // Method to check if all sound effects have been played
  void _checkAllSoundEffectsPlayed() {
    if (_playedSoundEffects.length == _allSoundEffects.length) {
      // Trigger the achievement for playing all sound effects
      completeAchievementByTitle('Annoying Bastard');
    }
  }

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
    if (!_achievements[index].isCompleted) {
      _achievements[index].isCompleted = true;
      _achievements[index].hidden = false;
      await _saveAchievements();
      callNotification(_achievements[index].title, _achievements[index].description, _achievements[index].image);
      notifyListeners();
    }
  }

  Future<void> completeAchievementByTitle(String title) async {
    await _ensureAchievementsLoaded();
    try {
      final achievement = _achievements.firstWhere((achievement) => achievement.title == title);
      if (!achievement.isCompleted) {
        achievement.isCompleted = true;
        achievement.hidden = false;
        await _saveAchievements();
        callNotification(achievement.title, achievement.description, achievement.image);
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

    // Setze Achievements auf die Standardwerte zurück
    _achievements = defaultAchievements.map((achievement) {
      return Achievement(
        title: achievement.title,
        description: achievement.description,
        image: achievement.image,
        isCompleted: false,  // Setze auf false, um unerledigte Achievements zu markieren
        hidden: true,  // Setze auf true, um alle Achievements versteckt zu machen
      );
    }).toList();

    // Speichere die zurückgesetzten Achievements
    await _saveAchievements();

    // Benachrichtige alle Listener über die Änderung
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
        bigPicture: image.isNotEmpty ? image : null,  // Optional: set image if available
      ),
    );
  }
}
