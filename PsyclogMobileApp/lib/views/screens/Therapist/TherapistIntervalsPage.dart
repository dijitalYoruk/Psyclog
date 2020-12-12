import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyclog_app/service/TherapistServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/util/CapExtension.dart';

class TherapistIntervalsPage extends StatefulWidget {
  @override
  _TherapistIntervalsPageState createState() => _TherapistIntervalsPageState();
}

class _TherapistIntervalsPageState extends State<TherapistIntervalsPage> {
  TherapistServerService _therapistServerService;
  PageController _pageViewController;

  Map<String, List<int>> days;
  String _chosenDay;
  List<int> _chosenIntervals;
  List<int> _blockedIntervals;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _pageViewController = PageController(initialPage: 0);

    initializeService();

    days = Map<String, List<int>>();
    _chosenDay = "";
    _chosenIntervals = List<int>();
    _blockedIntervals = List<int>();
  }

  initializeService() async {
    _therapistServerService = await TherapistServerService.getTherapistServerService();
  }

  Future<bool> getBlockedDays(String chosenDay) async {
    if (_therapistServerService != null) {
      days = await _therapistServerService.getBlockedDays();
      if (days != null) {
        _chosenIntervals = days[chosenDay];
        _blockedIntervals = days[chosenDay];
        return true;
      } else
        return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
      controller: _pageViewController,
      physics: NeverScrollableScrollPhysics(),
      children: [
        Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            iconTheme: IconThemeData(color: ViewConstants.myBlack),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, false),
            ),
            title: Text(
              "Choose a Day",
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
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment(4, 4),
                          colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
                    ),
                    child: Builder(builder: (BuildContext context) {
                      List<String> weekdays = ["monday", "tuesday", "wednesday", "thursday", "friday"];

                      return SafeArea(
                          child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 40),
                              child: Column(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.6,
                                    child: StatefulBuilder(
                                      builder: (BuildContext context, void Function(void Function()) buttonSetState) {
                                        return ListView.builder(
                                          physics: BouncingScrollPhysics(),
                                          itemCount: weekdays.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Container(
                                              margin: EdgeInsets.symmetric(horizontal: 35, vertical: 10),
                                              child: LayoutBuilder(
                                                builder: (BuildContext context, BoxConstraints constraints) {
                                                  double elevation = _chosenDay == weekdays[index] ? 20 : 2;
                                                  Color buttonColor = _chosenDay == weekdays[index]
                                                      ? ViewConstants.myBlue.withOpacity(0.75)
                                                      : ViewConstants.myWhite;

                                                  return MaterialButton(
                                                    elevation: elevation,
                                                    child: Text(
                                                      weekdays[index].inCaps,
                                                      style: GoogleFonts.lato(
                                                          fontSize: 13,
                                                          color: ViewConstants.myBlack,
                                                          fontWeight: FontWeight.bold),
                                                    ),
                                                    minWidth: constraints.maxWidth,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                                    splashColor: ViewConstants.myBlue.withOpacity(0.5),
                                                    color: buttonColor,
                                                    onPressed: () {
                                                      buttonSetState(() {
                                                        _chosenDay = weekdays[index];
                                                        print(_chosenDay);
                                                      });
                                                    },
                                                  );
                                                },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 40),
                                    child: AutoSizeText(
                                      "You can choose a day above to block intervals for that day.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.lato(
                                          fontSize: 16, color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
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
                                                splashColor: ViewConstants.myBlue,
                                                color: ViewConstants.myBlue.withOpacity(0.25),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                onPressed: () async {
                                                  if (_chosenDay != "") {
                                                    bool isReceived = await getBlockedDays(_chosenDay);
                                                    if (isReceived) {
                                                      setState(() {
                                                        _pageViewController.animateToPage(
                                                            _pageViewController.page.toInt() + 1,
                                                            duration: Duration(milliseconds: 666),
                                                            curve: Curves.decelerate);
                                                      });
                                                    } else {
                                                      final snackBar = SnackBar(
                                                          content: Text('Choose a day from the list above.',
                                                              style: GoogleFonts.lato(color: ViewConstants.myGrey)));

                                                      Scaffold.of(context).showSnackBar(snackBar);
                                                    }
                                                  } else {
                                                    final snackBar = SnackBar(
                                                        content: Text('Please try again.',
                                                            style: GoogleFonts.lato(color: ViewConstants.myGrey)));

                                                    Scaffold.of(context).showSnackBar(snackBar);
                                                  }
                                                },
                                                child: Text(
                                                  "Continue",
                                                  style: GoogleFonts.lato(
                                                      fontSize: 16,
                                                      color: ViewConstants.myBlack,
                                                      fontWeight: FontWeight.bold),
                                                )),
                                          ),
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              )));
                    }),
                  ),
                ),
              ),
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
                  _blockedIntervals = List<int>();
                  setState(() {
                    _chosenDay = "";
                  });
                },
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              title: Text(
                "Daily Intervals",
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
                          colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
                    ),
                  ),
                ),
              ),
              SafeArea(
                  child: Column(children: [
                Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: _chosenDay != ""
                          ? AutoSizeText(
                              _chosenDay.inCaps,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack),
                              maxLines: 1,
                            )
                          : Container(),
                    )),
                Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemBuilder: (BuildContext context, int index) {
                      bool _applied = _blockedIntervals.contains(index);

                      CalendarInterval _interval = CalendarConstants.getIntervalByIndex(index);

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 10, horizontal: 35),
                        child: StatefulBuilder(
                          builder: (BuildContext context, void Function(void Function()) setState) {
                            return MaterialButton(
                              clipBehavior: Clip.hardEdge,
                              elevation: _applied ? 20 : 2,
                              padding: EdgeInsets.zero,
                              splashColor: ViewConstants.myYellow.withOpacity(0.5),
                              color: ViewConstants.myWhite,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              onPressed: () {
                                if (_applied) {
                                  _chosenIntervals.remove(index);
                                } else {
                                  _chosenIntervals.add(index);
                                }
                                print(_chosenIntervals);

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
                                              ? ViewConstants.myYellow.withOpacity(0.5)
                                              : ViewConstants.myBlue.withOpacity(0.4),
                                        ),
                                        child: AutoSizeText(
                                          "Session " + (index + 1).toString(),
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
                                                _interval.startTime.substring(0, 5),
                                                style: GoogleFonts.lato(
                                                    fontSize: 16,
                                                    color: ViewConstants.myBlue,
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
                                                _interval.endTime.substring(0, 5),
                                                style: GoogleFonts.lato(
                                                    fontSize: 16,
                                                    color: ViewConstants.myBlue,
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
                    itemCount: 13,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: AutoSizeText(
                          "Choose sessions to disable appointments at that time. Yellow sessions will be blocked whereas blue sessions will be open to reservation.",
                          style: GoogleFonts.lato(color: ViewConstants.myGrey, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                      ),
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
                              splashColor: ViewConstants.myBlue,
                              color: ViewConstants.myBlue.withOpacity(0.25),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              onPressed: () async {
                                setState(() {
                                  _pageViewController.animateToPage(_pageViewController.page.toInt() + 1,
                                      duration: Duration(milliseconds: 666), curve: Curves.decelerate);
                                });
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
                  await _pageViewController.animateToPage(_pageViewController.page.toInt() - 1,
                      duration: Duration(milliseconds: 666), curve: Curves.decelerate);
                },
              ),
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              title: Text(
                "Confirm Your Choices",
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
                          colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(
                          child: _chosenDay != ""
                              ? AutoSizeText(
                                  _chosenDay.inCaps,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myBlack),
                                  maxLines: 1,
                                )
                              : Container(),
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: Builder(
                        builder: (BuildContext context) {
                          _chosenIntervals.sort();

                          return ListView.builder(
                            physics: BouncingScrollPhysics(),
                            itemCount: _chosenIntervals.length,
                            itemBuilder: (BuildContext context, int index) {
                              CalendarInterval _interval = CalendarConstants.getIntervalByIndex(_chosenIntervals[index]);

                              return Card(
                                color: ViewConstants.myWhite,
                                margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                elevation: 4,
                                child: Container(
                                  child: Column(
                                    children: [
                                      LayoutBuilder(
                                        builder: (BuildContext context, BoxConstraints constraints) {
                                          return Container(
                                            padding: EdgeInsets.all(10),
                                            width: constraints.maxWidth,
                                            decoration: BoxDecoration(
                                              color: ViewConstants.myYellow.withOpacity(0.5),
                                            ),
                                            child: AutoSizeText(
                                              "Session " + (_chosenIntervals[index] + 1).toString(),
                                              style: GoogleFonts.lato(
                                                  color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
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
                                                      fontSize: 14,
                                                      color: ViewConstants.myBlack,
                                                      fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: AutoSizeText(
                                                    _interval.startTime.substring(0, 5),
                                                    style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        color: ViewConstants.myBlue,
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
                                                      fontSize: 14,
                                                      color: ViewConstants.myBlack,
                                                      fontWeight: FontWeight.bold),
                                                  textAlign: TextAlign.center,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(8.0),
                                                  child: AutoSizeText(
                                                    _interval.endTime.substring(0, 5),
                                                    style: GoogleFonts.lato(
                                                        fontSize: 16,
                                                        color: ViewConstants.myBlue,
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
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      child: Row(
                        children: [
                          Expanded(
                            child: AutoSizeText(
                              "The sessions chosen are shown above. If you confirm these sessions, they will be disabled for reservation.",
                              style: GoogleFonts.lato(color: ViewConstants.myGrey, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 3,
                            ),
                          ),
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
                                  splashColor: ViewConstants.myBlue,
                                  color: ViewConstants.myBlue.withOpacity(0.25),
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  onPressed: () async {
                                    int dayNumber;

                                    switch (_chosenDay) {
                                      case "monday":
                                        dayNumber = 1;
                                        break;
                                      case "tuesday":
                                        dayNumber = 2;
                                        break;
                                      case "wednesday":
                                        dayNumber = 3;
                                        break;
                                      case "thursday":
                                        dayNumber = 4;
                                        break;
                                      case "friday":
                                        dayNumber = 5;
                                        break;
                                    }
                                    bool isBlocked =
                                        await _therapistServerService.blockIntervals(_chosenIntervals, dayNumber);
                                    if (isBlocked) {
                                      Navigator.pop(context, true);
                                    } else {
                                      await _pageViewController.animateToPage(_pageViewController.initialPage,
                                          duration: Duration(milliseconds: 666), curve: Curves.decelerate);
                                      _chosenIntervals = List<int>();
                                      _blockedIntervals = List<int>();
                                      _chosenDay = "";
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
                  ],
                ),
              )
            ])),
      ],
    );
  }
}
