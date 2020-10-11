import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Client.dart';
import 'package:psyclog_app/src/models/Therapist.dart';

class ApprovedTherapistListViewModel extends ChangeNotifier {
  WebServerService _serverService;

  List<dynamic> _registeredTherapistList;

  int _currentPage;
  int _totalPage;

  Therapist getTherapistByElement(index) {
    return _registeredTherapistList[index];
  }

  int getTherapistListLength() {
    if (_registeredTherapistList.isNotEmpty)
      return _registeredTherapistList.length;
    else
      return 0;
  }

  ApprovedTherapistListViewModel() {
    _currentPage = 1;
    _totalPage = 1;

    _registeredTherapistList = List<Therapist>();

    initializeService();
  }

  initializeService() async {
    _serverService = await WebServerService.getWebServerService();

    try {
      var response =
          await _serverService.getRegisteredTherapistsByPage(_currentPage);

      if (response != null) {
        var decodedBody = jsonDecode(response.body);

        _totalPage = decodedBody["data"]["psychologists"]["totalPages"];

        _registeredTherapistList = (_serverService.currentUser as Client)
            .clientRegisteredPsychologists;

        print("Registered Therapists: " + _registeredTherapistList.toString());
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }
}
