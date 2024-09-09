import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olympiade/infos/achievements/achievement_screen.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:olympiade/infos/achievements/notification_controller.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main_menu.dart';
import 'setup/team_selection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelGroupKey: "achievement_channel_group",
        channelKey: "achievement_channel",
        channelName: "Achievement",
        channelDescription: "Achievement Channel",
        defaultColor: const Color(0xFFA74900),
        onlyAlertOnce: true,
        importance: NotificationImportance.Max,
        ledColor: Colors.white)
  ], channelGroups: [
    NotificationChannelGroup(
        channelGroupKey: "achievement_channel_group",
        channelGroupName: "Achievement Group")
  ]);
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatefulWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod: NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod: NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: NotificationController.onDismissActionReceivedMethod,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkIfTeamSelected(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else {
          final bool teamSelected = snapshot.data ?? false;

          return MultiProvider(
            providers: [
              ChangeNotifierProvider(
                create: (context) => AchievementProvider(),
              ),
            ],
            child: MaterialApp(
              navigatorKey: MyApp.navigatorKey,
              debugShowCheckedModeBanner: false,
              title: 'Olympiade',
              theme: ThemeData.dark(useMaterial3: true),
              initialRoute: teamSelected ? '/main' : '/team_selection',
              routes: {
                '/main': (context) => const MainMenu(),
                '/team_selection': (context) => const TeamSelection(),
                '/achievements': (context) => const AchievementScreen(),
              },
            ),
          );
        }
      },
    );
  }

  Future<bool> _checkIfTeamSelected() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('selectedTeam');
  }
}