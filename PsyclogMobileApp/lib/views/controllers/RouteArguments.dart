import 'package:psyclog_app/src/models/Therapist.dart';

class TherapistRequestScreenArguments {
  final Therapist therapist;
  final bool currentUserApplied;
  final String therapistArea;

  TherapistRequestScreenArguments(this.therapist, this.currentUserApplied, this.therapistArea);
}

class CreateAppointmentScreenArguments {
  final Therapist therapist;

  CreateAppointmentScreenArguments(this.therapist);
}