import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends WebServerService {
  static IO.Socket _socket;
  static String _serverAddress;
  static SocketService _socketService;

  static SocketService getSocketService() {
    if (_serverAddress == null) {
      _serverAddress = ServiceConstants.serverAddress;
    }
    if (_socket == null) {
      print("Empty Socket. Creating a new one.");
      try {
        _socket = IO.io(_serverAddress, <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
        });
        _socket.onConnect((data) => null);
        _socket.onDisconnect((data) => null);
        _socket.onConnectError((data) => print(data.toString()));

        _socket.connect();
      } catch (e) {
        print(e);
      }
    }
    if (_socketService == null) {
      print("Empty Socket Service. Creating a new one.");
      _socketService = new SocketService();
    }

    return _socketService;
  }

  static disposeService() {
    if (_socket != null) {
      _socket.clearListeners();
      _socket.disconnect();
      print("Socket Service is disposed");
    } else {
      print("Socket was not alive");
    }
  }

  get getSocket => _socket;
}
