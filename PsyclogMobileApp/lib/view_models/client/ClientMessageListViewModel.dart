import 'package:flutter/material.dart';
import 'package:psyclog_app/service/SocketService.dart';
import 'package:psyclog_app/service/util/ServiceErrorHandling.dart';
import 'package:psyclog_app/src/models/Contact.dart';
import 'package:psyclog_app/src/models/Message.dart';
import 'package:psyclog_app/src/models/Patient.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ClientMessageListViewModel extends ChangeNotifier {
  List<Contact> contactList;
  List chatList;

  // List<Message> messages = List<Message>();
  SocketService _socketService;
  IO.Socket _socket;

  ClientMessageListViewModel() {
    contactList = List<Contact>();
    chatList = List<dynamic>();
    initializeService();
  }

  initializeService() async {
    try {
      _socketService = await SocketService.getSocketService();
      _socket = _socketService.getSocket;
      await _activateUser();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _activateUser() async {
    final String userToken = await _socketService.getToken();

    if (userToken != null) {
      try {
        activateUser(userToken);
        _socket.clearListeners();
        setChat();
      } catch (e) {
        print(e);
      }
    } else {
      throw ServiceErrorHandling.noTokenError;
    }
  }

  void activateUser(String userToken) {
    _socket.emit("activateUser", {"accessToken": userToken});
  }

  void setChat() {
    _socket.on("chats", (chats) {
      chatList = chats as List;

      contactList = List<Contact>();

      print("chats");

      for (var value in chatList) {
        contactList.add(Contact(
            value["_id"],
            value["psychologist"]["isActive"],
            value["psychologist"]["_id"],
            value["psychologist"]["username"],
            value["psychologist"]["name"],
            value["psychologist"]["profileImage"],
            value["patient"],
            value["createdAt"],
            value["updateAt"],
            Message(
                value["lastMessage"]["isSeen"],
                value["lastMessage"]["_id"],
                value["lastMessage"]["message"],
                value["lastMessage"]["contact"],
                value["lastMessage"]["author"],
                value["lastMessage"]["chat"],
                value["lastMessage"]["createdAt"],
                value["lastMessage"]["updatedAt"])));
      }
      _socket.off("chats");

      for (Contact contact in contactList) {
        _socket.on(contact.getPsychologistID, (status) {
          contact.isActive = status;
          notifyListeners();
        });
      }

      notifyListeners();
      return;
    });
  }

  int getContactListLength() {
    return contactList.length;
  }

  Contact getContactByIndex(int index) {
    return contactList[index];
  }
}
