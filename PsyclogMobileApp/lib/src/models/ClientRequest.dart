import 'package:psyclog_app/src/models/Request.dart';

import 'Client.dart';

class ClientRequest extends Request {
  final Client _client;
  final String _content;
  final String _createdAt;
  final String _psychologistID;

  ClientRequest(String requestID, this._client, this._content, this._createdAt, this._psychologistID) : super(requestID);

  get getClient => _client;
  get getContent => _content;
  get getCreationDate => _createdAt;
  get getPsychologistID => _psychologistID;
}
