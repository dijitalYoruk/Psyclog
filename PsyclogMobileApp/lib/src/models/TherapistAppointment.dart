import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/views/util/DateParser.dart';

class TherapistAppointment {
  final String _appointmentID;
  final List<int> _intervals;
  final Patient _patient;
  final String _psychologistID;
  final DateTime _appointmentDate;
  final int _appointmentPrice;
  final int _endTime;
  final int _startTime;

  TherapistAppointment.fromJson(Map<String, dynamic> json)
      : _appointmentID = json['_id'] as String,
        _intervals = List<int>.generate(json['intervals'].length, (index) => json['intervals'][index]),
        _patient = Patient.fromJsonForAppointment(json['patient']),
        _psychologistID = json['psychologist'] as String,
        _appointmentDate = DateParser.jsonToDateTime(json['appointmentDate']),
        _appointmentPrice = json['price'] as int,
        _endTime = json['end'] as int,
        _startTime = json['start'] as int;

  get getAppointmentID => _appointmentID;
  get getIntervals => _intervals;
  get getPatient => _patient;
  get getPsychologistID => _psychologistID;
  get getAppointmentDate => _appointmentDate;
  get getAppointmentPrice => _appointmentPrice;
  get getEndTime => _endTime;
  get getStartTime => _startTime;
}
