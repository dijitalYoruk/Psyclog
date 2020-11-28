import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:psyclog_app/src/models/Appointment.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/view_models/client/ClientAppointmentListViewModel.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:intl/intl.dart';

class ClientAppointmentPage extends StatefulWidget {
  @override
  _ClientAppointmentPageState createState() => _ClientAppointmentPageState();
}

class _ClientAppointmentPageState extends State<ClientAppointmentPage> {
  ClientAppointmentListViewModel _appointmentListViewModel;
  WebServerService _webServerService;

  List<Color> _cardBackgroundColors;

  ScrollController _scrollController;

  final ValueNotifier<double> _scrollOffset = ValueNotifier<double>(0);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _appointmentListViewModel = ClientAppointmentListViewModel();

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

    Patient patient = _webServerService.currentUser;

    if (patient != null && patient.profileImageURL != null) {
      try {
        profileImage = Image.network(patient.profileImageURL, fit: BoxFit.fill);
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
                expandedHeight: MediaQuery.of(context).size.height * 0.18,
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
                            Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: FutureBuilder(
                                future: getProfileImage(),
                                initialData: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, ViewConstants.clientProfileRoute);
                                  },
                                  child: Icon(
                                    Icons.person,
                                    color: ViewConstants.myGrey,
                                  ),
                                ),
                                builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                                  if (snapshot.data is Image) {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(context, ViewConstants.clientProfileRoute);
                                      },
                                      child: CircleAvatar(
                                        backgroundImage: (snapshot.data as Image).image,
                                      ),
                                    );
                                  } else {
                                    return InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(context, ViewConstants.clientProfileRoute);
                                      },
                                      child: Icon(
                                        Icons.person,
                                        color: ViewConstants.myGrey,
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 12,
                          margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                          child: FlatButton(
                            color: ViewConstants.myBlue.withOpacity(0.75),
                            splashColor: ViewConstants.myYellow,
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
                        )
                      ],
                    ),
                    stretchModes: [
                      StretchMode.zoomBackground,
                    ],
                  ),
                ),
              ),
              ChangeNotifierProvider<ClientAppointmentListViewModel>(
                create: (context) => _appointmentListViewModel,
                child: Consumer<ClientAppointmentListViewModel>(
                  builder: (context, model, child) {
                    int _dateLength = model.getDateTimeListLength();

                    if (_dateLength != 0) {
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
                          Appointment _currentAppointment = model.getAppointmentByIndex(_appointmentIndex);
                          if (_currentAppointment.getAppointmentDate == _dateTime) {
                            Color _backgroundColor = _cardBackgroundColors.elementAt(_dateIndex % 5);

                            _schedule.add(ValueListenableBuilder(
                              child: Builder(
                                builder: (BuildContext context) {
                                  Therapist _currentTherapist = _currentAppointment.getTherapist;

                                  CalendarInterval startTime = CalendarConstants.getIntervalByIndex(
                                      (_currentAppointment.getIntervals as List<int>).first);
                                  CalendarInterval endTime = CalendarConstants.getIntervalByIndex(
                                      (_currentAppointment.getIntervals as List<int>).last);

                                  Widget profileImage;

                                  if (_currentTherapist.profileImageURL != "") {
                                    try {
                                      profileImage = Image.network(
                                          _currentTherapist.profileImageURL +
                                              "/people/" +
                                              (_appointmentIndex % 10).toString(),
                                          fit: BoxFit.fill);
                                    } catch (e) {
                                      print(e);
                                      profileImage = Icon(
                                        Icons.person,
                                        color: ViewConstants.myLightBlue,
                                        size: 75,
                                      );
                                    }
                                  } else {
                                    profileImage = Icon(
                                      Icons.person,
                                      color: ViewConstants.myLightBlue,
                                      size: 75,
                                    );
                                  }

                                  return Container(
                                    child: Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Opacity(
                                                opacity: 0.75,
                                                child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
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
                                                    )),
                                              ),
                                              AutoSizeText(
                                                _currentTherapist.getFullName(),
                                                style: GoogleFonts.lato(
                                                    color: ViewConstants.myGrey, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                            children: [
                                              AutoSizeText(
                                                startTime.startTime.substring(0, 5) +
                                                    " - " +
                                                    endTime.endTime.substring(0, 5),
                                                style: GoogleFonts.lato(
                                                    color: ViewConstants.myGrey, fontWeight: FontWeight.bold, fontSize: 15),
                                              ),
                                            ],
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
                                double width = MediaQuery.of(context).size.width;

                                return Container(
                                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  height: height * 0.25,
                                  child: Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      shadowColor: Colors.transparent,
                                      color: _backgroundColor.withRed(_colorValue.toInt()).withOpacity(0.3),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: width / 30,
                                            color: _backgroundColor.withRed(_colorValue.toInt()).withOpacity(0.5),
                                          ),
                                          VerticalDivider(
                                            color: _backgroundColor.withRed(_colorValue.toInt()).withOpacity(0.5),
                                            thickness: 3,
                                            width: 10,
                                          ),
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
                    } else {
                      return SliverToBoxAdapter(
                        child: CircularProgressIndicator(),
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
