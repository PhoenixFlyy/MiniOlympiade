import 'package:flutter/material.dart';

class SoundBoard extends StatelessWidget {
  const SoundBoard({super.key});

  Widget PlayButton(String buttonText, void Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: SizedBox(
        height: 75,
        child: FilledButton(
          style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
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
              PlayButton("Start der Runde", () => {}),
              PlayButton("Ende der Runde", () => {}),
              PlayButton("1 Minute übrig", () => {}),
              PlayButton("Pause", () => {}),
              PlayButton("SIUUU", () => {}),
              PlayButton("Villager", () => {}),
              PlayButton("Yeet", () => {}),
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
