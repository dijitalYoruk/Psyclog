import 'package:flutter/material.dart';
import 'package:psyclog_app/service/SocketService.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/Therapist.dart';

class ClientMessageListViewModel extends ChangeNotifier {
  Patient currentUser;
  List<Therapist> therapistList = List<Therapist>();
  // List<Message> messages = List<Message>();
  SocketService _socketService;

  ClientMessageListViewModel() {
    _socketService = SocketService();
    _socketService.createSocketConnection();

    initializeTherapistList();
  }

  initializeTherapistList() async {}
}
