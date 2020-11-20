import 'package:flutter/material.dart';
import 'package:psyclog_app/service/TherapistServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Client.dart';

class TherapistRegisteredListViewModel extends ChangeNotifier {
  TherapistServerService _serverService;

  List<Client> _registeredClientList;

  Client getTherapistByElement(index) {
    return _registeredClientList[index];
  }

  int getClientListLength() {
    if (_registeredClientList.isNotEmpty)
      return _registeredClientList.length;
    else
      return 0;
  }

  TherapistRegisteredListViewModel() {
    _registeredClientList = List<Client>();

    initializeService();
  }

  initializeService() async {
    _serverService = await TherapistServerService.getTherapistServerService();

    try {} catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }
}
