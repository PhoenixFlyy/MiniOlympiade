import 'package:flutter/material.dart';

String getLabelForScore(double value) {
  if (value == 0.0) {
    return "Verlierer";
  } else if (value == 0.5) {
    return "Unentsch.";
  } else if (value == 1.0) {
    return "Gewinner";
  }
  return "";
}

Widget getScoreText(double value) {
  if (value == 0) {
    return const Text(
      "Verloren",
      style: TextStyle(
        color: Colors.red,
        fontWeight: FontWeight.bold,
      ),
    );
  } else if (value == 1) {
    return const Text(
      "Gewonnen",
      style: TextStyle(
        color: Colors.amber,
        fontWeight: FontWeight.bold,
      ),
    );
  } else if (value == 0.5) {
    return const Text(
      "Unentschieden",
      style: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
  } else {
    return const Text(
      "N/A",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

Widget getShortScoreText(double value) {
  if (value == 0) {
    return const Text(
      "0",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  } else if (value == 1) {
    return const Text(
      "1",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  } else if (value == 0.5) {
    return const Text(
      "0.5",
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
    );
  } else {
    return const Text(
      "N/A",
      style: TextStyle(
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');

  String days = duration.inDays != 0 ? '${duration.inDays} d ' : '';
  String hours = '${twoDigits(duration.inHours.remainder(24))} h ';
  String minutes = '${twoDigits(duration.inMinutes.remainder(60))} Min';

  return days + hours + minutes;
}