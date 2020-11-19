import 'package:flutter/material.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/User.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/util/CapExtension.dart';

class ClientProfilePage extends StatefulWidget {
  @override
  _ClientProfilePageState createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage>
    with TickerProviderStateMixin {
  WebServerService _serverService;
  User _currentUser;
  Future<bool> _futureData;
  TabController _profileTabController;
  PageController _profilePageController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureData = _setService();
    _profileTabController = TabController(length: 2, vsync: this);
    _profilePageController = PageController(initialPage: 0);
  }

  Future<bool> _setService() async {
    bool result;

    print("Starting services for Profile Page...");

    try {
      _serverService = await WebServerService.getWebServerService();
      result = true;
    } catch (e) {
      print("Exception:" + e.toString());
      result = false;
    }
    return result;
  }

  Future<bool> _setCurrentUser() async {
    try {
      _currentUser = _serverService.currentUser;

      print("Welcome, " + _currentUser.userFirstName + " !");

      if (_currentUser != null) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Current User cannot be created. Exception: " + e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return PageView(
      physics: PageScrollPhysics(),
      pageSnapping: true,
      controller: _profilePageController,
      children: [
        FutureBuilder(
            future: _futureData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Scaffold(
                  backgroundColor: ViewConstants.myWhite,
                  body: CustomScrollView(
                    physics: BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverAppBar(
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        stretch: true,
                        floating: false,
                        backgroundColor: Colors.transparent,
                        expandedHeight:
                            MediaQuery.of(context).size.height * 0.4,
                        flexibleSpace: FlexibleSpaceBar(
                          collapseMode: CollapseMode.pin,
                          stretchModes: [StretchMode.zoomBackground],
                          background: Container(
                            margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            height: MediaQuery.of(context).size.height * 0.4,
                            decoration: BoxDecoration(
                              color: ViewConstants.myWhite,
                              boxShadow: [
                                BoxShadow(
                                  color: ViewConstants.myBlack.withOpacity(0.3),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: FutureBuilder(
                              future: _setCurrentUser(),
                              builder: (context, snapshot) {
                                if (snapshot.data == true) {
                                  return SafeArea(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Card(
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              clipBehavior: Clip.antiAlias,
                                              margin: EdgeInsets.all(15),
                                              child: SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.12,
                                                child: Image.network(
                                                  "https://avatarfiles.alphacoders.com/715/thumb-1920-71560.jpg",
                                                  fit: BoxFit.scaleDown,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              _currentUser.userFirstName
                                                      .toString()
                                                      .inCaps +
                                                  " " +
                                                  _currentUser.userSurname
                                                      .toString()
                                                      .inCaps,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: ViewConstants.myBlack,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "OpenSans",
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: Text(
                                                _currentUser.userEmail,
                                                style: TextStyle(
                                                    color:
                                                        ViewConstants.myBlack,
                                                    fontWeight: FontWeight.w700,
                                                    fontFamily: "OpenSans",
                                                    fontSize: 12),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Align(
                                          alignment:
                                              FractionalOffset.bottomCenter,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Expanded(
                                                    child: MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10))),
                                                  elevation: 0,
                                                  focusElevation: 0,
                                                  highlightElevation: 0,
                                                  hoverElevation: 0,
                                                  splashColor:
                                                      ViewConstants.myLightBlue,
                                                  color: ViewConstants.myBlack,
                                                  padding: EdgeInsets.zero,
                                                  child: Text(
                                                    "My Stories",
                                                    style: TextStyle(
                                                        color: ViewConstants
                                                            .myWhite,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontFamily: "OpenSans",
                                                        fontSize: 12),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _profileTabController
                                                          .index = 0;
                                                    });
                                                  },
                                                )),
                                                Expanded(
                                                    child: MaterialButton(
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                              topRight: Radius
                                                                  .circular(10),
                                                              bottomRight:
                                                                  Radius
                                                                      .circular(
                                                                          10))),
                                                  elevation: 0,
                                                  focusElevation: 0,
                                                  highlightElevation: 0,
                                                  hoverElevation: 0,
                                                  splashColor:
                                                      ViewConstants.myLightBlue,
                                                  color: ViewConstants.myBlack,
                                                  padding: EdgeInsets.zero,
                                                  child: Text(
                                                    "My Therapists",
                                                    style: TextStyle(
                                                        color: ViewConstants
                                                            .myWhite,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontFamily: "OpenSans",
                                                        fontSize: 12),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _profileTabController
                                                          .index = 1;
                                                    });
                                                  },
                                                )),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: CircularProgressIndicator(),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
        Container(
          color: ViewConstants.myWhite,
        )
      ],
    );
  }
}
