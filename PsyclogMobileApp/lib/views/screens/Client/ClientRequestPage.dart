import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/widgets/RequestInformationCard.dart';

class ClientRequestPage extends StatelessWidget {
  final Therapist therapist;
  final bool currentUserApplied;

  const ClientRequestPage({Key key, this.therapist, this.currentUserApplied}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: ViewConstants.myWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        iconTheme: IconThemeData(
          color: ViewConstants.myBlack,
        ),
      ),
      body: Stack(children: [
        Container(
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height * 0.3,
                width: MediaQuery.of(context).size.width * 0.9,
                child: Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: ViewConstants.myBlue,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LayoutBuilder(builder: (context, constraints) {
                              return SizedBox(
                                width: constraints.maxWidth,
                                child: AutoSizeText(
                                  "Dr. " + therapist.getFullName(),
                                  style: TextStyle(color: ViewConstants.myBlack, fontWeight: FontWeight.w500),
                                  maxLines: 2,
                                  presetFontSizes: [35, 32, 29, 26, 23],
                                ),
                              );
                            }),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: LayoutBuilder(builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth * 0.95,
                                  child: AutoSizeText(
                                    "Family and Marriage Therapist",
                                    style: TextStyle(color: ViewConstants.myBlack, fontWeight: FontWeight.w500),
                                    maxLines: 1,
                                    presetFontSizes: [16, 13, 11, 9, 7],
                                  ),
                                );
                              }),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: LayoutBuilder(builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth * 0.80,
                                  child: AutoSizeText(
                                    Random().nextInt(20).toString() + " years experience",
                                    style: TextStyle(color: ViewConstants.myBlack, fontWeight: FontWeight.w300),
                                    maxLines: 1,
                                    presetFontSizes: [15, 13, 11, 9, 7],
                                  ),
                                );
                              }),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 5),
                                child: LayoutBuilder(builder: (context, constraints) {
                                  return Container(
                                    width: constraints.maxWidth,
                                    height: constraints.maxHeight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: ViewConstants.myYellow.withOpacity(0.75),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.chat),
                                            onPressed: () {},
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: ViewConstants.myBlue.withOpacity(0.75),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.call),
                                            onPressed: () {},
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: ViewConstants.myLightBlack.withOpacity(0.75),
                                            shape: BoxShape.circle,
                                          ),
                                          child: IconButton(
                                            icon: Icon(Icons.schedule),
                                            onPressed: () {},
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: LayoutBuilder(builder: (context, constraints) {
                          return SizedBox(
                            width: constraints.maxWidth * 0.15,
                            child: AutoSizeText(
                              "About",
                              style: TextStyle(color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              presetFontSizes: [26, 24, 22, 20, 18],
                            ),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: LayoutBuilder(builder: (context, constraints) {
                          return SizedBox(
                            width: constraints.maxWidth,
                            child: AutoSizeText(
                              "Phasellus non sem id magna faucibus pharetra nec eu orci. "
                              "Nam eu rhoncus nibh. Praesent et risus porttitor, "
                              "laoreet ex eget, vestibulum tellus. Sed non commodo lacus. "
                              "Quisque cursus ultrices odio, eleifend consequat ante mattis id. "
                              "Suspendisse consectetur sollicitudin tortor ac efficitur. "
                              "Proin ac varius tortor, a scelerisque arcu. ",
                              style: TextStyle(color: ViewConstants.myBlack.withOpacity(0.50), fontWeight: FontWeight.w300),
                              presetFontSizes: [18, 16, 14, 12, 10],
                              maxLines: 6,
                            ),
                          );
                        }),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Container(
                            width: constraints.maxWidth,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: SizedBox(
                                          width: constraints.maxWidth * 0.20,
                                          child: AutoSizeText(
                                            "Patients",
                                            style: TextStyle(color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            presetFontSizes: [26, 24, 22, 20, 18],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: SizedBox(
                                          width: constraints.maxWidth,
                                          child: AutoSizeText(
                                            "97",
                                            style: TextStyle(
                                                color: ViewConstants.myBlack.withOpacity(0.50), fontWeight: FontWeight.w300),
                                            maxLines: 1,
                                            presetFontSizes: [20, 19, 17],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: SizedBox(
                                          width: constraints.maxWidth * 0.20,
                                          child: AutoSizeText(
                                            "Sessions",
                                            style: TextStyle(color: ViewConstants.myBlack, fontWeight: FontWeight.w600),
                                            maxLines: 1,
                                            presetFontSizes: [26, 24, 22, 20, 18],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: SizedBox(
                                          width: constraints.maxWidth,
                                          child: AutoSizeText(
                                            "282",
                                            style: TextStyle(
                                                color: ViewConstants.myBlack.withOpacity(0.50), fontWeight: FontWeight.w300),
                                            maxLines: 1,
                                            presetFontSizes: [20, 19, 17],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        RequestInformationCard(
          therapistID: therapist.userID,
          therapistName: therapist.getFullName(),
          currentUserApplied: currentUserApplied,
        )
      ]),
    );
  }
}
