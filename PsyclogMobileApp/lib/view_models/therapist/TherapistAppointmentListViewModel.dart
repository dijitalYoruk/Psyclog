import 'package:flutter/material.dart';
import 'package:psyclog_app/service/TherapistServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/TherapistAppointment.dart';
import 'package:psyclog_app/src/models/TherapistSchedule.dart';

class TherapistAppointmentListViewModel extends ChangeNotifier {
  TherapistServerService _serverService;

  List<TherapistAppointment> _appointmentList;
  List<DateTime> _dateTimeList;

  TherapistAppointmentListViewModel() {
    _appointmentList = List<TherapistAppointment>();
    _dateTimeList = List<DateTime>();

    initializeService();
  }

  TherapistAppointment getAppointmentByIndex(int index) {
    return _appointmentList[index];
  }

  DateTime getDateTimeByIndex(int index) {
    return _dateTimeList[index];
  }

  int getAppointmentListLength() {
    if (_appointmentList.isNotEmpty)
      return _appointmentList.length;
    else
      return 0;
  }

  int getDateTimeListLength() {
    if (_dateTimeList.isNotEmpty)
      return _dateTimeList.length;
    else
      return 0;
  }

  initializeService() async {
    if (_serverService == null) _serverService = await TherapistServerService.getTherapistServerService();

    try {
      TherapistSchedule _schedule = await _serverService.getAppointmentList();

      _appointmentList = _schedule.getAppointmentList as List<TherapistAppointment>;
      _dateTimeList = _schedule.getDateTimeList as List<DateTime>;

      print(_dateTimeList);

      if (_appointmentList.isNotEmpty) {
        print("Appointments are fetched successfully.");
        notifyListeners();
      } else {
        print("Appointment List is empty.");
        notifyListeners();
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
  }

  Future<bool> cancelAppointmentByIndex(int index) async {
    try {
      bool isCancelled = await _serverService.cancelAppointment(getAppointmentByIndex(index).getAppointmentID);

      if (isCancelled) {
        initializeService();
        return true;
      } else {
        return false;
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
      return false;
    }
  }
}
