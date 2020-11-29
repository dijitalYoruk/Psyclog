import 'package:psyclog_app/src/models/User.dart';
import 'package:psyclog_app/views/util/CapExtension.dart';

class Patient extends User {
  final List<dynamic> _registeredPsychologistIDs;
  final int _cash;

  get clientRegisteredPsychologists => _registeredPsychologistIDs;
  get currentBalance => _cash;

  Patient.fromJson(Map<String, dynamic> parsedJson)
      : _registeredPsychologistIDs = parsedJson["data"]["user"]["registeredPsychologists"] as List<dynamic>,
        _cash = parsedJson["data"]["user"]["cash"] as int,
        super.fromJson(parsedJson);

  Patient.fromJsonForToken(Map<String, dynamic> parsedJson)
      : _registeredPsychologistIDs = parsedJson["data"]["profile"]["registeredPsychologists"] as List<dynamic>,
        _cash = parsedJson["data"]["profile"]["cash"] as int,
        super.fromJsonForToken(parsedJson);

  Patient.fromJsonForList(Map<String, dynamic> parsedJson)
      : _registeredPsychologistIDs = parsedJson["registeredPsychologists"] as List<dynamic>,
        _cash = parsedJson["cash"] as int,
        super.fromJsonForList(parsedJson);

  Patient.fromJsonForAppointment(Map<String, dynamic> parsedJson)
      : _registeredPsychologistIDs = null,
        _cash = null,
        super.fromJsonForAppointment(parsedJson);

  String getFullName() {
    return userFirstName.toString().inCaps + " " + userSurname.toString().inCaps;
  }
}
