import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:meta_extras/src/analyzer_plugin/debugging/debugging.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/annotation_points/annotated_node_visitor.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/annotation_points/annotation_point.dart';

class AnnotationPointFinder {
  AnnotationPointFinder(this.unitResult);

  final ResolvedUnitResult unitResult;

  Iterable<AnnotationPoint> find() {
    final annotatedElements = <AnnotationPoint>[];

    unitResult.unit.visitChildren(AnnotatedNodeVisitor((aN) {
      Element? element;

      if (aN is Declaration) {
        element = aN.declaredElement;
      }
      //  else if (aN is FormalParameter) {
      //   element = aN.declaredElement;
      // }

      if (element == null) return;

      final annotations = _getAnnotations(element);
      if (annotations.isNotEmpty) {
        annotatedElements.add(
          AnnotationPoint(target: element, annotations: annotations),
        );
      }
    }, (a) {
      Element? element;

      final parent = a.parent;
      // if (parent is Declaration) {
      //   element = parent.declaredElement;
      // } else
      if (parent is FormalParameter) {
        element = parent.declaredElement;
      }

      if (element == null) return;

      if (annotatedElements.indexWhere((e) => e.target == element) != -1) {
        return;
      }

      final annotations = _getAnnotations(element);
      if (annotations.isNotEmpty) {
        annotatedElements.add(
          AnnotationPoint(target: element, annotations: annotations),
        );
      }
    }));

    return annotatedElements;
  }

  Iterable<ElementAnnotation> _getAnnotations(Element element) {
    final annotations = <ElementAnnotation>[];

    for (var annotation in element.metadata) {
      final library = annotation.element?.library;
      final annotationUri = library?.source.uri;

      if (annotationUri == null) continue;

      // TODO: Can we somehow get rid of this magic string?
      //       Perhaps https://stackoverflow.com/a/75064421
      if (annotationUri.pathSegments.first != 'meta_extras') continue;

      annotations.add(annotation);
    }

    return annotations;
  }
}
