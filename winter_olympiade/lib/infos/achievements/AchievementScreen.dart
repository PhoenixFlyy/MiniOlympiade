import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'achievement_provider.dart';
import 'dart:ui';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  Widget build(BuildContext context) {
    final achievements = context.watch<AchievementProvider>().getAchievementList();
    int completedAchievements = achievements
        .where((achievement) => achievement.isCompleted)
        .length;
    context.read<AchievementProvider>().completeAchievementByTitle('Nerd');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Achievements'),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Reset Achievements',
              onPressed: () =>
                  context.read<AchievementProvider>().resetAchievements(),
            ),
            Text(
              '$completedAchievements / ${achievements.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          return achievementContainer(
            image: achievements[index].image,
            title: achievements[index].title,
            description: achievements[index].description,
            isCompleted: achievements[index].isCompleted,
            hidden: achievements[index].hidden,
          );
        },
      ),
    );
  }



  Widget achievementContainer({
    required String image,
    required String title,
    required String description,
    required bool isCompleted,
    required bool hidden,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: hidden
          ? BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 2, color: Colors.white),
      )
          : BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: isCompleted
              ? [Colors.green[600]!, Colors.green[900]!]
              : [Colors.grey[600]!, Colors.grey[900]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          tileMode: TileMode.repeated,
        ),
        boxShadow: [
          BoxShadow(
            color: isCompleted
                ? Colors.green.withOpacity(1)
                : Colors.green.withOpacity(0),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background layer with blurred image
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  Image.asset(
                    image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(Icons.error, size: 80, color: Colors.red),
                        ),
                      );
                    },
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                      child: Container(
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Foreground layer with existing content
          Padding(
            padding: const EdgeInsets.all(12.0), // Apply padding here to the content
            child: hidden
                ? const SizedBox(
              width: 80,
              height: 80,
              child: Center(
                child: Text("? ? ?", style: TextStyle(fontSize: 24, color: Colors.white)),
              ),
            )
                : Row(
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
          ),
        ],
      ),
    );
  }


}