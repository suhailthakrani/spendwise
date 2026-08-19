import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Input text must not use tight tracking — negative [letterSpacing] overlaps
/// glyph hit boxes so a caret drag highlights characters instead of moving.
TextStyle? appInputTextStyle(BuildContext context, [TextStyle? style]) {
  final base = style ?? Theme.of(context).textTheme.bodyLarge;
  return base?.copyWith(letterSpacing: 0);
}

/// Finger/trackpad drags on a field start a text selection. Users trying to
/// place the caret between letters get a highlight instead. Collapse those
/// drags back to a caret, while keeping long-press / double-tap word select.
class _CaretDragScope extends StatefulWidget {
  const _CaretDragScope({
    required this.controller,
    required this.child,
  });

  final TextEditingController controller;
  final Widget child;

  @override
  State<_CaretDragScope> createState() => _CaretDragScopeState();
}

class _CaretDragScopeState extends State<_CaretDragScope> {
  var _dragging = false;
  var _applying = false;
  Offset? _down;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_collapseDragSelection);
  }

  @override
  void didUpdateWidget(_CaretDragScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_collapseDragSelection);
      widget.controller.addListener(_collapseDragSelection);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_collapseDragSelection);
    super.dispose();
  }

  void _collapseDragSelection() {
    if (_applying || !_dragging) return;
    final selection = widget.controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    final length = (selection.end - selection.start).abs();
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.android);
    // Desktop: keep real drag-select, but ignore 1–3 glyph sloppy clicks.
    if (!isMobile && length > 3) return;

    final caret = TextSelection.collapsed(
      offset: selection.extentOffset.clamp(0, widget.controller.text.length),
    );
    if (selection == caret) return;
    _applying = true;
    widget.controller.selection = caret;
    _applying = false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _down = event.localPosition;
        _dragging = false;
      },
      onPointerMove: (event) {
        final origin = _down;
        if (origin == null) return;
        if ((event.localPosition - origin).distance >= kTouchSlop) {
          _dragging = true;
        }
      },
      onPointerUp: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _dragging = false;
          _down = null;
        });
      },
      onPointerCancel: (_) {
        _dragging = false;
        _down = null;
      },
      child: widget.child,
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.obscureText = false,
    this.enabled,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool autofocus;
  final bool obscureText;
  final bool? enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final GestureTapCallback? onTap;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _controller;
  var _ownsController = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      _ownsController = widget.controller == null;
      _controller = widget.controller ?? TextEditingController();
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CaretDragScope(
      controller: _controller,
      child: TextField(
        controller: _controller,
        focusNode: widget.focusNode,
        decoration: widget.decoration,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: appInputTextStyle(context, widget.style),
        textAlign: widget.textAlign,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        minLines: widget.minLines,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        autofillHints: widget.autofillHints,
        smartDashesType: SmartDashesType.disabled,
        smartQuotesType: SmartQuotesType.disabled,
        stylusHandwritingEnabled: false,
      ),
    );
  }
}

class AppTextFormField extends StatefulWidget {
  const AppTextFormField({
    super.key,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.textAlign = TextAlign.start,
    this.autofocus = false,
    this.obscureText = false,
    this.enabled,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.inputFormatters,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.autofillHints,
    this.validator,
    this.autovalidateMode,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextAlign textAlign;
  final bool autofocus;
  final bool obscureText;
  final bool? enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final GestureTapCallback? onTap;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  State<AppTextFormField> createState() => _AppTextFormFieldState();
}

class _AppTextFormFieldState extends State<AppTextFormField> {
  late TextEditingController _controller;
  var _ownsController = false;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller = widget.controller ??
        TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(AppTextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _controller.dispose();
      }
      _ownsController = widget.controller == null;
      _controller = widget.controller ??
          TextEditingController(text: widget.initialValue);
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _CaretDragScope(
      controller: _controller,
      child: TextFormField(
        controller: _controller,
        focusNode: widget.focusNode,
        decoration: widget.decoration,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: appInputTextStyle(context, widget.style),
        textAlign: widget.textAlign,
        autofocus: widget.autofocus,
        obscureText: widget.obscureText,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        minLines: widget.minLines,
        inputFormatters: widget.inputFormatters,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onFieldSubmitted,
        onTap: widget.onTap,
        autofillHints: widget.autofillHints,
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode,
        smartDashesType: SmartDashesType.disabled,
        smartQuotesType: SmartQuotesType.disabled,
        stylusHandwritingEnabled: false,
      ),
    );
  }
}
