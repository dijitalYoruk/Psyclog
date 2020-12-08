import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/view_models/therapist/TherapistRegisteredListViewModel.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class TherapistSessionPage extends StatefulWidget {
  @override
  _TherapistSessionPageState createState() => _TherapistSessionPageState();
}

class _TherapistSessionPageState extends State<TherapistSessionPage> {
  TherapistRegisteredListViewModel _therapistRegisteredListViewModel;
  WebServerService _webServerService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _therapistRegisteredListViewModel = TherapistRegisteredListViewModel();
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
                begin: Alignment.topLeft,
                end: Alignment(10, 10),
                colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
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
                              child: Text("Clients",
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
                            ),
                          ],
                        ),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height / 12,
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
                                    "Pending Requests",
                                    style: GoogleFonts.lato(
                                        fontSize: 14, color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                  ),
                                  Icon(Icons.arrow_forward)
                                ],
                              ),
                              onPressed: () async {
                                Navigator.pushNamed(context, ViewConstants.therapistPendingRequestRoute);
                              },
                            ),
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
                  shadowColor: ViewConstants.myBlue,
                  color: ViewConstants.myWhite,
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Container(
                    padding: EdgeInsets.all(18),
                    height: MediaQuery.of(context).size.height / 8,
                    decoration: BoxDecoration(color: ViewConstants.myBlue.withOpacity(0.4)),
                    child: Center(
                      child: AutoSizeText(
                        "From the list below, you can find the registered clients for fast and efficient access to your notes.",
                        maxLines: 2,
                        minFontSize: 8,
                        maxFontSize: 20,
                        stepGranularity: 1,
                        style: GoogleFonts.lato(fontSize: 13, color: ViewConstants.myGrey),
                      ),
                    ),
                  ),
                ),
              ),
              ChangeNotifierProvider<TherapistRegisteredListViewModel>(
                create: (context) => _therapistRegisteredListViewModel,
                child: Consumer<TherapistRegisteredListViewModel>(
                  builder: (context, model, child) => SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: MediaQuery.of(context).size.width / 2,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        Patient patient = model.getPatientByIndex(index);

                        Widget profileImage;

                        if (patient.profileImageURL != null) {
                          try {
                            profileImage = Image.network(patient.profileImageURL + "/people/" + (index % 10).toString(),
                                fit: BoxFit.fill);
                          } catch (e) {
                            print(e);
                            profileImage = Icon(
                              Icons.person,
                              color: ViewConstants.myBlue,
                              size: 75,
                            );
                          }
                        } else {
                          profileImage = Icon(
                            Icons.person,
                            color: ViewConstants.myBlue,
                            size: 75,
                          );
                        }

                        return Card(
                            clipBehavior: Clip.hardEdge,
                            elevation: 2,
                            shadowColor: ViewConstants.myBlue,
                            color: ViewConstants.myWhite,
                            margin: EdgeInsets.only(left: index.isEven ? 20 : 10, right: index.isEven ? 10 : 20, bottom: 20),
                            child: Container(
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  profileImage,
                                  Container(
                                    decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                          ViewConstants.myBlue.withOpacity(0.3),
                                          ViewConstants.myBlack.withOpacity(0.6),
                                          ViewConstants.myBlack
                                        ])),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5.0),
                                          child: Text(patient.getFullName(),
                                              style: GoogleFonts.lato(fontSize: 16, color: ViewConstants.myWhite)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 3.0),
                                          child: Text("Contact",
                                              style: GoogleFonts.lato(fontSize: 12, color: ViewConstants.myYellow)),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 5.0),
                                          child: Text(patient.userEmail,
                                              style: GoogleFonts.lato(fontSize: 11, color: ViewConstants.myWhite)),
                                        ),
                                        LayoutBuilder(
                                          builder: (BuildContext context, BoxConstraints constraints) {
                                            return FlatButton(
                                              minWidth: constraints.maxWidth,
                                              onPressed: () {},
                                              child: Text("Client Notes",
                                                  style: GoogleFonts.lato(fontSize: 14, color: ViewConstants.myBlack)),
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              color: ViewConstants.myYellow,
                                              splashColor: ViewConstants.myYellow,
                                              shape: RoundedRectangleBorder(),
                                            );
                                          },
                                        )
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ));
                      },
                      childCount: model.getClientListLength(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
