import 'package:psyclog_app/src/models/Client.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/src/models/User.dart';

class UserModelController {
  static User createUserFromJSON(dynamic decodedBody) {
    try {
      var user = User.fromJson(decodedBody);
      return user;
    }
    catch (e) {
      print(e);
      throw Exception("");
    }
  }

  static Client createClientFromJSON(dynamic decodedBody) {
    try {
      var client = Client.fromJson(decodedBody);
      return client;
    }
    catch (e) {
      print(e);
      throw Exception("");
    }
  }

  static Client createClientFromJSONForToken(dynamic decodedBody) {
    try {
      var client = Client.fromJsonForToken(decodedBody);
      return client;
    }
    catch (e) {
      print(e);
      throw Exception("");
    }
  }

  static Therapist createTherapistFromJSON(dynamic decodedBody) {
    try {
      var therapist = Therapist.fromJson(decodedBody);
      return therapist;
    }
    catch (e) {
      print(e);
      throw Exception("");
    }
  }

  static Therapist createTherapistFromJSONForList(dynamic decodedBody) {
    try {
      var therapist = Therapist.fromJsonForList(decodedBody);
      return therapist;
    }
    catch (e) {
      print(e);
      throw Exception("");
    }
  }

  static Therapist createTherapistFromJSONForToken(dynamic decodedBody) {
    try {
      var therapist = Therapist.fromJsonForList(decodedBody);
      return therapist;
    }
    catch (e) {
      print(e);
      throw Exception("");
    }
  }
}
