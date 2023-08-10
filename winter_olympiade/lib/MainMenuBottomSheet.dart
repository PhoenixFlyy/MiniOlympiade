import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:winter_olympiade/utils/DateTimeUtils.dart';
import 'package:winter_olympiade/utils/TimerPickerWidget.dart';

import 'TeamSelection.dart';

class MainMenuBottomSheet extends StatefulWidget {
  final DateTime eventEndTime;
  final DateTime eventStartTime;
  const MainMenuBottomSheet(
      {super.key, required this.eventEndTime, required this.eventStartTime});

  @override
  State<MainMenuBottomSheet> createState() => _MainMenuBottomSheetState();
}

class _MainMenuBottomSheetState extends State<MainMenuBottomSheet> {
  final _roundTimeController = TextEditingController();
  final _maxTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _maxTimeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  labelText: "Schachuhr Zeit in Sekunden"),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  maxChessTime = Duration(
                      seconds: int.tryParse(value) ?? maxChessTime.inSeconds);
                });
              },
            ),
            TextField(
              // New TextField for round time
              controller: _roundTimeController,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Rundenzeit in Minuten"),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  roundTimeDuration = Duration(
                      minutes:
                          int.tryParse(value) ?? roundTimeDuration.inMinutes);
                });
              },
            ),
            const SizedBox(height: 16.0),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const TeamSelection(),
                  ),
                  (route) => false,
                );
              },
              child: const Text('Teamauswahl'),
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Event Start:", style: TextStyle(fontSize: 18)),
                Text(DateFormat('dd MMMM HH:mm').format(_eventStartTime),
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
            const SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Event End:", style: TextStyle(fontSize: 18)),
                Text(DateFormat('dd MMMM HH:mm:ss').format(_eventEndTime),
                    style: const TextStyle(fontSize: 18)),
              ],
            ),
            if (selectedTeamName == "Felix99" || selectedTeamName == "Simon00")
              FilledButton.tonal(
                onPressed: () => updateIsPausedInDatabase(),
                child: const Text("Update Pause in Database"),
              ),
            if (selectedTeamName == "Felix99" || selectedTeamName == "Simon00")
              TimePickerWidget(
                  currentEventStartTime: _eventStartTime,
                  onDateTimeSelected: (newTime) {
                    final DatabaseReference databaseReference =
                        FirebaseDatabase.instance.ref('/time');
                    databaseReference.update({
                      "pauseTime": 0,
                      "startTime": dateTimeToString(newTime),
                    });
                  }),
          ],
        ),
      ),
    );
  }
}
