import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:olympiade/wuecade/screens/main_menu_screen.dart';
import 'package:starsview/starsview.dart';
import '../infos/AchievementScreen.dart';

class WuecadeMainMenu extends StatelessWidget {
  const WuecadeMainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Wuecade Games'),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: <Color>[
                    Colors.black,
                    Colors.black26,
                  ]
                ),
              ),
            ),
            const StarsView(
              fps: 60,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Center(
                    child: Image.asset('assets/pokalganz.png'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 14,
                        width: double.infinity,
                        child: FilledButton.tonal(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[500],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(16.0),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FlappyMain()),
                            );
                          },
                          child: const Text(
                            'Flappy Birds',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 14,
                        width: double.infinity,
                        child: FilledButton.tonal(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[500],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.all(16.0),
                          ),
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AchievementScreen()),
                            );
                          },
                          child: const Text(
                            'Achievements',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}