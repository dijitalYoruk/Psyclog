import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:psyclog_app/service/ClientServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/TherapistRequest.dart';
import 'package:psyclog_app/src/models/controller/UserModelController.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/util/ViewErrorHandling.dart';

class ClientPendingListViewModel extends ChangeNotifier {
  ClientServerService _serverService;

  List<TherapistRequest> _pendingTherapistList;

  int _currentPage;
  int _totalPage;

  ClientPendingListViewModel() {
    _currentPage = 1;
    _totalPage = 1;

    _pendingTherapistList = List<TherapistRequest>();
    initializeService();
  }

  initializeService() async {
    _serverService = await ClientServerService.getClientServerService();

    try {
      var response = await _serverService.getPendingTherapistsByPage(_currentPage);

      if (response != null) {
        var decodedBody = jsonDecode(response.body);

        _totalPage = decodedBody["data"]["requests"]["totalPages"];

        _pendingTherapistList = await getTherapistByPageFromService(_currentPage);
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }

  int getCurrentListLength() {
    if (_pendingTherapistList.isNotEmpty)
      return _pendingTherapistList.length;
    else
      return 0;
  }

  TherapistRequest getTherapistByIndex(int index) {
    return _pendingTherapistList[index];
  }

  Future<List<TherapistRequest>> getTherapistByPageFromService(int currentPage) async {
    List<TherapistRequest> _pendingList;

    try {
      var response = await _serverService.getPendingTherapistsByPage(currentPage);

      if (response != null) {
        var _decodedBody = jsonDecode(response.body);

        int numberOfTherapists = _decodedBody["data"]["requests"]["docs"].length;

        _pendingList = List<TherapistRequest>.generate(
            numberOfTherapists,
            (index) => TherapistRequest(
                _decodedBody["data"]["requests"]["docs"][index]['_id'],
                UserModelController.createTherapistFromJSONForList(
                    _decodedBody["data"]["requests"]["docs"][index]['psychologist'])));

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
      var requestMoreData = itemPosition % ViewConstants.therapistsPerPage == 0 && itemPosition != 0;
      var pageToRequest = 1 + (itemPosition ~/ ViewConstants.therapistsPerPage);

      if (requestMoreData && pageToRequest > _currentPage && _currentPage < _totalPage) {
        print('handleItemCreated | pageToRequest: $pageToRequest');
        _currentPage = pageToRequest;

        // Loading indicator inserted into the list
        _showLoadingIndicator();

        // Adding new therapists to the list

        List<TherapistRequest> _newRequests = await getTherapistByPageFromService(_currentPage);

        try {
          _pendingTherapistList.addAll(_newRequests);
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

  Future<bool> removePendingRequestByIndex(int index) async {
    String response = await _serverService.removePendingRequestByID(_pendingTherapistList[index].getRequestID);

    if (response == ServiceErrorHandling.successfulStatusCode) {
      _pendingTherapistList.removeAt(index);
      return true;
    } else {
      print("Removing Pending request failed. Response: " + response);
      return false;
    }
  }

  void _showLoadingIndicator() {
    _pendingTherapistList.add(null);
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    _pendingTherapistList.remove(null);
    notifyListeners();
  }
}
