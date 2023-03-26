import 'dart:isolate';

import 'package:meta_extras/analyzer_plugin.dart' as plugin;

void main(List<String> _, SendPort sendPort) => plugin.start(sendPort);
