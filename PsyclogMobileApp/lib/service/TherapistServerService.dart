import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/middleware/UserRestrict.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Note.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/TherapistAppointment.dart';
import 'package:psyclog_app/src/models/TherapistSchedule.dart';
import 'package:psyclog_app/src/models/controller/UserModelController.dart';

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

  Future<Response> getPendingPatientsByPage(int page) async {
    if (UserRestrict.restrictAccessByGivenRoles(
        [ServiceConstants.ROLE_PSYCHOLOGIST, ServiceConstants.ROLE_ADMIN], super.currentUser.userRole)) {
      final String currentUserToken = await getToken();

      if (currentUserToken != null) {
        try {
          var result = await http.get('$_serverAddress/$_currentAPI/patientRequests?page=' + page.toString(),
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

  Future<List<Patient>> getRegisteredPatients() async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      List<Patient> _registeredPatientsList = List<Patient>();

      try {
        var response = await http.get('$_serverAddress/$_currentAPI/user/registered-patients',
            headers: {'Authorization': "Bearer " + currentUserToken});

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          dynamic _decodedBody = jsonDecode(response.body);

          int numberOfPatients = _decodedBody['data']['registeredPatients']['patients'].length;

          _registeredPatientsList = List<Patient>.generate(
              numberOfPatients,
              (index) => UserModelController.createClientFromJSONForList(
                  _decodedBody['data']['registeredPatients']['patients'][index]));

          return _registeredPatientsList;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<String> acceptRequestByID(String requestID) async {
    final String currentUserToken = await getToken();
    final message = jsonEncode({"requestId": requestID});

    if (currentUserToken != null) {
      try {
        var response = await http.post('$_serverAddress/$_currentAPI/patientRequests/accept',
            headers: {'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'}, body: message);

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
        var response = await http.post('$_serverAddress/$_currentAPI/patientRequests/deny',
            headers: {'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'}, body: message);

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

  Future<Map<String, List<int>>> getBlockedDays() async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      try {
        var response = await http.post('$_serverAddress/$_currentAPI/appointment/blocked-days',
            headers: {'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'});

        final Map<String, List<int>> days = Map<String, List<int>>();

        print(response.body);

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          dynamic _decodedBody = jsonDecode(response.body);

          for (dynamic item in _decodedBody["data"]["days"]) {
            days[item["day"] as String] = List.generate(item["blocked"].length, (index) => item["blocked"][index]);
          }
          return days;
        } else {
          return days;
        }
      } catch (e) {
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<TherapistSchedule> getAppointmentList() async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      List<TherapistAppointment> _appointmentList = List<TherapistAppointment>();
      List<DateTime> _dateTimeList = List<DateTime>();

      try {
        var response = await http.get('$_serverAddress/$_currentAPI/appointment/personal-appointments',
            headers: {'Authorization': "Bearer " + currentUserToken});

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          dynamic _decodedBody = jsonDecode(response.body);

          int numberOfAppointments = _decodedBody['data']['appointments'].length;

          if (numberOfAppointments != 0) {
            TherapistAppointment _head = TherapistAppointment.fromJson(_decodedBody['data']['appointments'][0]);

            _appointmentList.add(_head);

            _dateTimeList.add(_head.getAppointmentDate);

            // Inserting appointments based on their date
            for (int i = 1; i < numberOfAppointments; i++) {
              TherapistAppointment _curr = TherapistAppointment.fromJson(_decodedBody['data']['appointments'][i]);

              if (!_dateTimeList.contains(_curr.getAppointmentDate)) _dateTimeList.add(_curr.getAppointmentDate);

              int index = 0;
              bool inserted = false;

              for (TherapistAppointment _appointment in _appointmentList) {
                if ((_curr.getAppointmentDate as DateTime).isBefore(_appointment.getAppointmentDate)) {
                  _appointmentList.insert(index, _curr);
                  inserted = true;
                  break;
                }
                index++;
              }

              if (!inserted) _appointmentList.add(_curr);
            }

            // Sorting all the dates
            _dateTimeList.sort();

            TherapistSchedule _schedule = TherapistSchedule(_appointmentList, _dateTimeList);

            return _schedule;
          } else {
            return TherapistSchedule(_appointmentList, _dateTimeList);
          }
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<bool> blockIntervals(List<int> blockedIntervals, int dayNumber) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      final message = jsonEncode({"blockedIntervals": blockedIntervals, "day": dayNumber});

      try {
        var response = await http.post('$_serverAddress/$_currentAPI/appointment/block-intervals',
            headers: {'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'}, body: message);

        print(response.body);

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<bool> cancelAppointment(String appointmentID) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      final message = jsonEncode({"appointmentId": appointmentID});

      try {
        var response = await http.post('$_serverAddress/$_currentAPI/appointment/cancel',
            headers: {'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'}, body: message);

        print(response.body);

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        return null;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<List<Note>> getNoteList(String patientID) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      List<Note> _noteList = List<Note>();

      try {
        var response = await http.get('$_serverAddress/$_currentAPI/patientNotes?patient=$patientID',
            headers: {'Authorization': "Bearer " + currentUserToken});

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          dynamic _decodedBody = jsonDecode(response.body);

          int numberOfNotes = _decodedBody['data']['notes'].length;

          _noteList = List<Note>.generate(numberOfNotes, (index) => Note.fromJson(_decodedBody["data"]["notes"][index]));

          return _noteList;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<bool> createNote(String content, String patientID) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      final message = jsonEncode({
        "content": content,
        "patient": patientID,
      });

      try {
        var response = await http.post('$_serverAddress/$_currentAPI/patientNotes',
            headers: {'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'}, body: message);

        print(response.body);

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return true;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<bool> deleteNote(String noteID) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      try {
        var request = http.Request('DELETE', Uri.parse('$_serverAddress/$_currentAPI/patientNotes'));
        request.body = jsonEncode({"noteId": noteID});
        request.headers
            .addAll(<String, String>{'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'});

        final response = await request.send();

        if (response.statusCode == ServiceConstants.STATUS_DELETE_SUCCESS_CODE) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
      return false;
    }
  }

  Future<bool> updateNote(String noteID, String content) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      try {
        var request = http.Request('PATCH', Uri.parse('$_serverAddress/$_currentAPI/patientNotes'));
        request.body = jsonEncode({"noteId": noteID, "content": content});
        request.headers
            .addAll(<String, String>{'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'});

        final response = await request.send();

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        print(e);
        throw ServiceErrorHandling.serverNotRespondingError;
      }
    } else {
      print(ServiceErrorHandling.tokenEmptyError);
      return false;
    }
  }
}
