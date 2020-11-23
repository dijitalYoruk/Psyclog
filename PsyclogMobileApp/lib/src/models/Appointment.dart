import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/views/util/DateParser.dart';

class Appointment {
  final String _appointmentID;
  final List<int> _intervals;
  final Therapist _therapist;
  final String _patientID;
  final DateTime _appointmentDate;
  final int _appointmentPrice;
  final int _endTime;
  final int _startTime;

  get getAppointmentID => _appointmentID;
  get getIntervals => _intervals;
  get getTherapist => _therapist;
  get getPatientID => _patientID;
  get getAppointmentDate => _appointmentDate;
  get getAppointmentPrice => _appointmentPrice;
  get getEndTime => _endTime;
  get getStartTime => _startTime;

  Appointment.fromJson(Map<String, dynamic> json)
      : _appointmentID = json['_id'] as String,
        _intervals = json['_intervals'] as List<int>,
        _therapist = Therapist.fromJsonForAppointment(json),
        _patientID = json['patient'] as String,
        _appointmentDate = DateParser.jsonToDateTime(json['appointmentDate']),
        _appointmentPrice = json['price'] as int,
        _endTime = json['end'] as int,
        _startTime = json['start'] as int;
}
