import 'package:psyclog_app/service/WebServerService.dart';
import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService extends WebServerService {
  static IO.Socket _socket;
  static String _serverAddress;
  static SocketService _socketService;

  static Future<SocketService> getSocketService() async {
    if (_serverAddress == null) {
      _serverAddress = ServiceConstants.serverAddress;
    }
    if (_socket == null) {
      print("Empty Socket Service for Client Storage Service. Creating a new one.");
      _socket = IO.io(_serverAddress, IO.OptionBuilder().setTransports(['websocket']).build());

      _socket.on("connect", (_) => print('Connected'));
      _socket.on("disconnect", (_) => print('Disconnected'));
    }
    if (_socketService == null) {
      print("Empty Service for Client Server Service. Creating a new one.");
      _socketService = new SocketService();
    }

    if(!_socket.connected) {
      _socket.connect();
    }
    return _socketService;
  }

  static disposeService() {
    if(_socket != null) {
      _socket.clearListeners();
      _socket.disconnect();
      print("Socket Service is disposed");
    } else {
      print("Socket was not alive");
    }
  }

  get getSocket => _socket;
}
