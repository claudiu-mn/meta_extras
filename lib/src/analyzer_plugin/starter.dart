import 'dart:isolate';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_plugin/starter.dart';
import 'package:meta_extras/src/analyzer_plugin/debugging/debugging.dart';
import 'package:meta_extras/src/analyzer_plugin/debugging/plugin_proxy.dart';
import 'package:meta_extras/src/analyzer_plugin/meta_extras_plugin.dart';

void start(SendPort sendPort) {
  if (kMetaExtrasDebug) {
    _startDebugging(sendPort);
  } else {
    _startNormally(sendPort);
  }
}

void _startDebugging(SendPort sendPort) {
  PluginProxy(sendPort).start();
}

void _startNormally(SendPort sendPort) {
  ServerPluginStarter(
    MetaExtrasPlugin(resourceProvider: PhysicalResourceProvider.INSTANCE),
  ).start(sendPort);
}
