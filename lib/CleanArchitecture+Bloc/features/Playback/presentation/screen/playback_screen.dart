import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntavideofeedapp/CleanArchitecture+Bloc/shared/utils/snackbar_util.dart';

class PlaybackScreen extends StatefulWidget {
  const PlaybackScreen({super.key});

  @override
  State<PlaybackScreen> createState() => _PlaybackScreenState();
}

class _PlaybackScreenState extends State<PlaybackScreen> {
  DateTime? fromDateTime;
  DateTime? toDateTime;
  Future<void> _selectDateTime(bool isFrom) async {
    DateTime now = DateTime.now();
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(Duration(days: 365)),
      lastDate: now.add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );
    if (date == null) return;
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time == null) return;
    final selectedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isFrom) {
        fromDateTime = selectedDateTime;
      } else {
        toDateTime = selectedDateTime;
      }
    });
  }

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "Select";
    return DateFormat('yyyy-MM-dd – hh:mm a').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: Text("Playback")),
      floatingActionButton: FloatingActionButton.extended(
        label: Text("Send Request"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () {
          if (fromDateTime != null && toDateTime != null) {
            SnackbarUtil.showSnackbar(
              message: "Request sent successfully!",
              backgroundColor: Colors.green,
            );
          } else {
            SnackbarUtil.showSnackbar(
              message: "Please select both dates.",
              backgroundColor: Colors.red,
            );
          }
        },
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    onTap: () => _selectDateTime(true),
                    title: Text("From"),
                    subtitle: Text(formatDateTime(fromDateTime)),
                    trailing: Icon(Icons.calendar_today),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    onTap: () => _selectDateTime(false),
                    title: Text("From"),
                    subtitle: Text(formatDateTime(toDateTime)),
                    trailing: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
