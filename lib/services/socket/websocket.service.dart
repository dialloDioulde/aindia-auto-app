/**
 * @created 19/10/2023 - 22:59
 * @project aindia_auto_app
 * @author mamadoudiallo
 */

import 'package:web_socket_channel/io.dart';

class WebSocketService {
  //final channel = IOWebSocketChannel.connect('ws://10.0.2.2:3000');

  IOWebSocketChannel setupWebSocket() {
    return IOWebSocketChannel.connect('ws://10.0.2.2:3000');
  }

  void startWebSocket(IOWebSocketChannel channel) {
    channel.stream.listen((message) {});
  }

  void sendMessageWebSocket(IOWebSocketChannel channel) {
    final event = {
      'type': 'test',
      'data': "I'm a web socket test.",
    };
    channel.sink.add(event.toString());
  }

  void closeWebSocket(IOWebSocketChannel channel) {
    channel.sink.close();
  }
}