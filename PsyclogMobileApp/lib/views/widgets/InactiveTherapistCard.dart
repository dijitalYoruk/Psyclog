import 'package:flutter/material.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/util/CapExtension.dart';

class InactiveTherapistCard extends StatelessWidget {
  final Therapist therapist;
  final Color pageColor;

  const InactiveTherapistCard({Key key, this.therapist, this.pageColor})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double containerHeight = MediaQuery.of(context).size.height / 8 + 20;

    return Card(
      margin: EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 2,
      child: Opacity(
        opacity: 0.50,
        child: Container(
          height: containerHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: ViewConstants.myWhite,
          ),
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: ViewConstants.myBlack,
                  borderRadius: BorderRadius.circular(10),
                ),
                width: MediaQuery.of(context).size.height / 8,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Dr. " +
                              therapist.userFirstName.toString().inCaps +
                              " " +
                              therapist.userSurname.toString().inCaps,
                          style: TextStyle(
                              fontSize: 12,
                              color: ViewConstants.darkGreyBlue,
                              fontFamily: "OpenSans",
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              "Currently Unavailable",
                              style: TextStyle(
                                  fontSize: 15,
                                  color: ViewConstants.myBlack,
                                  fontFamily: "OpenSans",
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
          alignment: Alignment.center,
        ),
      ),
    );
  }
}
