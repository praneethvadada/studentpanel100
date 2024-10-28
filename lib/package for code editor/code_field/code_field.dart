import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For clipboard and key handling
import 'package:studentpanel100/package%20for%20code%20editor/code_field/clipboard_manager.dart';
import 'package:studentpanel100/package%20for%20code%20editor/code_field/linked_scroll_controller.dart';
import '../code_theme/code_theme.dart';
import '../line_numbers/line_number_controller.dart';
import '../line_numbers/line_number_style.dart';
import 'code_controller.dart';

class CodeField extends StatefulWidget {
  final SmartQuotesType? smartQuotesType;
  final TextInputType? keyboardType;
  final int? minLines;
  final int? maxLines;
  final bool expands;
  final bool wrap;
  final CodeController controller;
  final LineNumberStyle lineNumberStyle;
  final Color? cursorColor;
  final TextStyle? textStyle;
  final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
  final bool? enabled;
  final void Function(String)? onChanged;
  final bool readOnly;
  final bool isDense;
  final TextSelectionControls? selectionControls;
  final Color? background;
  final EdgeInsets padding;
  final Decoration? decoration;
  final TextSelectionThemeData? textSelectionTheme;
  final FocusNode? focusNode;
  final void Function()? onTap;
  final bool lineNumbers;
  final bool horizontalScroll;

  const CodeField({
    Key? key,
    required this.controller,
    this.minLines,
    this.maxLines,
    this.expands = false,
    this.wrap = false,
    this.background,
    this.decoration,
    this.textStyle,
    this.padding = EdgeInsets.zero,
    this.lineNumberStyle = const LineNumberStyle(),
    this.enabled,
    this.onTap,
    this.readOnly = false,
    this.cursorColor,
    this.textSelectionTheme,
    this.lineNumberBuilder,
    this.focusNode,
    this.onChanged,
    this.isDense = false,
    this.smartQuotesType,
    this.keyboardType,
    this.lineNumbers = true,
    this.horizontalScroll = true,
    this.selectionControls,
  }) : super(key: key);

  @override
  State<CodeField> createState() => _CodeFieldState();
}

class _CodeFieldState extends State<CodeField> {
  LinkedScrollControllerGroup? _controllers;
  ScrollController? _numberScroll;
  ScrollController? _codeScroll;
  LineNumberController? _numberController;
  FocusNode? _focusNode;
  final ClipboardManager _clipboardManager = ClipboardManager();
  ScrollController _horizontalScrollController =
      ScrollController(); // Initialize here

  @override
  void initState() {
    super.initState();
    _controllers = LinkedScrollControllerGroup();
    _numberScroll = _controllers?.addAndGet();
    _codeScroll = _controllers?.addAndGet();
    _numberController = LineNumberController(widget.lineNumberBuilder);
    widget.controller.addListener(_onTextChanged);
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode!.onKey = _onKey;
    _focusNode!.attach(context, onKey: _onKey);
    _horizontalScrollController = ScrollController();

    _onTextChanged(); // Initial call to populate line numbers
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _numberScroll?.dispose();
    _codeScroll?.dispose();
    _numberController?.dispose();
    _horizontalScrollController.dispose();

    super.dispose();
  }

  KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
    if (widget.readOnly) {
      return KeyEventResult.ignored;
    }

    if (event is RawKeyDownEvent) {
      // Intercept Ctrl+H to display clipboard history
      if (event.isControlPressed &&
          event.logicalKey == LogicalKeyboardKey.keyH) {
        _showClipboardHistory();
        return KeyEventResult.handled;
      }
      // Intercept opening braces or quotes to auto-insert matching closing characters
      if (event.logicalKey == LogicalKeyboardKey.bracketLeft ||
          event.logicalKey == LogicalKeyboardKey.braceLeft ||
          event.logicalKey == LogicalKeyboardKey.parenthesisLeft ||
          event.character == '"' ||
          event.character == "'") {
        // Check for typed quotes directly
        _handleBraceOrQuoteInsertion(event.character!);
        return KeyEventResult.handled;
      }

      // Intercept Enter key to handle indentation inside braces
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        _handleEnterKey();
        return KeyEventResult.handled;
      }

      // Intercept the Tab key press to insert custom spaces for indentation
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        _handleTabKey();
        return KeyEventResult.handled;
      }
      if (event.isControlPressed) {
        if (event.logicalKey == LogicalKeyboardKey.keyC) {
          _clipboardManager.addToClipboard(
              widget.controller.selection.textInside(widget.controller.text));
          return KeyEventResult.handled;
        }

        if (event.logicalKey == LogicalKeyboardKey.keyX) {
          _clipboardManager.addToClipboard(
              widget.controller.selection.textInside(widget.controller.text));
          widget.controller.text = widget.controller.text.replaceRange(
            widget.controller.selection.start,
            widget.controller.selection.end,
            '',
          );
          return KeyEventResult.handled;
        }

        if (event.logicalKey == LogicalKeyboardKey.keyV) {
          final pasteText = _clipboardManager.internalClipboard;
          final updatedText = widget.controller.text.replaceRange(
            widget.controller.selection.start,
            widget.controller.selection.end,
            pasteText,
          );
          widget.controller.value = TextEditingValue(
            text: updatedText,
            selection: TextSelection.collapsed(
              offset: widget.controller.selection.start + pasteText.length,
            ),
          );
          return KeyEventResult.handled;
        }
      }
    }

    // Let the controller handle other key events
    return widget.controller.onKey(event);
  }

  void _showClipboardHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Clipboard History'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: _clipboardManager.clipboardHistory
                        .asMap()
                        .entries
                        .map((entry) => Container(
                              color: entry.key % 2 == 0
                                  ? Colors.grey[200]
                                  : Colors.white,
                              child: ListTile(
                                title: Text(
                                  entry.value,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() {
                                      _clipboardManager
                                          .deleteFromClipboardHistory(
                                              entry.key);
                                    });
                                  },
                                ),
                                onTap: () {
                                  _clipboardManager.addToClipboard(entry.value);
                                  _pasteFromInternalClipboard();
                                  Navigator.of(context).pop();
                                },
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _pasteFromInternalClipboard() {
    final pasteText = _clipboardManager.internalClipboard;
    final cursorPosition = widget.controller.selection.start;
    final updatedText = widget.controller.text.replaceRange(
      cursorPosition,
      cursorPosition,
      pasteText,
    );
    widget.controller.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: cursorPosition + pasteText.length,
      ),
    );
  }

// Handle the insertion of braces and quotes with matching pairs
  void _handleBraceOrQuoteInsertion(String character) {
    String closingChar = '';
    switch (character) {
      case '{':
        closingChar = '}';
        break;
      case '[':
        closingChar = ']';
        break;
      case '(':
        closingChar = ')';
        break;
      case '"':
        closingChar = '"';
        break;
      case "'":
        closingChar = "'";
        break;
      default:
        return; // Do nothing if it's not an opening brace or quote
    }

    setState(() {
      int cursorPosition = widget.controller.selection.baseOffset;

      // Insert the opening brace/quote and matching closing brace/quote
      String updatedText = widget.controller.text;
      updatedText = updatedText.replaceRange(
          cursorPosition, cursorPosition, character + closingChar);

      // Update the controller and place the cursor between the braces/quotes
      widget.controller.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(
            offset:
                cursorPosition + 1), // Place cursor between the quotes/braces
      );
    });
  }

// Handle the Enter key inside braces for automatic indentation
  void _handleEnterKey() {
    int cursorPosition = widget.controller.selection.baseOffset;
    String textBeforeCursor =
        widget.controller.text.substring(0, cursorPosition);
    String textAfterCursor = widget.controller.text.substring(cursorPosition);

    // Check if the previous character is an opening brace and next character is a closing brace
    if (textBeforeCursor.isNotEmpty &&
        textAfterCursor.isNotEmpty &&
        textBeforeCursor.endsWith('{') &&
        textAfterCursor.startsWith('}')) {
      // Get the current line's indentation level (count spaces at the start of the line)
      String currentIndentation = _getIndentation(textBeforeCursor);

      // Add one level of indentation for the new line inside the braces
      String newIndentedLine =
          '\n' + currentIndentation + '    '; // Indent with 4 spaces

      // Create the new text with closing brace on a new indented line
      String updatedText = textBeforeCursor +
          newIndentedLine +
          '\n' +
          currentIndentation +
          textAfterCursor;

      // Update the controller text and move the cursor to the indented line
      widget.controller.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(
            offset: cursorPosition +
                newIndentedLine.length), // Place cursor at the new indent
      );
    } else {
      // Default Enter behavior (just insert a new line)
      String newText = widget.controller.text
          .replaceRange(cursorPosition, cursorPosition, '\n');
      widget.controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(
            offset: cursorPosition + 1), // Move cursor after the new line
      );
    }
  }

// Helper function to get the indentation of the current line
  String _getIndentation(String text) {
    int lastLineBreak = text.lastIndexOf('\n');
    if (lastLineBreak == -1) {
      return ''; // No previous line, no indentation
    }

    String lastLine = text.substring(lastLineBreak + 1);
    String indentation = '';
    for (int i = 0; i < lastLine.length; i++) {
      if (lastLine[i] == ' ') {
        indentation += ' ';
      } else {
        break;
      }
    }

    return indentation;
  }

  void _handleTabKey() {
    setState(() {
      int cursorPosition = widget.controller.selection.baseOffset;

      // Insert 4 spaces (for tab size)
      String updatedText = widget.controller.text;
      updatedText =
          updatedText.replaceRange(cursorPosition, cursorPosition, '    ');

      // Update the controller with new text and move the cursor accordingly
      widget.controller.value = TextEditingValue(
        text: updatedText,
        selection: TextSelection.collapsed(
            offset: cursorPosition + 4), // Move cursor after tab
      );
    });
  }

  void _onTextChanged() {
    // Rebuild line number
    final str = widget.controller.text.split('\n');
    final buf = <String>[];

    for (var k = 0; k < str.length; k++) {
      buf.add((k + 1).toString());
    }

    _numberController?.text = buf.join('\n');
    setState(() {});
  }

  Widget _wrapInScrollView(
    Widget codeField,
    TextStyle textStyle,
    double minWidth,
  ) {
    final leftPad = widget.lineNumberStyle.margin / 2;

    // Using IntrinsicWidth to maintain structure and layout consistency
    final intrinsic = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 0,
              minWidth: max(minWidth - leftPad, 0),
            ),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _clipboardManager
                    .internalClipboard, // Displaying clipboard content
                style: textStyle,
              ),
            ),
          ),
          widget.expands ? Expanded(child: codeField) : codeField,
        ],
      ),
    );

    // SingleChildScrollView to enable horizontal scrolling while keeping all existing constraints
    return Scrollbar(
      thumbVisibility: true, // Keeps scrollbar visible
      controller: _horizontalScrollController, // Attach the controller

      child: SingleChildScrollView(
        controller: _horizontalScrollController,
        // scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(
          left: leftPad,
          right: widget.padding.right,
        ),
        scrollDirection: Axis.horizontal,
        physics: widget.horizontalScroll
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics(),
        child: intrinsic,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Default color scheme
    const rootKey = 'root';
    final defaultBg = Colors.grey.shade900;
    final defaultText = Colors.grey.shade200;

    final styles = CodeTheme.of(context)?.styles;
    Color? backgroundCol =
        widget.background ?? styles?[rootKey]?.backgroundColor ?? defaultBg;

    if (widget.decoration != null) {
      backgroundCol = null;
    }

    TextStyle textStyle = widget.textStyle ?? const TextStyle();
    textStyle = textStyle.copyWith(
      color: textStyle.color ?? styles?[rootKey]?.color ?? defaultText,
      fontSize: textStyle.fontSize ?? 16.0,
    );

    TextStyle numberTextStyle =
        widget.lineNumberStyle.textStyle ?? const TextStyle();
    final numberColor =
        (styles?[rootKey]?.color ?? defaultText).withOpacity(0.7);

    // Copy important attributes
    numberTextStyle = numberTextStyle.copyWith(
      color: numberTextStyle.color ?? numberColor,
      fontSize: textStyle.fontSize,
      fontFamily: textStyle.fontFamily,
    );

    final cursorColor =
        widget.cursorColor ?? styles?[rootKey]?.color ?? defaultText;

    TextField? lineNumberCol;
    Container? numberCol;

    if (widget.lineNumbers) {
      lineNumberCol = TextField(
        smartQuotesType: widget.smartQuotesType,
        scrollPadding: widget.padding,
        style: numberTextStyle,
        controller: _numberController,
        enabled: false,
        minLines: widget.minLines,
        maxLines: widget.maxLines,
        selectionControls: widget.selectionControls,
        expands: widget.expands,
        scrollController: _numberScroll,
        decoration: InputDecoration(
          disabledBorder: InputBorder.none,
          isDense: widget.isDense,
        ),
        textAlign: widget.lineNumberStyle.textAlign,
      );

      numberCol = Container(
        width: widget.lineNumberStyle.width,
        padding: EdgeInsets.only(
          left: widget.padding.left,
          right: widget.lineNumberStyle.margin / 2,
        ),
        color: widget.lineNumberStyle.background,
        child: lineNumberCol,
      );
    }

    final codeField = GestureDetector(
      onSecondaryTap: () {
        // Disable right-click context menu
      },
      child: TextField(
        keyboardType: widget.keyboardType,
        smartQuotesType: widget.smartQuotesType,
        focusNode: _focusNode,
        onTap: widget.onTap,
        scrollPadding: widget.padding,
        style: textStyle,
        controller: widget.controller,
        minLines: widget.minLines,
        selectionControls: widget.selectionControls,
        // maxLines: widget.maxLines,
        maxLines: null, // Allow unlimited lines to wrap content to new lines

        expands: widget.expands,
        scrollController: _codeScroll,
        // scrollPhysics:
        //     const ClampingScrollPhysics(), // Limit to horizontal scroll
        scrollPhysics:
            const AlwaysScrollableScrollPhysics(), // Ensures scrollable behavior

        decoration: InputDecoration(
          disabledBorder: InputBorder.none,
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          isDense: widget.isDense,
        ),
        cursorColor: cursorColor,
        autocorrect: false,
        enableSuggestions: false,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        readOnly: widget.readOnly,
      ),
    );

    final codeCol = Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: widget.textSelectionTheme,
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          // Control horizontal scrolling
          return widget.wrap
              ? codeField
              : _wrapInScrollView(codeField, textStyle, constraints.maxWidth);
        },
      ),
    );

    return Container(
      decoration: widget.decoration,
      color: backgroundCol,
      padding: !widget.lineNumbers ? const EdgeInsets.only(left: 8) : null,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.lineNumbers && numberCol != null) numberCol,
          Expanded(child: codeCol),
        ],
      ),
    );
  }
}
