import 'package:auto_size_text/auto_size_text.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:psyclog_app/service/SocketService.dart';
import 'package:psyclog_app/src/models/Contact.dart';
import 'package:psyclog_app/src/models/Message.dart';
import 'package:psyclog_app/views/util/ViewConstants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ClientChatListViewModel extends ChangeNotifier {
  Contact contact;
  List<Message> messageList;
  BuildContext context;
  SocketService _socketService;
  IO.Socket _socket;

  int skipCount;
  int pageCount;

  ClientChatListViewModel(Contact contact, BuildContext context) {
    this.contact = contact;
    this.context = context;
    skipCount = 0;
    pageCount = 1;
  }

  get getMessageCount => messageList.length;

  Message getMessageByIndex(int index) {
    return messageList[index];
  }

  initializeService() async {
    _socketService = await SocketService.getSocketService();

    messageList = List<Message>();

    try {
      _socket = _socketService.getSocket;

      print("Current chatID:" + contact.getChatID);

      // All the connections
      await setMessageConnection();
      await setActiveConnection();
      await setPreviousMessagesConnection();
      await setSeenMessages();
      retrievePreviousMessages();
      signalLastMessage(contact.lastMessage);
    } catch (e) {
      print(e);
    }
  }

  setPreviousMessagesConnection() {
    _socket.on('previousMessages', (messages) {
      skipCount += messages.length;

      for (var message in messages) {
        Message newMessage = Message.messageWithOwner(
            message["isSeen"],
            message["_id"],
            message["message"],
            MessageOwner(message["author"]["_id"], message["author"]["username"], message["author"]["name"],
                message["author"]["profileImage"]),
            message["contact"],
            message["chat"],
            message["createdAt"],
            message["updatedAt"],
            null);
        messageList.add(newMessage);
      }
      notifyListeners();
    });
  }

  setMessageConnection() {
    _socket.off("message");
    _socket.on("message", (message) {
      Message newMessage = Message.messageWithOwner(
          message["isSeen"],
          message["_id"],
          message["message"],
          MessageOwner(message["author"]["_id"], message["author"]["username"], message["author"]["name"],
              message["author"]["profileImage"]),
          message["contact"],
          message["chat"],
          message["createdAt"],
          message["updatedAt"],
          null);
      if (message["author"]["_id"] == contact.getPsychologistID) {
        newMessage.isSeen = true;
        messageList.insert(0, newMessage);
        signalLastMessage(newMessage);
        notifyListeners();
      } else if (message["author"]["_id"] == contact.getPatientID) {
        messageList.insert(0, newMessage);
        signalLastMessage(newMessage);
        notifyListeners();
      } else {
        Flushbar(
          margin: EdgeInsets.all(14),
          borderRadius: 8,
          leftBarIndicatorColor: ViewConstants.myBlue,
          icon: newMessage.messageOwner.profileImage != null
              ? Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundImage: (Image.network(newMessage.messageOwner.profileImage + "/people/1")).image,
                  ),
                )
              : null,
          title: "",
          titleText: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AutoSizeText(newMessage.messageOwner.name + " (@" + newMessage.messageOwner.username + ")"),
          ),
          messageText: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: AutoSizeText(newMessage.text),
          ),
          flushbarStyle: FlushbarStyle.FLOATING,
          reverseAnimationCurve: Curves.decelerate,
          forwardAnimationCurve: Curves.decelerate,
          flushbarPosition: FlushbarPosition.TOP,
          backgroundColor: ViewConstants.myBlack,
          duration: Duration(seconds: 3),
        )..show(this.context);
      }
    });
  }

  setActiveConnection() {
    _socket.off(contact.getPsychologistID);
    _socket.on(contact.getPsychologistID, (status) {
      print(status);
      contact.isActive = status;
      notifyListeners();
    });
  }

  handleItemCreated(index) {
    var itemPosition = index + 1;
    var requestMoreData = itemPosition % 10 == 0 && itemPosition != 0;
    var pageToRequest = 1 + (itemPosition ~/ 10);

    if (requestMoreData && pageToRequest > pageCount) {
      print("Requested" + pageCount.toString());
      pageCount++;
      retrievePreviousMessages();
      print(skipCount);
    }
  }

  Future<void> sendMessage(String messageText) async {
    final String userToken = await _socketService.getToken();
    final String chatID = contact.getChatID;

    _socket.emit('sendMessage', {"accessToken": userToken, "message": messageText, "chat": chatID});
  }

  Future<void> retrievePreviousMessages() async {
    final String userToken = await _socketService.getToken();
    final String chatID = contact.getChatID;

    _socket.emit('retrievePreviousMessages', {"accessToken": userToken, "chat": chatID, "skip": skipCount});
  }

  Future<void> setSeenMessages() async {
    String contactID = contact.getPsychologistID;

    _socket.on('message-seen-chat-$contactID', (seenMessageIDs) {
      List<String> messageIDs = List<String>.generate(seenMessageIDs.length, (index) => seenMessageIDs[index]);

      print(messageIDs);

      for (Message message in messageList) {
        if (message.isSeen) continue;
        message.isSeen = messageIDs.contains(message.getId);
      }
      notifyListeners();
    });
  }

  Future<void> signalLastMessage(Message message) async {
    final String userToken = await _socketService.getToken();
    if (message.getAuthorID == contact.getPatientID)
      return;
    else
      _socket.emit('messageSeen', {"chat": contact.getChatID, "accessToken": userToken});
  }

  @override
  void dispose() {
    String contactID = contact.getPsychologistID;

    _socket.off('previousMessages');
    _socket.off('message-seen-chat-$contactID');
    // TODO: implement dispose
    super.dispose();
  }
}
