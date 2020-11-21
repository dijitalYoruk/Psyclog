import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/view_models/therapist/TherapistAppointmentListViewModel.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class TherapistAppointmentPage extends StatefulWidget {
  @override
  _TherapistAppointmentPageState createState() => _TherapistAppointmentPageState();
}

class _TherapistAppointmentPageState extends State<TherapistAppointmentPage> {
  TherapistAppointmentListViewModel _appointmentListViewModel;

  List<Color> _cardBackgroundColors;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _appointmentListViewModel = TherapistAppointmentListViewModel();

    _cardBackgroundColors = [
      ViewConstants.myYellow,
      ViewConstants.myPink,
      ViewConstants.myBlue,
      ViewConstants.myLightBlue,
      ViewConstants.myLightGrey
    ];
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
                              child: CircleAvatar(
                                child: InkWell(
                                  onTap: () {
                                    Navigator.pushNamed(context, ViewConstants.therapistProfileRoute);
                                  },
                                ),
                                maxRadius: MediaQuery.of(context).size.height * 0.025,
                                backgroundImage:
                                    NetworkImage("https://avatarfiles.alphacoders.com/715/thumb-1920-71560.jpg"),
                              ),
                            )
                          ],
                        ),
                        Flexible(
                          child: Container(
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
                  builder: (context, model, child) => SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        Color _backgroundColor = _cardBackgroundColors.elementAt(index % _cardBackgroundColors.length);

                        return Card(
                          shadowColor: Colors.transparent,
                          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                          color: _backgroundColor.withOpacity(0.50),
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.18,
                            child: Row(
                              children: [
                                Container(
                                  color: _backgroundColor,
                                  width: MediaQuery.of(context).size.width / 30,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: 10,
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
