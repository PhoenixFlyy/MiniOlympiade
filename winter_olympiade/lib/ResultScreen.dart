import 'package:flutter/material.dart';
import 'package:winter_olympiade/utils/MatchDetails.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text("Ergebnis", style: TextStyle(fontSize: 20)),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pairings[0].length, (player) {
            return Container();
          })),
    );
  }
}
