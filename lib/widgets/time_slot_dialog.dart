import 'package:flutter/material.dart';
import '../models/time_slot.dart';

class TimeSlotDialog extends StatefulWidget {
  final Function(TimeSlot) onTimeSlotAdded;
  
  TimeSlotDialog({required this.onTimeSlotAdded});

  @override
  _TimeSlotDialogState createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  TimeOfDay? startTime;
  TimeOfDay? endTime;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Time Slot'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Start Time'),
            trailing: Text(
              startTime != null ? startTime!.format(context) : 'Select',
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() => startTime = time);
              }
            },
          ),
          ListTile(
            title: Text('End Time'),
            trailing: Text(
              endTime != null ? endTime!.format(context) : 'Select',
            ),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (time != null) {
                setState(() => endTime = time);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (startTime != null && endTime != null) {
              widget.onTimeSlotAdded(TimeSlot(
                startTime!.format(context),
                endTime!.format(context),
              ));
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}