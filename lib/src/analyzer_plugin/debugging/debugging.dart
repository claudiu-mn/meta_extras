import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:meta_extras/src/analyzer_plugin/debugging/web_socket_plugin_server.dart';
import 'package:meta_extras/src/analyzer_plugin/meta_extras_plugin.dart';

const kMetaExtrasDebug = false;

void debugPrint(Object? object) {
  if (!kMetaExtrasDebug) return;
  print(object);
}

void main() {
  const loc =
      'package:meta_extras/src/analyzer_plugin/debugging/debugging.dart:6:7';

  if (!kMetaExtrasDebug) {
    print('$loc Forgot to set `kMetaExtrasDebug = true`?');
    return;
  }

  print('$loc Remember to set `kMetaExtrasDebug = false` afterwards!');

  MetaExtrasPlugin(
    resourceProvider: PhysicalResourceProvider.INSTANCE,
  ).start(WebSocketPluginServer());
}
