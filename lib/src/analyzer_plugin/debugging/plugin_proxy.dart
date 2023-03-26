import 'dart:convert';
import 'dart:isolate';

import 'package:web_socket_channel/io.dart';

/// Taken from https://simonbinder.eu/posts/debugging_analysis_server_plugins/
class PluginProxy {
  PluginProxy(SendPort sendPort) : _sendPort = sendPort;

  final SendPort _sendPort;
  final ReceivePort _receive = ReceivePort();
  final IOWebSocketChannel _channel = IOWebSocketChannel.connect(
    'ws://localhost:9999',
  );

  Future<void> start() async {
    _sendPort.send(_receive.sendPort);

    _receive.listen((data) {
      // the server will send messages as maps, convert to json
      _channel.sink.add(json.encode(data));
    });

    _channel.stream.listen((data) {
      _sendPort.send(json.decode(data as String));
    });
  }
}
