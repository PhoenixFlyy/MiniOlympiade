import 'package:flutter/material.dart';

class ChessClock extends StatefulWidget {
  const ChessClock({Key? key}) : super(key: key);

  @override
  _ChessClockState createState() => _ChessClockState();
}

class _ChessClockState extends State<ChessClock> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          GestureDetector(
            onTap: () => {},
            child: Container(
              color: Colors.green,
              height: MediaQuery.of(context).size.height / 2,
              alignment: Alignment.center,
              child: Text(
                "formatTime(player1Time)",
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => {},
            child: Container(
              color: Colors.grey,
              height: MediaQuery.of(context).size.height / 2,
              alignment: Alignment.center,
              child: Text(
                "formatTime(player2Time)",
                style: TextStyle(fontSize: 40),
              ),
            ),
          ),
        ],
      ),
    );
  }
}