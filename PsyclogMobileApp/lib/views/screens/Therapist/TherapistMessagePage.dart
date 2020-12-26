import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/Contact.dart';
import 'package:psyclog_app/src/models/Therapist.dart';
import 'package:psyclog_app/view_models/therapist/TherapistUserMessageListViewModel.dart';
import 'package:psyclog_app/views/screens/Therapist/TherapistChatPage.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/widgets/AwareListItem.dart';

class TherapistMessagePage extends StatefulWidget {
  @override
  _TherapistMessagePageState createState() => _TherapistMessagePageState();
}

class _TherapistMessagePageState extends State<TherapistMessagePage> {
  TherapistUserMessageListViewModel _therapistMessageListViewModel;
  WebServerService _webServerService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<Widget> getProfileImage() async {
    Widget profileImage;

    _webServerService = await WebServerService.getWebServerService();

    //_webServerService.checkUserByCurrentToken();

    Therapist therapist = _webServerService.currentUser;

    if (therapist != null && therapist.profileImageURL != null) {
      try {
        profileImage = Image.network(therapist.profileImageURL, fit: BoxFit.fill);
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
    _therapistMessageListViewModel = Provider.of<TherapistUserMessageListViewModel>(context);

    return BackdropFilter(
        filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          color: ViewConstants.myWhite,
          child: Column(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                            ),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                color: ViewConstants.myBlack,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                    _therapistMessageListViewModel.getNotSeenCount() != 0
                                        ? _therapistMessageListViewModel.getNotSeenCount().toString()
                                        : "...",
                                    textAlign: TextAlign.left,
                                    style:
                                        TextStyle(fontSize: 13, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                            ),
                            child: Text("Chats",
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 20, color: ViewConstants.myBlack, fontWeight: FontWeight.bold)),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                            ),
                            child: FutureBuilder(
                              future: getProfileImage(),
                              initialData: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(context, ViewConstants.therapistProfileRoute);
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
                                      Navigator.pushNamed(context, ViewConstants.therapistProfileRoute);
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: (snapshot.data as Image).image,
                                    ),
                                  );
                                } else {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, ViewConstants.therapistProfileRoute);
                                    },
                                    child: Icon(
                                      Icons.person,
                                      color: ViewConstants.myGrey,
                                    ),
                                  );
                                }
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Divider(
                  color: ViewConstants.myGrey.withOpacity(0.25),
                  thickness: 0.5,
                ),
              ),
              Expanded(
                  child: CustomScrollView(
                physics: BouncingScrollPhysics(),
                slivers: <Widget>[
                  Consumer<TherapistUserMessageListViewModel>(builder: (context, model, child) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          Contact currentContact = model.getContactByIndex(index);

                          if (currentContact != null) {
                            return AwareListItem(
                              itemCreated: () {
                                print("List Item:" + index.toString());
                              },
                              child: Builder(
                                builder: (context) {
                                  DateTime contactTime =
                                      DateParser.jsonToDateTimeWithClock(currentContact.lastMessage.createdAt);

                                  Duration lastSeenDuration = DateTime.now().difference(contactTime);

                                  String lastSeenTime;
                                  bool isSeen = model.isSeenByIndex(index);

                                  if (lastSeenDuration.inDays > 0) {
                                    lastSeenTime = lastSeenDuration.inDays.toString() + " d";
                                  } else if (lastSeenDuration.inHours > 0) {
                                    lastSeenTime = lastSeenDuration.inHours.toString() + " h";
                                  } else if (lastSeenDuration.inMinutes > 0) {
                                    lastSeenTime = lastSeenDuration.inMinutes.toString() + " m";
                                  } else {
                                    lastSeenTime = "now";
                                  }

                                  Color _backgroundColor, _textColor, _nameColor;

                                  if (!isSeen) {
                                    _backgroundColor = Colors.transparent;
                                    _nameColor = ViewConstants.myBlack;
                                    _textColor = ViewConstants.myGrey.withOpacity(0.75);
                                  } else {
                                    _backgroundColor = ViewConstants.myBlack;
                                    _nameColor = ViewConstants.myWhite;
                                    _textColor = ViewConstants.myWhite.withOpacity(0.75);
                                  }

                                  return InkWell(
                                    onTap: () async {
                                      _therapistMessageListViewModel.deactivateFlushBar();
                                      await Navigator.push(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (
                                              BuildContext context,
                                              Animation<double> animation,
                                              Animation<double> secondaryAnimation,
                                            ) =>
                                                TherapistChatPage(currentContact: model.getContactByIndex(index)),
                                            transitionsBuilder: (
                                              BuildContext context,
                                              Animation<double> animation,
                                              Animation<double> secondaryAnimation,
                                              Widget child,
                                            ) =>
                                                SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: child,
                                            ),
                                          ));
                                      _therapistMessageListViewModel.initializeService();
                                    },
                                    child: Card(
                                      elevation: 0,
                                      margin: EdgeInsets.zero,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero,
                                      ),
                                      color: _backgroundColor,
                                      shadowColor: Colors.transparent,
                                      child: Container(
                                        margin: EdgeInsets.only(left: 25, top: 15, bottom: 15),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Stack(
                                              children: [
                                                currentContact.profileImage != null
                                                    ? CircleAvatar(
                                                        radius: 24,
                                                        backgroundImage: (Image.network(currentContact.profileImage)).image,
                                                      )
                                                    : Icon(
                                                        Icons.person,
                                                        color: ViewConstants.myGrey,
                                                        size: 35,
                                                      ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: ViewConstants.myWhite,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Icon(
                                                      Icons.circle,
                                                      size: 18,
                                                      color: currentContact.isActive ? Colors.green : ViewConstants.myGrey,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(bottom: 10.0),
                                                      child: AutoSizeText(
                                                          currentContact.firstName + " (@" + currentContact.username + ")",
                                                          minFontSize: 15,
                                                          style: GoogleFonts.lato(
                                                              color: _nameColor, fontWeight: FontWeight.w600)),
                                                    ),
                                                    Container(
                                                      child: AutoSizeText(currentContact.lastMessage.text,
                                                          maxFontSize: 14,
                                                          maxLines: 1,
                                                          overflow: TextOverflow.clip,
                                                          style: GoogleFonts.lato(color: _textColor)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.only(right: 25.0),
                                                child: Column(
                                                  children: [
                                                    lastSeenTime != null
                                                        ? Text(lastSeenTime,
                                                            style: GoogleFonts.lato(
                                                                fontSize: 12,
                                                                color: _textColor.withOpacity(0.5),
                                                                fontWeight: FontWeight.w500))
                                                        : Container(),
                                                  ],
                                                ))
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          } else {
                            return Container();
                          }
                        },
                        childCount: model.getContactListLength(),
                      ),
                    );
                  }),
                ],
              ))
            ],
          ),
        ));
  }
}
