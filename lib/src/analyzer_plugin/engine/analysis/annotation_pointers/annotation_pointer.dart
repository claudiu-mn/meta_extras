import 'package:meta/meta.dart';

@immutable
class AnnotationPointer {
  const AnnotationPointer({
    required this.filePath,
    required this.nameOffset,
    required this.nameLength,
    required this.annotations,
  });

  final String filePath;
  final int nameOffset;
  final int nameLength;

  final Iterable<Annotation> annotations;
}

enum AnnotationType { info, warning, error }

@immutable
class Annotation {
  Annotation({required this.type, required this.message});

  final AnnotationType type;
  final String message;
}
