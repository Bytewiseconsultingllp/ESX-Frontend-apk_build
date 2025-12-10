import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:esx/core/services/url.dart';

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket socket;

  SocketService._internal();
  final String _socketUrl = productUrl;
  void initSocket(String userId) {
    socket = IO.io(
      _socketUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .setQuery({'userId': userId})
          .build(),
    );

    socket.connect();
  }

  void dispose() {
    socket.dispose();
  }
}
