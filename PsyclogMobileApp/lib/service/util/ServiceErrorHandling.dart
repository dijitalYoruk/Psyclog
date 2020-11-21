class ServiceErrorHandling {
  static const String successfulStatusCode = "200";
  static const String unsuccessfulStatusCode = "Failed Attempt. Try Again.";
  static const String userInformationError = "User Information could not be stored.";
  static const String serverNotRespondingError = "The server is not responding.";
  static const String tokenEmptyError = "User Token is Empty.";
  static const String tokenWrongError = "User Token is Wrong/Corrupt.";
  static const String listNotRetrievedError = "Therapist List could not be retrieved.";
  static const String couldNotSignUpError = "The Sign Up failed.";
  static const String userRestrictionError = "You have no rights to retrieve such information.";
  static const String noTokenError = "No token is stored in the current application.";
  static const String noRoleError = "Given role does not exists.";
  static const String couldNotCreateRequestError = "The request failed. Try later again.";
}
