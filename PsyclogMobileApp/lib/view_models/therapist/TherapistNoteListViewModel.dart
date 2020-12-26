import 'package:flutter/material.dart';
import 'package:psyclog_app/service/TherapistServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Note.dart';
import 'package:psyclog_app/src/models/Patient.dart';

class TherapistNoteListViewModel extends ChangeNotifier {
  TherapistServerService _serverService;

  List<Note> _noteList;

  Patient _currentPatient;

  TherapistNoteListViewModel(Patient patient) {
    _noteList = List<Note>();

    _currentPatient = patient;

    initializeService();
  }

  Note getNoteByIndex(int index) {
    return _noteList[index];
  }

  int getNoteListLength() {
    if (_noteList.isNotEmpty)
      return _noteList.length;
    else
      return 0;
  }

  initializeService() async {
    if (_serverService == null) _serverService = await TherapistServerService.getTherapistServerService();

    try {
      _noteList = await _serverService.getNoteList(_currentPatient.userID);

      if (_noteList.isNotEmpty) {
        print("Notes are fetched successfully.");
        notifyListeners();
      } else {
        print("Note List is empty.");
        notifyListeners();
      }
    } catch (error) {
      print(error);
      print(ServiceErrorHandling.serverNotRespondingError);
    }
  }

  Future<bool> createNote(String content) async {
    if (content != null) {
      bool isCreated = await _serverService.createNote(content, _currentPatient.userID);

      if (isCreated) {
        initializeService();
        notifyListeners();
      }

      return isCreated;
    } else
      return false;
  }

  updateNoteByIndex(int index, String content) async {
    if (index != null) {
      bool isUpdated = await _serverService.updateNote(getNoteByIndex(index).getNoteID, content);

      if (isUpdated) {
        initializeService();
        notifyListeners();
      }

      return isUpdated;
    } else
      return false;
  }

  deleteNoteByIndex(int index) async {
    if (index != null) {
      bool isDeleted = await _serverService.deleteNote(getNoteByIndex(index).getNoteID);

      if (isDeleted) {
        initializeService();
        notifyListeners();
      }

      return isDeleted;
    } else
      return false;
  }
}
