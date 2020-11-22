import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyclog_app/service/ClientServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientCreateAppointmentPage extends StatefulWidget {
  final Therapist therapist;

  ClientCreateAppointmentPage(this.therapist);

  @override
  _ClientCreateAppointmentPageState createState() => _ClientCreateAppointmentPageState();
}

class _ClientCreateAppointmentPageState extends State<ClientCreateAppointmentPage> {
  DateTime _currentDate;
  DateTime _chosenDate;
  PageController _pageViewController;
  ClientServerService _clientServerService;
  CalendarCarousel _calendarCarousel;
  List<CalendarInterval> _appropriateIntervals;
  List<int> _chosenIntervals;
  int _currentBalance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentDate = DateTime.now();
    _chosenDate = _currentDate;
    _pageViewController = PageController(initialPage: 0);
    _clientServerService = ClientServerService();
    _appropriateIntervals = List<CalendarInterval>();
    _chosenIntervals = List<int>();
  }

  Future<void> _getBalance() async {
    _currentBalance = await _clientServerService.getBalance();

    print("Your Balance: " + _currentBalance.toString());
  }

  Future<bool> _getDateStatus() async {
    if (_chosenDate != null && _chosenDate.weekday != 6 && _chosenDate.weekday != 7) {
      _appropriateIntervals = await _clientServerService.getDateStatus(
          widget.therapist.userID, _chosenDate.day, _chosenDate.month, _chosenDate.year);
      if (_appropriateIntervals != null || _appropriateIntervals.length != 0) {
        return true;
      } else {
        return false;
      }
    } else
      return false;
  }

  Future<bool> _createAppointment() async {
    bool isCreated = await _clientServerService.createAppointment(_chosenIntervals, _chosenDate, widget.therapist.userID);

    return isCreated;
  }

  CalendarCarousel<Event> buildCalendar() {

    _currentDate = DateTime.now();

    return CalendarCarousel<Event>(
      onDayPressed: (DateTime date, List<Event> events) {
        if (date.weekday != 6 && date.weekday != 7) this.setState(() => _chosenDate = date);
      },
      weekFormat: false,
      onDayLongPressed: (DateTime date) {},
      headerTextStyle: GoogleFonts.lato(fontSize: 24, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
      daysTextStyle: GoogleFonts.lato(fontSize: 13, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
      weekdayTextStyle: GoogleFonts.lato(fontSize: 13, color: ViewConstants.myGrey, fontWeight: FontWeight.bold),
      weekendTextStyle:
          GoogleFonts.lato(fontSize: 13, color: ViewConstants.myLightBlue.withOpacity(0.25), fontWeight: FontWeight.bold),
      inactiveDaysTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myGrey.withOpacity(0.25)),
      inactiveWeekendTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myLightBlue.withOpacity(0.25)),
      nextDaysTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myWhite.withOpacity(0.25)),
      prevDaysTextStyle: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myWhite.withOpacity(0.25)),
      headerMargin: EdgeInsets.only(bottom: 25),
      showHeaderButton: false,
      height: MediaQuery.of(context).size.height / 2,
      pageSnapping: false,
      selectedDateTime: _chosenDate.weekday != 6 && _chosenDate.weekday != 7 ? _chosenDate : null,
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
              ClipRect(
                child: BackdropFilter(
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
                                    bool nextPage = await _getDateStatus();

                                    if (nextPage) {
                                      setState(() {
                                        _pageViewController.animateToPage(_pageViewController.page.toInt() + 1,
                                            duration: Duration(milliseconds: 666), curve: Curves.decelerate);
                                      });
                                    }
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
                  await _pageViewController.animateToPage(_pageViewController.page.toInt() - 1,
                      duration: Duration(milliseconds: 666), curve: Curves.decelerate);
                  _chosenIntervals = List<int>();
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
              ClipRect(
                child: BackdropFilter(
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
              ),
              SafeArea(
                  child: Column(children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: AutoSizeText(
                        _chosenDate != null ? DateParser.monthToString(_chosenDate) : "No Date Chosen",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack),
                        maxLines: 1,
                      ),
                    )),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      CalendarInterval _currentInterval = _appropriateIntervals[index];

                      bool _applied = _chosenIntervals.contains(_currentInterval.interval);

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
                        child: StatefulBuilder(
                          builder: (BuildContext context, void Function(void Function()) setState) {
                            return MaterialButton(
                              clipBehavior: Clip.hardEdge,
                              elevation: _applied ? 20 : 2,
                              padding: EdgeInsets.zero,
                              splashColor: ViewConstants.myLightBlue.withOpacity(0.5),
                              color: ViewConstants.myWhite,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              onPressed: () {
                                if (_applied) {
                                  if (_chosenIntervals.contains(_currentInterval.interval + 1) &&
                                      _chosenIntervals.contains(_currentInterval.interval - 1)) {
                                    print("The session is between other intervals");
                                    return;
                                  } else {
                                    print("removed");
                                    _chosenIntervals.remove(_currentInterval.interval);
                                  }
                                } else {
                                  if ((_chosenIntervals.contains(_currentInterval.interval + 1) ||
                                          _chosenIntervals.contains(_currentInterval.interval - 1) ||
                                          _chosenIntervals.isEmpty) &&
                                      _chosenIntervals.length < 3) {
                                    print("added");
                                    _chosenIntervals.add(_currentInterval.interval);
                                  } else if (_chosenIntervals.length == 3) {
                                    print("Maximum 3 session can be reserved.");
                                    return;
                                  } else {
                                    print("The session is not adjacent to other sessions.");
                                    return;
                                  }
                                }
                                setState(() {
                                  _applied = !_applied;
                                });
                              },
                              child: Column(
                                children: [
                                  LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                      return Container(
                                        padding: EdgeInsets.all(10),
                                        width: constraints.maxWidth,
                                        decoration: BoxDecoration(
                                          color: _applied
                                              ? ViewConstants.myLightBlue.withOpacity(0.8)
                                              : ViewConstants.myLightBlue.withOpacity(0.4),
                                        ),
                                        child: AutoSizeText(
                                          "Session " + (_currentInterval.interval + 1).toString(),
                                          style: GoogleFonts.lato(color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    },
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Column(
                                          children: [
                                            AutoSizeText(
                                              "Beginning Time:",
                                              style: GoogleFonts.lato(
                                                  fontSize: 14, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: AutoSizeText(
                                                _currentInterval.startTime.substring(0, 5),
                                                style: GoogleFonts.lato(
                                                    fontSize: 16,
                                                    color: ViewConstants.myLightBlue,
                                                    fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            AutoSizeText(
                                              "End Time:",
                                              style: GoogleFonts.lato(
                                                  fontSize: 14, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                              textAlign: TextAlign.center,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: AutoSizeText(
                                                _currentInterval.endTime.substring(0, 5),
                                                style: GoogleFonts.lato(
                                                    fontSize: 16,
                                                    color: ViewConstants.myLightBlue,
                                                    fontWeight: FontWeight.bold),
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                    itemCount: _appropriateIntervals.length,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          "Choose one or sequential time intervals appropriate for you. We will schedule it for your personal appointment.",
                          style: GoogleFonts.lato(color: ViewConstants.myGrey, fontWeight: FontWeight.bold),
                          maxLines: 3,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.help,
                          color: ViewConstants.myGrey,
                        ),
                        onPressed: () {
                          showDialog(
                              barrierColor: Colors.transparent,
                              context: context,
                              builder: (context) => AlertDialog(
                                    backgroundColor: ViewConstants.myGrey.withOpacity(0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    contentPadding: EdgeInsets.all(10),
                                    content: Container(
                                      padding: EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              begin: Alignment.topLeft,
                                              end: Alignment(4, 4),
                                              colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
                                          borderRadius: BorderRadius.circular(20)),
                                      height: MediaQuery.of(context).size.height * 0.5,
                                      width: MediaQuery.of(context).size.width * 0.75,
                                      child: Column(children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Icon(
                                                  Icons.warning_rounded,
                                                  color: ViewConstants.myGrey,
                                                ),
                                              ),
                                              Expanded(
                                                  child: AutoSizeText(
                                                      "Maximum 3 Sessions can be reserved for one appointment",
                                                      maxLines: 3,
                                                      maxFontSize: 24,
                                                      style: GoogleFonts.lato(
                                                          color: ViewConstants.myGrey, fontWeight: FontWeight.bold)))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Icon(
                                                  Icons.warning_rounded,
                                                  color: ViewConstants.myGrey,
                                                ),
                                              ),
                                              Expanded(
                                                  child: AutoSizeText(
                                                      "Price for multiple session will be calculated based on PpH (Price per Hour)",
                                                      maxLines: 3,
                                                      maxFontSize: 24,
                                                      style: GoogleFonts.lato(
                                                          color: ViewConstants.myGrey, fontWeight: FontWeight.bold)))
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(right: 8.0),
                                                child: Icon(
                                                  Icons.warning_rounded,
                                                  color: ViewConstants.myGrey,
                                                ),
                                              ),
                                              Expanded(
                                                child: AutoSizeText(
                                                    "Multiple seasons must be reserved as sequential intervals",
                                                    maxLines: 3,
                                                    maxFontSize: 24,
                                                    style: GoogleFonts.lato(
                                                        color: ViewConstants.myGrey, fontWeight: FontWeight.bold)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ]),
                                    ),
                                    insetPadding: EdgeInsets.all(20),
                                  ));
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: FlatButton(
                              splashColor: ViewConstants.myLightBlue,
                              color: ViewConstants.myLightBlue.withOpacity(0.25),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onPressed: () async {
                                if (_chosenIntervals.isNotEmpty) {
                                  int _sessionPrice = (widget.therapist.appointmentPrice * _chosenIntervals.length);

                                  await _getBalance();

                                  if (_sessionPrice <= _currentBalance) {
                                    print("Balance is enough");

                                    setState(() {
                                      if (_chosenIntervals.length <= 3)
                                        setState(() {
                                          _pageViewController.animateToPage(_pageViewController.page.toInt() + 1,
                                              duration: Duration(milliseconds: 666), curve: Curves.decelerate);
                                        });
                                    });
                                  }
                                }
                              },
                              child: Text(
                                "Continue",
                                style: GoogleFonts.lato(
                                    fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                              )),
                        )
                      ],
                    ),
                  ),
                )
              ]))
            ])),
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
                },
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              title: Text(
                "Appointment Information",
                style: GoogleFonts.lato(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
            ),
            body: Stack(children: [
              ClipRect(
                child: BackdropFilter(
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
              ),
              SafeArea(
                child: ListView(
                  physics: BouncingScrollPhysics(),
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
                      height: MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment(10, 10),
                              colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
                          borderRadius: BorderRadius.circular(20)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                "Consultant: ",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
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
                              child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AutoSizeText(
                                "Date: ",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                    fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                maxLines: 1,
                              ),
                              AutoSizeText(
                                _chosenDate != null ? DateParser.monthToString(_chosenDate) : "No Date Chosen",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack),
                                maxLines: 1,
                              ),
                            ],
                          )),
                          Builder(
                            builder: (BuildContext context) {
                              _chosenIntervals.sort();

                              CalendarInterval startInterval = CalendarConstants.getIntervalByIndex(_chosenIntervals.first);
                              CalendarInterval endInterval = CalendarConstants.getIntervalByIndex(_chosenIntervals.last);

                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      AutoSizeText(
                                        "Beginning Time:",
                                        style: GoogleFonts.lato(
                                            fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: AutoSizeText(
                                          startInterval.startTime.toString().substring(0, 5),
                                          style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack),
                                          textAlign: TextAlign.center,
                                        ),
                                      )
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      AutoSizeText(
                                        "End Time:",
                                        style: GoogleFonts.lato(
                                            fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                        textAlign: TextAlign.center,
                                        maxFontSize: 16,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: AutoSizeText(
                                          endInterval.endTime.toString().substring(0, 5),
                                          style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack),
                                          textAlign: TextAlign.center,
                                          maxFontSize: 16,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    "Price per Hour: ",
                                    style: GoogleFonts.lato(
                                        fontSize: 14, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxFontSize: 16,
                                  ),
                                  AutoSizeText(
                                    (widget.therapist.appointmentPrice).toString() + " \$",
                                    style: GoogleFonts.lato(fontSize: 14, color: ViewConstants.myBlack),
                                    textAlign: TextAlign.center,
                                    maxFontSize: 16,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
                                child: AutoSizeText(
                                  "Since your appointment consist of " + _chosenIntervals.length.toString() + " session(s)",
                                  style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack),
                                  textAlign: TextAlign.center,
                                  maxFontSize: 16,
                                  maxLines: 1,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AutoSizeText(
                                    "Appointment Price: ",
                                    style: GoogleFonts.lato(
                                        fontSize: 18, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                    maxFontSize: 18,
                                  ),
                                  AutoSizeText(
                                    (widget.therapist.appointmentPrice * _chosenIntervals.length).toString() + " \$",
                                    style: GoogleFonts.lato(fontSize: 18, color: ViewConstants.myBlack),
                                    textAlign: TextAlign.center,
                                    maxFontSize: 18,
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(20),
                      margin: EdgeInsets.symmetric(horizontal: 35),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment(10, 10),
                              colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AutoSizeText(
                            "Your Balance: ",
                            style: GoogleFonts.lato(fontSize: 18, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                            maxFontSize: 18,
                          ),
                          AutoSizeText(
                            _currentBalance.toString() + " \$",
                            style: GoogleFonts.lato(fontSize: 18, color: ViewConstants.myBlack),
                            textAlign: TextAlign.center,
                            maxFontSize: 18,
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 35, vertical: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: FlatButton(
                                splashColor: ViewConstants.myLightBlue,
                                color: ViewConstants.myLightBlue.withOpacity(0.25),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                onPressed: () async {
                                  bool isCreated = await _createAppointment();

                                  if (isCreated) {
                                    Navigator.pop(context, true);
                                  } else {
                                    await _pageViewController.animateToPage(_pageViewController.initialPage,
                                        duration: Duration(milliseconds: 666), curve: Curves.decelerate);
                                    _chosenIntervals = List<int>();
                                  }
                                },
                                child: Text(
                                  "Continue",
                                  style: GoogleFonts.lato(
                                      fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              )
            ])),
      ],
    );
  }
}
