import 'package:flutter/material.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ViewConstants.myBlack,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(top: 100, bottom: 100),
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.height * 0.60,
              child: Image.asset(
                "assets/PSYCLOG_white_icon.png",
                fit: BoxFit.fitWidth,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
            child: Center(
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                color: ViewConstants.myWhite,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(context, ViewConstants.registerClientRoute);
                  },
                  child: Row(children: [
                    Expanded(
                      child: Text("Create a User Account",
                          textAlign: TextAlign.center,
                          style: ViewConstants.fieldStyle.copyWith(
                              fontSize: 15,
                              color: ViewConstants.myBlack,
                              fontWeight: FontWeight.bold)),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: ViewConstants.myBlack,
                    ),
                  ]),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(20),
            child: Center(
              child: Material(
                elevation: 5.0,
                borderRadius: BorderRadius.circular(10),
                color: ViewConstants.myWhite,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pushNamed(
                        context, ViewConstants.registerTherapistRoute);
                  },
                  child: Row(children: [
                    Expanded(
                      child: Text("Create a Therapist Account",
                          textAlign: TextAlign.center,
                          style: ViewConstants.fieldStyle.copyWith(
                              fontSize: 15,
                              color: ViewConstants.myBlack,
                              fontWeight: FontWeight.bold)),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: ViewConstants.myBlack,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
