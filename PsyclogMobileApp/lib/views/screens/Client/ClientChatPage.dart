import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/src/models/Contact.dart';
import 'package:psyclog_app/src/models/Message.dart';
import 'package:psyclog_app/view_models/client/ClientChatListViewModel.dart';
import 'package:psyclog_app/view_models/client/ClientUserMessageListViewModel.dart';
import 'package:psyclog_app/views/util/DateParser.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:psyclog_app/views/widgets/AwareListItem.dart';

class ClientChatPage extends StatefulWidget {
  final Contact currentContact;

  const ClientChatPage({Key key, this.currentContact}) : super(key: key);

  @override
  _ClientChatPageState createState() => _ClientChatPageState();
}

class _ClientChatPageState extends State<ClientChatPage> {
  ClientChatListViewModel _clientChatListViewModel;

  TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    _clientChatListViewModel = ClientChatListViewModel(widget.currentContact, this.context);
    super.initState();
  }

  Future<bool> initializeService() async {
    await _clientChatListViewModel.initializeService();
    return true;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ChangeNotifierProvider<ClientChatListViewModel>(
          create: (context) => _clientChatListViewModel,
          child: Container(
              color: ViewConstants.myWhite,
              child: Column(children: [
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Consumer<ClientChatListViewModel>(builder: (context, model, child) {
                            return Padding(
                              padding: EdgeInsets.only(
                                left: 20,
                              ),
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 24,
                                    backgroundImage: (Image.network(widget.currentContact.profileImage + "/people/2")).image,
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
                                        color: widget.currentContact.isActive ? Colors.green : ViewConstants.myGrey,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 10,
                            ),
                            child: AutoSizeText(
                                widget.currentContact.firstName + "\n(@" + widget.currentContact.username + ")",
                                textAlign: TextAlign.left,
                                maxLines: 2,
                                style: TextStyle(color: ViewConstants.myBlack, fontWeight: FontWeight.bold, height: 1.2)),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: Icon(
                              Icons.settings,
                              color: ViewConstants.myBlack,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Divider(
                    color: ViewConstants.myGrey.withOpacity(0.25),
                    thickness: 0.5,
                  ),
                ),
                Expanded(
                  child: FutureBuilder(
                    future: initializeService(),
                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.hasData) {
                        return Consumer<ClientChatListViewModel>(builder: (context, model, child) {
                          bool isAuthorLast = false;
                          bool isContactLast = false;

                          return CustomScrollView(
                            reverse: true,
                            shrinkWrap: true,
                            slivers: [
                              SliverList(
                                delegate: SliverChildBuilderDelegate((context, index) {
                                  return AwareListItem(itemCreated: () {
                                    model.handleItemCreated(index);
                                  }, child: Builder(
                                    builder: (BuildContext context) {
                                      Message currentMessage = model.getMessageByIndex(index);
                                      DateTime dateTime =
                                          DateParser.jsonToDateTimeWithClock(currentMessage.createdAt).toLocal();
                                      if (currentMessage.messageOwner.id == widget.currentContact.getPsychologistID) {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              child: Container(
                                                  margin: EdgeInsets.only(bottom: 5, left: 15),
                                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                  decoration: BoxDecoration(
                                                    color: ViewConstants.myBlack,
                                                    borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(10),
                                                        bottomRight: Radius.circular(10),
                                                        bottomLeft: Radius.circular(10)),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.end,
                                                    children: [
                                                      AutoSizeText(
                                                        currentMessage.text,
                                                        style: TextStyle(color: ViewConstants.myWhite, height: 1.5),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 3.0),
                                                        child: AutoSizeText(
                                                          dateTime.toString().substring(11, 16),
                                                          style: TextStyle(color: ViewConstants.myWhite, height: 1.5),
                                                          maxFontSize: 9,
                                                          minFontSize: 6,
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 8.0, right: 40),
                                              child: Icon(
                                                Icons.check,
                                                size: 15,
                                                color: currentMessage.isSeen
                                                    ? ViewConstants.myGreen
                                                    : ViewConstants.myBlack.withOpacity(0.25),
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 8.0, left: 40),
                                              child: Icon(
                                                Icons.check,
                                                size: 15,
                                                color: currentMessage.isSeen
                                                    ? ViewConstants.myGreen
                                                    : ViewConstants.myBlack.withOpacity(0.25),
                                              ),
                                            ),
                                            Flexible(
                                              child: Container(
                                                  margin: EdgeInsets.only(bottom: 5, right: 15),
                                                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                                  decoration: BoxDecoration(
                                                    color: ViewConstants.myGrey.withOpacity(0.1),
                                                    borderRadius: BorderRadius.only(
                                                        topLeft: Radius.circular(10),
                                                        bottomRight: Radius.circular(10),
                                                        bottomLeft: Radius.circular(10)),
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      AutoSizeText(
                                                        currentMessage.text,
                                                        style: TextStyle(color: ViewConstants.myBlack, height: 1.5),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 3.0),
                                                        child: AutoSizeText(
                                                          dateTime.toString().substring(11, 16),
                                                          style: TextStyle(color: ViewConstants.myBlack, height: 1.5),
                                                          maxFontSize: 9,
                                                          minFontSize: 6,
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                            )
                                          ],
                                        );
                                      }
                                    },
                                  ));
                                }, childCount: model.getMessageCount),
                              )
                            ],
                          );
                        });
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                ),
                Builder(
                  builder: (BuildContext context) {
                    double height;

                    if (MediaQuery.of(context).size.height > 750) {
                      height = MediaQuery.of(context).size.height * 0.075;
                    } else {
                      height = MediaQuery.of(context).size.height * 0.09;
                    }

                    return Consumer<ClientChatListViewModel>(builder: (context, model, child) {
                      return Container(
                        padding: EdgeInsets.only(left: 15),
                        decoration: BoxDecoration(
                          color: ViewConstants.myWhite,
                          border: Border(
                            top: BorderSide(width: 0.5, color: ViewConstants.myGrey.withOpacity(0.25)),
                          ),
                        ),
                        height: height,
                        child: Center(
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _textEditingController,
                                  style: GoogleFonts.lato(color: ViewConstants.myBlack),
                                  cursorWidth: 1.5,
                                  keyboardType: TextInputType.multiline,
                                  cursorColor: ViewConstants.myGreen,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Your message",
                                      hintStyle: GoogleFonts.lato(color: ViewConstants.myGrey)),
                                ),
                              ),
                              IconButton(
                                onPressed: () async {
                                  String messageText = _textEditingController.text;

                                  if (messageText != null && messageText != "") {
                                    await model.sendMessage(messageText);
                                  }

                                  _textEditingController.text = "";
                                  FocusManager.instance.primaryFocus.unfocus();
                                },
                                icon: Icon(
                                  Icons.message,
                                  color: ViewConstants.myGreen,
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    });
                  },
                )
              ]))),
    );
  }
}
