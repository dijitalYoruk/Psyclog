import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/views/util/DateParser.dart';

class ClientAppointment {
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

  ClientAppointment.fromJson(Map<String, dynamic> json)
      : _appointmentID = json['_id'] as String,
        _intervals = List<int>.generate(json['intervals'].length, (index) => json['intervals'][index]),
        _therapist = Therapist.fromJsonForAppointment(json['psychologist']),
        _patientID = json['patient'] as String,
        _appointmentDate = DateParser.jsonToDateTime(json['appointmentDate']),
        _appointmentPrice = json['price'] as int,
        _endTime = json['end'] as int,
        _startTime = json['start'] as int;
}
