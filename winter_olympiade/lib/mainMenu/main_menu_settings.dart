import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../setup/result_screen.dart';
import '../utils/date_time_picker.dart';
import '../utils/date_time_utils.dart';

class SettingsModal extends StatelessWidget {
  final TextEditingController maxChessTimeController;
  final TextEditingController roundTimeController;
  final TextEditingController playTimeController;
  final DateTime eventStartTime;
  final void Function() updateChessTimeInDatabase;
  final void Function() updateIsPausedInDatabase;

  const SettingsModal({
    super.key,
    required this.maxChessTimeController,
    required this.roundTimeController,
    required this.playTimeController,
    required this.eventStartTime,
    required this.updateChessTimeInDatabase,
    required this.updateIsPausedInDatabase,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(31.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text("Beginn:", style: TextStyle(fontSize: 18)),
                  Text(DateFormat(' dd.MM.yyyy, HH:mm').format(eventStartTime), style: const TextStyle(fontSize: 18)),
                  const Text(" Uhr", style: TextStyle(fontSize: 18)),
                  TimePickerWidget(
                    currentEventStartTime: eventStartTime,
                    onDateTimeSelected: (newTime) {
                      final DatabaseReference databaseReference = FirebaseDatabase.instance.ref('/time');
                      databaseReference.update({
                        "pauseTime": 0,
                        "startTime": dateTimeToString(newTime),
                      });
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 75,
                    width: 200,
                    child: TextField(
                      controller: maxChessTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Schachuhr Zeit in Sekunden"),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        maxChessTimeController.text = value;
                      },
                    ),
                  ),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: updateChessTimeInDatabase,
                    child: const Text("Update"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: updateIsPausedInDatabase,
                child: const Text("Update Pause in Database"),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ResultScreen(),
                    ),
                  );
                },
                child: const Text('Ergebnisse anschauen'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
