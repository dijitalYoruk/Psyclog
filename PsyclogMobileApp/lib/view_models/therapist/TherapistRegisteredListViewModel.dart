import 'package:flutter/material.dart';
import 'package:psyclog_app/service/TherapistServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Patient.dart';

class TherapistRegisteredListViewModel extends ChangeNotifier {
  TherapistServerService _serverService;

  List<Patient> _registeredPatientList;

  Patient getPatientByIndex(index) {
    return _registeredPatientList[index];
  }

  int getClientListLength() {
    if (_registeredPatientList.isNotEmpty)
      return _registeredPatientList.length;
    else
      return 0;
  }

  TherapistRegisteredListViewModel() {
    _registeredPatientList = List<Patient>();

    initializeService();
  }

  initializeService() async {
    _serverService = await TherapistServerService.getTherapistServerService();

    try {
      _registeredPatientList = await _serverService.getRegisteredPatients();
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }
}
