import 'package:psyclog_app/src/models/Request.dart';

import 'Patient.dart';

class PatientRequest extends Request {
  final Patient _patient;
  final String _content;
  final String _createdAt;
  final String _psychologistID;

  PatientRequest(String requestID, this._patient, this._content, this._createdAt, this._psychologistID) : super(requestID);

  get getPatient => _patient;
  get getContent => _content;
  get getCreationDate => _createdAt;
  get getPsychologistID => _psychologistID;
}
