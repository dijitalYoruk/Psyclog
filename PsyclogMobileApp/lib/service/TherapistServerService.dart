import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';

class TherapistServerService extends WebServerService {
  static String _serverAddress;
  static TherapistServerService _therapistServerService;
  static FlutterSecureStorage _secureStorage;
  static String _currentAPI;

  get currentTherapist => super.currentUser;

  static Future<TherapistServerService> getClientServerService() async {

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
}