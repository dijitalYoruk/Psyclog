import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyclog_app/service/ClientServerService.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientCreateAppointmentPage extends StatefulWidget {
  final Therapist therapist;

  ClientCreateAppointmentPage(this.therapist);

  @override
  _ClientCreateAppointmentPageState createState() => _ClientCreateAppointmentPageState();
}

class _ClientCreateAppointmentPageState extends State<ClientCreateAppointmentPage> {
  DateTime _currentDate;
  CalendarCarousel _calendarCarousel;
  PageController _pageViewController;
  ClientServerService _clientServerService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentDate = DateTime.now();
    _pageViewController = PageController(initialPage: 0);
    _clientServerService = ClientServerService();
  }

  Future<bool> getDateStatus() async {
    if (_currentDate != null) {
      await _clientServerService.getDateStatus(
          widget.therapist.userID, _currentDate.day, _currentDate.month, _currentDate.year);
      return true;
    } else
      return false;
  }

  String dateParser(DateTime dateTime) {
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

  CalendarCarousel<Event> buildCalendar() {
    return CalendarCarousel<Event>(
      onDayPressed: (DateTime date, List<Event> events) {
        this.setState(() => _currentDate = date);
      },
      weekFormat: false,
      onDayLongPressed: (DateTime date) {},
      headerTextStyle: GoogleFonts.lato(fontSize: 24, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
      daysTextStyle: GoogleFonts.lato(fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
      weekdayTextStyle: GoogleFonts.lato(fontSize: 13, color: ViewConstants.myGrey, fontWeight: FontWeight.bold),
      weekendTextStyle: GoogleFonts.lato(fontSize: 13, color: ViewConstants.myLightBlue, fontWeight: FontWeight.bold),
      inactiveDaysTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myGrey.withOpacity(0.25)),
      inactiveWeekendTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myGrey.withOpacity(0.25)),
      nextDaysTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myWhite.withOpacity(0.25)),
      prevDaysTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myWhite.withOpacity(0.25)),
      headerMargin: EdgeInsets.only(bottom: 25),
      showHeaderButton: false,
      height: MediaQuery.of(context).size.height / 2,
      pageSnapping: false,
      selectedDateTime: _currentDate,
      daysHaveCircularBorder: true,
      pageScrollPhysics: BouncingScrollPhysics(),
      customGridViewPhysics: NeverScrollableScrollPhysics(),
      minSelectedDate: _currentDate.subtract(Duration(days: 1)),
      maxSelectedDate: _currentDate.add(Duration(days: 120)),
      todayButtonColor: ViewConstants.myGrey,
      todayTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
      todayBorderColor: Colors.transparent,
      selectedDayButtonColor: ViewConstants.myLightBlue.withOpacity(0.25),
      selectedDayTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
      selectedDayBorderColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    _calendarCarousel = buildCalendar();

    return PageView(
      physics: NeverScrollableScrollPhysics(),
      pageSnapping: true,
      controller: _pageViewController,
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: IconThemeData(color: ViewConstants.myBlack),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            title: Text(
              "Appointment Day",
              style: GoogleFonts.lato(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
          ),
          body: Stack(
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(4, 4),
                        colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AutoSizeText(
                              "Consultant: ",
                              textAlign: TextAlign.center,
                              style:
                                  GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                            AutoSizeText(
                              widget.therapist.getFullName(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack),
                              maxLines: 1,
                            ),
                          ],
                        )),
                    Container(
                      padding: EdgeInsets.only(left: 20, right: 20, top: 10),
                      margin: EdgeInsets.symmetric(vertical: 15, horizontal: 35),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment(10, 10),
                              colors: [ViewConstants.myWhite, ViewConstants.myLightBlue])),
                      child: _calendarCarousel,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: AutoSizeText(
                        "Pick a time for your appointment and let us check its intervals for you.",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                        maxLines: 2,
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 35),
                              child: FlatButton(
                                  splashColor: ViewConstants.myLightBlue,
                                  color: ViewConstants.myLightBlue.withOpacity(0.25),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  onPressed: () async {

                                    await getDateStatus();

                                    _pageViewController.animateToPage(_pageViewController.page.toInt() + 1,
                                        duration: Duration(milliseconds: 666), curve: Curves.decelerate);
                                  },
                                  child: Text(
                                    "Continue",
                                    style: GoogleFonts.lato(
                                        fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                  )),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              iconTheme: IconThemeData(color: ViewConstants.myBlack),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () async {
                  _pageViewController.animateToPage(_pageViewController.page.toInt() - 1,
                      duration: Duration(milliseconds: 666), curve: Curves.decelerate);

                  _currentDate = DateTime.now();
                  setState(() {});
                },
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              title: Text(
                "Appointment Time",
                style: GoogleFonts.lato(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: Stack(children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment(4, 4),
                        colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
                  ),
                ),
              ),
              SafeArea(
                  child: Column(children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: AutoSizeText(
                        dateParser(_currentDate),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack),
                        maxLines: 1,
                      ),
                    ))
              ]))
            ]))
      ],
    );
  }
}
