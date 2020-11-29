import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/view_models/client/ClientRegisteredListViewModel.dart';
import 'package:psyclog_app/views/controllers/RouteArguments.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientSessionPage extends StatefulWidget {
  @override
  _ClientSessionPageState createState() => _ClientSessionPageState();
}

class _ClientSessionPageState extends State<ClientSessionPage> {
  ClientRegisteredListViewModel _clientRegisteredListViewModel;
  WebServerService _webServerService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _clientRegisteredListViewModel = ClientRegisteredListViewModel();
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
    return Stack(
      children: [
        ClipRect(
          child: BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment(10, 10),
                colors: [ViewConstants.myWhite, ViewConstants.myLightBlue]),
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
                              child: Text("Consultants",
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
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 12,
                          margin: EdgeInsets.only(top: 20, right: 20, left: 20),
                          child: FlatButton(
                            color: ViewConstants.myLightBlue.withOpacity(0.75),
                            splashColor: ViewConstants.myPink,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Pending Requests",
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
                              await Navigator.pushNamed(context, ViewConstants.clientPendingRequestRoute);
                              _clientRegisteredListViewModel.initializeService();
                            },
                          ),
                        ),
                      ],
                    ),
                    stretchModes: [
                      StretchMode.zoomBackground,
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Card(
                  elevation: 4,
                  shadowColor: ViewConstants.myLightBlue,
                  color: ViewConstants.myWhite,
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Container(
                    padding: EdgeInsets.all(18),
                    height: MediaQuery.of(context).size.height / 8,
                    decoration: BoxDecoration(color: ViewConstants.myLightBlue.withOpacity(0.4)),
                    child: Center(
                      child: AutoSizeText(
                        "From the list below, you can find the registered therapists for fast and efficient consultation.",
                        maxLines: 2,
                        minFontSize: 8,
                        maxFontSize: 20,
                        stepGranularity: 1,
                        style: GoogleFonts.lato(color: ViewConstants.myGrey),
                      ),
                    ),
                  ),
                ),
              ),
              ChangeNotifierProvider<ClientRegisteredListViewModel>(
                create: (context) => _clientRegisteredListViewModel,
                child: Consumer<ClientRegisteredListViewModel>(
                  builder: (context, model, child) => SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        int listLength = model.getTherapistListLength();

                        if (index == listLength) {
                          return Card(
                            color: ViewConstants.myLightBlue.withOpacity(0.5),
                            margin: EdgeInsets.only(left: index.isEven ? 20 : 10, right: index.isEven ? 10 : 20, bottom: 20),
                            child: FlatButton(
                              splashColor: ViewConstants.myBlack,
                              onPressed: () {
                                // TODO Send to Psychologist Search List
                              },
                              child: Icon(
                                Icons.add,
                                color: ViewConstants.myWhite,
                              ),
                            ),
                          );
                        } else {
                          Therapist therapist = model.getTherapistByIndex(index);

                          Widget profileImage;

                          if (therapist.profileImageURL != "") {
                            try {
                              profileImage = Image.network(therapist.profileImageURL + "/people/" + (index % 10).toString(),
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

                          return Card(
                            clipBehavior: Clip.hardEdge,
                            elevation: 2,
                            shadowColor: ViewConstants.myLightBlue,
                            color: ViewConstants.myWhite,
                            margin: EdgeInsets.only(left: index.isEven ? 20 : 10, right: index.isEven ? 10 : 20, bottom: 20),
                            child: Container(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  profileImage,
                                  LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                      return Container(
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                              ViewConstants.myLightBlue.withOpacity(0.3),
                                              ViewConstants.myBlack.withOpacity(0.6),
                                              ViewConstants.myBlack
                                            ])),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Text("Dr. " + therapist.getFullName(),
                                                  textAlign: TextAlign.center,
                                                  style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myWhite)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Text("Family and Marriage",
                                                  style: GoogleFonts.lato(fontSize: 13, color: ViewConstants.myYellow)),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Text("Price per Hour: " + therapist.appointmentPrice.toString() + " \$",
                                                  style: GoogleFonts.lato(
                                                      fontSize: 13, color: ViewConstants.myLightBlueTransparent)),
                                            ),
                                            FlatButton(
                                              onPressed: () async {
                                                bool isCreated = await Navigator.pushNamed(
                                                    context, ViewConstants.clientCreateAppointmentRoute,
                                                    arguments: CreateAppointmentScreenArguments(therapist)) as bool;

                                                if (isCreated) {
                                                  final snackBar = SnackBar(
                                                      content: Text('Appointment has been created successfully.',
                                                          style: GoogleFonts.lato(color: ViewConstants.myGrey)));

                                                  Scaffold.of(context).showSnackBar(snackBar);
                                                }
                                              },
                                              child: Text("Get Appointment",
                                                  style: GoogleFonts.lato(fontSize: 14, color: ViewConstants.myWhite)),
                                              minWidth: constraints.minWidth,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              color: ViewConstants.myLightBlue.withOpacity(0.5),
                                              splashColor: ViewConstants.myYellow,
                                              shape: RoundedRectangleBorder(),
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      },
                      childCount: model.getTherapistListLength() + 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
