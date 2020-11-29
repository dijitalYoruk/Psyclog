import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/src/models/TherapistAppointment.dart';
import 'package:psyclog_app/view_models/therapist/TherapistAppointmentListViewModel.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class TherapistAppointmentPage extends StatefulWidget {
  @override
  _TherapistAppointmentPageState createState() => _TherapistAppointmentPageState();
}

class _TherapistAppointmentPageState extends State<TherapistAppointmentPage> {
  TherapistAppointmentListViewModel _appointmentListViewModel;
  WebServerService _webServerService;

  List<Color> _cardBackgroundColors;

  ScrollController _scrollController;

  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _appointmentListViewModel = TherapistAppointmentListViewModel();

    _scrollController = ScrollController();

    _scrollController.addListener(() {
      _scrollOffset.value = _scrollController.offset;
    });

    _cardBackgroundColors = [
      ViewConstants.myYellow,
      ViewConstants.myPink,
      ViewConstants.myBlue,
      ViewConstants.myLightBlue,
      ViewConstants.myLightGrey
    ];
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<Widget> getProfileImage() async {
    Widget profileImage;

    _webServerService = await WebServerService.getWebServerService();

    //_webServerService.checkUserByCurrentToken();

    Therapist therapist = _webServerService.currentUser;

    if (therapist != null && therapist.profileImageURL != "") {
      try {
        profileImage = Image.network(therapist.profileImageURL, fit: BoxFit.fill);
        return profileImage;
      } catch (e) {
        print(e);
        return Icon(Icons.person);
      }
    } else {
      return Icon(Icons.person);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft, end: Alignment(5, 5), colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
          ),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: MediaQuery.of(context).size.height * 0.28,
                pinned: false,
                stretch: true,
                automaticallyImplyLeading: false,
                backgroundColor: Colors.transparent,
                iconTheme: IconThemeData(
                  color: ViewConstants.myBlack,
                ),
                flexibleSpace: SafeArea(
                  child: FlexibleSpaceBar(
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: Text("Appointments",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(fontSize: 30, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                            ),
                            Flexible(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                ),
                                child: FutureBuilder(
                                  future: getProfileImage(),
                                  initialData: Icon(
                                    Icons.person,
                                    color: ViewConstants.myGrey,
                                  ),
                                  builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                                    if (snapshot.data is Image) {
                                      return InkWell(
                                        onTap: () {
                                          Navigator.pushNamed(context, ViewConstants.therapistProfileRoute);
                                        },
                                        child: CircleAvatar(
                                          backgroundImage: (snapshot.data as Image).image,
                                        ),
                                      );
                                    } else {
                                      return Icon(
                                        Icons.person,
                                        color: ViewConstants.myGrey,
                                      );
                                    }
                                  },
                                ),
                              ),
                            )
                          ],
                        ),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.075,
                            margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                            child: FlatButton(
                              color: ViewConstants.myBlue.withOpacity(0.75),
                              splashColor: ViewConstants.myPink,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Appointment History",
                                    style: TextStyle(
                                        color: ViewConstants.myWhite,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "OpenSans",
                                        fontSize: 13),
                                  ),
                                  Icon(Icons.arrow_forward)
                                ],
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height * 0.075,
                            margin: EdgeInsets.only(top: 10, right: 20, left: 20),
                            child: FlatButton(
                              color: ViewConstants.myPink.withOpacity(0.75),
                              splashColor: ViewConstants.myBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Blocked Intervals",
                                    style: TextStyle(
                                        color: ViewConstants.myWhite,
                                        fontWeight: FontWeight.w700,
                                        fontFamily: "OpenSans",
                                        fontSize: 13),
                                  ),
                                  Icon(Icons.arrow_forward)
                                ],
                              ),
                              onPressed: () async {
                                bool isBlocked = await Navigator.pushNamed(context, ViewConstants.therapistIntervalRoute) as bool;

                                if (isBlocked) {
                                  final snackBar = SnackBar(
                                      content: Text('Blocked intervals are saved successfully.',
                                          style: GoogleFonts.lato(color: ViewConstants.myGrey)));

                                  Scaffold.of(context).showSnackBar(snackBar);
                                }
                              },
                            ),
                          ),
                        )
                      ],
                    ),
                    stretchModes: [
                      StretchMode.zoomBackground,
                    ],
                  ),
                ),
              ),
              ChangeNotifierProvider<TherapistAppointmentListViewModel>(
                create: (context) => _appointmentListViewModel,
                child: Consumer<TherapistAppointmentListViewModel>(
                  builder: (context, model, child) {
                    int _dateLength = model.getDateTimeListLength();

                    if (_dateLength > 0) {
                      List<Widget> _schedule = List<Widget>();

                      int _dateIndex = 0;
                      int _appointmentIndex = 0;

                      DateTime _dateTime;

                      int _appointmentLength = model.getAppointmentListLength();

                      while (_dateIndex < _dateLength) {
                        _dateTime = model.getDateTimeByIndex(_dateIndex);

                        _schedule.add(Container(
                            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
                            child: Text(
                              DateParser.monthToString(_dateTime),
                              style: GoogleFonts.lato(
                                  color: ViewConstants.myBlue.withOpacity(0.5), fontWeight: FontWeight.bold),
                            )));

                        while (_appointmentIndex < _appointmentLength) {
                          int index = _appointmentIndex;

                          TherapistAppointment _currentAppointment = model.getAppointmentByIndex(index);
                          if (_currentAppointment.getAppointmentDate == _dateTime) {
                            Color _backgroundColor = _cardBackgroundColors.elementAt(_dateIndex % 5);

                            Patient _currentPatient = _currentAppointment.getPatient;

                            List<int> intervals = _currentAppointment.getIntervals;

                            CalendarInterval startTime = CalendarConstants.getIntervalByIndex(intervals.first);
                            CalendarInterval endTime = CalendarConstants.getIntervalByIndex(intervals.last);

                            int appointmentLength = intervals.length;

                            Widget profileImage;

                            if (_currentPatient.profileImageURL != null) {
                              try {
                                profileImage = Image.network(
                                    _currentPatient.profileImageURL + "/people/" + (_appointmentIndex % 10).toString(),
                                    fit: BoxFit.fill);
                              } catch (e) {
                                print(e);
                                profileImage = Icon(
                                  Icons.person,
                                  color: ViewConstants.myWhite,
                                  size: 50,
                                );
                              }
                            } else {
                              profileImage = Icon(
                                Icons.person,
                                color: ViewConstants.myWhite,
                                size: 50,
                              );
                            }

                            _schedule.add(ValueListenableBuilder(
                              child: Builder(
                                builder: (BuildContext builderContext) {
                                  return Container(
                                    child: Expanded(
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                AutoSizeText(
                                                  "Time: " +
                                                      startTime.startTime.substring(0, 5) +
                                                      " - " +
                                                      endTime.endTime.substring(0, 5) +
                                                      " (~$appointmentLength hour)",
                                                  style: GoogleFonts.lato(
                                                      color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                                  maxFontSize: 16,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            child: Divider(
                                              color: ViewConstants.myWhite.withOpacity(0.4),
                                              thickness: 2,
                                            ),
                                          ),
                                          Container(
                                            child: Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                child: Row(
                                                  children: [
                                                    Opacity(
                                                      opacity: 0.75,
                                                      child: Builder(
                                                        builder: (BuildContext context) {
                                                          if (profileImage is Image) {
                                                            return CircleAvatar(
                                                              backgroundImage: profileImage.image,
                                                            );
                                                          } else {
                                                            return profileImage;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                    Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                                          child: AutoSizeText(
                                                            _currentPatient.getFullName(),
                                                            style: GoogleFonts.lato(
                                                                color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                                            maxFontSize: 16,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                                          child: AutoSizeText(
                                                            _currentPatient.userEmail,
                                                            style: GoogleFonts.lato(
                                                                color: ViewConstants.myWhite.withOpacity(0.75)),
                                                            maxFontSize: 13,
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                    Spacer(),
                                                    IconButton(
                                                      splashRadius: 25,
                                                      splashColor: Colors.transparent,
                                                      icon: Icon(Icons.chat),
                                                      onPressed: () {},
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            child: Divider(
                                              color: ViewConstants.myWhite.withOpacity(0.4),
                                              thickness: 2,
                                            ),
                                          ),
                                          Builder(
                                            builder: (BuildContext builderContext) {
                                              int startUnixTime = _currentAppointment.getStartTime;
                                              int endUnixTime = _currentAppointment.getEndTime;

                                              int currentUnixTime = DateTime.now().toUtc().millisecondsSinceEpoch;

                                              List<Widget> buttons = [];

                                              if (currentUnixTime < endUnixTime && currentUnixTime > startUnixTime) {
                                                buttons.add(Expanded(
                                                  child: FlatButton(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    onPressed: () {},
                                                    child: AutoSizeText(
                                                      "Join",
                                                      style: GoogleFonts.lato(
                                                          color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                                      maxFontSize: 13,
                                                    ),
                                                  ),
                                                ));
                                              }

                                              if (currentUnixTime < startUnixTime) {
                                                buttons.add(Expanded(
                                                  child: FlatButton(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    onPressed: () {

                                                    },
                                                    child: AutoSizeText(
                                                      "Update",
                                                      style: GoogleFonts.lato(
                                                          color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                                      maxFontSize: 13,
                                                    ),
                                                  ),
                                                ));
                                                buttons.add(Expanded(
                                                  child: FlatButton(
                                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                    onPressed: () async {
                                                      await showDialog(
                                                          barrierColor: Colors.transparent,
                                                          context: context,
                                                          builder: (BuildContext dialogContext) {
                                                            return AlertDialog(
                                                              backgroundColor: Colors.transparent,
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(20),
                                                              ),
                                                              contentPadding: EdgeInsets.all(20),
                                                              content: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Container(
                                                                    padding: EdgeInsets.all(15),
                                                                    decoration: BoxDecoration(
                                                                        border: Border.all(
                                                                            color: ViewConstants.myBlue.withOpacity(0.5),
                                                                            width: 5),
                                                                        gradient: LinearGradient(
                                                                            begin: Alignment.topLeft,
                                                                            end: Alignment(4, 4),
                                                                            colors: [
                                                                              ViewConstants.myWhite,
                                                                              ViewConstants.myBlue
                                                                            ]),
                                                                        borderRadius: BorderRadius.circular(20)),
                                                                    child: Column(children: [
                                                                      Text("Do you want to cancel this appointment?",
                                                                          style:
                                                                              GoogleFonts.lato(color: ViewConstants.myGrey)),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 12.0),
                                                                        child: Row(
                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            FlatButton(
                                                                                shape: RoundedRectangleBorder(
                                                                                    side: BorderSide(
                                                                                        color: ViewConstants.myBlue
                                                                                            .withOpacity(0.5),
                                                                                        width: 2),
                                                                                    borderRadius: BorderRadius.circular(10)),
                                                                                onPressed: () async {
                                                                                  bool isCancelled = await model
                                                                                      .cancelAppointmentByIndex(index);

                                                                                  if (isCancelled) {
                                                                                    Navigator.pop(context);

                                                                                    final snackBar = SnackBar(
                                                                                        content: Text(
                                                                                            'Appointment is cancelled.',
                                                                                            style: GoogleFonts.lato(
                                                                                                color:
                                                                                                    ViewConstants.myGrey)));

                                                                                    Scaffold.of(context)
                                                                                        .showSnackBar(snackBar);
                                                                                  }
                                                                                },
                                                                                child: Text("Cancel",
                                                                                    style: GoogleFonts.lato(
                                                                                        color: ViewConstants.myBlue,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14))),
                                                                            FlatButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                child: Text("Return",
                                                                                    style: GoogleFonts.lato(
                                                                                        color: ViewConstants.myGrey,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        fontSize: 14))),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ]),
                                                                  ),
                                                                ],
                                                              ),
                                                              insetPadding: EdgeInsets.all(20),
                                                            );
                                                          });
                                                    },
                                                    child: AutoSizeText(
                                                      "Cancel",
                                                      style: GoogleFonts.lato(
                                                          color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                                      maxFontSize: 13,
                                                    ),
                                                  ),
                                                ));
                                              }

                                              return Container(
                                                width: MediaQuery.of(context).size.width,
                                                child: Row(
                                                  children: buttons,
                                                ),
                                              );
                                            },
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                              builder: (context, value, child) {
                                double _colorValue;
                                double _changeLength = 3;
                                double _div = value / (255 * _changeLength);

                                if (_div.toInt().isEven) {
                                  _colorValue = (value / _changeLength).abs() % 255;
                                } else {
                                  _colorValue = 255 - (value / _changeLength) % 255;
                                }

                                double height = MediaQuery.of(context).size.height;

                                Color _redAppliedColor = _backgroundColor.withBlue(_colorValue.toInt());

                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  height: height * 0.25,
                                  decoration: BoxDecoration(
                                    color: _redAppliedColor.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      shadowColor: Colors.transparent,
                                      color: ViewConstants.myBlue.withOpacity(0.7),
                                      child: Column(
                                        children: [
                                          child,
                                        ],
                                      )),
                                );
                              },
                              valueListenable: _scrollOffset,
                            ));
                            _appointmentIndex++;
                          } else {
                            break;
                          }
                        }
                        _dateIndex++;
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _schedule[index];
                          },
                          childCount: _schedule.length,
                        ),
                      );
                    } else if (_dateLength == 0) {
                      return SliverToBoxAdapter(
                        child: Container(),
                      );
                    } else {
                      return SliverToBoxAdapter(
                        child: Container(
                          width: MediaQuery.of(context).size.width / 3,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                  },
                ),
              )
            ],
          ),
        ));
  }
}
