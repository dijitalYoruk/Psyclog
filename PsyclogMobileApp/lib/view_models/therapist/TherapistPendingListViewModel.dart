import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:psyclog_app/service/TherapistServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/PatientRequest.dart';
import 'package:psyclog_app/src/models/controller/UserModelController.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/util/ViewErrorHandling.dart';

class TherapistPendingListViewModel extends ChangeNotifier {
  TherapistServerService _serverService;

  List<PatientRequest> _pendingPatientList;

  int _currentPage;
  int _totalPage;

  TherapistPendingListViewModel() {
    _currentPage = 1;
    _totalPage = 1;
    _pendingPatientList = List<PatientRequest>();
    initializeService();
  }

  initializeService() async {
    _serverService = await TherapistServerService.getTherapistServerService();

    try {
      var response = await _serverService.getPendingPatientsByPage(_currentPage);

      if (response != null) {
        var decodedBody = jsonDecode(response.body);

        _totalPage = decodedBody["data"]["requests"]["totalPages"];

        _pendingPatientList = await getPatientsByPageFromService(_currentPage);
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }

  int getCurrentListLength() {
    if (_pendingPatientList.isNotEmpty)
      return _pendingPatientList.length;
    else
      return 0;
  }

  PatientRequest getPatientByIndex(int index) {
    return _pendingPatientList[index];
  }

  Future<List<PatientRequest>> getPatientsByPageFromService(int currentPage) async {
    List<PatientRequest> _pendingList;

    try {
      var response = await _serverService.getPendingPatientsByPage(currentPage);

      if (response != null) {
        var _decodedBody = jsonDecode(response.body);

        int numberOfClients = _decodedBody["data"]["requests"]["docs"].length;

        _pendingList = List<PatientRequest>.generate(
            numberOfClients,
            (index) => PatientRequest(
                _decodedBody["data"]["requests"]["docs"][index]['_id'],
                UserModelController.createClientFromJSONForList(_decodedBody["data"]["requests"]["docs"][index]['patient']),
                _decodedBody["data"]["requests"]["docs"][index]['content'],
                _decodedBody["data"]["requests"]["docs"][index]['createdAt'],
                _decodedBody["data"]["requests"]["docs"][index]['psychologist']));

        return _pendingList;
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    return null;
  }

  Future<void> handleItemCreated(int index) async {
    if (_serverService != null) {
      var itemPosition = index + 1;
      var requestMoreData = itemPosition % ViewConstants.clientsPerPage == 0 && itemPosition != 0;
      var pageToRequest = 1 + (itemPosition ~/ ViewConstants.clientsPerPage);

      if (requestMoreData && pageToRequest > _currentPage && _currentPage < _totalPage) {
        print('handleItemCreated | pageToRequest: $pageToRequest');
        _currentPage = pageToRequest;

        // Loading indicator inserted into the list
        _showLoadingIndicator();

        // Adding new therapists to the list

        List<PatientRequest> _newRequests = await getPatientsByPageFromService(_currentPage);

        try {
          _pendingPatientList.addAll(_newRequests);
        } catch (e) {
          print(ViewErrorHandling.pageIsNotLoaded);
          _currentPage -= 1;
          print("Current Page: " + _currentPage.toString());
        }

        //Loading indicator removed from the list
        _removeLoadingIndicator();
      }
    } else {
      initializeService();
    }
  }

  Future<bool> acceptPendingRequestByIndex(int index) async {
    String response = await _serverService.acceptRequestByID(_pendingPatientList[index].getRequestID);

    if (response == ServiceErrorHandling.successfulStatusCode) {
      _pendingPatientList.removeAt(index);

      // TODO User information has to be updated here

      return true;
    } else {
      print("Accepting Pending request failed. Response: " + response);
      return false;
    }
  }

  Future<bool> denyPendingRequestByIndex(int index) async {
    String response = await _serverService.denyRequestByID(_pendingPatientList[index].getRequestID);

    if (response == ServiceErrorHandling.successfulStatusCode) {
      _pendingPatientList.removeAt(index);

      // TODO User information has to be updated here

      return true;
    } else {
      print("Accepting Pending request failed. Response: " + response);
      return false;
    }
  }

  void _showLoadingIndicator() {
    _pendingPatientList.add(null);
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    _pendingPatientList.remove(null);
    notifyListeners();
  }
}
