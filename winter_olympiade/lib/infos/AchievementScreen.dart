import 'package:flutter/material.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({super.key});

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: InteractiveViewer(
        constrained: false,
        minScale: 0.5,
        maxScale: 4.0,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                tileMode: TileMode.repeated,
                colors: <Color>[
                  Colors.red,
                  Colors.blue,
                ]
            ),
          ),
          width: 2000,
          height: 2000,
          child: Stack(
            children: [
              achievementContainer(
                image: 'assets/achievements/Folie2.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie3.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 250,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie4.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 400,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie5.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 550,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie6.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 700,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie7.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 850,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie8.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 1000,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie9.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie10.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie11.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie12.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie13.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie14.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie15.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie16.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie17.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie18.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie19.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie20.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie21.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie22.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie23.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie24.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie25.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie26.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie27.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie28.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie29.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie30.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie31.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie32.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie33.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie34.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie35.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie36.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie37.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie38.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie39.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie40.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie41.PNG',
                title: 'First Blood',
                description: 'Gewinne in der ersten Runde',
                left: 100,
                top: 100,
              ),
            ],
          ),
        ),
      ),
    );
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