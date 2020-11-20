import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:psyclog_app/service/ClientServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Client.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/src/models/controller/UserModelController.dart';
import 'package:psyclog_app/views/util/ViewErrorHandling.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientSearchListViewModel extends ChangeNotifier {
  ClientServerService _serverService;

  List<Therapist> _currentTherapistList;

  // TODO will check if the the therapist is registered before
  List<dynamic> _registeredTherapistsIDList;

  List<String> _pendingTherapistList;

  int _currentPage;
  int _totalPage;

  ClientSearchListViewModel() {
    _currentPage = 1;
    _totalPage = 1;
    _currentTherapistList = List<Therapist>();
    initializeService();
  }

  Therapist getTherapistByElement(int index) {
    return _currentTherapistList[index];
  }

  int getCurrentListLength() {
    if (_currentTherapistList.isNotEmpty)
      return _currentTherapistList.length;
    else
      return 0;
  }

  initializeService() async {
    _serverService = await ClientServerService.getClientServerService();

    try {
      var response = await _serverService.getTherapistsByPage(_currentPage);

      if (response != null) {
        var decodedBody = jsonDecode(response.body);

        _totalPage = decodedBody["data"]["psychologists"]["totalPages"];

        _registeredTherapistsIDList = (_serverService.currentClient as Client).clientRegisteredPsychologists;

        _currentTherapistList = await getTherapistsByPageFromService(_currentPage);

        await refreshPendingList();

        print("Registered Therapists: " + _registeredTherapistsIDList.toString());
        print("Pending Therapists: " + _pendingTherapistList.toString());
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    notifyListeners();
  }

  Future<void> refreshPendingList() async {
    _pendingTherapistList = await _serverService.getPendingTherapistsIDList();

    notifyListeners();
  }

  bool checkAppliedStatus(String therapistID) {
    if (_pendingTherapistList.contains(therapistID)) {
      return true;
    } else {
      return false;
    }
  }

  bool checkRegisteredStatus(String therapistID) {
    if (_registeredTherapistsIDList.contains(therapistID)) {
      return true;
    } else {
      return false;
    }
  }

  Future<List<Therapist>> getTherapistsByPageFromService(int page) async {
    List<Therapist> _therapistList;

    try {
      var response = await _serverService.getTherapistsByPage(page);

      if (response != null) {
        var decodedBody = jsonDecode(response.body);

        int numberOfTherapist = decodedBody["data"]["psychologists"]["docs"].length;

        _therapistList = List<Therapist>.generate(
            numberOfTherapist,
            (index) =>
                UserModelController.createTherapistFromJSONForList(decodedBody["data"]["psychologists"]["docs"][index]));

        return _therapistList;
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
    return null;
  }

  Future handleItemCreated(int index) async {
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

        List<Therapist> _newTherapists = await getTherapistsByPageFromService(_currentPage);

        try {
          _currentTherapistList.addAll(_newTherapists);
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

  void _showLoadingIndicator() {
    _currentTherapistList.add(null);
    notifyListeners();
  }

  void _removeLoadingIndicator() {
    _currentTherapistList.remove(null);
    notifyListeners();
  }
}
