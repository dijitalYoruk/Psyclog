import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:psyclog_app/service/TherapistServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/ClientRequest.dart';
import 'package:psyclog_app/src/models/controller/UserModelController.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/util/ViewErrorHandling.dart';

class TherapistPendingListViewModel extends ChangeNotifier {
  TherapistServerService _serverService;

  List<ClientRequest> _pendingClientList;

  int _currentPage;
  int _totalPage;

  TherapistPendingListViewModel() {
    _currentPage = 1;
    _totalPage = 1;
    _pendingClientList = List<ClientRequest>();
    initializeService();
  }

  initializeService() async {
    _serverService = await TherapistServerService.getTherapistServerService();

    try {
      var response = await _serverService.getPendingClientsByPage(_currentPage);

      if (response != null) {
        var decodedBody = jsonDecode(response.body);

        _totalPage = decodedBody["data"]["requests"]["totalPages"];

        _pendingClientList = await getClientsByPageFromService(_currentPage);
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }

  int getCurrentListLength() {
    if (_pendingClientList.isNotEmpty)
      return _pendingClientList.length;
    else
      return 0;
  }

  ClientRequest getClientByIndex(int index) {
    return _pendingClientList[index];
  }

  Future<List<ClientRequest>> getClientsByPageFromService(int currentPage) async {
    List<ClientRequest> _pendingList;

    try {
      var response = await _serverService.getPendingClientsByPage(currentPage);

      if (response != null) {
        var _decodedBody = jsonDecode(response.body);

        int numberOfClients = _decodedBody["data"]["requests"]["docs"].length;

        _pendingList = List<ClientRequest>.generate(
            numberOfClients,
            (index) => ClientRequest(
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

        List<ClientRequest> _newRequests = await getClientsByPageFromService(_currentPage);

        try {
          _pendingClientList.addAll(_newRequests);
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
    String response = await _serverService.acceptRequestByID(_pendingClientList[index].getRequestID);

    if (response == ServiceErrorHandling.successfulStatusCode) {
      _pendingClientList.removeAt(index);

      // TODO User information has to be updated here

      return true;
    } else {
      print("Accepting Pending request failed. Response: " + response);
      return false;
    }
  }

  Future<bool> denyPendingRequestByIndex(int index) async {
    String response = await _serverService.denyRequestByID(_pendingClientList[index].getRequestID);

    if (response == ServiceErrorHandling.successfulStatusCode) {
      _pendingClientList.removeAt(index);

      // TODO User information has to be updated here

      return true;
    } else {
      print("Accepting Pending request failed. Response: " + response);
      return false;
    }
  }

  void _showLoadingIndicator() {
    _pendingClientList.add(null);
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    _pendingClientList.remove(null);
    notifyListeners();
  }
}
