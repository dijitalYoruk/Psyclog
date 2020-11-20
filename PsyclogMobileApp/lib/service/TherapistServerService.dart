import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/middleware/UserRestrict.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';

class TherapistServerService extends WebServerService {
  static String _serverAddress;
  static TherapistServerService _therapistServerService;
  static FlutterSecureStorage _secureStorage;
  static String _currentAPI;

  get currentTherapist => super.currentUser;

  static Future<TherapistServerService> getTherapistServerService() async {
    if (_serverAddress == null) {
      _serverAddress = ServiceConstants.serverAddress;
      //192.168.1.35 for Local IP
    }
    if (_currentAPI == null) {
      _currentAPI = ServiceConstants.currentAPI;
    }
    if (_therapistServerService == null) {
      print("Empty Service for Therapist Server Service. Creating a new one.");
      _therapistServerService = new TherapistServerService();
    }
    if (_secureStorage == null) {
      print("Empty Storage for Therapist Storage Service. Creating a new one.");
      _secureStorage = new FlutterSecureStorage();
    }

    return _therapistServerService;
  }

  Future<Response> getPendingClientsByPage(int page) async {
    if (UserRestrict.restrictAccessByGivenRoles(
        [ServiceConstants.ROLE_PSYCHOLOGIST, ServiceConstants.ROLE_ADMIN],
        super.currentUser.userRole)) {
      final String currentUserToken = await getToken();

      if (currentUserToken != null) {
        try {
          var result = await http.get(
              '$_serverAddress/$_currentAPI/patientRequests?page=' +
                  page.toString(),
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
    } else {
      print(ServiceErrorHandling.userRestrictionError);
      return null;
    }
  }

  Future<String> acceptRequestByID(String requestID) async {
    final String currentUserToken = await getToken();
    final message = jsonEncode({"requestId": requestID});

    if (currentUserToken != null) {
      try {
        var response = await http.post(
            '$_serverAddress/$_currentAPI/patientRequests/accept',
            headers: {
              'Authorization': "Bearer " + currentUserToken,
              'Content-Type': 'application/json'
            },
            body: message);

        print(response.body);

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

  Future<String> denyRequestByID(String requestID) async {
    final String currentUserToken = await getToken();
    final message = jsonEncode({"requestId": requestID});

    if (currentUserToken != null) {
      try {
        var response = await http.post(
            '$_serverAddress/$_currentAPI/patientRequests/deny',
            headers: {
              'Authorization': "Bearer " + currentUserToken,
              'Content-Type': 'application/json'
            },
            body: message);

        print(response.body);

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
