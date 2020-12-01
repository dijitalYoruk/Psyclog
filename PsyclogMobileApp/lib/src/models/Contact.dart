import 'package:psyclog_app/src/models/Message.dart';

class Contact {
  final String _chatID;
  final String _psychologistID;
  final String _patientID;
  final String username;
  final String firstName;
  final String profileImage;
  final String createdAt;
  final String updatedAt;
  Message lastMessage;
  bool isActive;

  get getChatID => _chatID;
  get getPsychologistID => _psychologistID;
  get getPatientID => _patientID;

  Contact(this._chatID, this.isActive, this._psychologistID, this.username, this.firstName, this.profileImage,
      this._patientID, this.createdAt, this.updatedAt, this.lastMessage);
}
