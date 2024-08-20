import 'package:flutter/material.dart';
import 'AchievementList.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  late TransformationController _transformationController;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _transformationController.value = Matrix4.identity()..scale(0.5);
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: InteractiveViewer(
        constrained: false,
        minScale: 0.25,
        maxScale: 4.0,
        transformationController: _transformationController,
        child: Container(
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
          width: 3000,
          height: 2300,
          child: Stack(
            children: _buildAchievementContainers(),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAchievementContainers() {
    List<Widget> achievementContainers = [];
    double initialLeft = 100;
    double initialTop = 100;
    double verticalSpacing = 300;
    double horizontalSpacing = 600;
    int achievementsPerColumn = 7;

    for (int i = 0; i < achievements.length; i++) {
      double left = initialLeft + (i ~/ achievementsPerColumn) * horizontalSpacing;
      double top = initialTop + (i % achievementsPerColumn) * verticalSpacing;

      achievementContainers.add(
        achievementContainer(
          image: achievements[i]['image']!,
          title: achievements[i]['title']!,
          description: achievements[i]['description']!,
          left: left,
          top: top,
        ),
      );
    }

    return achievementContainers;
  }

  Widget achievementContainer({
    required String image,
    required String title,
    required String description,
    required double left,
    required double top,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 400,
        height: 120,
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [Colors.grey[600]!, Colors.grey[900]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.repeated,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withOpacity(1),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
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
    );
  }
}