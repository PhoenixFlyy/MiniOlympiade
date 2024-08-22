import 'package:flutter/material.dart';
import 'AchievementList.dart'; // Stelle sicher, dass dies die richtige Import-Anweisung für deine Daten ist

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  // Anzahl der totalen und abgeschlossenen Achievements
  final int totalAchievements = achievements.length;
  int completedAchievements = 0; // Dies sollte in der echten App aktualisiert werden. Vll mit Anzahl der Achievements mit iscompleted Eigenschaft abgleichen?

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Achievements'),
            Text(
              '$completedAchievements/$totalAchievements',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            tileMode: TileMode.repeated,
            colors: <Color>[
              Colors.red,
              Colors.blue,
            ],
          ),
        ),
        child: ListView.builder(
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            final image = achievement['image'] as String;
            final title = achievement['title'] as String;
            final description = achievement['description'] as String;
            final isCompleted = achievement['isCompleted'] as bool? ?? false; // Von ChatGPT eingefügt. Muss noch ausgearbeitet werden

            return achievementContainer(
              image: image,
              title: title,
              description: description,
              isCompleted: isCompleted,
            );
          },
        ),
      ),
    );
  }

  Widget achievementContainer({
    required String image,
    required String title,
    required String description,
    required bool isCompleted,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: isCompleted
              ? [Colors.green[600]!, Colors.green[900]!]//hier stattdessen Bild ändern von Fragezeichen zu richtigem und nicht ausgrauen?
              : [Colors.grey[600]!, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          tileMode: TileMode.repeated,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted ? Colors.green.withOpacity(0.8) : Colors.amber.withOpacity(1),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            image,
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, size: 80, color: Colors.red);
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
