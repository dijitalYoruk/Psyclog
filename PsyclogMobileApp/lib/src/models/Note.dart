import 'package:psyclog_app/views/util/DateParser.dart';

class Note {
  final String _noteID;
  final String _therapistID;
  final String _patientID;
  final String _content;
  final DateTime _createdAt;
  final DateTime _updatedAt;

  Note.fromJson(Map<String, dynamic> json)
      : _noteID = json['_id'] as String,
        _therapistID = json['psychologist'] as String,
        _patientID = json['patient'] as String,
        _content = json['content'] as String,
        _createdAt = DateParser.jsonToDateTime(json['createdAt']),
        _updatedAt = DateParser.jsonToDateTime(json['updatedAt']);

  get getNoteID => _noteID;
  get getTherapistID => _therapistID;
  get getPatientID => _patientID;
  get getContent => _content;
  get getCreatedAt => _createdAt;
  get getUpdatedAt => _updatedAt;
}