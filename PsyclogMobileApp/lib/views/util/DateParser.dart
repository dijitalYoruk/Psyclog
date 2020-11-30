class DateParser {
  static String monthToString(DateTime dateTime) {
    String result = dateTime.day.toString() + " ";

    switch (dateTime.month) {
      case 1:
        result += "January";
        break;
      case 2:
        result += "February";
        break;
      case 3:
        result += "March";
        break;
      case 4:
        result += "April";
        break;
      case 5:
        result += "May";
        break;
      case 6:
        result += "June";
        break;
      case 7:
        result += "July";
        break;
      case 8:
        result += "August";
        break;
      case 9:
        result += "September";
        break;
      case 10:
        result += "October";
        break;
      case 11:
        result += "November";
        break;
      case 12:
        result += "December";
        break;
    }

    return result + " " + dateTime.year.toString();
  }

  static DateTime jsonToDateTime(String jsonDateText) {
    List<String> jsonDateSubText = jsonDateText.split("-");

    DateTime _dateTime = DateTime(
        (int.parse(jsonDateSubText[0])), (int.parse(jsonDateSubText[1])), (int.parse(jsonDateSubText[2].substring(0, 2))));

    return _dateTime;
  }
}
