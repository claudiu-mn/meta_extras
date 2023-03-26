import 'package:analyzer/dart/element/element.dart';

class AnnotationPoint {
  const AnnotationPoint({
    required this.target,
    required this.annotations,
  });

  final Element target;

  /// Contains only the [ElementAnnotation]s declared in the `meta_extras` library
  final Iterable<ElementAnnotation> annotations;
}
