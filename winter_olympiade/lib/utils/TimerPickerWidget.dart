import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final Function(DateTime) onDateTimeSelected;
  final DateTime currentEventStartTime;

  const TimePickerWidget({
    Key? key,
    required this.onDateTimeSelected,
    required this.currentEventStartTime,
  }) : super(key: key);

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = widget.currentEventStartTime;
  }

  @override
  Widget build(BuildContext context) {
    DateFormat('dd.MM.yyyy HH:mm').format(_selectedDateTime);

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.access_time),
              onPressed: () async {
                final DateTime? pickedDateTime = await showDatePicker(
                  context: context,
                  initialDate: _selectedDateTime,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );

                if (pickedDateTime != null) {
                  if (!mounted) return;
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
                  );

                  if (pickedTime != null) {
                    DateTime newDateTime = DateTime(
                      pickedDateTime.year,
                      pickedDateTime.month,
                      pickedDateTime.day,
                      pickedTime.hour,
                      pickedTime.minute,
                    );

                    setState(() {
                      _selectedDateTime = newDateTime;
                    });

                    widget.onDateTimeSelected(newDateTime);
                  }
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
