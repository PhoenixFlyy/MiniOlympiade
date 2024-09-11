import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:infinite_carousel/infinite_carousel.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'achievement_list.dart';
import 'achievement_provider.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  Future<List<Achievement>> fetchAchievements() async {
    if (!mounted) return [];
    return context.read<AchievementProvider>().getAchievementList();
  }

  @override
  Widget build(BuildContext context) {
    final achievementsAppBar = context.watch<AchievementProvider>().getAchievementList();
    int completedAchievementsAppBar = achievementsAppBar.where((achievement) => achievement.isCompleted).length;
    context.read<AchievementProvider>().completeAchievementByTitle('Nerd');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Hero(
                tag: "achievementHero",
                child: Text(
                  'Achievements',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                    fontStyle: FontStyle.normal,
                    letterSpacing: 0.0,
                    wordSpacing: 0.0,
                    decoration: TextDecoration.none,
                    decorationColor: Colors.transparent,
                    decorationStyle: TextDecorationStyle.solid,
                    fontFamily: null,
                    height: 1.0,
                  ),
                )),
            IconButton(
              icon: const Icon(Icons.restart_alt),
              tooltip: 'Reset Achievements',
              onPressed: () => context.read<AchievementProvider>().resetAchievements(),
            ),
            Text(
              '$completedAchievementsAppBar / ${achievementsAppBar.length}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<List<Achievement>>(
        future: fetchAchievements(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) => skeletonContainer(),
            );
          } else {
            final achievements = snapshot.data!;
            return InfiniteCarousel.builder(
              itemCount: achievements.length,
              itemExtent: 155,
              center: false,
              anchor: 0.0,
              velocityFactor: 0.4,
              axisDirection: Axis.vertical,
              loop: false,
              itemBuilder: (context, itemIndex, realIndex) {
                return achievementContainer(
                  image: achievements[itemIndex].image,
                  title: achievements[itemIndex].title,
                  description: achievements[itemIndex].description,
                  isCompleted: achievements[itemIndex].isCompleted,
                  hidden: achievements[itemIndex].hidden,
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget skeletonContainer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey[800],
          borderRadius: BorderRadius.circular(10),
        ),
        height: 155,
        width: double.infinity,
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
              boxShadow: [
                BoxShadow(
                  color: isCompleted ? Colors.green.withOpacity(1) : Colors.green.withOpacity(0),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
      child: Stack(
        children: [
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
                        color: Colors.black,
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
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.shade200.withOpacity(0.7),
                                Colors.black.withOpacity(0.5),
                                Colors.black.withOpacity(0.7),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
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
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.amber,
                              blurRadius: 100,
                              spreadRadius: 3,
                              blurStyle: BlurStyle.normal
                            ),
                          ],
                        ),
                        child: Image.asset(
                          image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 80, color: Colors.red);
                          },
                        ),
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
