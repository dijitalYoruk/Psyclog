import 'package:flutter/material.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Client.dart';

class ApprovedClientListViewModel extends ChangeNotifier {
  WebServerService _serverService;

  List<Client> _registeredClientList;

  int _currentPage;
  int _totalPage;

  Client getTherapistByElement(index) {
    return _registeredClientList[index];
  }

  int getClientListLength() {
    if (_registeredClientList.isNotEmpty)
      return _registeredClientList.length;
    else
      return 0;
  }

  ApprovedClientListViewModel() {
    _currentPage = 1;
    _totalPage = 1;

    _registeredClientList = List<Client>();

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
