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
    if (state == null || !state.mounted) return;
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
    if (state == null || !state.mounted) return;
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

// ─────────────────────────────────────────────────────────────────────────────
// Helpers de dimensão
//
// Largura natural calculada exatamente:
//   padding lateral: 2 × 12 = 24
//   row1 (10 teclas): cada _Key tem padding horizontal sp/2 de cada lado
//     → largura por tecla = keyW + sp = 36 + 4 = 40
//     → 10 × 40 = 400
//   total = 24 + 400 = 424 + 4 de margem = 428px
//
// Scale = avW / 428 → teclado sempre cabe sem overflow
// ─────────────────────────────────────────────────────────────────────────────
const double _kbNaturalWidth = 446.0;

double _kbWidth(double avW) => avW.clamp(0.0, _kbNaturalWidth);
double _kbScale(double avW) =>
    (_kbWidth(avW) / _kbNaturalWidth).clamp(0.1, 1.0);
double _kbHeight(double avW) => 180.0 * _kbScale(avW);

// ─────────────────────────────────────────────────────────────────────────────
// Widget raiz
// ─────────────────────────────────────────────────────────────────────────────
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

    final keyboardBox =
        _keyboardKey.currentContext?.findRenderObject() as RenderBox?;
    if (keyboardBox != null) {
      final rect = keyboardBox.localToGlobal(Offset.zero) & keyboardBox.size;
      if (rect.contains(event.position)) return;
    }

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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final avW = constraints.maxWidth;
          final avH = constraints.maxHeight;

          return Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Positioned.fill(child: widget.child),
              if (_kb.visible)
                _FloatingKeyboard(
                  kb: _kb,
                  keyboardKey: _keyboardKey,
                  avW: avW,
                  avH: avH,
                ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Teclado flutuante
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingKeyboard extends StatefulWidget {
  const _FloatingKeyboard({
    required this.kb,
    required this.keyboardKey,
    required this.avW,
    required this.avH,
  });
  final VirtualKeyboardController kb;
  final GlobalKey keyboardKey;
  final double avW;
  final double avH;

  @override
  State<_FloatingKeyboard> createState() => _FloatingKeyboardState();
}

class _FloatingKeyboardState extends State<_FloatingKeyboard> {
  Offset? _position;
  Offset? _lastFieldPos;

  Offset _defaultPosition(double kbW, double kbH) {
    final fieldTop = widget.kb.fieldPosition.dy;
    final fieldBottom = fieldTop + widget.kb.fieldHeight;

    final left = ((widget.avW - kbW) / 2).clamp(0.0, widget.avW - kbW);
    double top = widget.avH - kbH - 16;

    if (fieldBottom > top - 8) {
      top = (fieldTop - kbH - 8).clamp(0.0, widget.avH - kbH);
    }

    return Offset(left, top);
  }

  @override
  Widget build(BuildContext context) {
    final kbW = _kbWidth(widget.avW);
    final kbH = _kbHeight(widget.avW);

    final fieldPos = widget.kb.fieldPosition;
    if (_position == null || _lastFieldPos != fieldPos) {
      _lastFieldPos = fieldPos;
      _position = _defaultPosition(kbW, kbH);
    }

    final safeLeft = _position!.dx.clamp(0.0, widget.avW - kbW);
    final safeTop = _position!.dy.clamp(0.0, widget.avH - kbH);

    return Positioned(
      left: safeLeft,
      top: safeTop,
      width: kbW,
      child: Material(
        key: widget.keyboardKey,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    _position = Offset(
                      (_position!.dx + details.delta.dx)
                          .clamp(0.0, widget.avW - kbW),
                      (_position!.dy + details.delta.dy)
                          .clamp(0.0, widget.avH - kbH),
                    );
                  });
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: const BoxDecoration(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xffcbd5e1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              _KeyboardWidget(kb: widget.kb, avW: widget.avW),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Teclas
// ─────────────────────────────────────────────────────────────────────────────
class _KeyboardWidget extends StatelessWidget {
  const _KeyboardWidget({required this.kb, required this.avW});
  final VirtualKeyboardController kb;
  final double avW;

  static const _row1 = ['q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p'];
  static const _row2 = ['a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l'];
  static const _row3 = ['z', 'x', 'c', 'v', 'b', 'n', 'm'];
  static const _numbers = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0'];
  static const _symbols = ['!', '@', '#', r'$', '%', '&', '*', '(', ')', '-'];

  @override
  Widget build(BuildContext context) {
    final upper = kb._uppercase;
    final s = _kbScale(avW);

    final keyW = 36.0 * s;
    final keyH = 42.0 * s;
    final sp = 4.0 * s;
    final rowSp = 6.0 * s;
    final fs = 15.0 * s;
    final fsS = 11.0 * s;

    final kbW = _kbWidth(avW);
    final innerW = kbW - 2 * 12 * s;
    final spaceW = (innerW - (44 * s + sp + 52 * s + sp + 44 * s + sp * 3))
        .clamp(40 * s, 230 * s);

    return Padding(
      padding: EdgeInsets.fromLTRB(12 * s, 0, 12 * s, 16 * s),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _row(upper ? _symbols : _numbers,
              upper: false, keyW: keyW, keyH: keyH, sp: sp, fs: fs, fsS: fsS),
          SizedBox(height: rowSp),
          _row(_row1,
              upper: upper, keyW: keyW, keyH: keyH, sp: sp, fs: fs, fsS: fsS),
          SizedBox(height: rowSp),
          _row(_row2,
              upper: upper, keyW: keyW, keyH: keyH, sp: sp, fs: fs, fsS: fsS),
          SizedBox(height: rowSp),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _ShiftKey(kb: kb, w: 46 * s, h: keyH),
              SizedBox(width: sp),
              ..._row3.map<Widget>((k) => _Key(
                    label: upper ? k.toUpperCase() : k,
                    onTap: () => kb._type(upper ? k.toUpperCase() : k),
                    w: keyW,
                    h: keyH,
                    sp: sp,
                    fs: fs,
                    fsS: fsS,
                  )),
              SizedBox(width: sp),
              _BackspaceKey(kb: kb, w: 46 * s, h: keyH),
            ],
          ),
          SizedBox(height: rowSp),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _Key(
                  label: '.,',
                  onTap: () => kb._type('.'),
                  w: 44 * s,
                  h: keyH,
                  sp: sp,
                  fs: fsS,
                  fsS: fsS),
              SizedBox(width: sp),
              _Key(
                  label: 'Espaço',
                  onTap: () => kb._type(' '),
                  w: spaceW,
                  h: keyH,
                  sp: 0,
                  fs: fsS,
                  fsS: fsS),
              SizedBox(width: sp),
              _Key(
                  label: '↵',
                  onTap: () => kb._type('\n'),
                  w: 52 * s,
                  h: keyH,
                  sp: sp,
                  fs: fs,
                  fsS: fsS),
              SizedBox(width: sp),
              GestureDetector(
                onTap: kb.hide,
                child: Container(
                  width: 44 * s,
                  height: keyH,
                  decoration: BoxDecoration(
                    color: const Color(0xffcbd5e1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.keyboard_hide_outlined,
                      size: 20 * s, color: const Color(0xff475569)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(List<String> keys,
      {required bool upper,
      required double keyW,
      required double keyH,
      required double sp,
      required double fs,
      required double fsS}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: keys
          .map<Widget>((k) => _Key(
                label: upper ? k.toUpperCase() : k,
                onTap: () => kb._type(upper ? k.toUpperCase() : k),
                w: keyW,
                h: keyH,
                sp: sp,
                fs: fs,
                fsS: fsS,
              ))
          .toList(),
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({
    required this.label,
    required this.onTap,
    required this.h,
    required this.sp,
    required this.fs,
    required this.fsS,
    this.w,
  });
  final String label;
  final VoidCallback onTap;
  final double? w;
  final double h;
  final double sp;
  final double fs;
  final double fsS;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sp / 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: w,
          height: h,
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
                fontSize: label.length > 1 ? fsS : fs,
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
  const _ShiftKey({required this.kb, required this.w, required this.h});
  final VirtualKeyboardController kb;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    final active = kb._shift || kb._capsLock;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: kb._toggleShift,
        onDoubleTap: kb._toggleCaps,
        child: Container(
          width: w,
          height: h,
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
  const _BackspaceKey({required this.kb, required this.w, required this.h});
  final VirtualKeyboardController kb;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: GestureDetector(
        onTap: kb._backspace,
        child: Container(
          width: w,
          height: h,
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
