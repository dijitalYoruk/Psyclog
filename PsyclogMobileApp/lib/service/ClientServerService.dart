library services;

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'middleware/UserRestrict.dart';

class ClientServerService extends WebServerService {

  static String _serverAddress;
  static ClientServerService _clientServerService;
  static FlutterSecureStorage _secureStorage;
  static String _currentAPI;

  get currentClient => super.currentUser;

  static Future<ClientServerService> getClientServerService() async {

    // TODO USER Restrictions

    if (_serverAddress == null) {
      _serverAddress = ServiceConstants.serverAddress;
      //192.168.1.35 for Local IP
    }
    if (_currentAPI == null) {
      _currentAPI = ServiceConstants.currentAPI;
    }
    if (_clientServerService == null) {
      print("Empty Service for Client Server Service. Creating a new one.");
      _clientServerService = new ClientServerService();
    }
    if (_secureStorage == null) {
      print("Empty Storage for Client Storage Service. Creating a new one.");
      _secureStorage = new FlutterSecureStorage();
    }

    return _clientServerService;
  }

  Future<Response> getTherapistsByPage(int page) async {
    if (UserRestrict.restrictAccessByGivenRoles(
        [ServiceConstants.ROLE_USER, ServiceConstants.ROLE_ADMIN],
        super.currentUser.userRole)) {
      // Waiting for User Token to be retrieved
      var userToken = await getToken();

      if (userToken != null) {
        // Waiting for Therapist List
        try {
          var res = await http.get(
            '$_serverAddress/$_currentAPI/user/psychologists?page=' +
                page.toString(),
            headers: {'Authorization': "Bearer " + userToken.toString()},
          );

          return res;
        } catch (e) {
          print(ServiceErrorHandling.listNotRetrievedError);
        }
      } else {
        print(ServiceErrorHandling.tokenEmptyError);
      }
      return null;
    } else {
      print(ServiceErrorHandling.userRestrictionError);
      return null;
    }
  }

  createPatientRequest(String therapistID, String infoMessage) async {

    // TODO USER Restrictions

    final message =
    jsonEncode({"psychologist": therapistID, "content": infoMessage});

    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      try {
        var result =
        await http.post('$_serverAddress/$_currentAPI/patientRequests',
            headers: {
              'Authorization': "Bearer " + currentUserToken,
              'Content-Type': 'application/json'
            },
            body: message);

        if (result.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return ServiceErrorHandling.successfulStatusCode;
        } else {
          return ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        return ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      return ServiceErrorHandling.noTokenError;
    }
  }

  Future<Response> getPendingTherapistsList() async {

    // TODO USER Restrictions

    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      try {
        var result = await http.get(
            '$_serverAddress/$_currentAPI/patientRequests',
            headers: {'Authorization': "Bearer " + currentUserToken});

        if (result.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return result;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<List<String>> getPendingTherapistsIDList() async {

    // TODO USER Restrictions

    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      List<String> _requestedTherapistList = List<String>();

      try {
        var result = await http.get(
            '$_serverAddress/$_currentAPI/patientRequests',
            headers: {'Authorization': "Bearer " + currentUserToken});

        if (result.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          dynamic _decodedBody = jsonDecode(result.body);

          for (int index = 0;
          index < _decodedBody['data']['requests']['totalDocs'];
          index++) {
            _requestedTherapistList.add(_decodedBody['data']['requests']['docs']
            [index]['psychologist']['_id']);
          }

          return _requestedTherapistList;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<String> removePendingRequestByID(requestID) async {

    // TODO USER Restrictions

    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      try {
        var request = http.Request('DELETE',
            Uri.parse('$_serverAddress/$_currentAPI/patientRequests'));
        request.body = jsonEncode({"requestId": requestID});

        request.headers.addAll(<String, String>{
          'Authorization': "Bearer " + currentUserToken,
          'Content-Type': 'application/json'
        });

        print(request.body);

        final response = await request.send();

        print(response.statusCode);

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return ServiceErrorHandling.successfulStatusCode;
        } else {
          return ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        return ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }
}