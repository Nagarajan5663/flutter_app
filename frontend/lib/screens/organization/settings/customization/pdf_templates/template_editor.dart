import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class _RichTextStyleRange {
  int start;
  int end;

  TextStyle? fontStyle;
  double? fontSize;
  FontWeight? fontWeight;

  _RichTextStyleRange({
    required this.start,
    required this.end,
    this.fontStyle,
    this.fontSize,
    this.fontWeight,
  });
}

class _RichTemplateController extends TextEditingController {
  final List<_RichTextStyleRange> styles = [];

  _RichTemplateController({
    String? text,
  }) : super(text: text);

  void applyStyle({
    required int start,
    required int end,
    TextStyle? fontStyle,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    if (start < 0 || end <= start || end > text.length) {
      return;
    }

    styles.add(
      _RichTextStyleRange(
        start: start,
        end: end,
        fontStyle: fontStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );

    notifyListeners();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (text.isEmpty || styles.isEmpty) {
      return TextSpan(
        text: text,
        style: style,
      );
    }

    final List<InlineSpan> children = [];
    int index = 0;

    while (index < text.length) {
      _RichTextStyleRange? active;

      for (final item in styles.reversed) {
        if (index >= item.start && index < item.end) {
          active = item;
          break;
        }
      }

      int next = text.length;

      for (final item in styles) {
        if (item.start > index) {
          next = next < item.start ? next : item.start;
        }

        if (active != null && item.end > index) {
          next = next < item.end ? next : item.end;
        }
      }

      if (active != null) {
        next = active.end.clamp(index + 1, text.length);
      }

      children.add(
        TextSpan(
          text: text.substring(index, next),
          style: active?.fontStyle?.copyWith(
                fontSize: active.fontSize ??
                    active.fontStyle?.fontSize ??
                    style?.fontSize,
                fontWeight: active.fontWeight ??
                    active.fontStyle?.fontWeight ??
                    style?.fontWeight,
                color: style?.color,
                height: style?.height,
              ) ??
              style?.copyWith(
                fontSize: active?.fontSize,
                fontWeight: active?.fontWeight,
              ),
        ),
      );

      index = next;
    }

    return TextSpan(
      style: style,
      children: children,
    );
  }
}

class TemplateEditor extends StatefulWidget {
  final TextEditingController controller;

  const TemplateEditor({
    super.key,
    required this.controller,
  });

  @override
  State<TemplateEditor> createState() =>
      _TemplateEditorState();
}

class _TemplateEditorState
    extends State<TemplateEditor> {
  String _font = 'System Font';
  String _fontSize = '12pt';
  String _paragraph = 'Paragraph';
  TextSelection _savedSelection =
      const TextSelection.collapsed(offset: 0);
  final List<TextEditingValue> _undoStack = [];
  final List<TextEditingValue> _redoStack = [];
  late TextEditingValue _lastEditorValue;
  late final _RichTemplateController _richController;
  bool _updatingHistory = false;

  @override
  void initState() {
    super.initState();

    _richController = _RichTemplateController(
      text: widget.controller.text,
    );
    _richController.selection = widget.controller.selection;
    _lastEditorValue = widget.controller.value;
    widget.controller.addListener(_recordEditorChange);
    _richController.addListener(_syncRichController);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_recordEditorChange);
    _richController.removeListener(_syncRichController);
    _richController.dispose();
    super.dispose();
  }

  void _syncRichController() {
    final TextSelection selection = _richController.selection;

    if (selection.isValid && !selection.isCollapsed) {
      _savedSelection = selection;
    }

    if (widget.controller.text != _richController.text) {
      widget.controller.value = TextEditingValue(
        text: _richController.text,
        selection: selection,
      );
    } else {
      widget.controller.selection = selection;
    }
  }

  TextSelection _activeFormattingSelection() {
    final TextSelection current = _richController.selection;

    if (current.isValid && !current.isCollapsed) {
      _savedSelection = current;
      return current;
    }

    if (_savedSelection.isValid &&
        !_savedSelection.isCollapsed &&
        _savedSelection.start >= 0 &&
        _savedSelection.end <= _richController.text.length) {
      return _savedSelection;
    }

    return const TextSelection.collapsed(offset: 0);
  }

  void _recordEditorChange() {
    if (_updatingHistory) return;

    final TextEditingValue currentValue = widget.controller.value;
    if (currentValue == _lastEditorValue) return;

    _undoStack.add(_lastEditorValue);
    _redoStack.clear();
    _lastEditorValue = currentValue;
  }

  void _applyEditorValue(TextEditingValue value) {
    _updatingHistory = true;
    widget.controller.value = value;
    _richController.value = value;
    _lastEditorValue = value;
    _updatingHistory = false;
  }

  void _undoEdit() {
    if (_undoStack.isEmpty) return;
    _redoStack.add(widget.controller.value);
    _applyEditorValue(_undoStack.removeLast());
  }

  void _redoEdit() {
    if (_redoStack.isEmpty) return;
    _undoStack.add(widget.controller.value);
    _applyEditorValue(_redoStack.removeLast());
  }

  TextRange _selectedRange() {
    final TextSelection selection = _richController.selection;
    if (!selection.isValid) {
      return const TextRange(start: 0, end: 0);
    }
    final int start = selection.start < 0 ? 0 : selection.start;
    final int end = selection.end < 0
        ? widget.controller.text.length
        : selection.end;
    return TextRange(
      start: start <= end ? start : end,
      end: start <= end ? end : start,
    );
  }

  Future<void> _copyEdit() async {
    final TextRange range = _selectedRange();
    if (range.isCollapsed) return;
    await Clipboard.setData(
      ClipboardData(text: widget.controller.text.substring(range.start, range.end)),
    );
  }

  Future<void> _cutEdit() async {
    final TextRange range = _selectedRange();
    if (range.isCollapsed) return;
    await _copyEdit();
    _applyEditorValue(
      widget.controller.value.copyWith(
        text: widget.controller.text.replaceRange(range.start, range.end, ''),
        selection: TextSelection.collapsed(offset: range.start),
      ),
    );
  }

  Future<void> _pasteEdit() async {
    final ClipboardData? data = await Clipboard.getData('text/plain');
    final String? pastedText = data?.text;
    if (pastedText == null) return;

    final TextRange range = _selectedRange();
    final String updatedText = widget.controller.text.replaceRange(
      range.start,
      range.end,
      pastedText,
    );
    _applyEditorValue(
      widget.controller.value.copyWith(
        text: updatedText,
        selection: TextSelection.collapsed(
          offset: range.start + pastedText.length,
        ),
      ),
    );
  }

  void _selectAllEdit() {
    _richController.selection = TextSelection(
      baseOffset: 0,
      extentOffset: widget.controller.text.length,
    );
  }

  TextStyle _getSelectedFontStyle(String font) {
    switch (font) {
      case 'Arial':
        return GoogleFonts.roboto();
      case 'Arial Black':
        return GoogleFonts.anton();
      case 'Book Antiqua':
        return GoogleFonts.libreBaskerville();
      case 'Comic Sans MS':
        return GoogleFonts.comicNeue();
      case 'Courier New':
        return GoogleFonts.robotoMono();
      case 'Georgia':
        return GoogleFonts.merriweather();
      case 'Helvetica':
        return GoogleFonts.openSans();
      case 'Impact':
        return GoogleFonts.oswald(fontWeight: FontWeight.w700);
      case 'Tahoma':
        return GoogleFonts.notoSans();
      case 'Terminal':
        return GoogleFonts.sourceCodePro();
      case 'Times New Roman':
        return GoogleFonts.tinos();
      case 'Trebuchet MS':
        return GoogleFonts.lato();
      case 'Verdana':
        return GoogleFonts.nunitoSans();
      case 'Andale Mono':
        return GoogleFonts.spaceMono();
      default:
        return GoogleFonts.roboto();
    }
  }

  void _applySelectedFont(String font) {
    final TextSelection selection = _activeFormattingSelection();

    if (selection.isCollapsed) {
      return;
    }

    final TextStyle selectedStyle = _getSelectedFontStyle(font);

    _richController.applyStyle(
      start: selection.start,
      end: selection.end,
      fontStyle: selectedStyle,
    );

    _richController.selection = selection;

    setState(() {
      _font = font;
    });
  }

  void _applySelectedFontSize(String size) {
    final TextSelection selection = _activeFormattingSelection();

    if (selection.isCollapsed) {
      return;
    }

    final double fontSize = double.tryParse(
          size.replaceAll('pt', ''),
        ) ??
        12;

    _richController.applyStyle(
      start: selection.start,
      end: selection.end,
      fontSize: fontSize,
    );

    _richController.selection = selection;

    setState(() {
      _fontSize = size;
    });
  }

  void _applySelectedParagraph(String paragraph) {
    final TextSelection selection = _activeFormattingSelection();

    if (selection.isCollapsed) {
      return;
    }

    double fontSize = 14;
    FontWeight fontWeight = FontWeight.normal;

    switch (paragraph) {
      case 'Heading 1':
        fontSize = 32;
        fontWeight = FontWeight.bold;
        break;
      case 'Heading 2':
        fontSize = 28;
        fontWeight = FontWeight.bold;
        break;
      case 'Heading 3':
        fontSize = 24;
        fontWeight = FontWeight.bold;
        break;
      case 'Heading 4':
        fontSize = 20;
        fontWeight = FontWeight.bold;
        break;
      case 'Heading 5':
        fontSize = 17;
        fontWeight = FontWeight.bold;
        break;
      case 'Heading 6':
        fontSize = 14;
        fontWeight = FontWeight.bold;
        break;
      case 'Preformatted':
        fontSize = 14;
        fontWeight = FontWeight.normal;
        break;
      case 'Paragraph':
      default:
        fontSize = 14;
        fontWeight = FontWeight.normal;
        break;
    }

    _richController.applyStyle(
      start: selection.start,
      end: selection.end,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );

    _richController.selection = selection;

    setState(() {
      _paragraph = paragraph;
    });
  }

  static const List<String> _fonts = [
    'System Font',
    'Andale Mono',
    'Arial',
    'Arial Black',
    'Book Antiqua',
    'Comic Sans MS',
    'Courier New',
    'Georgia',
    'Helvetica',
    'Impact',
    'Symbol',
    'Tahoma',
    'Terminal',
    'Times New Roman',
  ];

  static const List<String> _fontSizes = [
    '8pt',
    '10pt',
    '12pt',
    '14pt',
    '18pt',
    '24pt',
    '36pt',
  ];

  static const List<String> _paragraphs = [
    'Paragraph',
    'Heading 1',
    'Heading 2',
    'Heading 3',
    'Heading 4',
    'Heading 5',
    'Heading 6',
    'Preformatted',
  ];

  Future<void> _showFileMenu() async {
    await showMenu<String>(
      context: context,
      color: Colors.white,
      position:
          const RelativeRect.fromLTRB(
        60,
        250,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'new',
          child: Text(
            'New document',
          ),
        ),
        PopupMenuItem(
          value: 'restore',
          child: Text(
            'Restore last draft',
          ),
        ),
        PopupMenuItem(
          value: 'preview',
          child: Text(
            'Preview',
          ),
        ),
        PopupMenuItem(
          value: 'print',
          child: Text(
            'Print...',
          ),
        ),
      ],
    );
  }

  Future<void> _showEditMenu() async {
    final String? selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      position:
          const RelativeRect.fromLTRB(
        110,
        250,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'undo',
          child: Text('Undo'),
        ),
        PopupMenuItem(
          value: 'redo',
          child: Text('Redo'),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'cut',
          child: Text('Cut'),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Text('Copy'),
        ),
        PopupMenuItem(
          value: 'paste',
          child: Text('Paste'),
        ),
        PopupMenuItem(
          value: 'paste_text',
          child: Text(
            'Paste as text',
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'select_all',
          child: Text(
            'Select all',
          ),
        ),
        PopupMenuItem(
          value: 'find',
          child: Text(
            'Find and replace...',
          ),
        ),
      ],
    );

    switch (selected) {
      case 'undo':
        _undoEdit();
      case 'redo':
        _redoEdit();
      case 'cut':
        _cutEdit();
      case 'copy':
        _copyEdit();
      case 'paste':
      case 'paste_text':
        _pasteEdit();
      case 'select_all':
        _selectAllEdit();
      case 'find':
        _openFindReplaceDialog();
    }
  }

  Future<void> _openFindReplaceDialog() async {
    final TextEditingController findController =
        TextEditingController();
    final TextEditingController replaceController =
        TextEditingController();
    bool caseSensitive = false;
    bool wholeWords = false;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final bool hasFindText = findController.text.isNotEmpty;
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Find and Replace',
                              style: TextStyle(
                                color: Color(0xFF233142),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: findController,
                              autofocus: true,
                              onChanged: (_) => setDialogState(() {}),
                              decoration: _findFieldDecoration('Find'),
                            ),
                          ),
                          const SizedBox(width: 5),
                          _FindArrowButton(
                            icon: Icons.keyboard_arrow_up_rounded,
                            onTap: hasFindText
                                ? () => _findPrevious(
                                      findController.text,
                                      caseSensitive: caseSensitive,
                                      wholeWords: wholeWords,
                                    )
                                : null,
                          ),
                          const SizedBox(width: 5),
                          _FindArrowButton(
                            icon: Icons.keyboard_arrow_down_rounded,
                            onTap: hasFindText
                                ? () => _findNext(
                                      findController.text,
                                      caseSensitive: caseSensitive,
                                      wholeWords: wholeWords,
                                    )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: replaceController,
                        decoration: _findFieldDecoration('Replace with'),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          PopupMenuButton<String>(
                            color: Colors.white,
                            tooltip: 'Options',
                            onSelected: (value) {
                              setDialogState(() {
                                if (value == 'case_sensitive') {
                                  caseSensitive = !caseSensitive;
                                }
                                if (value == 'whole_words') {
                                  wholeWords = !wholeWords;
                                }
                              });
                            },
                            itemBuilder: (context) => [
                              CheckedPopupMenuItem(
                                value: 'case_sensitive',
                                checked: caseSensitive,
                                child: const Text('Match case'),
                              ),
                              CheckedPopupMenuItem(
                                value: 'whole_words',
                                checked: wholeWords,
                                child: const Text('Whole words only'),
                              ),
                            ],
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.settings,
                                  size: 20,
                                  color: Color(0xFF263238),
                                ),
                                SizedBox(width: 2),
                                Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 17,
                                  color: Color(0xFF6F7478),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: hasFindText
                                ? () => _findNext(
                                      findController.text,
                                      caseSensitive: caseSensitive,
                                      wholeWords: wholeWords,
                                    )
                                : null,
                            style: _findButtonStyle(
                              backgroundColor: const Color(0xFF0D6EFD),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  const Color(0xFFE7E7E7),
                              disabledForegroundColor:
                                  const Color(0xFF9B9B9B),
                            ),
                            child: const Text('Find'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: hasFindText
                                ? () => _replaceCurrent(
                                      findController.text,
                                      replaceController.text,
                                      caseSensitive: caseSensitive,
                                      wholeWords: wholeWords,
                                    )
                                : null,
                            style: _findButtonStyle(
                              backgroundColor: const Color(0xFFF1F1F1),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor:
                                  const Color(0xFFF1F1F1),
                              disabledForegroundColor:
                                  const Color(0xFFAAAAAA),
                            ),
                            child: const Text('Replace'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: hasFindText
                                ? () => _replaceAll(
                                      findController.text,
                                      replaceController.text,
                                      caseSensitive: caseSensitive,
                                      wholeWords: wholeWords,
                                    )
                                : null,
                            style: _findButtonStyle(
                              backgroundColor: const Color(0xFFF1F1F1),
                              foregroundColor: Colors.black,
                              disabledBackgroundColor:
                                  const Color(0xFFF1F1F1),
                              disabledForegroundColor:
                                  const Color(0xFFAAAAAA),
                            ),
                            child: const Text('Replace all'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    findController.dispose();
    replaceController.dispose();
  }

  InputDecoration _findFieldDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFFE2E5E7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xFF0D6EFD),
          width: 1.5,
        ),
      ),
    );
  }

  ButtonStyle _findButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
    required Color disabledBackgroundColor,
    required Color disabledForegroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      disabledForegroundColor: disabledForegroundColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  RegExp _buildSearchRegExp(
    String text, {
    required bool caseSensitive,
    required bool wholeWords,
  }) {
    final String escaped = RegExp.escape(text);
    return RegExp(
      wholeWords ? '\\b$escaped\\b' : escaped,
      caseSensitive: caseSensitive,
    );
  }

  void _findNext(
    String text, {
    required bool caseSensitive,
    required bool wholeWords,
  }) {
    if (text.isEmpty) return;
    final String content = widget.controller.text;
    final RegExp regex = _buildSearchRegExp(
      text,
      caseSensitive: caseSensitive,
      wholeWords: wholeWords,
    );
    final int current = widget.controller.selection.end >= 0
        ? widget.controller.selection.end
        : 0;
    final int startOffset = current.clamp(0, content.length).toInt();
    RegExpMatch? match = regex.firstMatch(content.substring(startOffset));
    int offset = startOffset;

    if (match == null) {
      match = regex.firstMatch(content);
      offset = 0;
    }
    if (match == null) return;

    widget.controller.selection = TextSelection(
      baseOffset: offset + match.start,
      extentOffset: offset + match.end,
    );
  }

  void _findPrevious(
    String text, {
    required bool caseSensitive,
    required bool wholeWords,
  }) {
    if (text.isEmpty) return;
    final String content = widget.controller.text;
    final RegExp regex = _buildSearchRegExp(
      text,
      caseSensitive: caseSensitive,
      wholeWords: wholeWords,
    );
    final int current = widget.controller.selection.start >= 0
        ? widget.controller.selection.start
        : content.length;
    final int endOffset = current.clamp(0, content.length).toInt();
    final List<RegExpMatch> before = regex
        .allMatches(content.substring(0, endOffset))
        .toList();
    final List<RegExpMatch> matches = before.isNotEmpty
        ? before
        : regex.allMatches(content).toList();
    if (matches.isEmpty) return;

    final RegExpMatch match = matches.last;
    widget.controller.selection = TextSelection(
      baseOffset: match.start,
      extentOffset: match.end,
    );
  }

  void _replaceCurrent(
    String find,
    String replace, {
    required bool caseSensitive,
    required bool wholeWords,
  }) {
    if (find.isEmpty) return;
    final TextSelection selection = widget.controller.selection;
    if (!selection.isValid || selection.isCollapsed) {
      _findNext(
        find,
        caseSensitive: caseSensitive,
        wholeWords: wholeWords,
      );
      return;
    }

    final String selectedText = selection.textInside(widget.controller.text);
    final RegExp regex = _buildSearchRegExp(
      find,
      caseSensitive: caseSensitive,
      wholeWords: wholeWords,
    );
    if (!regex.hasMatch(selectedText)) {
      _findNext(
        find,
        caseSensitive: caseSensitive,
        wholeWords: wholeWords,
      );
      return;
    }

    final String updated = widget.controller.text.replaceRange(
      selection.start,
      selection.end,
      replace,
    );
    final int cursor = selection.start + replace.length;
    widget.controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: cursor),
    );
    _findNext(
      find,
      caseSensitive: caseSensitive,
      wholeWords: wholeWords,
    );
  }

  void _replaceAll(
    String find,
    String replace, {
    required bool caseSensitive,
    required bool wholeWords,
  }) {
    if (find.isEmpty) return;
    final RegExp regex = _buildSearchRegExp(
      find,
      caseSensitive: caseSensitive,
      wholeWords: wholeWords,
    );
    final String updated = widget.controller.text.replaceAll(regex, replace);
    widget.controller.value = TextEditingValue(
      text: updated,
      selection: TextSelection.collapsed(offset: updated.length),
    );
  }

  Future<void> _showViewMenu() async {
    final String? selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      position:
          const RelativeRect.fromLTRB(
        160,
        250,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'source',
          child: Text(
            'Source code',
          ),
        ),
        PopupMenuItem(
          value: 'visual',
          child: Text(
            'Visual aids',
          ),
        ),
        PopupMenuItem(
          value: 'invisible',
          child: Text(
            'Show invisible characters',
          ),
        ),
        PopupMenuItem(
          value: 'blocks',
          child: Text(
            'Show blocks',
          ),
        ),
        PopupMenuItem(
          value: 'preview',
          child: Text(
            'Preview',
          ),
        ),
        PopupMenuItem(
          value: 'fullscreen',
          child: Text(
            'Fullscreen',
          ),
        ),
      ],
    );

    if (selected == 'source') {
      _openSourceCodeDialog();
    }

    if (selected == 'preview') {
      _openPreviewDialog();
    }

    if (selected == 'fullscreen') {
      _openFullscreenEditor();
    }
  }

  Future<void> _openPreviewDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.black),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 640,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    8,
                    8,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Preview',
                          style: TextStyle(
                            color: Color(0xFF233142),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(
                      16,
                      6,
                      16,
                      12,
                    ),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        widget.controller.text,
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: _imageButtonStyle(
                          backgroundColor: const Color(0xFF0D6EFD),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openFullscreenEditor() async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => _FullscreenTemplateEditorPage(
          controller: widget.controller,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showInsertMenu() async {
    final String? selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      position:
          const RelativeRect.fromLTRB(
        210,
        250,
        0,
        0,
      ),
      items: const [
        PopupMenuItem(
          value: 'image',
          child: Text(
            'Image...',
          ),
        ),
        PopupMenuItem(
          value: 'link',
          child: Text(
            'Link...',
          ),
        ),
        PopupMenuItem(
          value: 'media',
          child: Text(
            'Media...',
          ),
        ),
        PopupMenuItem(
          value: 'template',
          child: Text(
            'Insert template...',
          ),
        ),
        PopupMenuItem(
          value: 'code',
          child: Text(
            'Code sample...',
          ),
        ),
        PopupMenuItem(
          value: 'table',
          child: Text(
            'Table',
          ),
        ),
        PopupMenuItem(
          value: 'special',
          child: Text(
            'Special character...',
          ),
        ),
        PopupMenuItem(
          value: 'emoji',
          child: Text(
            'Emojis...',
          ),
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'line',
          child: Text(
            'Horizontal line',
          ),
        ),
        PopupMenuItem(
          value: 'page',
          child: Text(
            'Page break',
          ),
        ),
        PopupMenuItem(
          value: 'space',
          child: Text(
            'Nonbreaking space',
          ),
        ),
        PopupMenuItem(
          value: 'anchor',
          child: Text(
            'Anchor...',
          ),
        ),
      ],
    );

    if (selected == 'image') {
      _openImageDialog();
    }

    if (selected == 'link') {
      _openLinkDialog();
    }

    if (selected == 'media') {
      _openMediaDialog();
    }

    if (selected == 'code') {
      _openCodeSampleDialog();
    }

    if (selected == 'special') {
      _openSpecialCharacterDialog();
    }

    if (selected == 'emoji') {
      _openEmojiDialog();
    }

    if (selected == 'anchor') {
      _openAnchorDialog();
    }
  }

  Future<void> _openAnchorDialog() async {
    final TextEditingController idController =
        TextEditingController();

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Anchor',
                          style: TextStyle(
                            color: Color(0xFF233142),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'ID',
                    style: TextStyle(
                      color: Color(0xFF6F7478),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  TextFormField(
                    controller: idController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'example',
                      hintStyle: const TextStyle(
                        color: Color(0xFF7D858A),
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 12,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Color(0xFF0D6EFD),
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Color(0xFF0D6EFD),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: _imageButtonStyle(
                          backgroundColor: const Color(0xFFF1F1F1),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final String id = idController.text.trim();

                          if (id.isNotEmpty) {
                            final String anchorTag = '<a id="$id"></a>';
                            final String current = widget.controller.text;
                            final TextSelection selection =
                                widget.controller.selection;
                            final int insertPosition = selection.start >= 0
                                ? selection.start
                                : current.length;
                            final String updated = current.replaceRange(
                              insertPosition,
                              insertPosition,
                              anchorTag,
                            );

                            widget.controller.value = TextEditingValue(
                              text: updated,
                              selection: TextSelection.collapsed(
                                offset: insertPosition + anchorTag.length,
                              ),
                            );
                          }

                          Navigator.pop(context);
                        },
                        style: _imageButtonStyle(
                          backgroundColor: const Color(0xFF0D6EFD),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    idController.dispose();
  }

  Future<void> _openImageDialog() async {
    final TextEditingController sourceController =
        TextEditingController();
    final TextEditingController altController =
        TextEditingController();
    final TextEditingController widthController =
        TextEditingController();
    final TextEditingController heightController =
        TextEditingController();
    bool lockAspectRatio = true;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Insert/Edit Image',
                              style: TextStyle(
                                color: Color(0xFF233142),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Source',
                        style: TextStyle(
                          color: Color(0xFF6F7478),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: sourceController,
                        autofocus: true,
                        decoration: _imageFieldDecoration(
                          focused: true,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Alternative description',
                        style: TextStyle(
                          color: Color(0xFF6F7478),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: altController,
                        decoration: _imageFieldDecoration(),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _imageDimensionField(
                              label: 'Width',
                              controller: widthController,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: _imageDimensionField(
                              label: 'Height',
                              controller: heightController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 7),
                            child: IconButton(
                              onPressed: () {
                                setDialogState(() {
                                  lockAspectRatio = !lockAspectRatio;
                                });
                              },
                              icon: Icon(
                                lockAspectRatio
                                    ? Icons.lock_rounded
                                    : Icons.lock_open_rounded,
                                size: 18,
                                color: const Color(0xFF233142),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: _imageButtonStyle(
                              backgroundColor: const Color(0xFFF1F1F1),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final String source =
                                  sourceController.text.trim();

                              if (source.isNotEmpty) {
                                final String alt =
                                    altController.text.trim();
                                final String width =
                                    widthController.text.trim();
                                final String height =
                                    heightController.text.trim();
                                String imageTag = '<img src="$source"';

                                if (alt.isNotEmpty) {
                                  imageTag += ' alt="$alt"';
                                }
                                if (width.isNotEmpty) {
                                  imageTag += ' width="$width"';
                                }
                                if (height.isNotEmpty) {
                                  imageTag += ' height="$height"';
                                }
                                imageTag += '>';

                                final String current =
                                    widget.controller.text;
                                widget.controller.text = current.isEmpty
                                    ? imageTag
                                    : '$current\n$imageTag';
                              }

                              Navigator.pop(context);
                            },
                            style: _imageButtonStyle(
                              backgroundColor: const Color(0xFF0D6EFD),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    sourceController.dispose();
    altController.dispose();
    widthController.dispose();
    heightController.dispose();
  }

  InputDecoration _imageFieldDecoration({
    bool focused = false,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: focused
              ? const Color(0xFF0D6EFD)
              : const Color(0xFFE2E5E7),
          width: focused ? 1.2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xFF0D6EFD),
          width: 1.5,
        ),
      ),
    );
  }

  Widget _imageDimensionField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6F7478),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 3),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: _imageFieldDecoration(),
        ),
      ],
    );
  }

  ButtonStyle _imageButtonStyle({
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }

  Future<void> _openLinkDialog() async {
    final TextEditingController urlController =
        TextEditingController();
    final TextEditingController textController =
        TextEditingController();
    final TextEditingController titleController =
        TextEditingController();
    String openIn = 'Current window';

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Insert/Edit Link',
                              style: TextStyle(
                                color: Color(0xFF233142),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'URL',
                        style: TextStyle(
                          color: Color(0xFF6F7478),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: urlController,
                        autofocus: true,
                        decoration: _linkFieldDecoration(
                          focused: true,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Text to display',
                        style: TextStyle(
                          color: Color(0xFF6F7478),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: textController,
                        decoration: _linkFieldDecoration(),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Title',
                        style: TextStyle(
                          color: Color(0xFF6F7478),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      TextFormField(
                        controller: titleController,
                        decoration: _linkFieldDecoration(),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Open link in',
                        style: TextStyle(
                          color: Color(0xFF6F7478),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      DropdownButtonFormField<String>(
                        initialValue: openIn,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Color(0xFF233142),
                          fontSize: 14,
                        ),
                        decoration: _linkFieldDecoration(),
                        items: const [
                          DropdownMenuItem(
                            value: 'Current window',
                            child: Text(
                              'Current window',
                              style: TextStyle(
                                color: Color(0xFF233142),
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'New window',
                            child: Text(
                              'New window',
                              style: TextStyle(
                                color: Color(0xFF233142),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            openIn = value;
                          });
                        },
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: _imageButtonStyle(
                              backgroundColor: const Color(0xFFF1F1F1),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final String url =
                                  urlController.text.trim();

                              if (url.isNotEmpty) {
                                final String displayText =
                                    textController.text.trim().isEmpty
                                        ? url
                                        : textController.text.trim();
                                final String title =
                                    titleController.text.trim();
                                final String target =
                                    openIn == 'New window'
                                        ? ' target="_blank"'
                                        : '';
                                final String titleAttribute =
                                    title.isNotEmpty
                                        ? ' title="$title"'
                                        : '';
                                final String linkTag =
                                    '<a href="$url"$titleAttribute$target>'
                                    '$displayText</a>';
                                final String current =
                                    widget.controller.text;
                                widget.controller.text = current.isEmpty
                                    ? linkTag
                                    : '$current\n$linkTag';
                              }

                              Navigator.pop(context);
                            },
                            style: _imageButtonStyle(
                              backgroundColor: const Color(0xFF0D6EFD),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    urlController.dispose();
    textController.dispose();
    titleController.dispose();
  }

  InputDecoration _linkFieldDecoration({
    bool focused = false,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: focused
              ? const Color(0xFF0D6EFD)
              : const Color(0xFFE2E5E7),
          width: focused ? 1.2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xFF0D6EFD),
          width: 1.5,
        ),
      ),
    );
  }

  Future<void> _openMediaDialog() async {
    final TextEditingController sourceController =
        TextEditingController();
    final TextEditingController embedController =
        TextEditingController();
    final TextEditingController widthController =
        TextEditingController();
    final TextEditingController heightController =
        TextEditingController();
    final TextEditingController posterController =
        TextEditingController();
    final TextEditingController alternativeSourceController =
        TextEditingController();
    String selectedTab = 'General';
    bool lockAspectRatio = true;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 485,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    10,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Insert/Edit Media',
                              style: TextStyle(
                                color: Color(0xFF233142),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 85,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                _MediaTabButton(
                                  text: 'General',
                                  selected: selectedTab == 'General',
                                  onTap: () {
                                    setDialogState(() {
                                      selectedTab = 'General';
                                    });
                                  },
                                ),
                                _MediaTabButton(
                                  text: 'Embed',
                                  selected: selectedTab == 'Embed',
                                  onTap: () {
                                    setDialogState(() {
                                      selectedTab = 'Embed';
                                    });
                                  },
                                ),
                                _MediaTabButton(
                                  text: 'Advanced',
                                  selected: selectedTab == 'Advanced',
                                  onTap: () {
                                    setDialogState(() {
                                      selectedTab = 'Advanced';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildMediaTab(
                              selectedTab: selectedTab,
                              sourceController: sourceController,
                              embedController: embedController,
                              widthController: widthController,
                              heightController: heightController,
                              posterController: posterController,
                              alternativeSourceController:
                                  alternativeSourceController,
                              lockAspectRatio: lockAspectRatio,
                              onToggleLock: () {
                                setDialogState(() {
                                  lockAspectRatio = !lockAspectRatio;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: _imageButtonStyle(
                              backgroundColor: const Color(0xFFF1F1F1),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final String source =
                                  sourceController.text.trim();
                              final String embed =
                                  embedController.text.trim();
                              String mediaCode = '';

                              if (selectedTab == 'Embed' &&
                                  embed.isNotEmpty) {
                                mediaCode = embed;
                              } else if (source.isNotEmpty) {
                                final String width =
                                    widthController.text.trim();
                                final String height =
                                    heightController.text.trim();
                                mediaCode = '<video controls';

                                if (width.isNotEmpty) {
                                  mediaCode += ' width="$width"';
                                }
                                if (height.isNotEmpty) {
                                  mediaCode += ' height="$height"';
                                }

                                final String poster =
                                    posterController.text.trim();
                                if (poster.isNotEmpty) {
                                  mediaCode += ' poster="$poster"';
                                }

                                mediaCode += '>';
                                mediaCode += '<source src="$source">';

                                final String alternative =
                                    alternativeSourceController.text.trim();
                                if (alternative.isNotEmpty) {
                                  mediaCode +=
                                      '<source src="$alternative">';
                                }
                                mediaCode += '</video>';
                              }

                              if (mediaCode.isNotEmpty) {
                                final String current =
                                    widget.controller.text;
                                widget.controller.text = current.isEmpty
                                    ? mediaCode
                                    : '$current\n$mediaCode';
                              }
                              Navigator.pop(context);
                            },
                            style: _imageButtonStyle(
                              backgroundColor: const Color(0xFF0D6EFD),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    sourceController.dispose();
    embedController.dispose();
    widthController.dispose();
    heightController.dispose();
    posterController.dispose();
    alternativeSourceController.dispose();
  }

  Widget _buildMediaTab({
    required String selectedTab,
    required TextEditingController sourceController,
    required TextEditingController embedController,
    required TextEditingController widthController,
    required TextEditingController heightController,
    required TextEditingController posterController,
    required TextEditingController alternativeSourceController,
    required bool lockAspectRatio,
    required VoidCallback onToggleLock,
  }) {
    if (selectedTab == 'Embed') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paste your embed code below:',
            style: TextStyle(
              color: Color(0xFF6F7478),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 5),
          TextFormField(
            controller: embedController,
            minLines: 6,
            maxLines: 8,
            decoration: _mediaFieldDecoration(),
          ),
        ],
      );
    }

    if (selectedTab == 'Advanced') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alternative source URL',
            style: TextStyle(
              color: Color(0xFF6F7478),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          TextFormField(
            controller: alternativeSourceController,
            decoration: _mediaFieldDecoration(),
          ),
          const SizedBox(height: 10),
          const Text(
            'Poster',
            style: TextStyle(
              color: Color(0xFF6F7478),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 3),
          TextFormField(
            controller: posterController,
            decoration: _mediaFieldDecoration(),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Source',
          style: TextStyle(
            color: Color(0xFF6F7478),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 3),
        TextFormField(
          controller: sourceController,
          autofocus: true,
          decoration: _mediaFieldDecoration(focused: true),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: _mediaDimensionField(
                label: 'Width',
                controller: widthController,
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: _mediaDimensionField(
                label: 'Height',
                controller: heightController,
              ),
            ),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: IconButton(
                onPressed: onToggleLock,
                icon: Icon(
                  lockAspectRatio
                      ? Icons.lock_rounded
                      : Icons.lock_open_rounded,
                  size: 18,
                  color: const Color(0xFF233142),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _mediaDimensionField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6F7478),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 3),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: _mediaFieldDecoration(),
        ),
      ],
    );
  }

  InputDecoration _mediaFieldDecoration({
    bool focused = false,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: focused
              ? const Color(0xFF0D6EFD)
              : const Color(0xFFE2E5E7),
          width: focused ? 1.2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xFF0D6EFD),
          width: 1.5,
        ),
      ),
    );
  }

  Future<void> _openCodeSampleDialog() async {
    final TextEditingController codeController =
        TextEditingController();
    String selectedLanguage = 'HTML/XML';

    const List<String> languages = [
      'HTML/XML',
      'JavaScript',
      'CSS',
      'PHP',
      'Ruby',
      'Python',
      'Java',
      'C#',
      'C++',
    ];

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 625,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    16,
                    10,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Insert/Edit Code Sample',
                              style: TextStyle(
                                color: Color(0xFF233142),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Language',
                        style: TextStyle(
                          color: Color(0xFF6F7478),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      DropdownButtonFormField<String>(
                        initialValue: selectedLanguage,
                        isExpanded: true,
                        dropdownColor: Colors.white,
                        style: const TextStyle(
                          color: Color(0xFF233142),
                          fontSize: 14,
                        ),
                        decoration: _codeFieldDecoration(
                          focused: true,
                        ),
                        items: languages.map((language) {
                          return DropdownMenuItem<String>(
                            value: language,
                            child: Text(
                              language,
                              style: const TextStyle(
                                color: Color(0xFF233142),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Code view',
                        style: TextStyle(
                          color: Color(0xFF6F7478),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Expanded(
                        child: TextFormField(
                          controller: codeController,
                          expands: true,
                          minLines: null,
                          maxLines: null,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'monospace',
                            height: 1.45,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: _imageButtonStyle(
                              backgroundColor: const Color(0xFFF1F1F1),
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Cancel'),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              final String code = codeController.text.trim();
                              if (code.isNotEmpty) {
                                final String languageClass =
                                    _codeLanguageClass(selectedLanguage);
                                final String codeBlock =
                                    '<pre><code class="$languageClass">'
                                    '${_escapeHtml(code)}</code></pre>';
                                final String current = widget.controller.text;
                                widget.controller.text = current.isEmpty
                                    ? codeBlock
                                    : '$current\n$codeBlock';
                              }
                              Navigator.pop(context);
                            },
                            style: _imageButtonStyle(
                              backgroundColor: const Color(0xFF0D6EFD),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    codeController.dispose();
  }

  InputDecoration _codeFieldDecoration({
    bool focused = false,
  }) {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: BorderSide(
          color: focused
              ? const Color(0xFF0D6EFD)
              : const Color(0xFFE2E5E7),
          width: focused ? 1.2 : 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xFF0D6EFD),
          width: 1.2,
        ),
      ),
    );
  }

  String _codeLanguageClass(String language) {
    switch (language) {
      case 'JavaScript':
        return 'javascript';
      case 'CSS':
        return 'css';
      case 'PHP':
        return 'php';
      case 'Ruby':
        return 'ruby';
      case 'Python':
        return 'python';
      case 'Java':
        return 'java';
      case 'C#':
        return 'csharp';
      case 'C++':
        return 'cpp';
      case 'HTML/XML':
      default:
        return 'markup';
    }
  }

  String _escapeHtml(String value) {
    return value
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;');
  }

  Future<void> _openSpecialCharacterDialog() async {
    String selectedCategory = 'Arrows';
    String searchText = '';

    const Map<String, List<String>> characterGroups = {
      'All': [
        '←', '↑', '→', '↓', '↔', '↵', '⇐', '⇑', '⇒', '⇓',
        '↔', '∴', '⊂', '⊃', '⊄', '⊆', '⊇', '⊕', '⊗', '⊥',
        '·', '⌈', '⌉', '⌊', '⌋', '〈', '〉', '◊', '♠', '♣',
        '♥', '♦', '€', '£', '¥', '\u0024', '¢', '©', '®', '™',
        '“', '”', '‘', '’', '«', '»', '±', '×', '÷', '≈',
      ],
      'Currency': [
        '\u0024', '€', '£', '¥', '¢', '₹', '₩', '₽', '₺', '₫',
      ],
      'Text': [
        '©', '®', '™', '§', '¶', '•', '…', '–', '—', '№',
      ],
      'Quotations': [
        '"', "'", '“', '”', '‘', '’', '«', '»', '‹', '›',
      ],
      'Mathematical': [
        '+', '−', '×', '÷', '=', '≠', '≈', '≤', '≥', '±',
        '∞', '√', '∑', '∏', '∫', '∂', '∆', '∇', '∈', '∉',
        '⊂', '⊃', '⊆', '⊇', '⊕', '⊗',
      ],
      'Extended Latin': [
        'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Æ', 'Ç', 'È', 'É',
        'Ê', 'Ë', 'Ì', 'Í', 'Î', 'Ï', 'Ñ', 'Ò', 'Ó', 'Ô',
        'Õ', 'Ö', 'Ù', 'Ú', 'Û', 'Ü', 'Ý', 'ß',
      ],
      'Symbols': [
        '©', '®', '™', '°', '†', '‡', '•', '◊', '♠', '♣',
        '♥', '♦', '♀', '♂', '☀', '☁', '★', '☆', '✓', '✕',
      ],
      'Arrows': [
        '←', '↑', '→', '↓', '↔', '↵', '⇐', '⇑', '⇒', '⇓',
        '↔', '∴', '⊂', '⊃', '⊄', '⊆', '⊇', '⊕', '⊗', '⊥',
        '·', '⌈', '⌉', '⌊', '⌋', '〈', '〉', '◊', '♠', '♣',
        '♥', '♦',
      ],
    };

    const List<String> categories = [
      'All',
      'Currency',
      'Text',
      'Quotations',
      'Mathematical',
      'Extended Latin',
      'Symbols',
      'Arrows',
    ];

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final List<String> characters =
                characterGroups[selectedCategory] ?? const [];
            final String trimmedSearch = searchText.trim();
            final List<String> filteredCharacters = trimmedSearch.isEmpty
                ? characters
                : characters
                    .where((character) => character.contains(trimmedSearch))
                    .toList();

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  maxHeight: 395,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    14,
                    16,
                    10,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Special Character',
                              style: TextStyle(
                                color: Color(0xFF233142),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 115,
                              child: ListView(
                                children: [
                                  for (final category in categories)
                                    _SpecialCharacterCategory(
                                      text: category,
                                      selected: selectedCategory == category,
                                      onTap: () {
                                        setDialogState(() {
                                          selectedCategory = category;
                                          searchText = '';
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Search',
                                    style: TextStyle(
                                      color: Color(0xFF6F7478),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  TextFormField(
                                    onChanged: (value) {
                                      setDialogState(() {
                                        searchText = value;
                                      });
                                    },
                                    decoration: _specialCharacterDecoration(),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 10,
                                        mainAxisSpacing: 2,
                                        crossAxisSpacing: 2,
                                        childAspectRatio: 1,
                                      ),
                                      itemCount: filteredCharacters.length,
                                      itemBuilder: (context, index) {
                                        final String character =
                                            filteredCharacters[index];
                                        return _SpecialCharacterCell(
                                          character: character,
                                          onTap: () {
                                            final TextSelection selection =
                                                widget.controller.selection;
                                            final String text =
                                                widget.controller.text;
                                            final int start = selection.start >= 0
                                                ? selection.start
                                                : text.length;
                                            final int end = selection.end >= 0
                                                ? selection.end
                                                : text.length;
                                            final String updated = text.replaceRange(
                                              start,
                                              end,
                                              character,
                                            );
                                            widget.controller.value =
                                                TextEditingValue(
                                              text: updated,
                                              selection: TextSelection.collapsed(
                                                offset: start + character.length,
                                              ),
                                            );
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: _imageButtonStyle(
                            backgroundColor: const Color(0xFF0D6EFD),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _specialCharacterDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xFFE2E5E7),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(
          color: Color(0xFF0D6EFD),
        ),
      ),
    );
  }

  Future<void> _openEmojiDialog() async {
    String selectedCategory = 'All';
    String searchText = '';

    const Map<String, List<String>> emojiGroups = {
      'All': [
        '💯', '🔢', '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂',
        '🙂', '🙃', '😉', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗',
        '☺️', '😚', '😙', '🥲', '😋', '😛', '😜', '🤪', '😝', '🤑',
        '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏',
        '😒', '🙄', '😬', '🤥', '😌', '😔', '😪', '🤤', '😴', '😷',
        '🤒', '🤕', '🤢', '🤮', '🤧', '🥵', '🥶', '🥴', '😵', '🤯',
        '🤠', '🥳', '😎', '🤓', '🧐', '😕', '😟', '🙁', '☹️', '😮',
        '😯', '😲', '😳', '🥺', '😦', '😧', '😨', '😰', '😥', '😢',
        '😭', '😱', '😖', '😣', '😞', '😓', '😩', '😫', '🥱', '😤',
        '😡', '😠', '🤬', '😈', '👿', '💀', '☠️', '💩', '🤡', '👹',
        '👺', '👻', '👽', '👾', '🤖', '😺', '😸', '😹', '😻', '😼',
        '😽', '🙀', '😿', '😾', '👍', '👎', '👌', '✌️', '🤞', '🤟',
        '🤘', '🤙', '👈', '👉', '👆', '👇', '☝️', '✋', '🤚', '🖐️',
        '🖖', '👋', '🤏', '💪', '🙏', '👏', '🙌', '❤️', '🧡', '💛',
        '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔', '🐶', '🐱', '🐭',
        '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯', '🦁', '🐮', '🐷',
        '🐸', '🐵', '🐔', '🐧', '🐦', '🐤', '🦄', '🍏', '🍎', '🍐',
        '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐', '🍒', '🍑', '🥭',
        '🍍', '🥥', '🥝', '🍅', '🍆', '🥑', '🥦', '⚽', '🏀', '🏈',
        '⚾', '🎾', '🏐', '🏉', '🥏', '🎱', '🏓', '🏸', '🥅', '🏒',
        '🏑', '🥍', '🏏', '⛳', '🏹', '🚗', '🚕', '🚙', '🚌', '🚎',
        '🏎️', '🚓', '🚑', '🚒', '🚐', '🚚', '🚛', '🚜', '✈️', '🚀',
        '🚁', '🚢', '⛵', '⌚', '📱', '💻', '⌨️', '🖥️', '🖨️', '🖱️',
        '💽', '💾', '💿', '📷', '📹', '🎥', '📞', '☎️', '📺', '📻',
        '⏰', '🏳️', '🏴', '🏁', '🚩', '🇮🇳', '🇺🇸', '🇬🇧', '🇯🇵', '🇨🇦',
        '🇦🇺',
      ],
      'Symbols': [
        '💯', '🔢', '❤️', '💔', '❣️', '💕', '💞', '💓', '💗', '💖',
        '💘', '💝', '💟', '☮️', '✝️', '☪️', '🕉️', '☸️', '✡️', '🔯',
        '♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒',
        '♓', '⭕', '✅', '☑️', '✔️', '❌', '❎', '➕', '➖', '➗',
        '✖️', '♾️', '‼️', '⁉️', '❓', '❔', '❕', '❗',
      ],
      'People': [
        '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃',
        '😉', '😊', '😇', '🥰', '😍', '🤩', '😘', '😗', '☺️', '😚',
        '😙', '🥲', '😋', '😛', '😜', '🤪', '🤗', '🤭', '🤫', '🤔',
        '👍', '👎', '👌', '✌️', '🤞', '🤟', '🤘', '🤙', '👋', '👏',
        '🙌', '🙏', '💪',
      ],
      'Animals and Nature': [
        '🐶', '🐱', '🐭', '🐹', '🐰', '🦊', '🐻', '🐼', '🐨', '🐯',
        '🦁', '🐮', '🐷', '🐸', '🐵', '🐔', '🐧', '🐦', '🐤', '🦄',
        '🐝', '🦋', '🐌', '🐞', '🐜', '🕷️', '🌸', '🌹', '🌺', '🌻',
        '🌼', '🌷', '🌱', '🌲', '🌳', '🌴', '🌵', '🍀', '☘️',
      ],
      'Food and Drink': [
        '🍏', '🍎', '🍐', '🍊', '🍋', '🍌', '🍉', '🍇', '🍓', '🫐',
        '🍒', '🍑', '🥭', '🍍', '🥥', '🥝', '🍅', '🍆', '🥑', '🥦',
        '🥕', '🌽', '🌶️', '🥐', '🍞', '🥖', '🥨', '🧀', '🍳', '🍔',
        '🍟', '🍕', '🌭', '🥪', '🌮', '🍣', '🍜', '🍰', '🎂', '☕',
      ],
      'Activity': [
        '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🏉', '🥏', '🎱', '🏓',
        '🏸', '🥅', '🏒', '🏑', '🥍', '🏏', '⛳', '🏹', '🎣', '🤿',
        '🥊', '🥋', '🎽', '🛹', '🛼', '⛸️', '🎿', '🏂', '🏋️', '🤸',
      ],
      'Travel and Places': [
        '🚗', '🚕', '🚙', '🚌', '🚎', '🏎️', '🚓', '🚑', '🚒', '🚐',
        '🚚', '🚛', '🚜', '🛵', '🏍️', '🚲', '✈️', '🛫', '🛬', '🚀',
        '🚁', '🚢', '⛵', '🚤', '🏠', '🏡', '🏢', '🏥', '🏦', '🏨',
        '🏫', '🏰', '🗼', '🗽', '⛲', '🌋', '🏔️', '🏖️', '🏝️',
      ],
      'Objects': [
        '⌚', '📱', '💻', '⌨️', '🖥️', '🖨️', '🖱️', '💽', '💾', '💿',
        '📷', '📹', '🎥', '📞', '☎️', '📺', '📻', '⏰', '⌛', '🔋',
        '🔌', '💡', '🔦', '🕯️', '📚', '📖', '📝', '✏️', '✒️', '📌',
        '📍', '📎', '🔒', '🔓', '🔑', '🔨', '🪛', '🔧', '⚙️',
      ],
      'Flags': [
        '🏳️', '🏴', '🏁', '🚩', '🏳️‍🌈', '🇮🇳', '🇺🇸', '🇬🇧', '🇨🇦',
        '🇦🇺', '🇯🇵', '🇨🇳', '🇫🇷', '🇩🇪', '🇮🇹', '🇧🇷', '🇸🇬', '🇦🇪',
        '🇸🇦', '🇰🇷',
      ],
    };

    const List<String> categories = [
      'All',
      'Symbols',
      'People',
      'Animals and Nature',
      'Food and Drink',
      'Activity',
      'Travel and Places',
      'Objects',
      'Flags',
    ];

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.18),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final List<String> emojis =
                emojiGroups[selectedCategory] ?? const [];
            final String query = searchText.trim();
            final List<String> filteredEmojis = query.isEmpty
                ? emojis
                : emojis
                    .where((emoji) => emoji.contains(query))
                    .toList();

            return Dialog(
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 480,
                  maxHeight: 390,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Emojis',
                              style: TextStyle(
                                color: Color(0xFF233142),
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.close_rounded,
                              size: 22,
                              color: Color(0xFF263238),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 145,
                              child: ListView(
                                children: [
                                  for (final category in categories)
                                    _EmojiCategoryButton(
                                      text: category,
                                      selected: selectedCategory == category,
                                      onTap: () {
                                        setDialogState(() {
                                          selectedCategory = category;
                                          searchText = '';
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Search',
                                    style: TextStyle(
                                      color: Color(0xFF6F7478),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  TextFormField(
                                    onChanged: (value) {
                                      setDialogState(() {
                                        searchText = value;
                                      });
                                    },
                                    decoration: _emojiFieldDecoration(),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: Scrollbar(
                                      thumbVisibility: true,
                                      child: GridView.builder(
                                        padding: const EdgeInsets.only(right: 10),
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 8,
                                          mainAxisSpacing: 3,
                                          crossAxisSpacing: 3,
                                          childAspectRatio: 1,
                                        ),
                                        itemCount: filteredEmojis.length,
                                        itemBuilder: (context, index) {
                                          return _EmojiCell(
                                            emoji: filteredEmojis[index],
                                            onTap: () {
                                              _insertEmoji(filteredEmojis[index]);
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: _imageButtonStyle(
                            backgroundColor: const Color(0xFF0D6EFD),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Close'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  InputDecoration _emojiFieldDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFFE2E5E7)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5),
        borderSide: const BorderSide(color: Color(0xFF0D6EFD)),
      ),
    );
  }

  void _insertEmoji(String emoji) {
    final TextEditingController controller = widget.controller;
    final String currentText = controller.text;
    final TextSelection selection = controller.selection;
    final int start = selection.start >= 0
        ? selection.start
        : currentText.length;
    final int end = selection.end >= 0
        ? selection.end
        : currentText.length;
    final String updatedText = currentText.replaceRange(start, end, emoji);

    controller.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(
        offset: start + emoji.length,
      ),
    );
  }

  Future<void> _showFormatMenu() async {
    final String? selected = await showMenu<String>(
      context: context,
      color: Colors.white,
      position:
          const RelativeRect.fromLTRB(
        275,
        250,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'bold',
          child: Text(
            'Bold',
          ),
        ),
        PopupMenuItem(
          value: 'italic',
          child: Text(
            'Italic',
          ),
        ),
        PopupMenuItem(
          value: 'underline',
          child: Text(
            'Underline',
          ),
        ),
        PopupMenuItem(
          value: 'strike',
          child: Text(
            'Strikethrough',
          ),
        ),
        PopupMenuItem(
          value: 'super',
          child: Text(
            'Superscript',
          ),
        ),
        PopupMenuItem(
          value: 'sub',
          child: Text(
            'Subscript',
          ),
        ),
        PopupMenuItem(
          value: 'code',
          child: Text(
            'Code',
          ),
        ),
        PopupMenuDivider(),
        _submenuItem(
          label: 'Formats  ›',
          items: const ['Paragraph', 'Heading 1', 'Heading 2', 'Heading 3'],
        ),
        _submenuItem(
          label: 'Blocks  ›',
          items: const ['Paragraph', 'Blockquote', 'Preformatted'],
        ),
        _submenuItem(
          label: 'Fonts  ›',
          items: _fonts,
        ),
        _submenuItem(
          label: 'Font sizes  ›',
          items: _fontSizes,
        ),
        _submenuItem(
          label: 'Align  ›',
          items: const ['Left', 'Center', 'Right', 'Justify'],
        ),
        _submenuItem(
          label: 'Line height  ›',
          items: const ['Normal', '1.0', '1.5', '2.0'],
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'text_color',
          child: Text(
            'Text color',
          ),
        ),
        PopupMenuItem(
          value: 'background',
          child: Text(
            'Background color',
          ),
        ),
      ],
    );

    if (selected != null && selected.startsWith('text_color:')) {
      _applyTextColor(selected.substring('text_color:'.length));
    }
    if (selected == 'text_color') {
      _showTextColorDialog();
    }
  }

  void _applyTextColor(String colorHex) {
    final TextRange range = _selectedRange();
    if (range.isCollapsed) return;

    final Color color = Color(
      int.parse('FF${colorHex.substring(1)}', radix: 16),
    );

    _richController.applyStyle(
      start: range.start,
      end: range.end,
      fontStyle: TextStyle(color: color),
    );

    _richController.selection = _activeFormattingSelection();
  }

  Future<void> _showTextColorDialog() async {
    const List<Map<String, String>> colors = [
      {'name': 'Black', 'value': '#000000'},
      {'name': 'Red', 'value': '#D32F2F'},
      {'name': 'Green', 'value': '#2E7D32'},
      {'name': 'Blue', 'value': '#1565C0'},
      {'name': 'Orange', 'value': '#EF6C00'},
      {'name': 'Purple', 'value': '#6A1B9A'},
    ];

    final String? selectedColor = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Text color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in colors)
              TextButton(
                onPressed: () => Navigator.pop(context, color['value']),
                child: Text(
                  color['name']!,
                  style: TextStyle(
                    color: Color(
                      int.parse(
                        'FF${color['value']!.substring(1)}',
                        radix: 16,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (selectedColor != null) {
      _applyTextColor(selectedColor);
    }
  }

  PopupMenuItem<String> _submenuItem({
    required String label,
    required List<String> items,
  }) {
    return PopupMenuItem<String>(
      enabled: false,
      child: MouseRegion(
        onEnter: (_) => _showSubmenu(items),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            label,
            style: const TextStyle(color: Colors.black),
          ),
        ),
      ),
    );
  }

  bool _submenuVisible = false;

  Future<void> _showSubmenu(List<String> items) async {
    if (_submenuVisible && mounted) {
      Navigator.of(context).pop();
    }

    _submenuVisible = true;
    await showMenu<String>(
      context: context,
      color: Colors.white,
      position: const RelativeRect.fromLTRB(
        470,
        250,
        0,
        0,
      ),
      items: [
        for (final item in items)
          PopupMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(color: Colors.black),
            ),
          ),
      ],
    );
    _submenuVisible = false;
  }

  Future<void> _showToolsMenu() async {
    final String? selected = await showMenu<String>(
      context: context,
      color: Colors.black,
      position: const RelativeRect.fromLTRB(
        340,
        250,
        0,
        0,
      ),
      items: const [
        PopupMenuItem(
          value: 'source_code',
          child: Text(
            'Source code',
            style: TextStyle(color: Colors.white),
          ),
        ),
        PopupMenuItem(
          value: 'word_count',
          child: Text(
            'Word count',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );

    if (selected == 'source_code') {
      _openSourceCodeDialog();
    }

    if (selected == 'word_count') {
      _openWordCountDialog();
    }
  }

  Future<void> _openWordCountDialog() async {
    final String text = widget.controller.text;
    final String trimmedText = text.trim();

    final int words = trimmedText.isEmpty
        ? 0
        : trimmedText
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .length;

    final int characters = text.length;
    final int charactersNoSpaces =
        text.replaceAll(RegExp(r'\s'), '').length;

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 480,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                14,
                16,
                10,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Word Count',
                          style: TextStyle(
                            color: Color(0xFF233142),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: Text(
                          'Count',
                          style: TextStyle(
                            color: Color(0xFF263238),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Document',
                          style: TextStyle(
                            color: Color(0xFF263238),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Selection',
                          style: TextStyle(
                            color: Color(0xFF263238),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _wordCountRow(
                    label: 'Words',
                    document: words,
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFF7D8488),
                  ),
                  _wordCountRow(
                    label: 'Characters (no spaces)',
                    document: charactersNoSpaces,
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFF7D8488),
                  ),
                  _wordCountRow(
                    label: 'Characters',
                    document: characters,
                  ),
                  const SizedBox(height: 22),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D6EFD),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _wordCountRow({
    required String label,
    required int document,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF37424A),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              document.toString(),
              style: const TextStyle(
                color: Color(0xFF37424A),
                fontSize: 14,
              ),
            ),
          ),
          const Expanded(
            flex: 2,
            child: Text(
              '0',
              style: TextStyle(
                color: Color(0xFF37424A),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSourceCodeDialog() async {
    final TextEditingController sourceController =
        TextEditingController(
      text: widget.controller.text,
    );

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.all(10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: SizedBox(
            width: double.infinity,
            height: 620,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    12,
                    8,
                    8,
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Source Code',
                          style: TextStyle(
                            color: Color(0xFF233142),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 22,
                          color: Color(0xFF263238),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      6,
                      16,
                      12,
                    ),
                    child: TextFormField(
                      controller: sourceController,
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'monospace',
                        height: 1.4,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.all(8),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D6EFD),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color(0xFF0D6EFD),
                            width: 1.7,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF1F1F1),
                          foregroundColor: Colors.black,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          widget.controller.text =
                              sourceController.text;
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D6EFD),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    sourceController.dispose();
  }

  Future<void> _showTableMenu() async {
    await showMenu<String>(
      context: context,
      color: Colors.white,
      position: const RelativeRect.fromLTRB(
        400,
        250,
        0,
        0,
      ),
      items: [
        PopupMenuItem(
          value: 'table',
          child: Text(
            'Table',
          ),
        ),
        _submenuItem(
          label: 'Cell  ›',
          items: const ['Merge cells', 'Split cells'],
        ),
        _submenuItem(
          label: 'Row  ›',
          items: const ['Insert row above', 'Insert row below', 'Delete row'],
        ),
        _submenuItem(
          label: 'Column  ›',
          items: const [
            'Insert column left',
            'Insert column right',
            'Delete column',
          ],
        ),
        PopupMenuDivider(),
        PopupMenuItem(
          value: 'table_properties',
          child: Text(
            'Table properties',
          ),
        ),
        PopupMenuItem(
          value: 'delete_table',
          child: Text(
            'Delete table',
          ),
        ),
      ],
    );
  }

  Future<void> _showHelpMenu() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(
        alpha: 0.18,
      ),
      builder: (context) {
        return const _HelpDialog();
      },
    );
  }

  Widget _menuItem(String label, {VoidCallback? onPressed}) {
    return MenuItemButton(
      onPressed: onPressed,
      style: _menuOptionStyle,
      child: Text(
        label,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  static const ButtonStyle _menuOptionStyle = ButtonStyle(
    overlayColor: WidgetStatePropertyAll(Color(0xFF0D6EFD)),
  );

  List<Widget> _menuChildren(String menu) {
    switch (menu) {
      case 'File':
        return [
          _menuItem('New document'),
          _menuItem('Restore last draft'),
          _menuItem('Preview', onPressed: _openPreviewDialog),
          _menuItem('Print...'),
        ];
      case 'Edit':
        return [
          _menuItem('Undo', onPressed: _undoEdit),
          _menuItem('Redo', onPressed: _redoEdit),
          _menuItem('Cut', onPressed: _cutEdit),
          _menuItem('Copy', onPressed: _copyEdit),
          _menuItem('Paste', onPressed: _pasteEdit),
          _menuItem('Paste as text', onPressed: _pasteEdit),
          _menuItem('Select all', onPressed: _selectAllEdit),
          _menuItem('Find and replace...', onPressed: _openFindReplaceDialog),
        ];
      case 'View':
        return [
          _menuItem('Source code', onPressed: _openSourceCodeDialog),
          _menuItem('Visual aids'),
          _menuItem('Show invisible characters'),
          _menuItem('Show blocks'),
          _menuItem('Preview', onPressed: _openPreviewDialog),
          _menuItem('Fullscreen', onPressed: _openFullscreenEditor),
        ];
      case 'Insert':
        return [
          _menuItem('Image...', onPressed: _openImageDialog),
          _menuItem('Link...', onPressed: _openLinkDialog),
          _menuItem('Media...', onPressed: _openMediaDialog),
          _menuItem('Template...'),
          _menuItem(
            'Code sample...',
            onPressed: _openCodeSampleDialog,
          ),
          _menuItem('Table'),
          _menuItem('Special character...', onPressed: _openSpecialCharacterDialog),
          _menuItem('Emojis...', onPressed: _openEmojiDialog),
          _menuItem('Horizontal line'),
          _menuItem('Page break'),
          _menuItem('Nonbreaking space'),
          _menuItem('Anchor...', onPressed: _openAnchorDialog),
        ];
      case 'Format':
        return [
          _menuItem('Bold'),
          _menuItem('Italic'),
          _menuItem('Underline'),
          _menuItem('Strikethrough'),
          _menuItem('Superscript'),
          _menuItem('Subscript'),
          _menuItem('Code'),
          SubmenuButton(
            style: _menuOptionStyle,
            menuChildren: [
              _menuItem('Paragraph'),
              _menuItem('Heading 1'),
              _menuItem('Heading 2'),
              _menuItem('Heading 3'),
            ],
            child: const Text('Formats'),
          ),
          SubmenuButton(
            style: _menuOptionStyle,
            menuChildren: [
              _menuItem('Paragraph'),
              _menuItem('Blockquote'),
              _menuItem('Preformatted'),
            ],
            child: const Text('Blocks'),
          ),
          SubmenuButton(
            style: _menuOptionStyle,
            menuChildren: [
              for (final font in _fonts) _menuItem(font),
            ],
            child: const Text('Fonts'),
          ),
          SubmenuButton(
            style: _menuOptionStyle,
            menuChildren: [
              for (final size in _fontSizes) _menuItem(size),
            ],
            child: const Text('Font sizes'),
          ),
          SubmenuButton(
            style: _menuOptionStyle,
            menuChildren: [
              _menuItem('Left'),
              _menuItem('Center'),
              _menuItem('Right'),
              _menuItem('Justify'),
            ],
            child: const Text('Align'),
          ),
          SubmenuButton(
            style: _menuOptionStyle,
            menuChildren: [
              _menuItem('Normal'),
              _menuItem('1.0'),
              _menuItem('1.5'),
              _menuItem('2.0'),
            ],
            child: const Text('Line height'),
          ),
          _menuItem('Text color', onPressed: _showTextColorDialog),
          _menuItem('Background color'),
        ];
      case 'Tools':
        return [
          _menuItem('Source code', onPressed: _openSourceCodeDialog),
          _menuItem('Word count', onPressed: _openWordCountDialog),
        ];
      case 'Table':
        return [
          _menuItem('Table'),
          SubmenuButton(
            style: _menuOptionStyle,
            menuChildren: [_menuItem('Merge cells'), _menuItem('Split cells')],
            child: const Text('Cell'),
          ),
          SubmenuButton(
            style: _menuOptionStyle,
            menuChildren: [
              _menuItem('Insert row above'),
              _menuItem('Insert row below'),
              _menuItem('Delete row'),
            ],
            child: const Text('Row'),
          ),
          SubmenuButton(
            style: _menuOptionStyle,
            menuChildren: [
              _menuItem('Insert column left'),
              _menuItem('Insert column right'),
              _menuItem('Delete column'),
            ],
            child: const Text('Column'),
          ),
          _menuItem('Table properties'),
          _menuItem('Delete table'),
        ];
      case 'Help':
        return [
          _menuItem('Help', onPressed: _showHelpMenu),
        ];
      default:
        return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        popupMenuTheme: const PopupMenuThemeData(
          color: Colors.white,
          textStyle: TextStyle(color: Colors.black),
        ),
        menuTheme: const MenuThemeData(
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
          ),
        ),
      ),
      child: Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.white,
          width: 1.2,
        ),
      ),
      child: Column(
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 42),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MenuButton(
                  text: 'File',
                  onTap: _showFileMenu,
                  menuChildren: _menuChildren('File'),
                ),
                _MenuButton(
                  text: 'Edit',
                  onTap: _showEditMenu,
                  menuChildren: _menuChildren('Edit'),
                ),
                _MenuButton(
                  text: 'View',
                  onTap: _showViewMenu,
                  menuChildren: _menuChildren('View'),
                ),
                _MenuButton(
                  text: 'Insert',
                  onTap: _showInsertMenu,
                  menuChildren: _menuChildren('Insert'),
                ),
                _MenuButton(
                  text: 'Format',
                  onTap: _showFormatMenu,
                  menuChildren: _menuChildren('Format'),
                ),
                _MenuButton(
                  text: 'Tools',
                  onTap: _showToolsMenu,
                  menuChildren: _menuChildren('Tools'),
                ),
                _MenuButton(
                  text: 'Table',
                  onTap: _showTableMenu,
                  menuChildren: _menuChildren('Table'),
                ),
                _MenuButton(
                  text: 'Help',
                  onTap: _showHelpMenu,
                  menuChildren: _menuChildren('Help'),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.undo_rounded, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.redo_rounded, size: 18, color: Color(0xFF2F3032)),
                const SizedBox(width: 8),
                const Icon(Icons.format_bold, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.format_italic, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.format_underlined, size: 18, color: Color(0xFF2F3032)),
                const SizedBox(width: 8),
                SizedBox(
                  width: 160,
                  height: 34,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      hoverColor: const Color(0xFF0D6EFD),
                    ),
                    child: DropdownButtonFormField<String>(
                    value: _font,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.black),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF3A3A3A), size: 18),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFCDD1D4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFCDD1D4)),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: _fonts
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      _applySelectedFont(value);
                    },
                    ),
                  ),
                ),
                SizedBox(
                  width: 92,
                  height: 34,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      hoverColor: const Color(0xFF0D6EFD),
                    ),
                    child: DropdownButtonFormField<String>(
                    value: _fontSize,
                    style: const TextStyle(color: Colors.black),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF3A3A3A), size: 18),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFCDD1D4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFCDD1D4)),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: _fontSizes
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      _applySelectedFontSize(value);
                    },
                    ),
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 34,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      hoverColor: const Color(0xFF0D6EFD),
                    ),
                    child: DropdownButtonFormField<String>(
                    value: _paragraph,
                    isExpanded: true,
                    style: const TextStyle(color: Colors.black),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF3A3A3A), size: 18),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFCDD1D4)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(color: Color(0xFFCDD1D4)),
                      ),
                    ),
                    dropdownColor: Colors.white,
                    items: _paragraphs
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              item,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      _applySelectedParagraph(value);
                    },
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.format_align_left, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.format_align_center, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.format_align_right, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.format_align_justify, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.format_indent_decrease, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.format_indent_increase, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.format_list_numbered, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.format_list_bulleted, size: 18, color: Color(0xFF2F3032)),
                const Icon(Icons.more_horiz, size: 18, color: Color(0xFF2F3032)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: TextFormField(
                controller: _richController,
                minLines: 24,
                maxLines: null,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF202224),
                  height: 1.5,
                ),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.all(18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _EmojiCategoryButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _EmojiCategoryButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? const Color(0xFF0D6EFD)
                : const Color(0xFF6F7478),
            fontSize: 13,
            decoration: selected
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: const Color(0xFF0D6EFD),
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }
}

class _EmojiCell extends StatefulWidget {
  final String emoji;
  final VoidCallback onTap;

  const _EmojiCell({
    required this.emoji,
    required this.onTap,
  });

  @override
  State<_EmojiCell> createState() => _EmojiCellState();
}

class _EmojiCellState extends State<_EmojiCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFFDCEBFF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.emoji,
            style: const TextStyle(fontSize: 19),
          ),
        ),
      ),
    );
  }
}

class _SpecialCharacterCategory extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SpecialCharacterCategory({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? const Color(0xFF0D6EFD)
                : const Color(0xFF6F7478),
            fontSize: 13,
            decoration: selected
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: const Color(0xFF0D6EFD),
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }
}

class _SpecialCharacterCell extends StatefulWidget {
  final String character;
  final VoidCallback onTap;

  const _SpecialCharacterCell({
    required this.character,
    required this.onTap,
  });

  @override
  State<_SpecialCharacterCell> createState() =>
      _SpecialCharacterCellState();
}

class _SpecialCharacterCellState
    extends State<_SpecialCharacterCell> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          _hovered = false;
        });
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFFDCEBFF)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            widget.character,
            style: const TextStyle(
              color: Color(0xFF233142),
              fontSize: 17,
            ),
          ),
        ),
      ),
    );
  }
}

class _MediaTabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _MediaTabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 7,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? const Color(0xFF0D6EFD)
                : const Color(0xFF6F7478),
            fontSize: 13,
            decoration: selected
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: const Color(0xFF0D6EFD),
            decorationThickness: 2,
          ),
        ),
      ),
    );
  }
}

class _FindArrowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _FindArrowButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(
          icon,
          size: 23,
          color: enabled
              ? const Color(0xFF73808A)
              : const Color(0xFFAEB5BA),
        ),
      ),
    );
  }
}

class _FullscreenTemplateEditorPage extends StatelessWidget {
  final TextEditingController controller;

  const _FullscreenTemplateEditorPage({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE3E7E9),
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Template Body',
                      style: TextStyle(
                        color: Color(0xFF233142),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Exit Fullscreen',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.fullscreen_exit_rounded,
                      size: 25,
                      color: Color(0xFF263238),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextFormField(
                  controller: controller,
                  expands: true,
                  minLines: null,
                  maxLines: null,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Template Body',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(18),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFFDDE2E5),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFF0D6EFD),
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                12,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FA),
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE3E7E9),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.fullscreen_exit_rounded,
                      size: 17,
                    ),
                    label: const Text('Exit Fullscreen'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String text;
  final VoidCallback? onTap;
  final List<Widget> menuChildren;

  const _MenuButton({
    required this.text,
    this.onTap,
    this.menuChildren = const [],
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  static _MenuButtonState? _activeMenu;
  final MenuController _menuController = MenuController();

  void _openMenu() {
    _activeMenu?._menuController.close();
    _activeMenu = this;
    _menuController.open();
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      controller: _menuController,
      menuChildren: widget.menuChildren,
      builder: (context, controller, child) {
        return MouseRegion(
          onEnter: (_) => _openMenu(),
          child: InkWell(
            onTap: _openMenu,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Text(
                widget.text,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    if (identical(_activeMenu, this)) {
      _activeMenu = null;
    }
    super.dispose();
  }
}

class _HelpDialog extends StatefulWidget {
  const _HelpDialog();

  @override
  State<_HelpDialog> createState() =>
      _HelpDialogState();
}

class _HelpDialogState extends State<_HelpDialog> {
  String _selectedTab = 'Handy Shortcuts';

  static const List<String> _tabs = [
    'Handy Shortcuts',
    'Keyboard Navigation',
    'Plugins',
    'Version',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 40,
        vertical: 30,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 810,
          maxHeight: 625,
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                10,
                6,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Help',
                      style: TextStyle(
                        color: Color(0xFF2F3539),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 22,
                      color: Color(0xFF42484C),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 165,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        12,
                        8,
                        12,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          for (final tab in _tabs)
                            _HelpTabButton(
                              text: tab,
                              selected: _selectedTab == tab,
                              onTap: () {
                                setState(() {
                                  _selectedTab = tab;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        4,
                        12,
                        12,
                      ),
                      child: _buildContent(),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                6,
                16,
                10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D6EFD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 'Keyboard Navigation':
        return _keyboardNavigation();
      case 'Plugins':
        return _plugins();
      case 'Version':
        return _version();
      case 'Handy Shortcuts':
      default:
        return _handyShortcuts();
    }
  }

  Widget _handyShortcuts() {
    const shortcuts = [
      ['Italic', 'Ctrl + I'],
      ['Underline', 'Ctrl + U'],
      ['Select all', 'Ctrl + A'],
      ['Redo', 'Ctrl + Y or Ctrl + Shift + Z'],
      ['Undo', 'Ctrl + Z'],
      ['Heading 1', 'Shift + Alt + 1'],
      ['Heading 2', 'Shift + Alt + 2'],
      ['Heading 3', 'Shift + Alt + 3'],
      ['Heading 4', 'Shift + Alt + 4'],
      ['Heading 5', 'Shift + Alt + 5'],
      ['Heading 6', 'Shift + Alt + 6'],
      ['Paragraph', 'Shift + Alt + 7'],
      ['Div', 'Shift + Alt + 8'],
      ['Address', 'Shift + Alt + 9'],
      ['Open help dialog', 'Alt + 0'],
      ['Focus to menubar', 'Alt + F9'],
      ['Focus to toolbar', 'Alt + F10'],
      ['Focus to element path', 'Alt + F11'],
      ['Focus to contextual toolbar', 'Ctrl + F9'],
      ['Open popup menu for split buttons', 'Shift + Enter'],
      ['Insert link', 'Ctrl + K'],
      ['Save', 'Ctrl + S'],
      ['Find', 'Ctrl + F'],
    ];

    return Scrollbar(
      thumbVisibility: true,
      child: ListView.separated(
        itemCount: shortcuts.length,
        separatorBuilder: (_, __) {
          return const Divider(
            height: 1,
            color: Color(0xFF72777A),
          );
        },
        itemBuilder: (context, index) {
          final item = shortcuts[index];

          return Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item[0],
                    style: const TextStyle(
                      color: Color(0xFF454B4F),
                      fontSize: 14,
                    ),
                  ),
                ),
                SizedBox(
                  width: 240,
                  child: Text(
                    item[1],
                    style: const TextStyle(
                      color: Color(0xFF454B4F),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _keyboardNavigation() {
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            4,
            8,
            18,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Begin keyboard navigation',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Focus the Menu bar\n'
                'Windows or Linux: Alt+F9\n'
                'macOS: ⌃+F9\n\n'
                'Focus the Toolbar\n'
                'Windows or Linux: Alt+F10\n'
                'macOS: ⌃+F10\n\n'
                'Focus the Footer\n'
                'Windows or Linux: Alt+F11\n'
                'macOS: ⌃+F11\n\n'
                'Focus a contextual toolbar\n'
                'Windows, Linux or macOS: Ctrl+F9',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Navigate between UI sections',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'To move from one UI section to the next, press Tab.\n\n'
                'To move from one UI section to the previous, press Shift+Tab.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 18),
              Text(
                'Navigate within UI sections',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Use the appropriate Arrow keys to move between menu items, '
                'toolbar buttons and other controls.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _plugins() {
    const plugins = [
      'Advanced Typography',
      'AI Assistant',
      'Case Change',
      'Checklist',
      'Enhanced Image Editing',
      'Enhanced Media Embed',
      'Export',
      'Footnotes',
      'Format Painter',
      'Inline CSS',
      'Link Checker',
      'Mentions',
      'Merge Tags',
      'Page Embed',
      'Permanent Pen',
      'PowerPaste',
      'Real-Time Collaboration',
      'Spell Checker Pro',
      'Spelling Autocorrect',
      'Table of Contents',
      'Tiny Comments',
      'Tiny Drive',
    ];

    return Scrollbar(
      thumbVisibility: true,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          5,
          5,
          18,
          20,
        ),
        children: [
          for (final plugin in plugins)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 2,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      top: 6,
                    ),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(0xFF30363A),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      plugin,
                      style: const TextStyle(
                        color: Color(0xFF454B4F),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 15),
          const Text(
            'Learn more...',
            style: TextStyle(
              color: Color(0xFF1688E8),
              fontSize: 14,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _version() {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          'Version',
          style: TextStyle(
            color: Color(0xFF454B4F),
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _HelpTabButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _HelpTabButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 7,
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected
                ? const Color(0xFF1688E8)
                : const Color(0xFF777D81),
            fontSize: 13,
            decoration: selected
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: const Color(0xFF1688E8),
            decorationThickness: 2,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}