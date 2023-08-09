import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimePickerWidget extends StatefulWidget {
  final Function(DateTime) onDateTimeSelected;

  const TimePickerWidget({
    Key? key,
    required this.onDateTimeSelected,
  }) : super(key: key);

  @override
  _TimePickerWidgetState createState() => _TimePickerWidgetState();
}

class _TimePickerWidgetState extends State<TimePickerWidget> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime(2023, 8, 9);
  }

  @override
  Widget build(BuildContext context) {
    final formattedDateTime =
        DateFormat('dd.MM.yyyy HH:mm').format(_selectedDateTime);

    return Row(
      children: [
        Text('Event Startzeit: $formattedDateTime',
            style: const TextStyle(fontSize: 18)),
        IconButton(
          icon: const Icon(Icons.access_time),
          onPressed: () async {
            final TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
            );

            if (pickedTime != null) {
              DateTime newDateTime = DateTime(
                _selectedDateTime.year,
                _selectedDateTime.month,
                _selectedDateTime.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              setState(() {
                _selectedDateTime = newDateTime;
              });

              widget.onDateTimeSelected(newDateTime);
            }
          },
        ),
      ],
    );
  }
}
