import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';

class AnnotatedNodeVisitor extends GeneralizingAstVisitor<void> {
  const AnnotatedNodeVisitor(this.onAnnotatedNode, this.onAnnotation);

  final void Function(AstNode) onAnnotatedNode;
  final void Function(Annotation) onAnnotation;

  @override
  void visitAnnotatedNode(AnnotatedNode node) {
    // TODO: Parameters don't seem to be detected by this function
    onAnnotatedNode(node);
    super.visitAnnotatedNode(node);
  }

  @override
  void visitAnnotation(Annotation node) {
    onAnnotation(node);
    super.visitAnnotation(node);
  }
}
