import 'package:flutter/material.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Client.dart';

class TherapistPendingListViewModel extends ChangeNotifier {

  WebServerService _serverService;

  List<Client> _pendingClientList;

  int _currentPage;
  int _totalPage;

  Client getTherapistByElement(index) {
    return _pendingClientList[index];
  }

  int getClientListLength() {
    if (_pendingClientList.isNotEmpty)
      return _pendingClientList.length;
    else
      return 0;
  }

  TherapistPendingListViewModel() {
    _currentPage = 1;
    _totalPage = 1;

    _pendingClientList = List<Client>();

    initializeService();
  }

  initializeService() async {
    _serverService = await WebServerService.getWebServerService();

    try {

    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }
}