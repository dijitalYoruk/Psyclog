import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/Contact.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:psyclog_app/view_models/client/ClientMessageListViewModel.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/widgets/AwareListItem.dart';

class ClientMessagePage extends StatefulWidget {
  @override
  _ClientMessagePageState createState() => _ClientMessagePageState();
}

class _ClientMessagePageState extends State<ClientMessagePage> with AutomaticKeepAliveClientMixin {
  ClientMessageListViewModel _clientMessageListViewModel;
  WebServerService _webServerService;

  @override
  void initState() {
    _clientMessageListViewModel = ClientMessageListViewModel(context);
    _clientMessageListViewModel.initializeService();
    // TODO: implement initState
    super.initState();
  }

  Future<Widget> getProfileImage() async {
    Widget profileImage;

    _webServerService = await WebServerService.getWebServerService();

    //_webServerService.checkUserByCurrentToken();

    Patient patient = _webServerService.currentUser;

    if (patient != null && patient.profileImageURL != null) {
      try {
        profileImage = Image.network(patient.profileImageURL, fit: BoxFit.fill);
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
                                child: Text(_clientMessageListViewModel.getNotSeenCount() != 0 ? _clientMessageListViewModel.getNotSeenCount().toString() : "...",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(fontSize: 13, color: ViewConstants.myWhite, fontWeight: FontWeight.bold)),
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
                                  Navigator.pushNamed(context, ViewConstants.clientProfileRoute);
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
                                      Navigator.pushNamed(context, ViewConstants.clientProfileRoute);
                                    },
                                    child: CircleAvatar(
                                      backgroundImage: (snapshot.data as Image).image,
                                    ),
                                  );
                                } else {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.pushNamed(context, ViewConstants.clientProfileRoute);
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
                  ChangeNotifierProvider<ClientMessageListViewModel>(
                      create: (context) => _clientMessageListViewModel,
                      child: Consumer<ClientMessageListViewModel>(builder: (context, model, child) {
                        return SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return AwareListItem(
                                itemCreated: () {
                                  print("List Item:" + index.toString());
                                },
                                child: Builder(
                                  builder: (context) {
                                    Contact currentContact = model.getContactByIndex(index);

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
                                    } else if (lastSeenDuration.inSeconds > 0) {
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
                                      onTap: () {

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
                                                  CircleAvatar(
                                                    radius: 24,
                                                    backgroundImage: (Image.network(
                                                            currentContact.profileImage + "/people/" + ((index + 2) % 10).toString()))
                                                        .image,
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
                                                      Text(lastSeenTime,
                                                          style: GoogleFonts.lato(
                                                              fontSize: 12,
                                                              color: _textColor.withOpacity(0.5),
                                                              fontWeight: FontWeight.w500)),
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
                            },
                            childCount: model.getContactListLength(),
                          ),
                        );
                      })),
                ],
              ))
            ],
          ),
        ));
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
