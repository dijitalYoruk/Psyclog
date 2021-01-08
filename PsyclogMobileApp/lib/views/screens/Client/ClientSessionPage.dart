import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
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
  TextEditingController _titleEditingController, _contentEditingController;
  int reviewRating;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reviewRating = 0;
    _titleEditingController = TextEditingController();
    _contentEditingController = TextEditingController();
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
                begin: Alignment.topLeft, end: Alignment(10, 10), colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
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
                            color: ViewConstants.myBlue.withOpacity(0.5),
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
                          Therapist _currentTherapist = model.getTherapistByIndex(index);

                          Widget profileImage;

                          if (_currentTherapist.profileImageURL != "") {
                            try {
                              profileImage = Image.network(_currentTherapist.profileImageURL, fit: BoxFit.fill);
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
                                  LayoutBuilder(
                                    builder: (BuildContext context, BoxConstraints constraints) {
                                      return Container(
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
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            FlatButton(
                                              onPressed: () async {
                                                bool isCreated = await showDialog(
                                                    barrierColor: Colors.transparent,
                                                    context: context,
                                                    builder: (BuildContext dialogContext) {
                                                      _titleEditingController.text = "";
                                                      _contentEditingController.text = "";
                                                      reviewRating = 3;

                                                      return AlertDialog(
                                                        contentPadding: EdgeInsets.zero,
                                                        backgroundColor: Colors.transparent,
                                                        content: SizedBox(
                                                          height: MediaQuery.of(context).size.height * 0.6,
                                                          width: MediaQuery.of(context).size.width * 0.8,
                                                          child: Container(
                                                            clipBehavior: Clip.hardEdge,
                                                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                                            decoration: BoxDecoration(
                                                                borderRadius: BorderRadius.circular(10),
                                                                gradient: LinearGradient(
                                                                    begin: Alignment.topLeft,
                                                                    end: Alignment(1, 1),
                                                                    colors: [ViewConstants.myGrey, ViewConstants.myBlack])),
                                                            child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                        vertical: 15.0, horizontal: 10),
                                                                    child: AutoSizeText(
                                                                      "After creating your review, it will be shown in their request page. (You can only submit one review.)",
                                                                      maxLines: 2,
                                                                      style: GoogleFonts.heebo(fontWeight: FontWeight.bold),
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                      color: ViewConstants.myWhite,
                                                                      borderRadius: BorderRadius.circular(10),
                                                                    ),
                                                                    child: TextField(
                                                                      decoration: InputDecoration(
                                                                        contentPadding: EdgeInsets.all(10.0),
                                                                        focusedBorder: InputBorder.none,
                                                                        enabledBorder: InputBorder.none,
                                                                        border: InputBorder.none,
                                                                        hintText: "Review Title",
                                                                        hintStyle: GoogleFonts.heebo(
                                                                            color: ViewConstants.myBlack.withOpacity(0.5)),
                                                                      ),
                                                                      controller: _titleEditingController,
                                                                      style: GoogleFonts.heebo(color: ViewConstants.myBlack),
                                                                      maxLines: 1,
                                                                    ),
                                                                  ),
                                                                  Divider(),
                                                                  Expanded(
                                                                    child: Container(
                                                                      decoration: BoxDecoration(
                                                                        color: ViewConstants.myWhite,
                                                                        borderRadius: BorderRadius.circular(10),
                                                                      ),
                                                                      child: TextField(
                                                                        decoration: InputDecoration(
                                                                          contentPadding: EdgeInsets.all(10.0),
                                                                          focusedBorder: InputBorder.none,
                                                                          enabledBorder: InputBorder.none,
                                                                          border: InputBorder.none,
                                                                          hintText: "Review Content",
                                                                          hintStyle: GoogleFonts.heebo(
                                                                              color: ViewConstants.myBlack.withOpacity(0.5)),
                                                                        ),
                                                                        controller: _contentEditingController,
                                                                        style:
                                                                            GoogleFonts.heebo(color: ViewConstants.myBlack),
                                                                        minLines: null,
                                                                        maxLines: null,
                                                                        expands: true,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.all(8.0),
                                                                    child: RatingBar.builder(
                                                                      initialRating: reviewRating.toDouble(),
                                                                      itemCount: 5,
                                                                      itemBuilder: (context, index) {
                                                                        switch (index) {
                                                                          case 0:
                                                                            return Icon(
                                                                              Icons.sentiment_very_dissatisfied,
                                                                              color: Colors.red,
                                                                            );
                                                                          case 1:
                                                                            return Icon(
                                                                              Icons.sentiment_dissatisfied,
                                                                              color: Colors.redAccent,
                                                                            );
                                                                          case 2:
                                                                            return Icon(
                                                                              Icons.sentiment_neutral,
                                                                              color: Colors.amber,
                                                                            );
                                                                          case 3:
                                                                            return Icon(
                                                                              Icons.sentiment_satisfied,
                                                                              color: Colors.lightGreen,
                                                                            );
                                                                          case 4:
                                                                            return Icon(
                                                                              Icons.sentiment_very_satisfied,
                                                                              color: Colors.green,
                                                                            );
                                                                          default:
                                                                            return Icon(Icons.sentiment_very_dissatisfied);
                                                                        }
                                                                      },
                                                                      onRatingUpdate: (rating) {
                                                                        reviewRating = rating.toInt();
                                                                        print(rating);
                                                                      },
                                                                    ),
                                                                  ),
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child: FlatButton(
                                                                          color: ViewConstants.myWhite,
                                                                          shape: RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(10)),
                                                                          onPressed: () async {
                                                                            bool isCreated =
                                                                                await _clientRegisteredListViewModel
                                                                                    .createReview(
                                                                                        _titleEditingController.text,
                                                                                        _contentEditingController.text,
                                                                                        5,
                                                                                        _currentTherapist.userID);
                                                                            Navigator.pop(context, isCreated);
                                                                          },
                                                                          child: Text(
                                                                            "Create",
                                                                            style: GoogleFonts.heebo(
                                                                                color: ViewConstants.myBlack,
                                                                                fontWeight: FontWeight.bold),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ]),
                                                          ),
                                                        ),
                                                        insetPadding: EdgeInsets.all(20),
                                                      );
                                                    });

                                                if (isCreated != null && isCreated == true) {
                                                  final snackBar = SnackBar(
                                                      content: Text('Review has been created successfully.',
                                                          style: GoogleFonts.lato(color: ViewConstants.myGrey)));

                                                  Scaffold.of(context).showSnackBar(snackBar);
                                                }

                                                if (isCreated != null && isCreated == false) {
                                                  final snackBar = SnackBar(
                                                      content: Text('You already reviewed this consultant.',
                                                          style: GoogleFonts.lato(color: ViewConstants.myGrey)));

                                                  Scaffold.of(context).showSnackBar(snackBar);
                                                }
                                              },
                                              child: Text("Create Review",
                                                  style: GoogleFonts.lato(fontSize: 14, color: ViewConstants.myWhite)),
                                              minWidth: constraints.minWidth,
                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                              color: ViewConstants.myYellow.withOpacity(0.5),
                                              splashColor: ViewConstants.myBlue,
                                              shape: RoundedRectangleBorder(),
                                            ),
                                            Spacer(),
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Text("Dr. " + _currentTherapist.getFullName(),
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
                                              child: Text(
                                                  "Price per Hour: " + _currentTherapist.appointmentPrice.toString() + " \$",
                                                  style: GoogleFonts.lato(
                                                      fontSize: 13, color: ViewConstants.myLightBlueTransparent)),
                                            ),
                                            FlatButton(
                                              onPressed: () async {
                                                bool isCreated = await Navigator.pushNamed(
                                                    context, ViewConstants.clientCreateAppointmentRoute,
                                                    arguments: CreateAppointmentScreenArguments(_currentTherapist)) as bool;

                                                if (isCreated != null && isCreated == true) {
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
                                              color: ViewConstants.myBlue.withOpacity(0.5),
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
