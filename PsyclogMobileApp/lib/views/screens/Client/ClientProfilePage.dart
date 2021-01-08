import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientProfilePage extends StatefulWidget {
  @override
  _ClientProfilePageState createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> with TickerProviderStateMixin {
  WebServerService _webServerService;
  Patient _currentUser;
  PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(initialPage: 0);
    // TODO: implement initState
    super.initState();
  }

  Future<Widget> getProfileImage() async {
    Widget profileImage;

    _webServerService = await WebServerService.getWebServerService();

    //_webServerService.checkUserByCurrentToken();

    _currentUser = _webServerService.currentUser;

    if (_currentUser != null && _currentUser.profileImageURL != null) {
      try {
        profileImage = Image.network(_currentUser.profileImageURL, fit: BoxFit.fill);
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
  void dispose() {
    _pageController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: ViewConstants.myWhite,
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          Container(
            color: ViewConstants.myGrey.withOpacity(0.05),
            child: ListView(
              children: [
                SafeArea(
                  top: true,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.only(top: 10, bottom: 10),
                      width: MediaQuery.of(context).size.width / 3,
                      child: Image.asset(
                        "assets/PSYCLOG_black_text.png",
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text("Your Profile",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Text("Client Account",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontSize: 16, color: ViewConstants.myBlack.withOpacity(0.5), fontWeight: FontWeight.bold)),
                ),
                Container(
                  color: ViewConstants.myWhite,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: FutureBuilder(
                    future: getProfileImage(),
                    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          margin: EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                      margin: EdgeInsets.symmetric(vertical: 15),
                                      clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: ViewConstants.myBlack),
                                      child: SizedBox(height: 75, child: snapshot.data as Widget)),
                                  Container(
                                    margin: EdgeInsets.symmetric(horizontal: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            AutoSizeText(
                                              _currentUser.getFullName(),
                                              style: GoogleFonts.heebo(
                                                  color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                              minFontSize: 20,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0),
                                              child: AutoSizeText(
                                                "@" + _currentUser.userUsername,
                                                style: GoogleFonts.heebo(color: ViewConstants.myBlack),
                                                minFontSize: 15,
                                              ),
                                            ),
                                          ],
                                        ),
                                        AutoSizeText(
                                          _currentUser.userEmail,
                                          style: GoogleFonts.heebo(color: ViewConstants.myBlack),
                                          minFontSize: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Card(
                                color: ViewConstants.myBlue.withOpacity(0.75),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      AutoSizeText(
                                        "Phone Number: ",
                                        style: GoogleFonts.heebo(color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                        minFontSize: 14,
                                      ),
                                      AutoSizeText(
                                        _currentUser.phoneNumber,
                                        style: GoogleFonts.heebo(color: ViewConstants.myWhite),
                                        minFontSize: 14,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Card(
                                color: ViewConstants.myBlue.withOpacity(0.75),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      AutoSizeText(
                                        "You are with us since ",
                                        style: GoogleFonts.heebo(color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                        minFontSize: 14,
                                      ),
                                      AutoSizeText(
                                        DateParser.monthToString(DateParser.jsonToDateTime(_currentUser.userCreationDate)) +
                                            " !",
                                        style: GoogleFonts.heebo(color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                        minFontSize: 14,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: FlatButton(
                                  onPressed: () {
                                    _pageController.animateToPage(1,
                                        duration: Duration(milliseconds: 300), curve: Curves.decelerate);
                                  },
                                  child: AutoSizeText(
                                    "Edit Information",
                                    style: GoogleFonts.heebo(color: ViewConstants.myBlack, fontWeight: FontWeight.bold),
                                    minFontSize: 14,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  child: Text("Other Settings",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                ),
                Container(
                  color: ViewConstants.myWhite,
                  margin: EdgeInsets.symmetric(vertical: 15),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: ViewConstants.myBlue,
                                size: 30,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: AutoSizeText(
                                "My Wallet",
                                style: GoogleFonts.muli(color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                minFontSize: 16,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.arrow_forward,
                                color: ViewConstants.myBlack,
                              ),
                              onPressed: () {
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: ViewConstants.myGrey.withOpacity(0.2),
                          thickness: 1.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Icon(
                                Icons.support_agent,
                                color: ViewConstants.myYellow,
                                size: 30,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: AutoSizeText(
                                "Support",
                                style: GoogleFonts.muli(color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                minFontSize: 16,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.arrow_forward,
                                color: ViewConstants.myBlack,
                              ),
                              onPressed: () {
                              },
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Divider(
                          color: ViewConstants.myGrey.withOpacity(0.2),
                          thickness: 1.5,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Icon(
                                Icons.exit_to_app,
                                color: ViewConstants.myPink,
                                size: 30,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: AutoSizeText(
                                "Log Out",
                                style: GoogleFonts.muli(color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                minFontSize: 16,
                              ),
                            ),
                            Spacer(),
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                Icons.arrow_forward,
                                color: ViewConstants.myBlack,
                              ),
                              onPressed: () {
                              },
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
          Container(
            child: Container(
              color: ViewConstants.myGrey.withOpacity(0.05),
              child: ListView(
                children: [
                  SafeArea(
                    top: true,
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        width: MediaQuery.of(context).size.width / 3,
                        child: Image.asset(
                          "assets/PSYCLOG_black_text.png",
                          fit: BoxFit.fitWidth,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text("Edit Information",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text("Client Account",
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 16,
                                    color: ViewConstants.myBlack.withOpacity(0.5),
                                    fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: ViewConstants.myBlack,
                        ),
                        onPressed: () {
                          _pageController.animateToPage(0, duration: Duration(milliseconds: 300), curve: Curves.decelerate);
                        },
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
