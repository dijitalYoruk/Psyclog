import 'package:psyclog_app/service/util/ServiceConstants.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  IO.Socket socket;

  createSocketConnection() {
    socket = IO.io(
        ServiceConstants.serverAddress,
        IO.OptionBuilder().setTransports(['websocket']) // for Flutter or Dart VM
            .build());

    this.socket.on("connect", (_) => print('Connected'));
    this.socket.on("disconnect", (_) => print('Disconnected'));
  }
}