import 'package:flutter/material.dart';
import 'package:psyclog_app/src/models/Patient.dart';

class TherapistNotePage extends StatefulWidget {
  final Patient _currentPatient;

  const TherapistNotePage(this._currentPatient, {Key key}) : super(key: key);

  @override
  _TherapistNotePageState createState() => _TherapistNotePageState();
}

class _TherapistNotePageState extends State<TherapistNotePage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
