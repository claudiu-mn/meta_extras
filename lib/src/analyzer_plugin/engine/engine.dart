import 'package:analyzer/dart/analysis/results.dart';
import 'package:meta/meta.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/analysis_findings.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/annotation_pointers/annotation_pointer.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/annotation_pointers/annotation_pointer_finder.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/annotation_points/annotation_point.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/annotation_points/annotation_point_finder.dart';

const kEngine = _Engine();

@immutable
class _Engine {
  const _Engine();

  Stream<AnalysisFindings> run(Iterable<ResolvedUnitResult> units) async* {
    final points = <AnnotationPoint>[];

    for (var unit in units) {
      points.addAll(AnnotationPointFinder(unit).find());
    }

    if (points.isEmpty) return;

    for (final unit in units) {
      final analyses = <AnalysisFinding>[];
      for (final point in points) {
        await kAnnotationPointerFinder.run(unit, point).forEach((pointers) {
          for (final pointer in pointers) {
            for (final annotation in pointer.annotations) {
              analyses.add(AnalysisFinding(
                type: annotation.type.toAnalysisFindingType(),
                offset: pointer.nameOffset,
                length: pointer.nameLength,
                message: annotation.message,
              ));
            }
          }
        });
      }
      yield AnalysisFindings(unit: unit, analyses: analyses);
    }
  }
}

extension Conversion on AnnotationType {
  AnalysisFindingType toAnalysisFindingType() {
    switch (this) {
      case AnnotationType.info:
        return AnalysisFindingType.info;

      case AnnotationType.warning:
        return AnalysisFindingType.warning;

      case AnnotationType.error:
        return AnalysisFindingType.error;
    }
  }
}
