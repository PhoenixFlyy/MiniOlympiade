import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:winter_olympiade/Dartsrechner.dart';
import 'package:winter_olympiade/Laufplan.dart';
import 'package:winter_olympiade/Schachuhr.dart';

void main() {
  runApp(MaterialApp(home: mainMenu()));
}

class mainMenu extends StatefulWidget {
  const mainMenu({super.key});

  @override
  State<mainMenu> createState() => _mainMenuState();
}

class _mainMenuState extends State<mainMenu> {
  int currentRound = 1;
  int maxtime = 240;
  int eventStartTime = 0;

  bool eventStarted = false;
  String selectedTeam = ''; // Hier wird das ausgewählte Team gespeichert

  final _maxTimeController = TextEditingController();
  final _eventStartTimeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSelectedTeam();
  }

  void _loadSelectedTeam() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String storedSelectedTeam = prefs.getString('selectedTeam') ?? '';
    setState(() {
      selectedTeam = storedSelectedTeam;
    });
  }

  @override
  void dispose() {
    _maxTimeController.dispose();
    _eventStartTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mini Olympiade'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _openSettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.timer),
              SizedBox(width: 8.0),
              Text('00:00'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.circle),
              SizedBox(width: 8.0),
              Text('Runde $currentRound'),
            ],
          ),
          // Hier wird das ausgewählte Team angezeigt
          Text(
            'Ausgewähltes Team: $selectedTeam',
            style: TextStyle(fontSize: 16),
          ),

          Spacer(),
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => DartsRechner()));
                },
                child: Text('Dartsrechner'),
              ),
              SizedBox(width: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SchachUhr(
                                maxtime: maxtime,
                              )));
                },
                child: Text('Schachuhr'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () {
              // Aktion für den "Regeln"-Button
            },
            child: Text('Regeln'),
          ),
          SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: () {
              _startEvent();
            },
            child: Text(eventStarted ? 'Event Gestartet' : 'Event Starten'),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  void _openSettings() {
    _maxTimeController.text = maxtime.toString();
    _eventStartTimeController.text = eventStartTime.toString();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _maxTimeController,
                  keyboardType: TextInputType.number,
                  decoration:
                      InputDecoration(labelText: "Schachuhr Zeit in Sekunden"),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (value) {
                    setState(() {
                      maxtime = int.tryParse(value) ?? maxtime;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Laufplan()));
                  },
                  child: Text('Laufplan öffnen'),
                ),
                SizedBox(height: 16.0),
                TimePickerWidget(
                  controller: _eventStartTimeController,
                  labelText: "Event Startzeit",
                  onChanged: (value) {
                    setState(() {
                      eventStartTime = value;
                    });
                  },
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
        );
      },
    );
  }

  void _startEvent() {
    setState(() {
      eventStarted = true;
      eventStartTime = DateTime.now().second;
    });
  }
}

class TimePickerWidget extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final ValueChanged<int> onChanged;

  const TimePickerWidget({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.onChanged,
  }) : super(key: key);

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  int selectedTime = 0;

  @override
  void initState() {
    super.initState();
    selectedTime = int.tryParse(widget.controller.text) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: widget.labelText),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (value) {
              setState(() {
                selectedTime = int.tryParse(value) ?? 0;
                widget.onChanged(selectedTime);
              });
            },
          ),
        ),
        IconButton(
          icon: Icon(Icons.access_time),
          onPressed: () async {
            int pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(
                  hour: selectedTime ~/ 3600,
                  minute: (selectedTime % 3600) ~/ 60),
            ).then((time) => time!.hour * 3600 + time.minute * 60);
            setState(() {
              selectedTime = pickedTime;
              widget.controller.text = selectedTime.toString();
              widget.onChanged(selectedTime);
            });
          },
        ),
      ],
    );
  }
}
