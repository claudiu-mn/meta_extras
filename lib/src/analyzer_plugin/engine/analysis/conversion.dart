import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/analysis_findings.dart';

extension Conversion on AnalysisFinding {
  AnalysisErrorSeverity get analysisErrorSeverity {
    switch (type) {
      case AnalysisFindingType.info:
        return AnalysisErrorSeverity.INFO;

      case AnalysisFindingType.warning:
        return AnalysisErrorSeverity.WARNING;

      case AnalysisFindingType.error:
        return AnalysisErrorSeverity.ERROR;
    }
  }

  AnalysisErrorType get analysisErrorType {
    switch (type) {
      case AnalysisFindingType.info:
        // TODO: or LINT or TODO?
        return AnalysisErrorType.HINT;

      case AnalysisFindingType.warning:
        // TODO: or STATIC_TYPE_WARNING?
        return AnalysisErrorType.STATIC_WARNING;

      case AnalysisFindingType.error:
        // TODO: Or SYNTATIC_ERROR, or CHECKED_MODE_COMPILE_TIME_ERROR?
        return AnalysisErrorType.COMPILE_TIME_ERROR;
    }
  }

  String get analysisErrorCode {
    switch (type) {
      case AnalysisFindingType.info:
        return 'meta_extras_info';

      case AnalysisFindingType.warning:
        return 'meta_extras_warning';

      case AnalysisFindingType.error:
        return 'meta_extras_error';
    }
  }
}
