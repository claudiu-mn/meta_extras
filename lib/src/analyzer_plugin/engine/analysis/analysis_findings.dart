import 'package:analyzer/dart/analysis/results.dart';
import 'package:meta/meta.dart';

enum AnalysisFindingType { info, warning, error }

@immutable
class AnalysisFindings {
  const AnalysisFindings({required this.unit, required this.analyses});

  final ResolvedUnitResult unit;
  final Iterable<AnalysisFinding> analyses;
}

@immutable
class AnalysisFinding {
  AnalysisFinding({
    required this.type,
    required this.offset,
    required this.length,
    required this.message,
  });

  final AnalysisFindingType type;
  final int offset;
  final int length;
  final String message;
}
