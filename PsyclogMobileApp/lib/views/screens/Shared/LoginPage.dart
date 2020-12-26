import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final UnfocusDisposition disposition = UnfocusDisposition.scope;

  // Keyboard animation
  KeyboardVisibilityNotification _keyboardVisibility = KeyboardVisibilityNotification();
  int _keyboardVisibilitySubscriberId;
  bool _keyboardState;
  Alignment childAlignment = Alignment.center;
  //***End**

  // Web Server Service
  WebServerService _serverService;
  //***End***

  // Future boolean value to check the completion of service
  Future<bool> _futureData;
  //***End***

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _futureData = _setService();

    _keyboardState = _keyboardVisibility.isKeyboardVisible;

    _keyboardVisibilitySubscriberId = _keyboardVisibility.addNewListener(
      onChange: (bool visible) {
        setState(() {
          print("Keyboard: $visible");
          _keyboardState = visible;
          childAlignment = visible ? Alignment.topCenter : Alignment.center;
        });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _keyboardVisibility.removeListener(_keyboardVisibilitySubscriberId);
  }

  Future<bool> _setService() async {
    print("Starting services for Login Page...");
    try {
      _serverService = await WebServerService.getWebServerService();
      return true;
    } catch (e) {
      print("Exception:" + e.toString());
      return false;
    }
  }

  Future<void> _login(BuildContext context) async {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    final String result = await _serverService.attemptLogin(username, password);

    if (result == ServiceErrorHandling.successfulStatusCode) {
      Navigator.pushNamedAndRemoveUntil(context, ViewConstants.homeRoute, (Route<dynamic> route) => false);
    } else {
      final snackBar = SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          behavior: SnackBarBehavior.floating,
          content: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(result),
          ));
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: ViewConstants.myBlack,
      body: FutureBuilder(
        initialData: false,
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Stack(
              children: [
                Container(
                  color: Colors.transparent,
                  height: MediaQuery.of(context).size.height,
                  child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
                    SafeArea(
                      top: true,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: EdgeInsets.only(top: 25),
                          width: MediaQuery.of(context).size.width * 0.45,
                          child: Image.asset("assets/PSYCLOG_white_text.png", fit: BoxFit.fitWidth),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.15,
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Container(
                                  margin: EdgeInsets.only(bottom: 15),
                                  width: constraints.maxWidth * 0.75,
                                  height: constraints.maxHeight / 3,
                                  child: Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: ViewConstants.myWhite,
                                    child: MaterialButton(
                                      padding: EdgeInsets.zero,
                                      minWidth: constraints.maxWidth * 0.75,
                                      height: constraints.maxHeight / 3,
                                      onPressed: () {
                                        primaryFocus.unfocus(disposition: disposition);
                                        _login(context);
                                      },
                                      child: Text("Log in",
                                          textAlign: TextAlign.center,
                                          style: ViewConstants.fieldStyle.copyWith(
                                              fontSize: 18, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    primaryFocus.unfocus(disposition: disposition);
                                    Navigator.pushNamed(context, ViewConstants.registerRoute);
                                  },
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 20.0),
                                    child: SafeArea(
                                      top: false,
                                      bottom: true,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("You don't have an account?",
                                              style: TextStyle(
                                                  fontSize: 12, color: ViewConstants.myWhite, fontWeight: FontWeight.w400)),
                                          Text("\t\tSign up here",
                                              style: TextStyle(
                                                  fontSize: 12, color: ViewConstants.myWhite, fontWeight: FontWeight.w900)),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ]);
                            },
                          ),
                        ),
                      ),
                    ),
                  ]),
                ),
                Container(
                  padding: EdgeInsets.only(top: MediaQuery.of(context).size.height / 10),
                  color: Colors.transparent,
                  height: MediaQuery.of(context).size.height * 0.85,
                  child: AnimatedContainer(
                    curve: Curves.fastOutSlowIn,
                    duration: Duration(
                      milliseconds: 666,
                    ),
                    padding: const EdgeInsets.all(45),
                    alignment: childAlignment,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ViewConstants.myWhite,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(right: 25, left: 25, top: 30, bottom: 10),
                            child: Theme(
                              data: ThemeData(
                                primaryColor: ViewConstants.myBlack,
                                cursorColor: ViewConstants.myBlack,
                              ),
                              child: TextField(
                                keyboardType: TextInputType.emailAddress,
                                controller: _usernameController,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  icon: Icon(Icons.person),
                                  border: UnderlineInputBorder(),
                                  hintText: 'Username or E-mail',
                                  hintStyle: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 25, left: 25, top: 10, bottom: 10),
                            child: Theme(
                              data: ThemeData(
                                primaryColor: ViewConstants.myBlack,
                                cursorColor: ViewConstants.myBlack,
                              ),
                              child: TextField(
                                keyboardType: TextInputType.text,
                                controller: _passwordController,
                                obscureText: true,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.all(0),
                                  icon: Icon(Icons.lock_open),
                                  border: UnderlineInputBorder(),
                                  hintText: 'Password',
                                  hintStyle: TextStyle(fontSize: 13),
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: FractionalOffset.bottomCenter,
                            child: Container(
                              padding: EdgeInsets.only(right: 20),
                              alignment: Alignment.centerRight,
                              child: MaterialButton(
                                child: Text(
                                  "Forgot Password?",
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: ViewConstants.myBlack),
                                ),
                                onPressed: () {},
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
