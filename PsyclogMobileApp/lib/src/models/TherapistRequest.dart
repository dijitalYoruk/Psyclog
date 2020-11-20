import 'package:psyclog_app/src/models/Request.dart';

import 'Therapist.dart';

class TherapistRequest extends Request {
  final Therapist _therapist;

  TherapistRequest(String requestID, this._therapist) : super(requestID);

  get getTherapist => _therapist;
}
