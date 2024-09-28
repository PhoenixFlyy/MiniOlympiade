import 'package:flutter/material.dart';
import '../utils/play_sounds.dart';
import '../utils/sound_button.dart';

class SoundBoard extends StatelessWidget {
  const SoundBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final audioService = AudioService();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Soundboard"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(25),
        crossAxisCount: 2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        children: [
          SoundButton(
            buttonText: "Start der Runde",
            icon: Icons.play_circle_filled,
            onPressed: audioService.playStartSound,
          ),
          SoundButton(
            buttonText: "Ende der Runde",
            icon: Icons.stop_circle_outlined,
            onPressed: audioService.playGongAkkuratSound,
          ),
          SoundButton(
            buttonText: "1 Minute übrig",
            icon: Icons.timer,
            onPressed: audioService.playWhooshSound,
          ),
          SoundButton(
            buttonText: "Pause",
            icon: Icons.pause_circle_filled,
            onPressed: audioService.playWhistleSound,
          ),
          SoundButton(
            buttonText: "Alarm",
            icon: Icons.alarm,
            onPressed: audioService.playAlarmSound,
          ),
          SoundButton(
            buttonText: "SIUUU",
            icon: Icons.sports_soccer,
            onPressed: audioService.playSiuuuSound,
          ),
          SoundButton(
            buttonText: "Villager",
            icon: Icons.person,
            onPressed: audioService.playVillagerSound,
          ),
          SoundButton(
            buttonText: "Yeet",
            icon: Icons.tag_faces,
            onPressed: audioService.playYeetSound,
          ),
        ],
      ),
    );
  }
}