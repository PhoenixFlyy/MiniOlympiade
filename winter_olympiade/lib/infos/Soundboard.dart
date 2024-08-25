import 'package:flutter/material.dart';
import 'package:olympiade/infos/achievements/achievement_provider.dart';
import 'package:provider/provider.dart';

import 'PlaySounds.dart';

class SoundBoard extends StatelessWidget {
  const SoundBoard({super.key});

  Widget PlayButton(BuildContext context, String buttonText, void Function() onPressed) {
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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Soundboard"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              PlayButton(context, "Start der Runde", playStartSound),
              PlayButton(context, "Ende der Runde", playgongakkuratSound),
              PlayButton(context, "1 Minute übrig", playWhooshSound),
              PlayButton(context, "Pause", playWhistleSound),
              PlayButton(context, "SIUUU", playSiuuuSound),
              PlayButton(context, "Villager", playVillagerSound),
              PlayButton(context, "Yeet", playYeetSound),
            ],
          ),
        ),
      ),
    );
  }
}