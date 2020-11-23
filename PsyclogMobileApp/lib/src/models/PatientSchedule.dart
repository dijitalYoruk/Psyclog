import 'package:psyclog_app/src/models/Appointment.dart';

class PatientSchedule {
  final List<Appointment> _appointments;
  final List<DateTime> _dateTimes;

  get getAppointmentList => _appointments;
  get getDateTimeList => _dateTimes;

  PatientSchedule(this._appointments, this._dateTimes);
}