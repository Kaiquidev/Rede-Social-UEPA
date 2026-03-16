import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Envolve o app inteiro e permite rolar a página
/// clicando e arrastando com o botão esquerdo do mouse.
/// Funciona simultaneamente com scroll do mouse e teclado.
class MouseScrollWrapper extends StatefulWidget {
  const MouseScrollWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<MouseScrollWrapper> createState() => _MouseScrollWrapperState();
}

class _MouseScrollWrapperState extends State<MouseScrollWrapper> {
  bool _isDragging = false;
  double _lastY = 0;
  double _lastX = 0;

  // ScrollPosition capturada no momento do PointerDown
  ScrollPosition? _activePosition;

  void _onPointerDown(PointerDownEvent event) {
    if (event.buttons == kPrimaryMouseButton) {
      _isDragging = true;
      _lastY = event.position.dy;
      _lastX = event.position.dx;
      // Captura o scrollable mais profundo sob o ponto clicado
      _activePosition = _findDeepestScrollAt(event.position);
      // Se não encontrou nada específico, pega o primeiro scrollable da página
      _activePosition ??= _findFirstScroll();
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (!_isDragging) return;
    if (event.buttons != kPrimaryMouseButton) {
      _isDragging = false;
      return;
    }

    final dy = _lastY - event.position.dy;
    final dx = _lastX - event.position.dx;
    _lastY = event.position.dy;
    _lastX = event.position.dx;

    final pos = _activePosition;
    if (pos == null) return;

    if (pos.axis == Axis.vertical) {
      final newOffset = (pos.pixels + dy).clamp(
        pos.minScrollExtent,
        pos.maxScrollExtent,
      );
      pos.jumpTo(newOffset);
    } else {
      final newOffset = (pos.pixels + dx).clamp(
        pos.minScrollExtent,
        pos.maxScrollExtent,
      );
      pos.jumpTo(newOffset);
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    _isDragging = false;
    _activePosition = null;
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _isDragging = false;
    _activePosition = null;
  }

  /// Encontra o Scrollable mais profundo sob [globalPosition].
  ScrollPosition? _findDeepestScrollAt(Offset globalPosition) {
    ScrollPosition? found;

    void visitor(Element element) {
      if (element is StatefulElement && element.state is ScrollableState) {
        final ro = element.renderObject;
        if (ro is RenderBox && ro.hasSize) {
          final rect = ro.localToGlobal(Offset.zero) & ro.size;
          if (rect.contains(globalPosition)) {
            // Continua descendo — queremos o mais profundo
            found = (element.state as ScrollableState).position;
          }
        }
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return found;
  }

  /// Fallback: retorna o primeiro Scrollable vertical encontrado na árvore.
  ScrollPosition? _findFirstScroll() {
    ScrollPosition? found;

    void visitor(Element element) {
      if (found != null) return;
      if (element is StatefulElement && element.state is ScrollableState) {
        final pos = (element.state as ScrollableState).position;
        if (pos.axis == Axis.vertical) {
          found = pos;
          return;
        }
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);
    return found;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      onPointerMove: _onPointerMove,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
