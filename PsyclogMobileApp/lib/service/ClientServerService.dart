import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/PatientSchedule.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/src/models/controller/UserModelController.dart';
import 'middleware/UserRestrict.dart';
import 'package:psyclog_app/src/models/ClientAppointment.dart';

class ClientServerService extends WebServerService {
  static String _serverAddress;
  static ClientServerService _clientServerService;
  static String _currentAPI;

  get currentPatient => super.currentUser;

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

    return _clientServerService;
  }


  Future<Response> getTherapistsByPage(int page) async {
    if (UserRestrict.restrictAccessByGivenRoles(
        [ServiceConstants.ROLE_USER, ServiceConstants.ROLE_ADMIN], super.currentUser.userRole)) {
      // Waiting for User Token to be retrieved
      final String currentUserToken = await getToken();

      if (currentUserToken != null) {
        // Waiting for Therapist List
        try {
          var response = await http.get(
            '$_serverAddress/$_currentAPI/user/psychologists?search&page=' + page.toString(),
            headers: {'Authorization': "Bearer " + currentUserToken},
          );

          return response;
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

    final message = jsonEncode({"psychologist": therapistID, "content": infoMessage});

    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      try {
        var response = await http.post('$_serverAddress/$_currentAPI/patientRequests',
            headers: {'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'}, body: message);

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
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

  Future<Response> getPendingTherapistsByPage(int page) async {
    // TODO USER Restrictions

    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      try {
        var response = await http.get('$_serverAddress/$_currentAPI/patientRequests?page=' + page.toString(),
            headers: {'Authorization': "Bearer " + currentUserToken});

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          return response;
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
        var response = await http
            .get('$_serverAddress/$_currentAPI/patientRequests', headers: {'Authorization': "Bearer " + currentUserToken});

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          dynamic _decodedBody = jsonDecode(response.body);

          for (int index = 0; index < _decodedBody['data']['requests']['totalDocs']; index++) {
            _requestedTherapistList.add(_decodedBody['data']['requests']['docs'][index]['psychologist']['_id']);
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

  Future<String> removePendingRequestByID(String requestID) async {
    // TODO USER Restrictions

    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      try {
        var request = http.Request('DELETE', Uri.parse('$_serverAddress/$_currentAPI/patientRequests'));
        request.body = jsonEncode({"requestId": requestID});

        request.headers
            .addAll(<String, String>{'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'});

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

  Future<List<Therapist>> getRegisteredPsychologists() async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      List<Therapist> _registeredPsychologistList = List<Therapist>();

      try {
        var response = await http.get('$_serverAddress/$_currentAPI/user/registered-psychologists',
            headers: {'Authorization': "Bearer " + currentUserToken});

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          dynamic _decodedBody = jsonDecode(response.body);

          int numberOfTherapists = _decodedBody['data']['registeredPsychologists']['registeredPsychologists'].length;

          _registeredPsychologistList = List<Therapist>.generate(
              numberOfTherapists,
              (index) => UserModelController.createTherapistFromJSONForList(
                  _decodedBody['data']['registeredPsychologists']['registeredPsychologists'][index]));

          return _registeredPsychologistList;
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

  Future<List<CalendarInterval>> getDateStatus(String therapistID, int day, int month, int year) async {
    // TODO USER Restrictions
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      final message = jsonEncode({"psychologistId": therapistID, "day": day, "month": month, "year": year});

      try {
        var response = await http.post('$_serverAddress/$_currentAPI/appointment/date-status',
            headers: {'Authorization': "Bearer " + currentUserToken, 'Content-Type': 'application/json'}, body: message);

        print(response.body);

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          dynamic _decodedBody = jsonDecode(response.body);

          List<int> blockedIntervals =
              List.generate(_decodedBody["data"]["blocked"].length, (index) => _decodedBody["data"]["blocked"][index]);
          List<int> reservedIntervals =
              List.generate(_decodedBody["data"]["reserved"].length, (index) => _decodedBody["data"]["reserved"][index]);

          List<CalendarInterval> appropriateIntervals =
              CalendarConstants.getAppropriateIntervals(reservedIntervals, blockedIntervals);

          return appropriateIntervals;
        } else {
          throw ServiceErrorHandling.couldNotCreateRequestError;
        }
      } catch (e) {
        return null;
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  Future<bool> createAppointment(List<int> chosenIntervals, DateTime chosenDate, String therapistID) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      final message = jsonEncode({
        "psychologistId": therapistID,
        "day": chosenDate.day,
        "month": chosenDate.month,
        "year": chosenDate.year,
        "intervals": chosenIntervals
      });

      try {
        var response = await http.post('$_serverAddress/$_currentAPI/appointment',
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

  Future<PatientSchedule> getAppointmentList() async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      List<ClientAppointment> _appointmentList = List<ClientAppointment>();
      List<DateTime> _dateTimeList = List<DateTime>();

      try {
        var response = await http.get('$_serverAddress/$_currentAPI/appointment/personal-appointments',
            headers: {'Authorization': "Bearer " + currentUserToken});

        if (response.statusCode == ServiceConstants.STATUS_SUCCESS_CODE) {
          dynamic _decodedBody = jsonDecode(response.body);

          int numberOfAppointments = _decodedBody['data']['appointments'].length;

          if (numberOfAppointments != 0) {
            ClientAppointment _head = ClientAppointment.fromJson(_decodedBody['data']['appointments'][0]);

            _appointmentList.add(_head);

            _dateTimeList.add(_head.getAppointmentDate);

            // Inserting appointments based on their date
            for (int i = 1; i < numberOfAppointments; i++) {
              ClientAppointment _curr = ClientAppointment.fromJson(_decodedBody['data']['appointments'][i]);

              if (!_dateTimeList.contains(_curr.getAppointmentDate)) _dateTimeList.add(_curr.getAppointmentDate);

              int index = 0;
              bool inserted = false;

              for (ClientAppointment _appointment in _appointmentList) {
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

            PatientSchedule _schedule = PatientSchedule(_appointmentList, _dateTimeList);

            return _schedule;
          } else {
            return PatientSchedule(_appointmentList, _dateTimeList);
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

  Future<bool> terminateAppointment(String appointmentID) async {
    final String currentUserToken = await getToken();

    if (currentUserToken != null) {
      final message = jsonEncode({"appointmentId": appointmentID});

      try {
        var response = await http.post('$_serverAddress/$_currentAPI/appointment/terminate',
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
}
