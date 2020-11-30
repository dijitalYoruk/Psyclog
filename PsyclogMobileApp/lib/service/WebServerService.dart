library services;

import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/controller/UserModelController.dart';
import 'package:psyclog_app/src/models/util/ModelConstants.dart';
import 'package:psyclog_app/src/models/User.dart';

class WebServerService {
  static String _serverAddress;
  static WebServerService _serverService;
  static FlutterSecureStorage _secureStorage;
  static String _currentAPI;
  static User _currentUser;

  get currentUser => _currentUser;

  static Future<WebServerService> getWebServerService() async {
    if (_serverAddress == null) {
      _serverAddress = ServiceConstants.serverAddress;
      //192.168.1.37 for Local IP
    }
    if (_currentAPI == null) {
      _currentAPI = ServiceConstants.currentAPI;
    }
    if (_serverService == null) {
      print("Empty Service for Web Service. Creating a new one.");
      _serverService = new WebServerService();
    }
    if (_secureStorage == null) {
      print("Empty Storage for Storage Service. Creating a new one.");
      _secureStorage = new FlutterSecureStorage();
    }

    return _serverService;
  }

  Future<String> attemptLogin(String emailOrUsername, String password) async {
    final message = jsonEncode({"emailOrUsername": emailOrUsername, "password": password});

    try {
      var response =
          await http.post('$_serverAddress/$_currentAPI/auth/signIn', headers: ModelConstants.jsonTypeHeader, body: message);

      if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
        bool isUserCreated = _serverService.saveCurrentUserInformation(response.body);

        if (isUserCreated) {
          return ServiceErrorHandling.successfulStatusCode;
        } else {
          return ServiceErrorHandling.userInformationError;
        }
      } else {
        return jsonDecode(response.body)["message"];
      }
    } catch (error) {
      print(error);
      return ServiceErrorHandling.serverNotRespondingError;
    }
  }

  Future<Response> attemptUserSignUp(
      String username, String password, String passwordCheck, String email, String firstName, String lastName) async {
    final message = jsonEncode({
      "username": username,
      "email": email,
      "name": firstName,
      "surname": lastName,
      "password": password,
      "passwordConfirm": passwordCheck,
    });

    try {
      var response = await http.post('$_serverAddress/$_currentAPI/auth/signUp/patient',
          headers: ModelConstants.jsonTypeHeader, body: message);

      return response;
    } catch (e) {
      print(ServiceErrorHandling.couldNotSignUpError);
      return null;
    }
  }

  Future<String> checkUserByCurrentToken() async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      print("User Token: " + currentUserToken);

      try {
        var response = await http.get(
          '$_serverAddress/$_currentAPI/auth/profile',
          headers: {'Authorization': "Bearer " + currentUserToken},
        );

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          bool isUserCreated = saveCurrentUserInformationForToken(response.body);

          print("Current Token: " + currentUserToken);

          if (isUserCreated) {
            return ServiceErrorHandling.successfulStatusCode;
          } else {
            return ServiceErrorHandling.userInformationError;
          }
        } else {
          return ServiceErrorHandling.unsuccessfulStatusCode;
        }
      } catch (error) {
        print(error);
        return ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      return ServiceErrorHandling.noTokenError;
    }
  }

  bool saveCurrentUserInformationForToken(dynamic responseBody) {
    dynamic _decodedBody = jsonDecode(responseBody);

    if (_decodedBody["data"]["profile"]["role"] == ModelConstants.clientRole) {
      try {
        _currentUser = UserModelController.createClientFromJSONForToken(_decodedBody);

        return true;
      } catch (error) {
        print(ServiceErrorHandling.userInformationError);
        print(error);
      }
      return false;
    } else if (_decodedBody["data"]["profile"]["role"] == ModelConstants.therapistRole) {
      try {
        _currentUser = UserModelController.createTherapistFromJSONForToken(_decodedBody);

        return true;
      } catch (error) {
        print(ServiceErrorHandling.userInformationError);
        print(error);
      }
      return false;
    } else {
      print(ServiceErrorHandling.noRoleError);
      return false;
    }
  }

  bool saveCurrentUserInformation(dynamic responseBody) {
    dynamic _decodedBody = jsonDecode(responseBody);

    if (_decodedBody["data"]["user"]["role"] == ModelConstants.clientRole) {
      try {
        _currentUser = UserModelController.createClientFromJSON(_decodedBody);
        _setToken(_decodedBody["data"]["token"]);
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else if (_decodedBody["data"]["user"]["role"] == ModelConstants.therapistRole) {
      try {
        _currentUser = UserModelController.createTherapistFromJSON(_decodedBody);
        _setToken(_decodedBody["data"]["token"]);
        return true;
      } catch (e) {
        print(e);
        return false;
      }
    } else {
      return false;
    }
  }

  Future<int> getBalance() async {
    final String currentUserToken = await getToken();

    try {
      var response = await http.get(
        '$_serverAddress/$_currentAPI/wallet/checkBalance',
        headers: {'Authorization': "Bearer " + currentUserToken},
      );

      if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
        return jsonDecode(response.body)["data"]["balance"];
      } else {
        return null;
      }
    } catch (error) {
      print(error);
      return null;
    }
  }

  Future<String> getToken() async {
    String token = await _secureStorage.read(key: "token");

    return token;
  }

  void _setToken(String token) async {
    await _secureStorage.write(key: "token", value: token);

    print("User Token is set to: " + token);
  }

  Future<void> clearAllInfo() async {
    _currentUser = null;
    return _secureStorage.deleteAll();
  }
}
