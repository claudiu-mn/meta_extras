import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';

@immutable
class ElementUseAstVisitor extends GeneralizingAstVisitor<void> {
  const ElementUseAstVisitor({required this.element, required this.onUse});

  final Element element;
  final void Function(AstNode) onUse;

  @override
  void visitConstructorName(ConstructorName node) {
    if (element is ConstructorElement) {
      if (node.staticElement == element) {
        onUse(node);
        return;
      }
    }

    super.visitConstructorName(node);
  }

  @override
  void visitPostfixExpression(PostfixExpression node) {
    bool isWrite = _checkAssignmentExpressionSide(node.writeElement, element);

    if (isWrite) {
      AstNode highlighted = node.operand;
      if (node.operand is PrefixedIdentifier) {
        final prefixed = node.operand as PrefixedIdentifier;
        highlighted = prefixed.identifier;
      } else if (node.operand is PropertyAccess) {
        final access = node.operand as PropertyAccess;
        highlighted = access.propertyName;
      } else {
        // TODO: What about other types?
      }
      onUse(highlighted);
    }

    super.visitPostfixExpression(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    if (element is PropertyInducingElement) {
      // bool isRead = _checkAssignmentExpressionSide(node.readElement, element);
      bool isWrite = _checkAssignmentExpressionSide(node.writeElement, element);

      // if (isRead) onUse(node.rightHandSide);
      if (isWrite) {
        AstNode highlighted = node.leftHandSide;
        if (node.leftHandSide is PrefixedIdentifier) {
          final prefixed = node.leftHandSide as PrefixedIdentifier;
          highlighted = prefixed.identifier;
        } else if (node.leftHandSide is PropertyAccess) {
          final access = node.leftHandSide as PropertyAccess;
          highlighted = access.propertyName;
        } else {
          // TODO: What about other types?
        }
        onUse(highlighted);
      }

      // if (isRead || isWrite) return;
    }

    super.visitAssignmentExpression(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.staticElement == element) {
      onUse(node);
      return;
    }

    if (node.staticElement is PropertyAccessorElement) {
      if ((node.staticElement as PropertyAccessorElement).variable == element) {
        onUse(node);
        return;
      }
    }

    super.visitSimpleIdentifier(node);
  }

  @override
  void visitArgumentList(ArgumentList node) {
    for (var arg in node.arguments) {
      if (arg.staticParameterElement == element) {
        onUse(arg);
        return;
      }
    }

    super.visitArgumentList(node);
  }

  bool _checkAssignmentExpressionSide(Element? side, Element target) {
    if (side is PropertyAccessorElement && side.variable == target) {
      return true;
    } else if (side is LocalVariableElement && side.declaration == target) {
      return true;
    } else if (side is ParameterElement && side.declaration == target) {
      return true;
    } else {
      // TODO: Handle invalid code?
    }

    return false;
  }
}
