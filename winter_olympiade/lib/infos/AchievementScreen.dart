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
            title: 'First Blood!',
            description: 'Gewinne in der ersten Runde',
            left: 100,
            top: 100,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie3.PNG',
            title: 'No perfect score for you!',
            description: 'Verliere deine erste Disziplin',
            left: 100,
            top: 250,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie4.PNG',
            title: 'Ein weiterer Schritt zum Sieg',
            description: 'Schlage den ersten Gegner',
            left: 100,
            top: 400,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie5.PNG',
            title: 'Diesmal nicht!',
            description: 'Besiege einen der Sieger der Vorjahre',
            left: 100,
            top: 550,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie6.PNG',
            title: 'Win Streak!',
            description: 'Gewinne drei Disziplinen hintereinander',
            left: 100,
            top: 700,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie7.PNG',
            title: 'Gotta Catch \'Em All',
            description: 'Gewinne in jeder Disziplin mindestens einmal',
            left: 100,
            top: 850,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie8.PNG',
            title: 'Mr. Consistent',
            description: 'Sei in jeder Disziplin unter den Top 3',
            left: 100,
            top: 1000,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie9.PNG',
            title: 'Winner Winner Chicken Dinner',
            description: 'Gewinne das Event',
            left: 100,
            top: 1150,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie10.PNG',
            title: 'Ruhige Hände',
            description: 'Gewinne in Jenga',
            left: 100,
            top: 1300,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie11.PNG',
            title: 'Holzfäller!',
            description: 'Gewinne in Kubb',
            left: 100,
            top: 1450,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie12.PNG',
            title: 'Einloch-Experte',
            description: 'Gewinne in Billard',
            left: 100,
            top: 1600,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie13.PNG',
            title: 'Ab in den Ally Pally!',
            description: 'Gewinne in Darts',
            left: 100,
            top: 1750,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie14.PNG',
            title: 'Noch nüchtern? Die Gegner nicht mehr!',
            description: 'Gewinne in Bierpong',
            left: 100,
            top: 1900,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie15.PNG',
            title: 'Meeessssiiii!',
            description: 'Gewinne in Kicker',
            left: 100,
            top: 2050,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie16.PNG',
            title: 'Mein Teampartner ist schuld!',
            description: 'Verliere in jeder Disziplin mindestens einmal',
            left: 100,
            top: 2200,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie17.PNG',
            title: 'Comeback?',
            description: 'Gewinne nach mindestens drei Niederlagen in Folge',
            left: 100,
            top: 2350,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie18.PNG',
            title: 'Nicht aufzuhalten!',
            description: 'Gewinne in einer Disziplin gegen alle anderen',
            left: 100,
            top: 2500,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie19.PNG',
            title: 'Kanonenfutter',
            description: 'Verliere in einer Disziplin gegen alle anderen',
            left: 100,
            top: 2650,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie20.PNG',
            title: 'Ungespielt Moment',
            description: 'Gewinne fünf Disziplinen hintereinander',
            left: 100,
            top: 2800,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie21.PNG',
            title: 'Hochstapler',
            description: 'Gewinne oder verliere ein Jengaspiel auf Zeit',
            left: 100,
            top: 2950,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie22.PNG',
            title: 'Halbzeit!',
            description: 'Halte bis zur Pause durch',
            left: 100,
            top: 3100,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie23.PNG',
            title: 'Schreiberling',
            description: 'Trage die Ergebnisse ein',
            left: 100,
            top: 3250,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie24.PNG',
            title: 'Kurzer Prozess',
            description: 'Trage die Ergebnisse schon nach 5 min ein',
            left: 100,
            top: 3400,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie25.PNG',
            title: 'Chess GM',
            description: 'Gewinne Jenga mit über 2:30 Restzeit',
            left: 100,
            top: 3550,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie26.PNG',
            title: 'Sehr photogen!',
            description: 'Mache ein Foto von dir',
            left: 100,
            top: 3700,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie27.PNG',
            title: 'Umgekehrte Psychologie',
            description: 'Werfe eine Triple 1',
            left: 100,
            top: 3850,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie28.PNG',
            title: 'Mehr geht nicht!',
            description: 'Werfe eine Triple 20',
            left: 100,
            top: 4000,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie29.PNG',
            title: 'Bullseye!',
            description: 'Werfe ein double oder single Bullseye',
            left: 100,
            top: 4150,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie30.PNG',
            title: 'Verlaufen?',
            description: 'Verbringe mindestens 3 Minuten im Laufplan-Screen',
            left: 100,
            top: 4300,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie31.PNG',
            title: 'Nimm es ganz genau!',
            description: 'Schaue in den Regeln nach',
            left: 100,
            top: 4450,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie32.PNG',
            title: 'Bücherwurm',
            description: 'Klappe alle Regeln gleichzeitig auf',
            left: 100,
            top: 4600,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie33.PNG',
            title: 'Flappy Chick',
            description: 'Erreiche 10 Punkte in Flappy Bird',
            left: 100,
            top: 4750,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie34.PNG',
            title: 'Flappy Eagle',
            description: 'Erreiche 50 Punkte in Flappy Bird',
            left: 100,
            top: 4900,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie35.PNG',
            title: 'Gomme Mode',
            description: 'Spiele einen Soundeffekt ab',
            left: 100,
            top: 5050,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie36.PNG',
            title: 'Annoying Bastard',
            description: 'Spiele alle Soundeffekte ab',
            left: 100,
            top: 5200,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie37.PNG',
            title: 'Lass es regnen',
            description: 'Löse einen Konfettiregen aus',
            left: 100,
            top: 5350,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie38.PNG',
            title: 'Regenschauer',
            description: 'Löse 3 mal den Konfettiregen aus',
            left: 100,
            top: 5500,
          ),
          achievementContainer(
            image: 'assets/achievements/Folie39.PNG',
            title: 'Taifun',
            description: 'Löse 10 mal den Konfettiregen aus',
            left: 100,
                top: 5650,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie40.PNG',
                title: 'Cookie Clicker',
                description: 'Löse 100 mal den Konfettiregen aus',
                left: 100,
                top: 5800,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie41.PNG',
                title: 'Ich wäre gerne so wie du!',
                description: 'Füge deinem Namen mindestens zwei „X“ hinzu',
                left: 100,
                top: 5950,
              ),
              achievementContainer(
                image: 'assets/achievements/Folie42.PNG',
                title: 'Barista',
                description: 'Spendiere dem Dev einen Kaffee',
                left: 100,
                top: 6100,
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