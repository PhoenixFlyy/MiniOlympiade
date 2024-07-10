import 'package:flutter/material.dart';

import 'PlaySounds.dart';

class SoundBoard extends StatelessWidget {
  const SoundBoard({super.key});

  Widget PlayButton(String buttonText, void Function() onPressed) {
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
          onPressed: onPressed,
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
      appBar: AppBar(title: const Text("Soundboard")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              PlayButton("Start der Runde", playStartSound),
              PlayButton("Ende der Runde", playgongakkuratSound),
              PlayButton("1 Minute übrig", playWhooshSound),
              PlayButton("Pause", playWhistleSound),
              PlayButton("SIUUU", playSiuuuSound),
              PlayButton("Villager", playVillagerSound),
              PlayButton("Yeet", playYeetSound),
              //PlayButton("Schlagbolzen", playschlagbolzenSound),

              //PlayButton("gonghell", playgonghellSound),
              //PlayButton("gongvoluminös", playgongvoluminoesSound),
            ],
          ),
        ),
      ),
    );
  }
}
