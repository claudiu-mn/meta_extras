import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:meta/meta.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/annotation_pointers/annotation_pointer.dart'
    as pointer;
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/annotation_pointers/element_use_ast_visitor.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/annotation_points/annotation_point.dart';
import 'package:meta_extras/src/annotations/annotations.dart';

const kAnnotationPointerFinder = _AnnotationPointerFinder();

@immutable
class _AnnotationPointerFinder {
  const _AnnotationPointerFinder();

  Stream<Iterable<pointer.AnnotationPointer>> run(
    ResolvedUnitResult unitResult,
    AnnotationPoint point,
  ) async* {
    final pointers = <pointer.AnnotationPointer>[];

    unitResult.unit.visitChildren(ElementUseAstVisitor(
      element: point.target,
      onUse: (node) {
        pointers.add(_getPointer(unitResult.path, node, point));
      },
    ));

    yield pointers;
  }

  pointer.AnnotationPointer _getPointer(
    String filePath,
    AstNode node,
    AnnotationPoint point,
  ) {
    final pointerAnnotations = <pointer.Annotation>[];

    for (var annotation in point.annotations) {
      final library = annotation.element!.library!;

      final dartObj = annotation.computeConstantValue()!;
      final theClass = dartObj.type!.element!;

      // TODO: Can we make this a `switch`?
      if (theClass.id == library.getClass('$Warning')!.id) {
        pointerAnnotations.add(pointer.Annotation(
          type: pointer.AnnotationType.warning,
          message: dartObj.getField('message')!.toStringValue()!,
        ));
      } else if (theClass.id == library.getClass('$Info')!.id) {
        pointerAnnotations.add(pointer.Annotation(
          type: pointer.AnnotationType.info,
          message: dartObj.getField('message')!.toStringValue()!,
        ));
      } else if (theClass.id == library.getClass('$Error')!.id) {
        pointerAnnotations.add(pointer.Annotation(
          type: pointer.AnnotationType.error,
          message: dartObj.getField('message')!.toStringValue()!,
        ));
      }
    }

    return pointer.AnnotationPointer(
      filePath: filePath,
      nameOffset: node.offset,
      nameLength: node.length,
      annotations: pointerAnnotations,
    );
  }
}
