import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer_plugin/channel/channel.dart';
import 'package:analyzer_plugin/protocol/protocol.dart';

const _jsonEncoder = JsonEncoder.withIndent('  ');

/// Taken from https://simonbinder.eu/posts/debugging_analysis_server_plugins/
class WebSocketPluginServer implements PluginCommunicationChannel {
  WebSocketPluginServer() {
    _init();
  }

  final dynamic _address = InternetAddress.loopbackIPv4;
  final int _port = 9999;

  HttpServer? server;
  WebSocket? _currentClient;

  final StreamController<WebSocket?> _clientStream =
      StreamController.broadcast();

  Future<void> _init() async {
    server = await HttpServer.bind(_address, _port);
    print('listening on $_address at port $_port');
    server!.transform(WebSocketTransformer()).listen(_handleClientAdded);
  }

  void _handleClientAdded(WebSocket socket) {
    if (_currentClient != null) {
      print(
        'ignoring connection attempt because an active client already exists',
      );
      socket.close();
    } else {
      print('client connected');
      _currentClient = socket;
      _clientStream.add(_currentClient!);
      _currentClient!.done.then((_) {
        print('client disconnected');
        _currentClient = null;
        _clientStream.add(null);
      });
    }
  }

  @override
  void close() {
    server?.close(force: true);
  }

  @override
  void listen(
    void Function(Request request) onRequest, {
    Function? onError,
    void Function()? onDone,
  }) {
    final stream = _clientStream.stream;

    // wait until we're connected
    stream.firstWhere((socket) => socket != null).then((_) {
      _currentClient!.listen((data) {
        final jsonObj = json.decode(data as String) as Map<String, Object?>;

        print('<=== (${jsonObj.runtimeType})');
        print(_jsonEncoder.convert(jsonObj));

        onRequest(Request.fromJson(jsonObj));
      });
    });
    stream.firstWhere((socket) => socket == null).then(
          (_) => onDone?.call(),
        );
  }

  @override
  void sendNotification(Notification notification) {
    final jsonMap = notification.toJson();
    print('Ntype: ${jsonMap.runtimeType}');
    print('N: $jsonMap');
    _currentClient?.add(json.encode(jsonMap));
  }

  @override
  void sendResponse(Response response) {
    final jsonObj = response.toJson();
    print('${jsonObj.runtimeType} ===>');
    print(_jsonEncoder.convert(jsonObj));
    _currentClient?.add(json.encode(response.toJson()));
  }
}
