import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:psyclog_app/service/ClientServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/TherapistRequest.dart';
import 'package:psyclog_app/src/models/controller/UserModelController.dart';

class ClientPendingListViewModel extends ChangeNotifier {
  ClientServerService _serverService;

  List<TherapistRequest> _pendingTherapistList;

  ClientPendingListViewModel() {

    _pendingTherapistList = List<TherapistRequest>();
    initializeService();
  }

  initializeService() async {
    _serverService = await ClientServerService.getClientServerService();

    try {
      var response = await _serverService.getPendingTherapistsList();

      if (response != null) {
        var _decodedBody = jsonDecode(response.body);

        print(_decodedBody['data']['requests']['docs']);

        int numberOfTherapist = _decodedBody["data"]["requests"]["docs"].length;

        _pendingTherapistList = List<TherapistRequest>.generate(
            numberOfTherapist,
                (index) => TherapistRequest(_decodedBody["data"]["requests"]["docs"][index]['_id'], UserModelController.createTherapistFromJSONForList(_decodedBody["data"]["requests"]["docs"][index]['psychologist'])));

      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }

  TherapistRequest getTherapistByIndex(int index) {
    return _pendingTherapistList[index];
  }

  Future<bool> removePendingRequestByIndex(int index) async {
    String response = await _serverService.removePendingRequestByID(_pendingTherapistList[index].getRequestID);

    if(response == ServiceErrorHandling.successfulStatusCode) {
      _pendingTherapistList.removeAt(index);
      return true;
    }
    else {
      print("Removing Pending request failed. Response: " + response);
      return false;
    }

  }

  int getCurrentListLength() {
    if (_pendingTherapistList.isNotEmpty)
      return _pendingTherapistList.length;
    else
      return 0;
  }
}