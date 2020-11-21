import 'package:flutter/material.dart';
import 'package:psyclog_app/service/ClientServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Therapist.dart';

class ClientRegisteredListViewModel extends ChangeNotifier {
  ClientServerService _serverService;

  List<Therapist> _registeredTherapistList;

  Therapist getTherapistByIndex(index) {
    return _registeredTherapistList[index];
  }

  int getTherapistListLength() {
    if (_registeredTherapistList.isNotEmpty)
      return _registeredTherapistList.length;
    else
      return 0;
  }

  ClientRegisteredListViewModel() {
    _registeredTherapistList = List<Therapist>();

    initializeService();
  }

  initializeService() async {
    _serverService = await ClientServerService.getClientServerService();

    try {
      _registeredTherapistList = await _serverService.getRegisteredPsychologists();
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }
}
