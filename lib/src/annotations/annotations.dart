import 'package:meta_extras/src/annotations/message_annotation.dart';

class Info implements MessageAnnotation {
  const Info(this.message);

  @override
  final String message;
}

class Warning implements MessageAnnotation {
  const Warning(this.message);

  @override
  final String message;
}

class Error implements MessageAnnotation {
  const Error(this.message);

  @override
  final String message;
}
