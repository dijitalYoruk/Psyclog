class ServiceConstants {
  static const String ROLE_USER = "role_user";
  static const String ROLE_ADMIN = "role_admin";
  static const String ROLE_PSYCHOLOGIST = "role_psychologist";
  static const int STATUS_SUCCESS_CODE = 200;
  static String serverAddress = "http://192.168.1.36:8080";
  static String currentAPI = "api/v1";
}

class CalendarConstants {
  static List<CalendarInterval> intervals = [
    CalendarInterval(0, "10:00:00", "10:45:00"),
    CalendarInterval(1, "11:00:00", "11:45:00"),
    CalendarInterval(2, "12:00:00", "12:45:00"),
    CalendarInterval(3, "13:00:00", "13:45:00"),
    CalendarInterval(4, "14:00:00", "14:45:00"),
    CalendarInterval(5, "15:00:00", "15:45:00"),
    CalendarInterval(6, "16:00:00", "16:45:00"),
    CalendarInterval(7, "17:00:00", "17:45:00"),
    CalendarInterval(8, "18:00:00", "18:45:00"),
    CalendarInterval(9, "19:00:00", "19:45:00"),
    CalendarInterval(10, "20:00:00", "20:45:00"),
    CalendarInterval(11, "21:00:00", "21:45:00"),
    CalendarInterval(12, "22:00:00", "22:45:00"),
  ];

  static CalendarInterval getIntervalByIndex(int index) {
    return intervals.elementAt(index);
  }

  static List<CalendarInterval> getAppropriateIntervals(List<int> reservedIntervals, List<int> blockedIntervals) {
    List<CalendarInterval> appropriateIntervals = List<CalendarInterval>();

    for(CalendarInterval calendarInterval in intervals) {
      if(!reservedIntervals.contains(calendarInterval.interval) && !blockedIntervals.contains(calendarInterval.interval))
        appropriateIntervals.add(calendarInterval);
    }

    return appropriateIntervals;
  }
}

class CalendarInterval {
  final int interval;
  final String endTime;
  final String startTime;

  CalendarInterval(this.interval, this.endTime, this.startTime);
}
