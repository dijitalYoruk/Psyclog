import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';

class ClientSearchPage extends StatefulWidget {
  @override
  _ClientSearchPageState createState() => _ClientSearchPageState();
}

class _ClientSearchPageState extends State<ClientSearchPage> {
  TextEditingController _searchController;

  static GlobalKey<EditableTextState> _formKey = new GlobalKey<EditableTextState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment(5, 5), colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
              ),
            )),
        Theme(
          data: ThemeData(
            accentColor: ViewConstants.myBlack,
          ),
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
                padding: EdgeInsets.only(
                  top: 30,
                  bottom: 30,
                  left: 20,
                ),
                child: Text("Find your\nConsultation",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 30, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
              ),
              Container(
                decoration: BoxDecoration(
                  color: ViewConstants.myBlack,
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Icon(Icons.search, color: ViewConstants.myWhite),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(left: 10),
                        child: TextField(
                          autofocus: false,
                          key: _formKey,
                          keyboardType: TextInputType.emailAddress,
                          controller: _searchController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search',
                            hintStyle: TextStyle(fontSize: 18, color: ViewConstants.myWhite, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                ),
                child: Row(
                  children: [
                    Container(
                      child: Text("Browse Therapists",
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, ViewConstants.allTherapistsRoute, arguments: ViewConstants.allTherapists);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment(-1, -1),
                        end: Alignment(1, -0.5),
                        colors: <Color>[
                          ViewConstants.myBlue.withOpacity(0.75),
                          ViewConstants.myBlack,
                        ],
                      ),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.all_inclusive,
                                          color: ViewConstants.myWhite,
                                          size: 35,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: AutoSizeText(
                                      "All the consultants we work with. Safe and secure.",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                      minFontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: ViewConstants.myWhite
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: ViewConstants.myBlue,
                                size: 35,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, ViewConstants.allTherapistsRoute,
                        arguments: ViewConstants.preferredTherapists);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment(-1, -1),
                        end: Alignment(1, -0.5),
                        colors: <Color>[
                          ViewConstants.myPink.withOpacity(0.75),
                          ViewConstants.myBlack,
                        ],
                      ),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.thumb_up,
                                          color: ViewConstants.myWhite,
                                          size: 35,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: AutoSizeText(
                                      "Preferred by our clients. Favourites and experienced.",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                      minFontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ViewConstants.myWhite
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: ViewConstants.myPink,
                                size: 35,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, ViewConstants.allTherapistsRoute,
                        arguments: ViewConstants.latestTherapists);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment(-1, -1),
                        end: Alignment(1, -0.5),
                        colors: <Color>[
                          ViewConstants.myYellow.withOpacity(0.75),
                          ViewConstants.myBlack,
                        ],
                      ),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.fiber_new_rounded,
                                          color: ViewConstants.myWhite,
                                          size: 35,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: AutoSizeText(
                                      "Our newest consultants. Looking forward to work.",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                      minFontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ViewConstants.myWhite
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: ViewConstants.myYellow,
                                size: 35,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, ViewConstants.allTherapistsRoute,
                        arguments: ViewConstants.seniorTherapists);
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment(-1, -1),
                        end: Alignment(1, -0.5),
                        colors: <Color>[
                          ViewConstants.myGreyBlue,
                          ViewConstants.myBlack,
                        ],
                      ),
                    ),
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Icon(
                                          Icons.school,
                                          color: ViewConstants.myWhite,
                                          size: 35,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: AutoSizeText(
                                      "Bilkent Senior Students. Ready to bloom.",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(color: ViewConstants.myWhite, fontWeight: FontWeight.bold),
                                      minFontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(15),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: ViewConstants.myWhite
                              ),
                              child: Icon(
                                Icons.arrow_forward,
                                color: ViewConstants.myBlack,
                                size: 35,
                              ),
                            ),
                          )
                        ],
                      ),
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
