import 'package:psyclog_app/src/models/ClientAppointment.dart';

class PatientSchedule {
  final List<ClientAppointment> _appointments;
  final List<DateTime> _dateTimes;

  get getAppointmentList => _appointments;
  get getDateTimeList => _dateTimes;

  PatientSchedule(this._appointments, this._dateTimes);
}