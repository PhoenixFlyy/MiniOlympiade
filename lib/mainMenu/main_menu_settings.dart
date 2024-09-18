import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../utils/date_time_picker.dart';
import '../utils/date_time_utils.dart';

class SettingsModal extends StatelessWidget {
  final DateTime eventStartTime;
  final void Function(int) updateChessTimeInDatabase;
  final void Function() updateIsPausedInDatabase;
  final void Function() updateShowResultPermission;

  SettingsModal({
    super.key,
    required this.eventStartTime,
    required this.updateChessTimeInDatabase,
    required this.updateIsPausedInDatabase,
    required this.updateShowResultPermission,
  });

  final _maxChessTimeController = TextEditingController(text: "300");

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
                      controller: _maxChessTimeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Schachuhr Zeit in Sekunden"),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      onChanged: (value) {
                        _maxChessTimeController.text = value;
                      },
                    ),
                  ),
                  FilledButton.tonal(
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      final int chessTimeInSeconds = int.tryParse(_maxChessTimeController.text) ?? 300;
                      updateChessTimeInDatabase(chessTimeInSeconds);
                    },
                    child: const Text("Update"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: updateIsPausedInDatabase,
                child: const Text("Pause umschalten"),
              ),
              const SizedBox(height: 20),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: updateShowResultPermission,
                child: const Text("Erlaubnis für Ergebnisse umschalten"),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
