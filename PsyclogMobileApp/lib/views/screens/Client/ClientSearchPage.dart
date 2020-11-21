import 'dart:ui';

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
    final double categoryWidth = MediaQuery.of(context).size.width / 3;

    return Stack(
      children: [
        BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment(5, 5),
                    colors: [ViewConstants.myWhite, ViewConstants.myGreyBlue]),
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
              Container(
                padding: EdgeInsets.only(left: 15, right: 20, top: 10, bottom: 10),
                height: MediaQuery.of(context).size.height * 0.35,
                child: Theme(
                  data: ThemeData(
                    accentColor: ViewConstants.myLightBlue,
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, ViewConstants.allTherapistsRoute,
                                arguments: ViewConstants.allTherapists);
                          },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
                              gradient: LinearGradient(
                                begin: Alignment(-1, -1),
                                end: Alignment(1, -0.5),
                                colors: <Color>[
                                  ViewConstants.myLightBlue.withOpacity(0.75),
                                  ViewConstants.myBlack,
                                ],
                              ),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: MediaQuery.of(context).size.height / 3,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 40),
                                      child: Text(ViewConstants.allTherapists,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 3,
                                      child: Image.asset(
                                        "assets/therapists_pictures/william_james.png",
                                        fit: BoxFit.fill,
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
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, ViewConstants.allTherapistsRoute,
                                arguments: ViewConstants.preferredTherapists);
                          },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
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
                              width: MediaQuery.of(context).size.width / 3,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 40),
                                      child: Text(ViewConstants.preferredTherapists,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 3,
                                      child: Image.asset(
                                        "assets/therapists_pictures/sigmund_freud.png",
                                        fit: BoxFit.fill,
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
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, ViewConstants.allTherapistsRoute,
                                arguments: ViewConstants.latestTherapists);
                          },
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
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
                              width: MediaQuery.of(context).size.width / 3,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 40),
                                      child: Text(ViewConstants.latestTherapists,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 3,
                                      child: Image.asset(
                                        "assets/therapists_pictures/erik_erikson.png",
                                        fit: BoxFit.fill,
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
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
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
                                  ViewConstants.myGreyBlue.withOpacity(0.75),
                                  ViewConstants.myBlack,
                                ],
                              ),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width / 3,
                              height: MediaQuery.of(context).size.height / 3,
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 40),
                                      child: Text(ViewConstants.seniorTherapists,
                                          textAlign: TextAlign.left,
                                          style: TextStyle(
                                              fontSize: 16, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      width: MediaQuery.of(context).size.width / 3,
                                      child: Image.asset(
                                        "assets/therapists_pictures/melanie_klein.png",
                                        fit: BoxFit.fill,
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
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                ),
                child: Text("Today's News",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: EdgeInsets.only(left: 15, right: 20, top: 20, bottom: 20),
                height: MediaQuery.of(context).size.height / 3,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment(10, 0),
                      colors: [ViewConstants.myWhite, ViewConstants.myBlue]),
                ),
                child: Theme(
                  data: ThemeData(
                    accentColor: ViewConstants.myBlue,
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            color: ViewConstants.myWhite,
                            width: MediaQuery.of(context).size.width / 3,
                            height: MediaQuery.of(context).size.height / 3,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            color: ViewConstants.myWhite,
                            width: MediaQuery.of(context).size.width / 3,
                            height: MediaQuery.of(context).size.height / 3,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                        child: InkWell(
                          onTap: () {},
                          child: Container(
                            color: ViewConstants.myWhite,
                            width: MediaQuery.of(context).size.width / 3,
                            height: MediaQuery.of(context).size.height / 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                ),
                child: Text("News Categories",
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 50, left: 15, right: 20),
                height: categoryWidth,
                child: Theme(
                  data: ThemeData(
                    accentColor: ViewConstants.myWhite,
                  ),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: categoryWidth,
                          height: categoryWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/category_pictures/home_picture.png",
                                  fit: BoxFit.fill,
                                ),
                                Container(
                                  color: ViewConstants.myBlue.withOpacity(0.25),
                                ),
                                Center(
                                  child: Text("Family",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 20, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: categoryWidth,
                          height: categoryWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/category_pictures/parent_picture.png",
                                  fit: BoxFit.fill,
                                ),
                                Container(
                                  color: ViewConstants.myLightBlue.withOpacity(0.25),
                                ),
                                Center(
                                  child: Text("Parenting",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 20, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: categoryWidth,
                          height: categoryWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/category_pictures/relationship_picture.png",
                                  fit: BoxFit.fill,
                                ),
                                Container(
                                  color: ViewConstants.myYellow.withOpacity(0.25),
                                ),
                                Center(
                                  child: Text("Relationship",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 20, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: categoryWidth,
                          height: categoryWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/category_pictures/happy_picture.png",
                                  fit: BoxFit.fill,
                                ),
                                Container(
                                  color: ViewConstants.myLightBlue.withOpacity(0.25),
                                ),
                                Center(
                                  child: Text("Happiness",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 20, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          width: categoryWidth,
                          height: categoryWidth,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                Image.asset(
                                  "assets/category_pictures/personality_picture.png",
                                  fit: BoxFit.fill,
                                ),
                                Container(
                                  color: ViewConstants.myLightBlue.withOpacity(0.25),
                                ),
                                Center(
                                  child: Text("Personality",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                          fontSize: 20, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
