import 'package:psyclog_app/src/models/Request.dart';

import 'Client.dart';

class ClientRequest extends Request {

  final Client _client;

  ClientRequest(String requestID, this._client) : super(requestID);

}