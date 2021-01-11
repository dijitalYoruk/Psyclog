import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inner_drawer/inner_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyclog_app/service/ClientServerService.dart';
import 'package:psyclog_app/service/SocketService.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/src/models/User.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class InnerDrawerWithScreen extends StatefulWidget {
  final Widget scaffoldArea;

  const InnerDrawerWithScreen({Key key, @required this.scaffoldArea}) : super(key: key);

  @override
  _InnerDrawerWithScreenState createState() => _InnerDrawerWithScreenState();
}

class _InnerDrawerWithScreenState extends State<InnerDrawerWithScreen> {
  WebServerService _webServerService;
  User _currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<bool> initializeService() async {
    _webServerService = await WebServerService.getWebServerService();
    _currentUser = _webServerService.currentUser;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return InnerDrawer(
        onTapClose: true, // default false
        swipe: true, // default true
        tapScaffoldEnabled: false,
        // TODO Boolean Value "false" is bugged, it rebuilds the scaffold, discards its state, waiting for update or fix
        //When setting the vertical offset, be sure to use only top or bottom
        offset: IDOffset.only(bottom: 0.05, right: 0.0, left: 0.0),
        scale: IDOffset.horizontal(0.80), // set the offset in both directions
        proportionalChildArea: true, // default true
        borderRadius: 25, // default 0
        leftAnimationType: InnerDrawerAnimation.quadratic, // default static
        backgroundDecoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1, -1),
            end: Alignment(1, 1),
            colors: <Color>[
              ViewConstants.myBlue.withOpacity(1),
              ViewConstants.myBlack.withOpacity(1),
            ],
          ),
        ), // default  Theme.of(context).backgroundColor
        //when a pointer that is in contact with the screen and moves to the right or left
        leftChild: Material(
            color: Colors.transparent,
            child: SafeArea(
                right: false,
                left: false,
                child: Container(
                  padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
                  color: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            width: MediaQuery.of(context).size.width / 3,
                            child: Image.asset(
                              "assets/PSYCLOG_white_text.png",
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                      FutureBuilder(
                        future: initializeService(),
                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment(3, 3),
                                    colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: ViewConstants.myBlue,
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage: Image.network(_currentUser.profileImageURL, fit: BoxFit.fill).image,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: AutoSizeText(
                                      _currentUser.getFullName(),
                                      style: GoogleFonts.muli(color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                      ListTile(
                        title: Text("Homepage"),
                        leading: Icon(Icons.home),
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, ViewConstants.homeRoute, ((Route<dynamic> route) => false));
                        },
                      ),
                      ListTile(
                        title: Text("Profile"),
                        leading: Icon(Icons.person),
                        onTap: () {
                          if (_webServerService.currentUser is Patient) {
                            Navigator.pushReplacementNamed(context, ViewConstants.clientProfileRoute);
                          } else if (_webServerService.currentUser is Therapist) {
                            Navigator.pushReplacementNamed(context, ViewConstants.therapistProfileRoute);
                          }
                        },
                      ),
                      ListTile(
                        title: Text("Wallet"),
                        leading: Icon(Icons.monetization_on),
                        onTap: () {
                          if (_webServerService.currentUser is Patient) {
                            Navigator.pushReplacementNamed(context, ViewConstants.clientWalletRoute);
                          } else if (_webServerService.currentUser is Therapist) {
                            Navigator.pushReplacementNamed(context, ViewConstants.therapistWalletRoute);
                          }
                        },
                      ),
                      Spacer(),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: ListTile(
                          title: Text("Log Out"),
                          leading: Icon(Icons.arrow_back_ios),
                          onTap: () {
                            ClientServerService.getClientServerService().then((value) {
                              value.clearAllInfo();
                              SocketService.disposeService();
                              Navigator.pushNamedAndRemoveUntil(
                                  context, ViewConstants.welcomeRoute, (Route<dynamic> route) => false);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 15,
                      )
                    ],
                  ),
                ))), // required if rightChild is not set
        //  A Scaffold is generally used but you are free to use other widgets
        // Note: use "automaticallyImplyLeading: false" if you do not personalize "leading" of Bar
        scaffold: widget.scaffoldArea);
  }
}
