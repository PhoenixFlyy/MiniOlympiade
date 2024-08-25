import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:olympiade/main.dart';  // Stelle sicher, dass du den richtigen Pfad zur MyApp-Klasse hast

class NotificationController {
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {}

  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {}

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    // Hier wird überprüft, ob es sich um eine Achievement-Benachrichtigung handelt
    if (receivedAction.channelKey == 'achievement_channel') {
      // Navigiere zur Achievement-Seite
      MyApp.navigatorKey.currentState?.pushNamed('/achievements');
    }
  }
}
