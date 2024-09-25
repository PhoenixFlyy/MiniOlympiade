import 'package:flutter/material.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:provider/provider.dart';

import '../utils/play_sounds.dart';

class SoundBoard extends StatelessWidget {
  const SoundBoard({super.key});

  Widget playButton(BuildContext context, String buttonText, void Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: SizedBox(
        height: 50,
        child: FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              )),
          onPressed: () {
            context.read<AchievementProvider>().markSoundEffectAsPlayed(buttonText);
            context.read<AchievementProvider>().completeAchievementByTitle('Gomme Mode');
            onPressed();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.play_arrow, color: Colors.black),
              const SizedBox(width: 10),
              Text(buttonText, style: const TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text("Soundboard"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              playButton(context, "Start der Runde", audioService.playStartSound),
              playButton(context, "Ende der Runde", audioService.playGongAkkuratSound),
              playButton(context, "1 Minute übrig", audioService.playWhooshSound),
              playButton(context, "Pause", audioService.playWhistleSound),
              playButton(context, "Alarm", audioService.playAlarmSound),
              playButton(context, "SIUUU", audioService.playSiuuuSound),
              playButton(context, "Villager", audioService.playVillagerSound),
              playButton(context, "Yeet", audioService.playYeetSound),
            ],
          ),
        ),
      ),
    );
  }
}