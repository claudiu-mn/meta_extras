import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer_plugin/plugin/plugin.dart';
import 'package:analyzer_plugin/protocol/protocol_common.dart';
import 'package:analyzer_plugin/protocol/protocol_generated.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/analysis/conversion.dart';
import 'package:meta_extras/src/analyzer_plugin/engine/engine.dart';

class MetaExtrasPlugin extends ServerPlugin {
  MetaExtrasPlugin({required super.resourceProvider});

  @override
  List<String> get fileGlobsToAnalyze => const ['*.dart'];

  @override
  String get name => 'ME 1.0.0';

  @override
  String? get contactInfo => 'https://claudiu.mn';

  @override
  String get version => '1.0.0-alpha.0';

  final _results = <String, ResolvedUnitResult>{};

  @override
  Future<void> analyzeFiles({
    required AnalysisContext analysisContext,
    required List<String> paths,
  }) async {
    await super.analyzeFiles(analysisContext: analysisContext, paths: paths);

    await kEngine.run(_results.values).forEach((findings) {
      channel.sendNotification(
        AnalysisErrorsParams(
          findings.unit.path,
          findings.analyses.map((a) {
            final charLocation = findings.unit.lineInfo.getLocation(a.offset);

            return AnalysisError(
              a.analysisErrorSeverity,
              a.analysisErrorType,
              Location(
                findings.unit.path,
                a.offset,
                a.length,
                charLocation.lineNumber,
                charLocation.columnNumber,
              ),
              a.message,
              a.analysisErrorCode,
            );
          }).toList(),
        ).toNotification(),
      );
    });
  }

  @override
  Future<void> analyzeFile({
    required AnalysisContext analysisContext,
    required String path,
  }) async {
    if (!analysisContext.contextRoot.isAnalyzed(path)) return;

    // TODO: Added because fileGlobsToAnalyze seems to not do anything
    if (!path.endsWith('.dart')) return;

    try {
      _results[path] = await getResolvedUnitResult(path);
    } catch (e, stackTrace) {
      channel.sendNotification(
        PluginErrorParams(
          true, // false,
          e.toString(),
          stackTrace.toString(),
        ).toNotification(),
      );
    }
  }
}
