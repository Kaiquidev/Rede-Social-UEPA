import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VirtualKeyboardController extends ChangeNotifier {
  VirtualKeyboardController._();
  static final instance = VirtualKeyboardController._();

  bool _visible = false;
  bool _capsLock = false;
  bool _shift = false;
  bool _suppressed = false;
  EditableTextState? _editableState;
  Offset _fieldPosition = Offset.zero;
  double _fieldHeight = 0;

  bool get visible => _visible;
  bool get _uppercase => _capsLock || _shift;
  Offset get fieldPosition => _fieldPosition;
  double get fieldHeight => _fieldHeight;

  void activateAndShow(
      EditableTextState state, Offset position, double height) {
    _suppressed = false;
    _editableState = state;
    _fieldPosition = position;
    _fieldHeight = height;
    if (!_visible) {
      _visible = true;
      notifyListeners();
    }
  }

  void hide() {
    if (!_visible) return;
    _visible = false;
    _shift = false;
    _suppressed = true;
    Future.delayed(const Duration(milliseconds: 350), () {
      _suppressed = false;
    });
    notifyListeners();
  }

  void _type(String char) {
    final state = _editableState;
    if (state == null) return;
    final value = state.textEditingValue;
    final sel = value.selection.isValid
        ? value.selection
        : TextRange.collapsed(value.text.length);
    state.updateEditingValue(value.replaced(sel, char));
    if (_shift && !_capsLock) {
      _shift = false;
      notifyListeners();
    }
  }

  void _backspace() {
    final state = _editableState;
    if (state == null) return;
    final value = state.textEditingValue;
    final text = value.text;
    if (text.isEmpty) return;
    final sel = value.selection;
    final start = sel.isValid ? sel.start : text.length;
    final end = sel.isValid ? sel.end : text.length;
    TextEditingValue newValue;
    if (start != end) {
      newValue = value.replaced(sel, '');
    } else if (start > 0) {
      newValue = value.replaced(TextRange(start: start - 1, end: start), '');
    } else {
      return;
    }
    state.updateEditingValue(newValue);
  }

  void _toggleShift() {
    _shift = !_shift;
    notifyListeners();
  }

  void _toggleCaps() {
    _capsLock = !_capsLock;
    _shift = false;
    notifyListeners();
  }
}

class VirtualKeyboard extends StatefulWidget {
  const VirtualKeyboard({super.key, required this.child});
  final Widget child;

  @override
  State<VirtualKeyboard> createState() => _VirtualKeyboardState();
}

class _VirtualKeyboardState extends State<VirtualKeyboard> {
  final _kb = VirtualKeyboardController.instance;
  final _keyboardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _kb.addListener(_rebuild);
    HardwareKeyboard.instance.addHandler(_onPhysicalKey);
  }

  @override
  void dispose() {
    _kb.removeListener(_rebuild);
    HardwareKeyboard.instance.removeHandler(_onPhysicalKey);
    super.dispose();
  }

  void _rebuild() => setState(() {});
  bool _onPhysicalKey(KeyEvent event) => false;

  void _onPointerDown(PointerDownEvent event) {
    if (_kb._suppressed) return;

    // Clicou dentro do teclado? Não faz nada
    final keyboardBox =
        _keyboardKey.currentContext?.findRenderObject() as RenderBox?;
    if (keyboardBox != null) {
      final rect = keyboardBox.localToGlobal(Offset.zero) & keyboardBox.size;
      if (rect.contains(event.position)) return;
    }

    // Clicou num TextField? Abre o teclado
    EditableTextState? foundField;
    RenderBox? fieldBox;

    void visitor(Element element) {
      if (foundField != null) return;
      if (element is StatefulElement && element.state is EditableTextState) {
        final ro = element.renderObject;
        if (ro is RenderBox && ro.hasSize) {
          final rect = ro.localToGlobal(Offset.zero) & ro.size;
          if (rect.contains(event.position)) {
            foundField = element.state as EditableTextState;
            fieldBox = ro;
          }
        }
      }
      element.visitChildren(visitor);
    }

    context.visitChildElements(visitor);

    if (foundField != null && fieldBox != null) {
      final pos = fieldBox!.localToGlobal(Offset.zero);
      _kb.activateAndShow(foundField!, pos, fieldBox!.size.height);
    } else if (_kb.visible) {
      _kb.hide();
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: [
          widget.child,
          if (_kb.visible)
            _FloatingKeyboard(kb: _kb, keyboardKey: _keyboardKey),
        ],
      ),
    );
  }
}

/// Teclado flutuante posicionado como card abaixo do campo clicado
class _FloatingKeyboard extends StatelessWidget {
  const _FloatingKeyboard({required this.kb, required this.keyboardKey});
  final VirtualKeyboardController kb;
  final GlobalKey keyboardKey;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final keyboardWidth = screenSize.width.clamp(0.0, 680.0);
    const keyboardEstimatedHeight = 280.0;

    // Centraliza horizontalmente
    final left =
        ((screenSize.width - keyboardWidth) / 2).clamp(0.0, screenSize.width);

    // Posiciona abaixo do campo
    double top = kb.fieldPosition.dy + kb.fieldHeight + 8;
    if (top + keyboardEstimatedHeight > screenSize.height - 20) {
      top = kb.fieldPosition.dy - keyboardEstimatedHeight - 8;
    }
    if (top < 60) top = 60;

    return Positioned(
      left: left,
      top: top,
      width: keyboardWidth,
      child: Material(
        key: keyboardKey,
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xfff8fafc),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xffe2e8f0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: _KeyboardWidget(kb: kb),
        ),
      ),
    );
  }
}

class _KeyboardWidget extends StatelessWidget {
  const _KeyboardWidget({required this.kb});
  final VirtualKeyboardController kb;

  static const _row1 = ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'];
  static const _row2 = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'];
  static const _row3 = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];
  static const _numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  static const _symbols = ['!', '@', '#', r'$', '%', '&', '*', '(', ')', '-'];

  @override
  Widget build(BuildContext context) {
    final upper = kb._uppercase;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle de arrastar (visual)
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: const Color(0xffcbd5e1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildRow(upper ? _symbols : _numbers, upper: false),
          const SizedBox(height: 6),
          _buildRow(_row1, upper: upper),
          const SizedBox(height: 6),
          _buildRow(_row2, upper: upper),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ShiftKey(kb: kb),
              const SizedBox(width: 4),
              ..._row3.map<Widget>((k) => _Key(
                    label: upper ? k.toUpperCase() : k,
                    onTap: () => kb._type(upper ? k.toUpperCase() : k),
                  )),
              const SizedBox(width: 4),
              _BackspaceKey(kb: kb),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _Key(label: '.,', width: 44, onTap: () => kb._type('.')),
              const SizedBox(width: 4),
              Expanded(
                  child: _Key(label: 'Espaço', onTap: () => kb._type(' '))),
              const SizedBox(width: 4),
              _Key(label: '↵', width: 52, onTap: () => kb._type('\n')),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: kb.hide,
                child: Container(
                  width: 44,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xffcbd5e1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.keyboard_hide_outlined,
                      size: 20, color: Color(0xff475569)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys, {required bool upper}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: keys
          .map<Widget>((k) => _Key(
                label: upper ? k.toUpperCase() : k,
                onTap: () => kb._type(upper ? k.toUpperCase() : k),
              ))
          .toList(),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap, this.width});
  final String label;
  final VoidCallback onTap;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width ?? 36,
          height: 42,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffcbd5e1)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xffcbd5e1), blurRadius: 0, offset: Offset(0, 2))
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: label.length > 1 ? 11 : 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xff1e293b),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ShiftKey extends StatelessWidget {
  const _ShiftKey({required this.kb});
  final VirtualKeyboardController kb;

  @override
  Widget build(BuildContext context) {
    final active = kb._shift || kb._capsLock;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: kb._toggleShift,
        onDoubleTap: kb._toggleCaps,
        child: Container(
          width: 46,
          height: 42,
          decoration: BoxDecoration(
            color: active ? const Color(0xff1877f2) : const Color(0xffe2e8f0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color:
                    active ? const Color(0xff1877f2) : const Color(0xffcbd5e1)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xffcbd5e1), blurRadius: 0, offset: Offset(0, 2))
            ],
          ),
          child: Icon(
            kb._capsLock ? Icons.keyboard_capslock : Icons.keyboard_arrow_up,
            size: 20,
            color: active ? Colors.white : const Color(0xff475569),
          ),
        ),
      ),
    );
  }
}

class _BackspaceKey extends StatelessWidget {
  const _BackspaceKey({required this.kb});
  final VirtualKeyboardController kb;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: kb._backspace,
        child: Container(
          width: 46,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xffe2e8f0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffcbd5e1)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0xffcbd5e1), blurRadius: 0, offset: Offset(0, 2))
            ],
          ),
          child: const Icon(Icons.backspace_outlined,
              size: 18, color: Color(0xff475569)),
        ),
      ),
    );
  }
}
