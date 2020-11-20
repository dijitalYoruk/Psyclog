class UserRestrict {
  static bool restrictAccessByGivenRoles(List<String> roles, String currentUser) {
    if (roles.contains(currentUser)) {
      return true;
    } else {
      return false;
    }
  }
}
