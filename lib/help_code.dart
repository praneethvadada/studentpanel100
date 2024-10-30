import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:studentpanel100/widgets/arrows_ui.dart';

class CodingQuestionDetailPage extends StatefulWidget {
  final Map<String, dynamic> question;

  const CodingQuestionDetailPage({Key? key, required this.question})
      : super(key: key);

  @override
  State<CodingQuestionDetailPage> createState() =>
      _CodingQuestionDetailPageState();
}

class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage> {
  late CodeController _codeController;
  final FocusNode _focusNode = FocusNode();
  List<TestCaseResult> testResults = [];
  final ScrollController _rightPanelScrollController = ScrollController();
  String? _selectedLanguage =
      "Please select a Language"; // Default language prompt
  TextEditingController _customInputController =
      TextEditingController(); // Controller for custom input
  bool _iscustomInputfieldVisible = false;
  double _dividerPosition = 0.5;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(text: '''
***************************************************
***************  Select a Language  ***************
***************************************************
''');
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        RawKeyboard.instance.addListener(_handleKeyPress);
      } else {
        RawKeyboard.instance.removeListener(_handleKeyPress);
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    _customInputController.dispose();
    super.dispose();
  }

  // Capture Ctrl + / keyboard event
  void _handleKeyPress(RawKeyEvent event) {
    if (event.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.slash) {
      _commentSelectedLines();
    }
  }

  // Comment/uncomment selected lines based on language
  void _commentSelectedLines() {
    final selection = _codeController.selection;
    final text = _codeController.text;
    final commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

    if (selection.isCollapsed) {
      // No text is selected, so comment the current line
      int lineStart = selection.start;
      int lineEnd = selection.start;

      // Find the start and end of the line
      while (lineStart > 0 && text[lineStart - 1] != '\n') lineStart--;
      while (lineEnd < text.length && text[lineEnd] != '\n') lineEnd++;

      // Extract the current line and toggle comment
      final lineText = text.substring(lineStart, lineEnd);
      final isCommented = lineText.trimLeft().startsWith(commentSyntax);

      // Toggle comment on the line
      final newLineText = isCommented
          ? lineText.replaceFirst(commentSyntax, '').trimLeft() // Uncomment
          : '$commentSyntax $lineText'; // Comment

      // Replace the line in the text
      final newText = text.replaceRange(lineStart, lineEnd, newLineText);
      _codeController.value = _codeController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
            offset: isCommented
                ? selection.start - commentSyntax.length - 1
                : selection.start + commentSyntax.length + 1),
      );
    } else {
      // Text is selected, so comment each selected line
      final selectedText = text.substring(selection.start, selection.end);
      final lines = selectedText.split('\n');
      final allLinesCommented =
          lines.every((line) => line.trimLeft().startsWith(commentSyntax));

      // Toggle comment on each line
      final commentedLines = lines.map((line) {
        return allLinesCommented
            ? line.replaceFirst(commentSyntax, '').trimLeft() // Uncomment
            : '$commentSyntax $line'; // Comment
      }).join('\n');

      // Replace the selected text with the commented/uncommented text
      final newText =
          text.replaceRange(selection.start, selection.end, commentedLines);

      _codeController.value = _codeController.value.copyWith(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.start + commentedLines.length,
        ),
      );
    }
  }

  void _setStarterCode(String language) {
    String starterCode;
    switch (language.toLowerCase()) {
      case 'python':
        starterCode = '# Please Start Writing your Code here\n';
        break;
      case 'java':
        starterCode = '''
public class Main {
    public static void main(String[] args) {
        // Please Start Writing your Code from here
    }
}
''';
        break;
      case 'c':
        starterCode = '// Please Start Writing your Code here\n';
        break;
      case 'cpp':
        starterCode = '// Please Start Writing your Code here\n';
        break;
      default:
        starterCode = '// Please Start Writing your Code here\n';
    }
    _codeController.text = starterCode;
  }

  Future<void> _runCode(
      {required bool allTestCases, String? customInput}) async {
    if (_selectedLanguage == null || _codeController.text.trim().isEmpty) {
      print("No valid code provided or language not selected");
      return;
    }

    Uri endpoint;
    switch (_selectedLanguage!.toLowerCase()) {
      case 'python':
        endpoint = Uri.parse('http://localhost:8084/compile');
        break;
      case 'java':
        endpoint = Uri.parse('http://localhost:8083/compile');
        break;
      case 'cpp':
        endpoint = Uri.parse('http://localhost:8081/compile');
        break;
      case 'c':
        endpoint = Uri.parse('http://localhost:8082/compile');
        break;
      default:
        print("Unsupported language selected");
        return;
    }

    print('Selected Endpoint URL: $endpoint');

    final String code = _codeController.text.trim();
    List<Map<String, String>> testCases;

    // Determine which test cases to send based on the button clicked
    if (customInput != null) {
      testCases = [
        {
          'input': customInput.trim() + '\n',
          'output': '', // No expected output for custom input
        },
      ];
    } else if (allTestCases) {
      testCases = widget.question['test_cases']
          .map<Map<String, String>>((testCase) => {
                'input': testCase['input'].toString().trim() + '\n',
                'output': testCase['output'].toString().trim(),
              })
          .toList();
    } else {
      // Run only public test cases
      testCases = widget.question['test_cases']
          .where((testCase) => testCase['is_public'] == true)
          .map<Map<String, String>>((testCase) => {
                'input': testCase['input'].toString().trim() + '\n',
                'output': testCase['output'].toString().trim(),
              })
          .toList();
    }

    final Map<String, dynamic> requestBody = {
      'language': _selectedLanguage!.toLowerCase(),
      'code': code,
      'testcases': testCases,
    };

    print('Request Body: ${jsonEncode(requestBody)}');

    try {
      final response = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          testResults = responseBody.map((result) {
            return TestCaseResult(
              testCase: result['input'],
              expectedResult: result['expected_output'] ?? '',
              actualResult: result['actual_output'] ?? '',
              passed: result['success'] ?? false,
              errorMessage: result['error'] ?? '',
            );
          }).toList();
        });
        _scrollToResults();
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        print('Backend Error Response: ${response.body}');
        setState(() {
          testResults = [
            TestCaseResult(
              testCase: '',
              expectedResult: '',
              actualResult: '',
              passed: false,
              errorMessage: jsonDecode(response.body)['error'],
            ),
          ];
        });
      }
    } catch (error) {
      print('Error sending request: $error');
    }
  }

  void _scrollToResults() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _rightPanelScrollController.animateTo(
        _rightPanelScrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  void _navigateToCodeDisplay(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayCodePage(
          code: _codeController.text,
        ),
      ),
    );
  }

  void _toggleInputFieldVisibility() {
    setState(() {
      _iscustomInputfieldVisible = !_iscustomInputfieldVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question['title']),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          // Calculate the width of the panels based on the divider position
          final leftPanelWidth = screenWidth * _dividerPosition;
          final rightPanelWidth = screenWidth * (1 - _dividerPosition);
          return Row(
            children: [
              // Left Panel: Question details
              Container(
                width: leftPanelWidth,
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(25.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.question['title'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Text("Description",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.question['description'],
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        const Text("Input Format",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.question['input_format'],
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 16),
                        const Text("Output Format",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.question['output_format'],
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 16),
                        const Text("Constraints",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.question['constraints'],
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List<Widget>.generate(
                            widget.question['test_cases'].length,
                            (index) {
                              final testCase =
                                  widget.question['test_cases'][index];
                              return Card(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Input: ${testCase['input']}",
                                          style: TextStyle(fontSize: 16)),
                                      Text("Output: ${testCase['output']}",
                                          style: TextStyle(fontSize: 16)),
                                      if (testCase['is_public'])
                                        Text(
                                            "Explanation: ${testCase['explanation'] ?? ''}",
                                            style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 16),
                        Text("Difficulty",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(widget.question['difficulty'],
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),

              // VerticalDivider(width: 1, color: Colors.grey),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  setState(() {
                    _dividerPosition += details.delta.dx / screenWidth;
                    // Limit the position between 0.35 (35%) and 0.55 (55%)
                    _dividerPosition = _dividerPosition.clamp(0.28, 0.55);
                  });
                },
                child: Container(
                  color: Colors.transparent,
                  width: 22,
                  child: Center(
                    child: Row(
                      children: [
                        Container(
                          height: 5,
                          width: 10,
                          color: Colors.transparent,
                          child: CustomPaint(
                            painter: LeftArrowPainter(
                              strokeColor: Colors.grey,
                              strokeWidth: 0,
                              paintingStyle: PaintingStyle.fill,
                            ),
                            child: const SizedBox(
                              height: 5,
                              width: 10,
                            ),
                          ),
                        ),
                        Container(
                          height: double.infinity,
                          width: 2,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Container(
                          height: 5,
                          width: 10,
                          color: Colors.transparent,
                          child: CustomPaint(
                            painter: RightArrowPainter(
                              strokeColor: Colors.grey,
                              strokeWidth: 0,
                              paintingStyle: PaintingStyle.fill,
                            ),
                            child: const SizedBox(
                              height: 5,
                              width: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Right Panel: Code editor and results
              Expanded(
                child: Container(
                  width: rightPanelWidth,
                  height: MediaQuery.of(context).size.height * 2,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    controller: _rightPanelScrollController,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text("Select Language",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          DropdownButton<String>(
                            value: _selectedLanguage,
                            onChanged: (String? newValue) {
                              if (newValue != null &&
                                  newValue != "Please select a Language") {
                                if (_selectedLanguage !=
                                    "Please select a Language") {
                                  // Show alert if a language was previously selected
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("Change Language"),
                                        content: Text(
                                            "Changing the language will remove the current code. Do you want to proceed?"),
                                        actions: [
                                          TextButton(
                                            child: Text("Cancel"),
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                          ),
                                          TextButton(
                                            child: Text("Proceed"),
                                            onPressed: () {
                                              // Proceed with changing the language and setting starter code
                                              setState(() {
                                                _selectedLanguage = newValue;
                                                _setStarterCode(newValue);
                                              });
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  // Directly set language and starter code if no language was selected previously
                                  setState(() {
                                    _selectedLanguage = newValue;
                                    _setStarterCode(newValue);
                                  });
                                }
                              }
                            },
                            items: [
                              DropdownMenuItem<String>(
                                value: "Please select a Language",
                                child: Text("Please select a Language"),
                              ),
                              ...widget.question['allowed_languages']
                                  .cast<String>()
                                  .map<DropdownMenuItem<String>>(
                                      (String language) {
                                return DropdownMenuItem<String>(
                                  value: language,
                                  child: Text(language),
                                );
                              }).toList(),
                            ],
                          ),
                          Focus(
                            focusNode:
                                _focusNode, // Attach the focus node to Focus only
                            onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
                              if (keyEvent is KeyDownEvent) {
                                final keysPressed = HardwareKeyboard
                                    .instance.logicalKeysPressed;

                                // Check for Ctrl + / shortcut
                                if (keysPressed.contains(
                                        LogicalKeyboardKey.controlLeft) &&
                                    keysPressed
                                        .contains(LogicalKeyboardKey.slash)) {
                                  _commentSelectedLines();
                                  return KeyEventResult.handled;
                                }
                              }
                              return KeyEventResult.ignored;
                            },
                            child: Container(
                              // height: 200,
                              height: MediaQuery.of(context).size.height / 1.9,
                              child: CodeField(
                                controller: _codeController,
                                focusNode: FocusNode(),
                                textStyle: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                                cursorColor: Colors.white,
                                background: Colors.black,
                                expands: true,
                                wrap: false,
                                lineNumberStyle: LineNumberStyle(
                                  width: 40,
                                  margin: 8,
                                  textStyle: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                  background: Colors.grey.shade900,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  _runCode(allTestCases: false);
                                },
                                child: Text('Run'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _runCode(allTestCases: true);
                                },
                                child: Text('Submit'),
                              ),
                              ElevatedButton(
                                onPressed: _toggleInputFieldVisibility,
                                child: Text('Custom Input'),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          AnimatedCrossFade(
                            duration: Duration(milliseconds: 300),
                            firstChild: SizedBox.shrink(),
                            secondChild: Column(
                              children: [
                                Container(
                                  // height: 250,
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  child: TextField(
                                    minLines: 5,
                                    maxLines: 5,
                                    controller: _customInputController,
                                    decoration: InputDecoration(
                                      hintText: "Enter custom input",
                                      hintStyle:
                                          TextStyle(color: Colors.white54),
                                      filled: true,
                                      fillColor: Colors.black,
                                      border: OutlineInputBorder(),
                                    ),
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    _runCode(
                                      allTestCases: false,
                                      customInput: _customInputController.text,
                                    );
                                  },
                                  child: Text('Run Custom Input'),
                                ),
                              ],
                            ),
                            crossFadeState: _iscustomInputfieldVisible
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                          ),
                          SizedBox(height: 16),
                          if (testResults.isNotEmpty)
                            TestCaseResultsTable(testResults: testResults),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class TestCaseResult {
  final String testCase;
  final String expectedResult;
  final String actualResult;
  final bool passed;
  final String errorMessage;
  final bool isCustomInput;
  TestCaseResult({
    required this.testCase,
    required this.expectedResult,
    required this.actualResult,
    required this.passed,
    this.errorMessage = '',
    this.isCustomInput = false,
  });
}

class TestCaseResultsTable extends StatelessWidget {
  final List<TestCaseResult> testResults;

  TestCaseResultsTable({required this.testResults});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Test Results",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Divider(thickness: 2),
        Column(
          children: testResults.map((result) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text("Input: ${result.testCase}")),
                    Expanded(child: Text("Output: ${result.actualResult}")),
                    Expanded(
                      child: Text(
                        result.isCustomInput
                            ? "-"
                            : "Expected: ${result.expectedResult}",
                      ),
                    ),
                    Expanded(
                      child: Text(
                        result.isCustomInput
                            ? "-"
                            : (result.passed ? "Passed" : "Failed"),
                        style: TextStyle(
                          color: result.isCustomInput
                              ? Colors.black
                              : (result.passed ? Colors.green : Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
                if (result.errorMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      "Error: ${result.errorMessage}",
                      style: TextStyle(
                          color: Colors.red, fontStyle: FontStyle.italic),
                    ),
                  ),
                Divider(thickness: 1),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}

class DisplayCodePage extends StatelessWidget {
  final String code;

  DisplayCodePage({required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          code,
          style: const TextStyle(
              fontFamily: 'SourceCodePro', fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}

// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
// // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';

// // import 'package:studentpanel100/widgets/arrows_ui.dart';

// // class CodingQuestionDetailPage extends StatefulWidget {
// //   final Map<String, dynamic> question;

// //   const CodingQuestionDetailPage({Key? key, required this.question})
// //       : super(key: key);

// //   @override
// //   State<CodingQuestionDetailPage> createState() =>
// //       _CodingQuestionDetailPageState();
// // }

// // class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage>
// //     with SingleTickerProviderStateMixin {
// //   late CodeController _codeController;
// //   final FocusNode _focusNode = FocusNode();
// //   List<TestCaseResult> testResults = [];
// //   final ScrollController _rightPanelScrollController = ScrollController();
// //   String? _selectedLanguage =
// //       "Please select a Language"; // Default language prompt
// //   TextEditingController _customInputController =
// //       TextEditingController(); // Controller for custom input
// //   bool _iscustomInputfieldVisible = false;
// //   double _dividerPosition = 0.5;
// //   late TabController _tabController;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _tabController = TabController(length: 3, vsync: this);
// //     _codeController = CodeController(text: '''
// // ***************************************************
// // ***************  Select a Language  ***************
// // ***************************************************
// // ''');
// //     _focusNode.addListener(() {
// //       if (_focusNode.hasFocus) {
// //         RawKeyboard.instance.addListener(_handleKeyPress);
// //       } else {
// //         RawKeyboard.instance.removeListener(_handleKeyPress);
// //       }
// //     });
// //   }

// //   @override
// //   void dispose() {
// //     _tabController.dispose();
// //     _codeController.dispose();
// //     _focusNode.dispose();
// //     _customInputController.dispose();
// //     super.dispose();
// //   }

// //   void _handleKeyPress(RawKeyEvent event) {
// //     if (event.isControlPressed &&
// //         event.logicalKey == LogicalKeyboardKey.slash) {
// //       _commentSelectedLines();
// //     }
// //   }

// //   void _commentSelectedLines() {
// //     final selection = _codeController.selection;
// //     final text = _codeController.text;
// //     final commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

// //     if (selection.isCollapsed) {
// //       // No text is selected, so comment the current line
// //       int lineStart = selection.start;
// //       int lineEnd = selection.start;

// //       while (lineStart > 0 && text[lineStart - 1] != '\n') lineStart--;
// //       while (lineEnd < text.length && text[lineEnd] != '\n') lineEnd++;

// //       final lineText = text.substring(lineStart, lineEnd);
// //       final isCommented = lineText.trimLeft().startsWith(commentSyntax);

// //       final newLineText = isCommented
// //           ? lineText.replaceFirst(commentSyntax, '').trimLeft() // Uncomment
// //           : '$commentSyntax $lineText'; // Comment

// //       final newText = text.replaceRange(lineStart, lineEnd, newLineText);
// //       _codeController.value = _codeController.value.copyWith(
// //         text: newText,
// //         selection: TextSelection.collapsed(
// //             offset: isCommented
// //                 ? selection.start - commentSyntax.length - 1
// //                 : selection.start + commentSyntax.length + 1),
// //       );
// //     } else {
// //       final selectedText = text.substring(selection.start, selection.end);
// //       final lines = selectedText.split('\n');
// //       final allLinesCommented =
// //           lines.every((line) => line.trimLeft().startsWith(commentSyntax));

// //       final commentedLines = lines.map((line) {
// //         return allLinesCommented
// //             ? line.replaceFirst(commentSyntax, '').trimLeft() // Uncomment
// //             : '$commentSyntax $line'; // Comment
// //       }).join('\n');

// //       final newText =
// //           text.replaceRange(selection.start, selection.end, commentedLines);

// //       _codeController.value = _codeController.value.copyWith(
// //         text: newText,
// //         selection: TextSelection(
// //           baseOffset: selection.start,
// //           extentOffset: selection.start + commentedLines.length,
// //         ),
// //       );
// //     }
// //   }

// //   Widget buildQuestionTab() {
// //     return Padding(
// //       padding: EdgeInsets.all(16.0),
// //       child: SingleChildScrollView(
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(widget.question['title'],
// //                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// //             SizedBox(height: 16),
// //             Text("Description",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //             Text(widget.question['description'],
// //                 style: TextStyle(fontSize: 16)),
// //             SizedBox(height: 16),
// //             Text("Input Format",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //             Text(widget.question['input_format'],
// //                 style: TextStyle(fontSize: 16)),
// //             SizedBox(height: 16),
// //             Text("Output Format",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //             Text(widget.question['output_format'],
// //                 style: TextStyle(fontSize: 16)),
// //             SizedBox(height: 16),
// //             Text("Constraints",
// //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //             Text(widget.question['constraints'],
// //                 style: TextStyle(fontSize: 16)),
// //             SizedBox(height: 16),
// //           ],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget buildCodeTab() {
// //     return Padding(
// //       padding: EdgeInsets.all(16.0),
// //       child: Column(
// //         children: [
// //           DropdownButton<String>(
// //             value: _selectedLanguage,
// //             onChanged: (String? newValue) {
// //               if (newValue != null && newValue != "Please select a Language") {
// //                 setState(() {
// //                   _selectedLanguage = newValue;
// //                 });
// //               }
// //             },
// //             items: [
// //               DropdownMenuItem(
// //                   value: "Please select a Language",
// //                   child: Text("Please select a Language")),
// //               ...widget.question['allowed_languages']
// //                   .cast<String>()
// //                   .map<DropdownMenuItem<String>>(
// //                 (String language) {
// //                   return DropdownMenuItem(
// //                       value: language, child: Text(language));
// //                 },
// //               ).toList(),
// //             ],
// //           ),
// //           CodeField(
// //             controller: _codeController,
// //             focusNode: _focusNode,
// //             textStyle: TextStyle(
// //                 fontFamily: 'RobotoMono', fontSize: 16, color: Colors.white),
// //             cursorColor: Colors.white,
// //             background: Colors.black,
// //             expands: true,
// //             wrap: false,
// //             lineNumberStyle: LineNumberStyle(
// //               width: 40,
// //               margin: 8,
// //               textStyle: TextStyle(color: Colors.grey.shade600, fontSize: 16),
// //               background: Colors.grey.shade900,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget buildOutputTab() {
// //     return Padding(
// //       padding: EdgeInsets.all(16.0),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           ElevatedButton(
// //             onPressed: () {
// //               _runCode(allTestCases: false);
// //             },
// //             child: Text('Run'),
// //           ),
// //           SizedBox(height: 16),
// //           if (testResults.isNotEmpty)
// //             TestCaseResultsTable(testResults: testResults),
// //         ],
// //       ),
// //     );
// //   }

// //   void _scrollToResults() {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _rightPanelScrollController.animateTo(
// //         _rightPanelScrollController.position.maxScrollExtent,
// //         duration: Duration(milliseconds: 500),
// //         curve: Curves.easeOut,
// //       );
// //     });
// //   }

// //   Future<void> _runCode(
// //       {required bool allTestCases, String? customInput}) async {
// //     if (_selectedLanguage == null || _codeController.text.trim().isEmpty) {
// //       print("No valid code provided or language not selected");
// //       return;
// //     }

// //     Uri endpoint;
// //     switch (_selectedLanguage!.toLowerCase()) {
// //       case 'python':
// //         endpoint = Uri.parse('http://localhost:8084/compile');
// //         break;
// //       case 'java':
// //         endpoint = Uri.parse('http://localhost:8083/compile');
// //         break;
// //       case 'cpp':
// //         endpoint = Uri.parse('http://localhost:8081/compile');
// //         break;
// //       case 'c':
// //         endpoint = Uri.parse('http://localhost:8082/compile');
// //         break;
// //       default:
// //         print("Unsupported language selected");
// //         return;
// //     }

// //     print('Selected Endpoint URL: $endpoint');

// //     final String code = _codeController.text.trim();
// //     List<Map<String, String>> testCases;

// //     // Determine which test cases to send based on the button clicked
// //     if (customInput != null) {
// //       testCases = [
// //         {
// //           'input': customInput.trim() + '\n',
// //           'output': '', // No expected output for custom input
// //         },
// //       ];
// //     } else if (allTestCases) {
// //       testCases = widget.question['test_cases']
// //           .map<Map<String, String>>((testCase) => {
// //                 'input': testCase['input'].toString().trim() + '\n',
// //                 'output': testCase['output'].toString().trim(),
// //               })
// //           .toList();
// //     } else {
// //       // Run only public test cases
// //       testCases = widget.question['test_cases']
// //           .where((testCase) => testCase['is_public'] == true)
// //           .map<Map<String, String>>((testCase) => {
// //                 'input': testCase['input'].toString().trim() + '\n',
// //                 'output': testCase['output'].toString().trim(),
// //               })
// //           .toList();
// //     }

// //     final Map<String, dynamic> requestBody = {
// //       'language': _selectedLanguage!.toLowerCase(),
// //       'code': code,
// //       'testcases': testCases,
// //     };

// //     print('Request Body: ${jsonEncode(requestBody)}');

// //     try {
// //       final response = await http.post(
// //         endpoint,
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(requestBody),
// //       );

// //       if (response.statusCode == 200) {
// //         final List<dynamic> responseBody = jsonDecode(response.body);
// //         setState(() {
// //           testResults = responseBody.map((result) {
// //             return TestCaseResult(
// //               testCase: result['input'],
// //               expectedResult: result['expected_output'] ?? '',
// //               actualResult: result['actual_output'] ?? '',
// //               passed: result['success'] ?? false,
// //               errorMessage: result['error'] ?? '',
// //             );
// //           }).toList();
// //         });
// //         _scrollToResults();
// //       } else {
// //         print('Error: ${response.statusCode} - ${response.reasonPhrase}');
// //         print('Backend Error Response: ${response.body}');
// //         setState(() {
// //           testResults = [
// //             TestCaseResult(
// //               testCase: '',
// //               expectedResult: '',
// //               actualResult: '',
// //               passed: false,
// //               errorMessage: jsonDecode(response.body)['error'],
// //             ),
// //           ];
// //         });
// //       }
// //     } catch (error) {
// //       print('Error sending request: $error');
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final bool isMobile = MediaQuery.of(context).size.width < 600;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(widget.question['title']),
// //         bottom: isMobile
// //             ? TabBar(
// //                 controller: _tabController,
// //                 tabs: [
// //                   Tab(text: "Question"),
// //                   Tab(text: "Code"),
// //                   Tab(text: "Output"),
// //                 ],
// //               )
// //             : null,
// //       ),
// //       body: isMobile
// //           ? TabBarView(
// //               controller: _tabController,
// //               children: [
// //                 buildQuestionTab(),
// //                 buildCodeTab(),
// //                 buildOutputTab(),
// //               ],
// //             )
// //           : Row(
// //               children: [
// //                 Expanded(flex: 3, child: buildQuestionTab()),
// //                 Expanded(flex: 4, child: buildCodeTab()),
// //                 Expanded(flex: 3, child: buildOutputTab()),
// //               ],
// //             ),
// //     );
// //   }
// // }

// // class TestCaseResult {
// //   final String testCase;
// //   final String expectedResult;
// //   final String actualResult;
// //   final bool passed;
// //   final String errorMessage;

// //   TestCaseResult({
// //     required this.testCase,
// //     required this.expectedResult,
// //     required this.actualResult,
// //     required this.passed,
// //     this.errorMessage = '',
// //   });
// // }

// // class TestCaseResultsTable extends StatelessWidget {
// //   final List<TestCaseResult> testResults;

// //   TestCaseResultsTable({required this.testResults});

// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text("Test Results",
// //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// //         Divider(thickness: 2),
// //         Column(
// //           children: testResults.map((result) {
// //             return Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Expanded(child: Text("Input: ${result.testCase}")),
// //                     Expanded(child: Text("Output: ${result.actualResult}")),
// //                     Expanded(child: Text("Expected: ${result.expectedResult}")),
// //                     Expanded(
// //                       child: Text(
// //                         result.passed ? "Passed" : "Failed",
// //                         style: TextStyle(
// //                             color: result.passed ? Colors.green : Colors.red),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 if (result.errorMessage.isNotEmpty)
// //                   Padding(
// //                     padding: const EdgeInsets.only(top: 4.0),
// //                     child: Text(
// //                       "Error: ${result.errorMessage}",
// //                       style: TextStyle(
// //                           color: Colors.red, fontStyle: FontStyle.italic),
// //                     ),
// //                   ),
// //                 Divider(thickness: 1),
// //               ],
// //             );
// //           }).toList(),
// //         ),
// //       ],
// //     );
// //   }
// // }



// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
// import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// import 'package:studentpanel100/widgets/arrows_ui.dart';

// class CodingQuestionDetailPage extends StatefulWidget {
//   final Map<String, dynamic> question;

//   const CodingQuestionDetailPage({Key? key, required this.question})
//       : super(key: key);

//   @override
//   State<CodingQuestionDetailPage> createState() =>
//       _CodingQuestionDetailPageState();
// }

// class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage> {
//   late CodeController _codeController;
//   final FocusNode _focusNode = FocusNode();
//   List<TestCaseResult> testResults = [];
//   final ScrollController _rightPanelScrollController = ScrollController();
//   String? _selectedLanguage =
//       "Please select a Language"; // Default language prompt
//   TextEditingController _customInputController =
//       TextEditingController(); // Controller for custom input
//   bool _iscustomInputfieldVisible = false;
//   double _dividerPosition = 0.5;

//   @override
//   void initState() {
//     super.initState();
//     _codeController = CodeController(text: '''
// ***************************************************
// ***************  Select a Language  ***************
// ***************************************************
// ''');
//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus) {
//         RawKeyboard.instance.addListener(_handleKeyPress);
//       } else {
//         RawKeyboard.instance.removeListener(_handleKeyPress);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _codeController.dispose();
//     _focusNode.dispose();
//     _customInputController.dispose();
//     super.dispose();
//   }

//   // Capture Ctrl + / keyboard event
//   void _handleKeyPress(RawKeyEvent event) {
//     if (event.isControlPressed &&
//         event.logicalKey == LogicalKeyboardKey.slash) {
//       _commentSelectedLines();
//     }
//   }

//   // Comment/uncomment selected lines based on language
//   void _commentSelectedLines() {
//     final selection = _codeController.selection;
//     final text = _codeController.text;
//     final commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

//     if (selection.isCollapsed) {
//       // No text is selected, so comment the current line
//       int lineStart = selection.start;
//       int lineEnd = selection.start;

//       // Find the start and end of the line
//       while (lineStart > 0 && text[lineStart - 1] != '\n') lineStart--;
//       while (lineEnd < text.length && text[lineEnd] != '\n') lineEnd++;

//       // Extract the current line and toggle comment
//       final lineText = text.substring(lineStart, lineEnd);
//       final isCommented = lineText.trimLeft().startsWith(commentSyntax);

//       // Toggle comment on the line
//       final newLineText = isCommented
//           ? lineText.replaceFirst(commentSyntax, '').trimLeft() // Uncomment
//           : '$commentSyntax $lineText'; // Comment

//       // Replace the line in the text
//       final newText = text.replaceRange(lineStart, lineEnd, newLineText);
//       _codeController.value = _codeController.value.copyWith(
//         text: newText,
//         selection: TextSelection.collapsed(
//             offset: isCommented
//                 ? selection.start - commentSyntax.length - 1
//                 : selection.start + commentSyntax.length + 1),
//       );
//     } else {
//       // Text is selected, so comment each selected line
//       final selectedText = text.substring(selection.start, selection.end);
//       final lines = selectedText.split('\n');
//       final allLinesCommented =
//           lines.every((line) => line.trimLeft().startsWith(commentSyntax));

//       // Toggle comment on each line
//       final commentedLines = lines.map((line) {
//         return allLinesCommented
//             ? line.replaceFirst(commentSyntax, '').trimLeft() // Uncomment
//             : '$commentSyntax $line'; // Comment
//       }).join('\n');

//       // Replace the selected text with the commented/uncommented text
//       final newText =
//           text.replaceRange(selection.start, selection.end, commentedLines);

//       _codeController.value = _codeController.value.copyWith(
//         text: newText,
//         selection: TextSelection(
//           baseOffset: selection.start,
//           extentOffset: selection.start + commentedLines.length,
//         ),
//       );
//     }
//   }

//   void _setStarterCode(String language) {
//     String starterCode;
//     switch (language.toLowerCase()) {
//       case 'python':
//         starterCode = '# Please Start Writing your Code here\n';
//         break;
//       case 'java':
//         starterCode = '''
// public class Main {
//     public static void main(String[] args) {
//         // Please Start Writing your Code from here
//     }
// }
// ''';
//         break;
//       case 'c':
//         starterCode = '// Please Start Writing your Code here\n';
//         break;
//       case 'cpp':
//         starterCode = '// Please Start Writing your Code here\n';
//         break;
//       default:
//         starterCode = '// Please Start Writing your Code here\n';
//     }
//     _codeController.text = starterCode;
//   }

//   Future<void> _runCode(
//       {required bool allTestCases, String? customInput}) async {
//     if (_selectedLanguage == null || _codeController.text.trim().isEmpty) {
//       print("No valid code provided or language not selected");
//       return;
//     }

//     Uri endpoint;
//     switch (_selectedLanguage!.toLowerCase()) {
//       case 'python':
//         endpoint = Uri.parse('http://localhost:8084/compile');
//         break;
//       case 'java':
//         endpoint = Uri.parse('http://localhost:8083/compile');
//         break;
//       case 'cpp':
//         endpoint = Uri.parse('http://localhost:8081/compile');
//         break;
//       case 'c':
//         endpoint = Uri.parse('http://localhost:8082/compile');
//         break;
//       default:
//         print("Unsupported language selected");
//         return;
//     }

//     print('Selected Endpoint URL: $endpoint');

//     final String code = _codeController.text.trim();
//     List<Map<String, String>> testCases;

//     // Determine which test cases to send based on the button clicked
//     if (customInput != null) {
//       testCases = [
//         {
//           'input': customInput.trim() + '\n',
//           'output': '', // No expected output for custom input
//         },
//       ];
//     } else if (allTestCases) {
//       testCases = widget.question['test_cases']
//           .map<Map<String, String>>((testCase) => {
//                 'input': testCase['input'].toString().trim() + '\n',
//                 'output': testCase['output'].toString().trim(),
//               })
//           .toList();
//     } else {
//       // Run only public test cases
//       testCases = widget.question['test_cases']
//           .where((testCase) => testCase['is_public'] == true)
//           .map<Map<String, String>>((testCase) => {
//                 'input': testCase['input'].toString().trim() + '\n',
//                 'output': testCase['output'].toString().trim(),
//               })
//           .toList();
//     }

//     final Map<String, dynamic> requestBody = {
//       'language': _selectedLanguage!.toLowerCase(),
//       'code': code,
//       'testcases': testCases,
//     };

//     print('Request Body: ${jsonEncode(requestBody)}');

//     try {
//       final response = await http.post(
//         endpoint,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> responseBody = jsonDecode(response.body);
//         setState(() {
//           testResults = responseBody.map((result) {
//             return TestCaseResult(
//               testCase: result['input'],
//               expectedResult: result['expected_output'] ?? '',
//               actualResult: result['actual_output'] ?? '',
//               passed: result['success'] ?? false,
//               errorMessage: result['error'] ?? '',
//             );
//           }).toList();
//         });
//         _scrollToResults();
//       } else {
//         print('Error: ${response.statusCode} - ${response.reasonPhrase}');
//         print('Backend Error Response: ${response.body}');
//         setState(() {
//           testResults = [
//             TestCaseResult(
//               testCase: '',
//               expectedResult: '',
//               actualResult: '',
//               passed: false,
//               errorMessage: jsonDecode(response.body)['error'],
//             ),
//           ];
//         });
//       }
//     } catch (error) {
//       print('Error sending request: $error');
//     }
//   }

//   void _scrollToResults() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _rightPanelScrollController.animateTo(
//         _rightPanelScrollController.position.maxScrollExtent,
//         duration: Duration(milliseconds: 500),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   void _navigateToCodeDisplay(BuildContext context) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => DisplayCodePage(
//           code: _codeController.text,
//         ),
//       ),
//     );
//   }

//   void _toggleInputFieldVisibility() {
//     setState(() {
//       _iscustomInputfieldVisible = !_iscustomInputfieldVisible;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.question['title']),
//       ),
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final screenWidth = constraints.maxWidth;

//           // Calculate the width of the panels based on the divider position
//           final leftPanelWidth = screenWidth * _dividerPosition;
//           final rightPanelWidth = screenWidth * (1 - _dividerPosition);
//           return Row(
//             children: [
//               // Left Panel: Question details
//               Container(
//                 width: leftPanelWidth,
//                 color: Colors.white,
//                 child: Padding(
//                   padding: EdgeInsets.all(25.0),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(widget.question['title'],
//                             style: const TextStyle(
//                                 fontSize: 24, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 16),
//                         const Text("Description",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text(widget.question['description'],
//                             style: TextStyle(fontSize: 16)),
//                         const SizedBox(height: 16),
//                         const Text("Input Format",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text(widget.question['input_format'],
//                             style: TextStyle(fontSize: 16)),
//                         SizedBox(height: 16),
//                         const Text("Output Format",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text(widget.question['output_format'],
//                             style: TextStyle(fontSize: 16)),
//                         SizedBox(height: 16),
//                         const Text("Constraints",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text(widget.question['constraints'],
//                             style: TextStyle(fontSize: 16)),
//                         SizedBox(height: 8),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: List<Widget>.generate(
//                             widget.question['test_cases'].length,
//                             (index) {
//                               final testCase =
//                                   widget.question['test_cases'][index];
//                               return Card(
//                                 margin: EdgeInsets.symmetric(vertical: 8),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(12.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text("Input: ${testCase['input']}",
//                                           style: TextStyle(fontSize: 16)),
//                                       Text("Output: ${testCase['output']}",
//                                           style: TextStyle(fontSize: 16)),
//                                       if (testCase['is_public'])
//                                         Text(
//                                             "Explanation: ${testCase['explanation'] ?? ''}",
//                                             style: TextStyle(fontSize: 16)),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                         SizedBox(height: 16),
//                         Text("Difficulty",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         SizedBox(height: 8),
//                         Text(widget.question['difficulty'],
//                             style: TextStyle(fontSize: 16)),
//                         SizedBox(height: 16),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//               // VerticalDivider(width: 1, color: Colors.grey),
//               GestureDetector(
//                 behavior: HitTestBehavior.translucent,
//                 onHorizontalDragUpdate: (details) {
//                   setState(() {
//                     _dividerPosition += details.delta.dx / screenWidth;
//                     // Limit the position between 0.35 (35%) and 0.55 (55%)
//                     _dividerPosition = _dividerPosition.clamp(0.28, 0.55);
//                   });
//                 },
//                 child: Container(
//                   color: Colors.transparent,
//                   width: 22,
//                   child: Center(
//                     child: Row(
//                       children: [
//                         Container(
//                           height: 5,
//                           width: 10,
//                           color: Colors.transparent,
//                           child: CustomPaint(
//                             painter: LeftArrowPainter(
//                               strokeColor: Colors.grey,
//                               strokeWidth: 0,
//                               paintingStyle: PaintingStyle.fill,
//                             ),
//                             child: const SizedBox(
//                               height: 5,
//                               width: 10,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           height: double.infinity,
//                           width: 2,
//                           decoration: BoxDecoration(
//                             color: Colors.grey,
//                             borderRadius: BorderRadius.circular(2),
//                           ),
//                         ),
//                         Container(
//                           height: 5,
//                           width: 10,
//                           color: Colors.transparent,
//                           child: CustomPaint(
//                             painter: RightArrowPainter(
//                               strokeColor: Colors.grey,
//                               strokeWidth: 0,
//                               paintingStyle: PaintingStyle.fill,
//                             ),
//                             child: const SizedBox(
//                               height: 5,
//                               width: 10,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

//               // Right Panel: Code editor and results
//               Expanded(
//                 child: Container(
//                   width: rightPanelWidth,
//                   height: MediaQuery.of(context).size.height * 2,
//                   color: Colors.white,
//                   child: SingleChildScrollView(
//                     controller: _rightPanelScrollController,
//                     child: Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Column(
//                         children: [
//                           Text("Select Language",
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold)),
//                           DropdownButton<String>(
//                             value: _selectedLanguage,
//                             onChanged: (String? newValue) {
//                               if (newValue != null &&
//                                   newValue != "Please select a Language") {
//                                 if (_selectedLanguage !=
//                                     "Please select a Language") {
//                                   // Show alert if a language was previously selected
//                                   showDialog(
//                                     context: context,
//                                     builder: (BuildContext context) {
//                                       return AlertDialog(
//                                         title: Text("Change Language"),
//                                         content: Text(
//                                             "Changing the language will remove the current code. Do you want to proceed?"),
//                                         actions: [
//                                           TextButton(
//                                             child: Text("Cancel"),
//                                             onPressed: () {
//                                               Navigator.of(context)
//                                                   .pop(); // Close the dialog
//                                             },
//                                           ),
//                                           TextButton(
//                                             child: Text("Proceed"),
//                                             onPressed: () {
//                                               // Proceed with changing the language and setting starter code
//                                               setState(() {
//                                                 _selectedLanguage = newValue;
//                                                 _setStarterCode(newValue);
//                                               });
//                                               Navigator.of(context)
//                                                   .pop(); // Close the dialog
//                                             },
//                                           ),
//                                         ],
//                                       );
//                                     },
//                                   );
//                                 } else {
//                                   // Directly set language and starter code if no language was selected previously
//                                   setState(() {
//                                     _selectedLanguage = newValue;
//                                     _setStarterCode(newValue);
//                                   });
//                                 }
//                               }
//                             },
//                             items: [
//                               DropdownMenuItem<String>(
//                                 value: "Please select a Language",
//                                 child: Text("Please select a Language"),
//                               ),
//                               ...widget.question['allowed_languages']
//                                   .cast<String>()
//                                   .map<DropdownMenuItem<String>>(
//                                       (String language) {
//                                 return DropdownMenuItem<String>(
//                                   value: language,
//                                   child: Text(language),
//                                 );
//                               }).toList(),
//                             ],
//                           ),
//                           Focus(
//                             focusNode:
//                                 _focusNode, // Attach the focus node to Focus only
//                             onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
//                               if (keyEvent is KeyDownEvent) {
//                                 final keysPressed = HardwareKeyboard
//                                     .instance.logicalKeysPressed;

//                                 // Check for Ctrl + / shortcut
//                                 if (keysPressed.contains(
//                                         LogicalKeyboardKey.controlLeft) &&
//                                     keysPressed
//                                         .contains(LogicalKeyboardKey.slash)) {
//                                   _commentSelectedLines();
//                                   return KeyEventResult.handled;
//                                 }
//                               }
//                               return KeyEventResult.ignored;
//                             },
//                             child: Container(
//                               // height: 200,
//                               height: MediaQuery.of(context).size.height / 1.9,
//                               child: CodeField(
//                                 controller: _codeController,
//                                 focusNode: FocusNode(),
//                                 textStyle: TextStyle(
//                                   fontFamily: 'RobotoMono',
//                                   fontSize: 16,
//                                   color: Colors.white,
//                                 ),
//                                 cursorColor: Colors.white,
//                                 background: Colors.black,
//                                 expands: true,
//                                 wrap: false,
//                                 lineNumberStyle: LineNumberStyle(
//                                   width: 40,
//                                   margin: 8,
//                                   textStyle: TextStyle(
//                                     color: Colors.grey.shade600,
//                                     fontSize: 16,
//                                   ),
//                                   background: Colors.grey.shade900,
//                                 ),
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 16),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                             children: [
//                               ElevatedButton(
//                                 onPressed: () {
//                                   _runCode(allTestCases: false);
//                                 },
//                                 child: Text('Run'),
//                               ),
//                               ElevatedButton(
//                                 onPressed: () {
//                                   _runCode(allTestCases: true);
//                                 },
//                                 child: Text('Submit'),
//                               ),
//                               ElevatedButton(
//                                 onPressed: _toggleInputFieldVisibility,
//                                 child: Text('Custom Input'),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 16),
//                           AnimatedCrossFade(
//                             duration: Duration(milliseconds: 300),
//                             firstChild: SizedBox.shrink(),
//                             secondChild: Column(
//                               children: [
//                                 Container(
//                                   // height: 250,
//                                   width:
//                                       MediaQuery.of(context).size.width * 0.25,
//                                   child: TextField(
//                                     minLines: 5,
//                                     maxLines: 5,
//                                     controller: _customInputController,
//                                     decoration: InputDecoration(
//                                       hintText: "Enter custom input",
//                                       hintStyle:
//                                           TextStyle(color: Colors.white54),
//                                       filled: true,
//                                       fillColor: Colors.black,
//                                       border: OutlineInputBorder(),
//                                     ),
//                                     style: TextStyle(color: Colors.white),
//                                   ),
//                                 ),
//                                 SizedBox(height: 10),
//                                 ElevatedButton(
//                                   onPressed: () {
//                                     _runCode(
//                                       allTestCases: false,
//                                       customInput: _customInputController.text,
//                                     );
//                                   },
//                                   child: Text('Run Custom Input'),
//                                 ),
//                               ],
//                             ),
//                             crossFadeState: _iscustomInputfieldVisible
//                                 ? CrossFadeState.showSecond
//                                 : CrossFadeState.showFirst,
//                           ),
//                           SizedBox(height: 16),
//                           if (testResults.isNotEmpty)
//                             TestCaseResultsTable(testResults: testResults),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

// class TestCaseResult {
//   final String testCase;
//   final String expectedResult;
//   final String actualResult;
//   final bool passed;
//   final String errorMessage;
//   final bool isCustomInput;
//   TestCaseResult({
//     required this.testCase,
//     required this.expectedResult,
//     required this.actualResult,
//     required this.passed,
//     this.errorMessage = '',
//     this.isCustomInput = false,
//   });
// }

// class TestCaseResultsTable extends StatelessWidget {
//   final List<TestCaseResult> testResults;

//   TestCaseResultsTable({required this.testResults});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text("Test Results",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//         Divider(thickness: 2),
//         Column(
//           children: testResults.map((result) {
//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(child: Text("Input: ${result.testCase}")),
//                     Expanded(child: Text("Output: ${result.actualResult}")),
//                     Expanded(
//                       child: Text(
//                         result.isCustomInput
//                             ? "-"
//                             : "Expected: ${result.expectedResult}",
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         result.isCustomInput
//                             ? "-"
//                             : (result.passed ? "Passed" : "Failed"),
//                         style: TextStyle(
//                           color: result.isCustomInput
//                               ? Colors.black
//                               : (result.passed ? Colors.green : Colors.red),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (result.errorMessage.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4.0),
//                     child: Text(
//                       "Error: ${result.errorMessage}",
//                       style: TextStyle(
//                           color: Colors.red, fontStyle: FontStyle.italic),
//                     ),
//                   ),
//                 Divider(thickness: 1),
//               ],
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
// }

// class DisplayCodePage extends StatelessWidget {
//   final String code;

//   DisplayCodePage({required this.code});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Your Code'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Text(
//           code,
//           style: const TextStyle(
//               fontFamily: 'SourceCodePro', fontSize: 16, color: Colors.black),
//         ),
//       ),
//     );
//   }
// }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter/services.dart';
// // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
// // // // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
// // // // import 'package:http/http.dart' as http;
// // // // import 'dart:convert';

// // // // class CodingQuestionDetailPage extends StatefulWidget {
// // // //   final Map<String, dynamic> question;

// // // //   const CodingQuestionDetailPage({Key? key, required this.question})
// // // //       : super(key: key);

// // // //   @override
// // // //   State<CodingQuestionDetailPage> createState() =>
// // // //       _CodingQuestionDetailPageState();
// // // // }

// // // // class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage> {
// // // //   late CodeController _codeController;
// // // //   final FocusNode _focusNode = FocusNode();
// // // //   List<TestCaseResult> testResults = [];
// // // //   final ScrollController _rightPanelScrollController = ScrollController();
// // // //   String? _selectedLanguage =
// // // //       "Please select a Language"; // Default language prompt
// // // //   TextEditingController _customInputController =
// // // //       TextEditingController(); // Controller for custom input
// // // //   bool _iscustomInputfieldVisible = false;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     _codeController = CodeController(text: '''
// // // // ***************************************************
// // // // ***************  Select a Language  ***************
// // // // ***************************************************
// // // // ''');
// // // //     _focusNode.addListener(() {
// // // //       if (_focusNode.hasFocus) {
// // // //         RawKeyboard.instance.addListener(_handleKeyPress);
// // // //       } else {
// // // //         RawKeyboard.instance.removeListener(_handleKeyPress);
// // // //       }
// // // //     });
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _codeController.dispose();
// // // //     _focusNode.dispose();
// // // //     _customInputController.dispose();
// // // //     super.dispose();
// // // //   }

// // // //   // Capture Ctrl + / keyboard event
// // // //   void _handleKeyPress(RawKeyEvent event) {
// // // //     if (event.isControlPressed &&
// // // //         event.logicalKey == LogicalKeyboardKey.slash) {
// // // //       _commentSelectedLines();
// // // //     }
// // // //   }

// // // //   // Comment/uncomment selected lines based on language
// // // //   void _commentSelectedLines() {
// // // //     final selection = _codeController.selection;
// // // //     final text = _codeController.text;
// // // //     final commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

// // // //     if (selection.isCollapsed) {
// // // //       // No text is selected, so comment the current line
// // // //       int lineStart = selection.start;
// // // //       int lineEnd = selection.start;

// // // //       // Find the start and end of the line
// // // //       while (lineStart > 0 && text[lineStart - 1] != '\n') lineStart--;
// // // //       while (lineEnd < text.length && text[lineEnd] != '\n') lineEnd++;

// // // //       // Extract the current line and toggle comment
// // // //       final lineText = text.substring(lineStart, lineEnd);
// // // //       final isCommented = lineText.trimLeft().startsWith(commentSyntax);

// // // //       // Toggle comment on the line
// // // //       final newLineText = isCommented
// // // //           ? lineText.replaceFirst(commentSyntax, '').trimLeft() // Uncomment
// // // //           : '$commentSyntax $lineText'; // Comment

// // // //       // Replace the line in the text
// // // //       final newText = text.replaceRange(lineStart, lineEnd, newLineText);
// // // //       _codeController.value = _codeController.value.copyWith(
// // // //         text: newText,
// // // //         selection: TextSelection.collapsed(
// // // //             offset: isCommented
// // // //                 ? selection.start - commentSyntax.length - 1
// // // //                 : selection.start + commentSyntax.length + 1),
// // // //       );
// // // //     } else {
// // // //       // Text is selected, so comment each selected line
// // // //       final selectedText = text.substring(selection.start, selection.end);
// // // //       final lines = selectedText.split('\n');
// // // //       final allLinesCommented =
// // // //           lines.every((line) => line.trimLeft().startsWith(commentSyntax));

// // // //       // Toggle comment on each line
// // // //       final commentedLines = lines.map((line) {
// // // //         return allLinesCommented
// // // //             ? line.replaceFirst(commentSyntax, '').trimLeft() // Uncomment
// // // //             : '$commentSyntax $line'; // Comment
// // // //       }).join('\n');

// // // //       // Replace the selected text with the commented/uncommented text
// // // //       final newText =
// // // //           text.replaceRange(selection.start, selection.end, commentedLines);

// // // //       _codeController.value = _codeController.value.copyWith(
// // // //         text: newText,
// // // //         selection: TextSelection(
// // // //           baseOffset: selection.start,
// // // //           extentOffset: selection.start + commentedLines.length,
// // // //         ),
// // // //       );
// // // //     }
// // // //   }

// // // //   void _setStarterCode(String language) {
// // // //     String starterCode;
// // // //     switch (language.toLowerCase()) {
// // // //       case 'python':
// // // //         starterCode = '# Please Start Writing your Code here\n';
// // // //         break;
// // // //       case 'java':
// // // //         starterCode = '''
// // // // public class Main {
// // // //     public static void main(String[] args) {
// // // //         // Please Start Writing your Code from here
// // // //     }
// // // // }
// // // // ''';
// // // //         break;
// // // //       case 'c':
// // // //         starterCode = '// Please Start Writing your Code here\n';
// // // //         break;
// // // //       case 'cpp':
// // // //         starterCode = '// Please Start Writing your Code here\n';
// // // //         break;
// // // //       default:
// // // //         starterCode = '// Please Start Writing your Code here\n';
// // // //     }
// // // //     _codeController.text = starterCode;
// // // //   }

// // // //   Future<void> _runCode(
// // // //       {required bool allTestCases, String? customInput}) async {
// // // //     if (_selectedLanguage == null || _codeController.text.trim().isEmpty) {
// // // //       print("No valid code provided or language not selected");
// // // //       return;
// // // //     }

// // // //     Uri endpoint;
// // // //     switch (_selectedLanguage!.toLowerCase()) {
// // // //       case 'python':
// // // //         endpoint = Uri.parse('http://localhost:8084/compile');
// // // //         break;
// // // //       case 'java':
// // // //         endpoint = Uri.parse('http://localhost:8083/compile');
// // // //         break;
// // // //       case 'cpp':
// // // //         endpoint = Uri.parse('http://localhost:8081/compile');
// // // //         break;
// // // //       case 'c':
// // // //         endpoint = Uri.parse('http://localhost:8082/compile');
// // // //         break;
// // // //       default:
// // // //         print("Unsupported language selected");
// // // //         return;
// // // //     }

// // // //     print('Selected Endpoint URL: $endpoint');

// // // //     final String code = _codeController.text.trim();
// // // //     List<Map<String, String>> testCases;

// // // //     // Determine which test cases to send based on the button clicked
// // // //     if (customInput != null) {
// // // //       testCases = [
// // // //         {
// // // //           'input': customInput.trim() + '\n',
// // // //           'output': '', // No expected output for custom input
// // // //         },
// // // //       ];
// // // //     } else if (allTestCases) {
// // // //       testCases = widget.question['test_cases']
// // // //           .map<Map<String, String>>((testCase) => {
// // // //                 'input': testCase['input'].toString().trim() + '\n',
// // // //                 'output': testCase['output'].toString().trim(),
// // // //               })
// // // //           .toList();
// // // //     } else {
// // // //       // Run only public test cases
// // // //       testCases = widget.question['test_cases']
// // // //           .where((testCase) => testCase['is_public'] == true)
// // // //           .map<Map<String, String>>((testCase) => {
// // // //                 'input': testCase['input'].toString().trim() + '\n',
// // // //                 'output': testCase['output'].toString().trim(),
// // // //               })
// // // //           .toList();
// // // //     }

// // // //     final Map<String, dynamic> requestBody = {
// // // //       'language': _selectedLanguage!.toLowerCase(),
// // // //       'code': code,
// // // //       'testcases': testCases,
// // // //     };

// // // //     print('Request Body: ${jsonEncode(requestBody)}');

// // // //     try {
// // // //       final response = await http.post(
// // // //         endpoint,
// // // //         headers: {'Content-Type': 'application/json'},
// // // //         body: jsonEncode(requestBody),
// // // //       );

// // // //       if (response.statusCode == 200) {
// // // //         final List<dynamic> responseBody = jsonDecode(response.body);
// // // //         setState(() {
// // // //           testResults = responseBody.map((result) {
// // // //             return TestCaseResult(
// // // //               testCase: result['input'],
// // // //               expectedResult: result['expected_output'] ?? '',
// // // //               actualResult: result['actual_output'] ?? '',
// // // //               passed: result['success'] ?? false,
// // // //               errorMessage: result['error'] ?? '',
// // // //             );
// // // //           }).toList();
// // // //         });
// // // //         _scrollToResults();
// // // //       } else {
// // // //         print('Error: ${response.statusCode} - ${response.reasonPhrase}');
// // // //         print('Backend Error Response: ${response.body}');
// // // //         setState(() {
// // // //           testResults = [
// // // //             TestCaseResult(
// // // //               testCase: '',
// // // //               expectedResult: '',
// // // //               actualResult: '',
// // // //               passed: false,
// // // //               errorMessage: jsonDecode(response.body)['error'],
// // // //             ),
// // // //           ];
// // // //         });
// // // //       }
// // // //     } catch (error) {
// // // //       print('Error sending request: $error');
// // // //     }
// // // //   }

// // // //   void _scrollToResults() {
// // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // //       _rightPanelScrollController.animateTo(
// // // //         _rightPanelScrollController.position.maxScrollExtent,
// // // //         duration: Duration(milliseconds: 500),
// // // //         curve: Curves.easeOut,
// // // //       );
// // // //     });
// // // //   }

// // // //   void _navigateToCodeDisplay(BuildContext context) {
// // // //     Navigator.push(
// // // //       context,
// // // //       MaterialPageRoute(
// // // //         builder: (context) => DisplayCodePage(
// // // //           code: _codeController.text,
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }

// // // //   void _toggleInputFieldVisibility() {
// // // //     setState(() {
// // // //       _iscustomInputfieldVisible = !_iscustomInputfieldVisible;
// // // //     });
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: Text(widget.question['title']),
// // // //       ),
// // // //       body: Row(
// // // //         children: [
// // // //           // Left Panel: Question details
// // // //           Expanded(
// // // //             flex: 2,
// // // //             child: Padding(
// // // //               padding: EdgeInsets.all(16.0),
// // // //               child: SingleChildScrollView(
// // // //                 child: Column(
// // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // //                   children: [
// // // //                     Text(widget.question['title'],
// // // //                         style: const TextStyle(
// // // //                             fontSize: 24, fontWeight: FontWeight.bold)),
// // // //                     const SizedBox(height: 16),
// // // //                     const Text("Description",
// // // //                         style: TextStyle(
// // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // //                     Text(widget.question['description'],
// // // //                         style: TextStyle(fontSize: 16)),
// // // //                     const SizedBox(height: 16),
// // // //                     const Text("Input Format",
// // // //                         style: TextStyle(
// // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // //                     Text(widget.question['input_format'],
// // // //                         style: TextStyle(fontSize: 16)),
// // // //                     SizedBox(height: 16),
// // // //                     const Text("Output Format",
// // // //                         style: TextStyle(
// // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // //                     Text(widget.question['output_format'],
// // // //                         style: TextStyle(fontSize: 16)),
// // // //                     SizedBox(height: 16),
// // // //                     const Text("Constraints",
// // // //                         style: TextStyle(
// // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // //                     Text(widget.question['constraints'],
// // // //                         style: TextStyle(fontSize: 16)),
// // // //                     SizedBox(height: 8),
// // // //                     Column(
// // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // //                       children: List<Widget>.generate(
// // // //                         widget.question['test_cases'].length,
// // // //                         (index) {
// // // //                           final testCase = widget.question['test_cases'][index];
// // // //                           return Card(
// // // //                             margin: EdgeInsets.symmetric(vertical: 8),
// // // //                             child: Padding(
// // // //                               padding: const EdgeInsets.all(12.0),
// // // //                               child: Column(
// // // //                                 crossAxisAlignment: CrossAxisAlignment.start,
// // // //                                 children: [
// // // //                                   Text("Input: ${testCase['input']}",
// // // //                                       style: TextStyle(fontSize: 16)),
// // // //                                   Text("Output: ${testCase['output']}",
// // // //                                       style: TextStyle(fontSize: 16)),
// // // //                                   if (testCase['is_public'])
// // // //                                     Text(
// // // //                                         "Explanation: ${testCase['explanation'] ?? ''}",
// // // //                                         style: TextStyle(fontSize: 16)),
// // // //                                 ],
// // // //                               ),
// // // //                             ),
// // // //                           );
// // // //                         },
// // // //                       ),
// // // //                     ),
// // // //                     SizedBox(height: 16),
// // // //                     Text("Difficulty",
// // // //                         style: TextStyle(
// // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // //                     SizedBox(height: 8),
// // // //                     Text(widget.question['difficulty'],
// // // //                         style: TextStyle(fontSize: 16)),
// // // //                     SizedBox(height: 16),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //           VerticalDivider(width: 1, color: Colors.grey),

// // // //           // Right Panel: Code editor and results
// // // //           Expanded(
// // // //             flex: 3,
// // // //             child: SingleChildScrollView(
// // // //               controller: _rightPanelScrollController,
// // // //               child: Padding(
// // // //                 padding: EdgeInsets.all(16.0),
// // // //                 child: Column(
// // // //                   children: [
// // // //                     Text("Select Language",
// // // //                         style: TextStyle(
// // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // //                     DropdownButton<String>(
// // // //                       value: _selectedLanguage,
// // // //                       onChanged: (String? newValue) {
// // // //                         if (newValue != null &&
// // // //                             newValue != "Please select a Language") {
// // // //                           if (_selectedLanguage != "Please select a Language") {
// // // //                             // Show alert if a language was previously selected
// // // //                             showDialog(
// // // //                               context: context,
// // // //                               builder: (BuildContext context) {
// // // //                                 return AlertDialog(
// // // //                                   title: Text("Change Language"),
// // // //                                   content: Text(
// // // //                                       "Changing the language will remove the current code. Do you want to proceed?"),
// // // //                                   actions: [
// // // //                                     TextButton(
// // // //                                       child: Text("Cancel"),
// // // //                                       onPressed: () {
// // // //                                         Navigator.of(context)
// // // //                                             .pop(); // Close the dialog
// // // //                                       },
// // // //                                     ),
// // // //                                     TextButton(
// // // //                                       child: Text("Proceed"),
// // // //                                       onPressed: () {
// // // //                                         // Proceed with changing the language and setting starter code
// // // //                                         setState(() {
// // // //                                           _selectedLanguage = newValue;
// // // //                                           _setStarterCode(newValue);
// // // //                                         });
// // // //                                         Navigator.of(context)
// // // //                                             .pop(); // Close the dialog
// // // //                                       },
// // // //                                     ),
// // // //                                   ],
// // // //                                 );
// // // //                               },
// // // //                             );
// // // //                           } else {
// // // //                             // Directly set language and starter code if no language was selected previously
// // // //                             setState(() {
// // // //                               _selectedLanguage = newValue;
// // // //                               _setStarterCode(newValue);
// // // //                             });
// // // //                           }
// // // //                         }
// // // //                       },
// // // //                       items: [
// // // //                         DropdownMenuItem<String>(
// // // //                           value: "Please select a Language",
// // // //                           child: Text("Please select a Language"),
// // // //                         ),
// // // //                         ...widget.question['allowed_languages']
// // // //                             .cast<String>()
// // // //                             .map<DropdownMenuItem<String>>((String language) {
// // // //                           return DropdownMenuItem<String>(
// // // //                             value: language,
// // // //                             child: Text(language),
// // // //                           );
// // // //                         }).toList(),
// // // //                       ],
// // // //                     ),
// // // //                     Focus(
// // // //                       focusNode:
// // // //                           _focusNode, // Attach the focus node to Focus only
// // // //                       onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
// // // //                         if (keyEvent is KeyDownEvent) {
// // // //                           final keysPressed =
// // // //                               HardwareKeyboard.instance.logicalKeysPressed;

// // // //                           // Check for Ctrl + / shortcut
// // // //                           if (keysPressed
// // // //                                   .contains(LogicalKeyboardKey.controlLeft) &&
// // // //                               keysPressed.contains(LogicalKeyboardKey.slash)) {
// // // //                             _commentSelectedLines(); // Call the comment function
// // // //                             return KeyEventResult
// // // //                                 .handled; // Prevent further handling
// // // //                           }
// // // //                         }
// // // //                         return KeyEventResult.ignored;
// // // //                       },
// // // //                       child: Container(
// // // //                         height: MediaQuery.of(context).size.height / 2,
// // // //                         child: CodeField(
// // // //                           controller: _codeController,
// // // //                           focusNode:
// // // //                               FocusNode(), // Use a new FocusNode for CodeField if needed
// // // //                           textStyle: TextStyle(
// // // //                             fontFamily: 'RobotoMono',
// // // //                             fontSize: 16,
// // // //                             color: Colors.white,
// // // //                           ),
// // // //                           cursorColor: Colors.white,
// // // //                           background: Colors.black,
// // // //                           expands: true,
// // // //                           wrap: false,
// // // //                           lineNumberStyle: LineNumberStyle(
// // // //                             width: 40,
// // // //                             margin: 8,
// // // //                             textStyle: TextStyle(
// // // //                               color: Colors.grey.shade600,
// // // //                               fontSize: 16,
// // // //                             ),
// // // //                             background: Colors.grey.shade900,
// // // //                           ),
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                     SizedBox(height: 16),
// // // //                     Row(
// // // //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // // //                       children: [
// // // //                         ElevatedButton(
// // // //                           onPressed: () {
// // // //                             _runCode(
// // // //                                 allTestCases:
// // // //                                     false); // Run only public test cases
// // // //                           },
// // // //                           child: Text('Run'),
// // // //                         ),
// // // //                         ElevatedButton(
// // // //                           onPressed: () {
// // // //                             _runCode(allTestCases: true); // Run all test cases
// // // //                           },
// // // //                           child: Text('Submit'),
// // // //                         ),
// // // //                         ElevatedButton(
// // // //                           onPressed: _toggleInputFieldVisibility,
// // // //                           child: Text('Custom Input'),
// // // //                         ),
// // // //                       ],
// // // //                     ),
// // // //                     SizedBox(height: 16),
// // // //                     AnimatedCrossFade(
// // // //                       duration: Duration(milliseconds: 300),
// // // //                       firstChild: SizedBox.shrink(),
// // // //                       secondChild: Column(
// // // //                         children: [
// // // //                           Container(
// // // //                             // height: 250,
// // // //                             width: MediaQuery.of(context).size.width * 0.25,
// // // //                             child: TextField(
// // // //                               minLines: 5,
// // // //                               maxLines: 5,
// // // //                               controller: _customInputController,
// // // //                               decoration: InputDecoration(
// // // //                                 hintText: "Enter custom input",
// // // //                                 hintStyle: TextStyle(color: Colors.white54),
// // // //                                 filled: true,
// // // //                                 fillColor: Colors.black,
// // // //                                 border: OutlineInputBorder(),
// // // //                               ),
// // // //                               style: TextStyle(color: Colors.white),
// // // //                             ),
// // // //                           ),
// // // //                           SizedBox(height: 10),
// // // //                           ElevatedButton(
// // // //                             onPressed: () {
// // // //                               _runCode(
// // // //                                 allTestCases: false,
// // // //                                 customInput: _customInputController.text,
// // // //                               );
// // // //                             },
// // // //                             child: Text('Run Custom Input'),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                       crossFadeState: _iscustomInputfieldVisible
// // // //                           ? CrossFadeState.showSecond
// // // //                           : CrossFadeState.showFirst,
// // // //                     ),
// // // //                     SizedBox(height: 16),
// // // //                     if (testResults.isNotEmpty)
// // // //                       TestCaseResultsTable(testResults: testResults),
// // // //                   ],
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }
// // // // }

// // // // class TestCaseResult {
// // // //   final String testCase;
// // // //   final String expectedResult;
// // // //   final String actualResult;
// // // //   final bool passed;
// // // //   final String errorMessage;
// // // //   final bool isCustomInput;
// // // //   TestCaseResult({
// // // //     required this.testCase,
// // // //     required this.expectedResult,
// // // //     required this.actualResult,
// // // //     required this.passed,
// // // //     this.errorMessage = '',
// // // //     this.isCustomInput = false,
// // // //   });
// // // // }

// // // // class TestCaseResultsTable extends StatelessWidget {
// // // //   final List<TestCaseResult> testResults;

// // // //   TestCaseResultsTable({required this.testResults});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         Text("Test Results",
// // // //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // //         Divider(thickness: 2),
// // // //         Column(
// // // //           children: testResults.map((result) {
// // // //             return Column(
// // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // //               children: [
// // // //                 Row(
// // // //                   children: [
// // // //                     Expanded(child: Text("Input: ${result.testCase}")),
// // // //                     Expanded(child: Text("Output: ${result.actualResult}")),
// // // //                     // Display "-" for "Expected" and "Pass/Fail" in custom inputs
// // // //                     Expanded(
// // // //                       child: Text(
// // // //                         result.isCustomInput
// // // //                             ? "-"
// // // //                             : "Expected: ${result.expectedResult}",
// // // //                       ),
// // // //                     ),
// // // //                     Expanded(
// // // //                       child: Text(
// // // //                         result.isCustomInput
// // // //                             ? "-"
// // // //                             : (result.passed ? "Passed" : "Failed"),
// // // //                         style: TextStyle(
// // // //                           color: result.isCustomInput
// // // //                               ? Colors.black
// // // //                               : (result.passed ? Colors.green : Colors.red),
// // // //                         ),
// // // //                       ),
// // // //                     ),
// // // //                   ],
// // // //                 ),
// // // //                 // Always display the error message if it exists
// // // //                 if (result.errorMessage.isNotEmpty)
// // // //                   Padding(
// // // //                     padding: const EdgeInsets.only(top: 4.0),
// // // //                     child: Text(
// // // //                       "Error: ${result.errorMessage}",
// // // //                       style: TextStyle(
// // // //                           color: Colors.red, fontStyle: FontStyle.italic),
// // // //                     ),
// // // //                   ),
// // // //                 Divider(thickness: 1),
// // // //               ],
// // // //             );
// // // //           }).toList(),
// // // //         ),
// // // //       ],
// // // //     );
// // // //   }
// // // // }

// // // // class DisplayCodePage extends StatelessWidget {
// // // //   final String code;

// // // //   DisplayCodePage({required this.code});

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: Text('Your Code'),
// // // //       ),
// // // //       body: Padding(
// // // //         padding: const EdgeInsets.all(16.0),
// // // //         child: Text(
// // // //           code,
// // // //           style: TextStyle(
// // // //               fontFamily: 'SourceCodePro', fontSize: 16, color: Colors.black),
// // // //         ),
// // // //       ),
// // // //     );
// // // //   }
// // // // }


// // // // // import 'dart:math';
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart'; // For clipboard and key handling
// // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/linked_scroll_controller.dart';
// // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_theme/code_theme.dart';
// // // // // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_controller.dart';
// // // // // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';

// // // // // class CodeField extends StatefulWidget {
// // // // //   final SmartQuotesType? smartQuotesType;
// // // // //   final TextInputType? keyboardType;
// // // // //   final int? minLines;
// // // // //   final int? maxLines;
// // // // //   final bool expands;
// // // // //   final bool wrap;
// // // // //   final CodeController controller;
// // // // //   final LineNumberStyle lineNumberStyle;
// // // // //   final Color? cursorColor;
// // // // //   final TextStyle? textStyle;
// // // // //   final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
// // // // //   final bool? enabled;
// // // // //   final void Function(String)? onChanged;
// // // // //   final bool readOnly;
// // // // //   final bool isDense;
// // // // //   final TextSelectionControls? selectionControls;
// // // // //   final Color? background;
// // // // //   final EdgeInsets padding;
// // // // //   final Decoration? decoration;
// // // // //   final TextSelectionThemeData? textSelectionTheme;
// // // // //   final FocusNode? focusNode;
// // // // //   final void Function()? onTap;
// // // // //   final bool lineNumbers;
// // // // //   final bool horizontalScroll;

// // // // //   const CodeField({
// // // // //     Key? key,
// // // // //     required this.controller,
// // // // //     this.minLines,
// // // // //     this.maxLines,
// // // // //     this.expands = false,
// // // // //     this.wrap = false,
// // // // //     this.background,
// // // // //     this.decoration,
// // // // //     this.textStyle,
// // // // //     this.padding = EdgeInsets.zero,
// // // // //     this.lineNumberStyle = const LineNumberStyle(),
// // // // //     this.enabled,
// // // // //     this.onTap,
// // // // //     this.readOnly = false,
// // // // //     this.cursorColor,
// // // // //     this.textSelectionTheme,
// // // // //     this.lineNumberBuilder,
// // // // //     this.focusNode,
// // // // //     this.onChanged,
// // // // //     this.isDense = false,
// // // // //     this.smartQuotesType,
// // // // //     this.keyboardType,
// // // // //     this.lineNumbers = true,
// // // // //     this.horizontalScroll = true,
// // // // //     this.selectionControls,
// // // // //   }) : super(key: key);

// // // // //   @override
// // // // //   State<CodeField> createState() => _CodeFieldState();
// // // // // }

// // // // // class _CodeFieldState extends State<CodeField> {
// // // // //   LinkedScrollControllerGroup? _controllers;
// // // // //   ScrollController? _numberScroll;
// // // // //   ScrollController? _codeScroll;
// // // // //   LineNumberController? _numberController;
// // // // //   FocusNode? _focusNode;

// // // // //   // Define the longestLine variable
// // // // //   String longestLine = '';

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _controllers = LinkedScrollControllerGroup();
// // // // //     _numberScroll = _controllers?.addAndGet();
// // // // //     _codeScroll = _controllers?.addAndGet();
// // // // //     _numberController = LineNumberController(widget.lineNumberBuilder);
// // // // //     widget.controller.addListener(_onTextChanged);
// // // // //     _focusNode = widget.focusNode ?? FocusNode();
// // // // //     _focusNode!.onKey = _onKey;
// // // // //     _focusNode!.attach(context, onKey: _onKey);

// // // // //     _onTextChanged(); // Initial call to populate line numbers
// // // // //   }

// // // // //   // Override keyboard key events to handle Tab key and block copy/paste/cut
// // // // //   // KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
// // // // //   //   if (widget.readOnly) {
// // // // //   //     return KeyEventResult.ignored;
// // // // //   //   }

// // // // //   //   if (event is RawKeyDownEvent) {
// // // // //   //     // Intercept opening braces to auto-insert matching closing braces
// // // // //   //     if (event.logicalKey == LogicalKeyboardKey.bracketLeft ||
// // // // //   //         event.logicalKey == LogicalKeyboardKey.braceLeft ||
// // // // //   //         event.logicalKey == LogicalKeyboardKey.parenthesisLeft) {
// // // // //   //       _handleBraceInsertion(event.character!);
// // // // //   //       return KeyEventResult.handled;
// // // // //   //     }

// // // // //   //     // Intercept the Tab key press to insert custom spaces for indentation
// // // // //   //     if (event.logicalKey == LogicalKeyboardKey.tab) {
// // // // //   //       _handleTabKey();
// // // // //   //       return KeyEventResult.handled;
// // // // //   //     }

// // // // //   //     // Intercept Ctrl + C (Copy)
// // // // //   //     if (event.isControlPressed &&
// // // // //   //         event.logicalKey == LogicalKeyboardKey.keyC) {
// // // // //   //       return KeyEventResult.handled; // Block copy operation
// // // // //   //     }

// // // // //   //     // Intercept Ctrl + X (Cut)
// // // // //   //     if (event.isControlPressed &&
// // // // //   //         event.logicalKey == LogicalKeyboardKey.keyX) {
// // // // //   //       return KeyEventResult.handled; // Block cut operation
// // // // //   //     }

// // // // //   //     // Intercept Ctrl + V (Paste)
// // // // //   //     if (event.isControlPressed &&
// // // // //   //         event.logicalKey == LogicalKeyboardKey.keyV) {
// // // // //   //       Clipboard.setData(ClipboardData(text: '')); // Block paste operation
// // // // //   //       return KeyEventResult.handled;
// // // // //   //     }
// // // // //   //   }

// // // // //   //   // Let the controller handle other key events
// // // // //   //   return widget.controller.onKey(event);
// // // // //   // }

// // // // // // Override keyboard key events to handle Tab key, Enter key, and block copy/paste/cut
// // // // //   // KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
// // // // //   //   if (widget.readOnly) {
// // // // //   //     return KeyEventResult.ignored;
// // // // //   //   }

// // // // //   //   if (event is RawKeyDownEvent) {
// // // // //   //     // Intercept opening braces to auto-insert matching closing braces
// // // // //   //     if (event.logicalKey == LogicalKeyboardKey.bracketLeft ||
// // // // //   //         event.logicalKey == LogicalKeyboardKey.braceLeft ||
// // // // //   //         event.logicalKey == LogicalKeyboardKey.parenthesisLeft) {
// // // // //   //       _handleBraceInsertion(event.character!);
// // // // //   //       return KeyEventResult.handled;
// // // // //   //     }

// // // // //   //     // Intercept Enter key to handle indentation inside braces
// // // // //   //     if (event.logicalKey == LogicalKeyboardKey.enter) {
// // // // //   //       _handleEnterKey();
// // // // //   //       return KeyEventResult.handled;
// // // // //   //     }

// // // // //   //     // Intercept the Tab key press to insert custom spaces for indentation
// // // // //   //     if (event.logicalKey == LogicalKeyboardKey.tab) {
// // // // //   //       _handleTabKey();
// // // // //   //       return KeyEventResult.handled;
// // // // //   //     }

// // // // //   //     // Intercept Ctrl + C (Copy)
// // // // //   //     if (event.isControlPressed &&
// // // // //   //         event.logicalKey == LogicalKeyboardKey.keyC) {
// // // // //   //       return KeyEventResult.handled; // Block copy operation
// // // // //   //     }

// // // // //   //     // Intercept Ctrl + X (Cut)
// // // // //   //     if (event.isControlPressed &&
// // // // //   //         event.logicalKey == LogicalKeyboardKey.keyX) {
// // // // //   //       return KeyEventResult.handled; // Block cut operation
// // // // //   //     }

// // // // //   //     // Intercept Ctrl + V (Paste)
// // // // //   //     if (event.isControlPressed &&
// // // // //   //         event.logicalKey == LogicalKeyboardKey.keyV) {
// // // // //   //       Clipboard.setData(ClipboardData(text: '')); // Block paste operation
// // // // //   //       return KeyEventResult.handled;
// // // // //   //     }
// // // // //   //   }

// // // // //   //   // Let the controller handle other key events
// // // // //   //   return widget.controller.onKey(event);
// // // // //   // }

// // // // // // KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
// // // // // //   if (widget.readOnly) {
// // // // // //     return KeyEventResult.ignored;
// // // // // //   }

// // // // // //   if (event is RawKeyDownEvent) {
// // // // // //     // Intercept opening braces or quotes to auto-insert matching closing characters
// // // // // //     if (event.logicalKey == LogicalKeyboardKey.bracketLeft ||
// // // // // //         event.logicalKey == LogicalKeyboardKey.braceLeft ||
// // // // // //         event.logicalKey == LogicalKeyboardKey.parenthesisLeft ||
// // // // // //         event.logicalKey == LogicalKeyboardKey.quoteSingle ||
// // // // // //         event.logicalKey == LogicalKeyboardKey.quoteDouble) {
// // // // // //       _handleBraceOrQuoteInsertion(event.character!);
// // // // // //       return KeyEventResult.handled;
// // // // // //     }

// // // // // //     // Intercept Enter key to handle indentation inside braces
// // // // // //     if (event.logicalKey == LogicalKeyboardKey.enter) {
// // // // // //       _handleEnterKey();
// // // // // //       return KeyEventResult.handled;
// // // // // //     }

// // // // // //     // Intercept the Tab key press to insert custom spaces for indentation
// // // // // //     if (event.logicalKey == LogicalKeyboardKey.tab) {
// // // // // //       _handleTabKey();
// // // // // //       return KeyEventResult.handled;
// // // // // //     }

// // // // // //     // Intercept Ctrl + C (Copy)
// // // // // //     if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyC) {
// // // // // //       return KeyEventResult.handled; // Block copy operation
// // // // // //     }

// // // // // //     // Intercept Ctrl + X (Cut)
// // // // // //     if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyX) {
// // // // // //       return KeyEventResult.handled; // Block cut operation
// // // // // //     }

// // // // // //     // Intercept Ctrl + V (Paste)
// // // // // //     if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyV) {
// // // // // //       Clipboard.setData(ClipboardData(text: '')); // Block paste operation
// // // // // //       return KeyEventResult.handled;
// // // // // //     }
// // // // // //   }

// // // // // //   // Let the controller handle other key events
// // // // // //   return widget.controller.onKey(event);
// // // // // // }

// // // // // // Override keyboard key events to handle Tab key, Enter key, and block copy/paste/cut
// // // // //   KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
// // // // //     if (widget.readOnly) {
// // // // //       return KeyEventResult.ignored;
// // // // //     }

// // // // //     if (event is RawKeyDownEvent) {
// // // // //       // Intercept opening braces or quotes to auto-insert matching closing characters
// // // // //       if (event.logicalKey == LogicalKeyboardKey.bracketLeft ||
// // // // //           event.logicalKey == LogicalKeyboardKey.braceLeft ||
// // // // //           event.logicalKey == LogicalKeyboardKey.parenthesisLeft ||
// // // // //           event.character == '"' ||
// // // // //           event.character == "'") {
// // // // //         // Check for typed quotes directly
// // // // //         _handleBraceOrQuoteInsertion(event.character!);
// // // // //         return KeyEventResult.handled;
// // // // //       }

// // // // //       // Intercept Enter key to handle indentation inside braces
// // // // //       if (event.logicalKey == LogicalKeyboardKey.enter) {
// // // // //         _handleEnterKey();
// // // // //         return KeyEventResult.handled;
// // // // //       }

// // // // //       // Intercept the Tab key press to insert custom spaces for indentation
// // // // //       if (event.logicalKey == LogicalKeyboardKey.tab) {
// // // // //         _handleTabKey();
// // // // //         return KeyEventResult.handled;
// // // // //       }

// // // // //       // Intercept Ctrl + C (Copy)
// // // // //       if (event.isControlPressed &&
// // // // //           event.logicalKey == LogicalKeyboardKey.keyC) {
// // // // //         return KeyEventResult.handled; // Block copy operation
// // // // //       }

// // // // //       // Intercept Ctrl + X (Cut)
// // // // //       if (event.isControlPressed &&
// // // // //           event.logicalKey == LogicalKeyboardKey.keyX) {
// // // // //         return KeyEventResult.handled; // Block cut operation
// // // // //       }

// // // // //       // Intercept Ctrl + V (Paste)
// // // // //       if (event.isControlPressed &&
// // // // //           event.logicalKey == LogicalKeyboardKey.keyV) {
// // // // //         Clipboard.setData(ClipboardData(text: '')); // Block paste operation
// // // // //         return KeyEventResult.handled;
// // // // //       }
// // // // //     }

// // // // //     // Let the controller handle other key events
// // // // //     return widget.controller.onKey(event);
// // // // //   }

// // // // // // Handle the insertion of braces and quotes with matching pairs
// // // // //   void _handleBraceOrQuoteInsertion(String character) {
// // // // //     String closingChar = '';
// // // // //     switch (character) {
// // // // //       case '{':
// // // // //         closingChar = '}';
// // // // //         break;
// // // // //       case '[':
// // // // //         closingChar = ']';
// // // // //         break;
// // // // //       case '(':
// // // // //         closingChar = ')';
// // // // //         break;
// // // // //       case '"':
// // // // //         closingChar = '"';
// // // // //         break;
// // // // //       case "'":
// // // // //         closingChar = "'";
// // // // //         break;
// // // // //       default:
// // // // //         return; // Do nothing if it's not an opening brace or quote
// // // // //     }

// // // // //     setState(() {
// // // // //       int cursorPosition = widget.controller.selection.baseOffset;

// // // // //       // Insert the opening brace/quote and matching closing brace/quote
// // // // //       String updatedText = widget.controller.text;
// // // // //       updatedText = updatedText.replaceRange(
// // // // //           cursorPosition, cursorPosition, character + closingChar);

// // // // //       // Update the controller and place the cursor between the braces/quotes
// // // // //       widget.controller.value = TextEditingValue(
// // // // //         text: updatedText,
// // // // //         selection: TextSelection.collapsed(
// // // // //             offset:
// // // // //                 cursorPosition + 1), // Place cursor between the quotes/braces
// // // // //       );
// // // // //     });
// // // // //   }

// // // // // // Handle the Enter key inside braces for automatic indentation
// // // // //   void _handleEnterKey() {
// // // // //     int cursorPosition = widget.controller.selection.baseOffset;
// // // // //     String textBeforeCursor =
// // // // //         widget.controller.text.substring(0, cursorPosition);
// // // // //     String textAfterCursor = widget.controller.text.substring(cursorPosition);

// // // // //     // Check if the previous character is an opening brace and next character is a closing brace
// // // // //     if (textBeforeCursor.isNotEmpty &&
// // // // //         textAfterCursor.isNotEmpty &&
// // // // //         textBeforeCursor.endsWith('{') &&
// // // // //         textAfterCursor.startsWith('}')) {
// // // // //       // Get the current line's indentation level (count spaces at the start of the line)
// // // // //       String currentIndentation = _getIndentation(textBeforeCursor);

// // // // //       // Add one level of indentation for the new line inside the braces
// // // // //       String newIndentedLine =
// // // // //           '\n' + currentIndentation + '    '; // Indent with 4 spaces

// // // // //       // Create the new text with closing brace on a new indented line
// // // // //       String updatedText = textBeforeCursor +
// // // // //           newIndentedLine +
// // // // //           '\n' +
// // // // //           currentIndentation +
// // // // //           textAfterCursor;

// // // // //       // Update the controller text and move the cursor to the indented line
// // // // //       widget.controller.value = TextEditingValue(
// // // // //         text: updatedText,
// // // // //         selection: TextSelection.collapsed(
// // // // //             offset: cursorPosition +
// // // // //                 newIndentedLine.length), // Place cursor at the new indent
// // // // //       );
// // // // //     } else {
// // // // //       // Default Enter behavior (just insert a new line)
// // // // //       String newText = widget.controller.text
// // // // //           .replaceRange(cursorPosition, cursorPosition, '\n');
// // // // //       widget.controller.value = TextEditingValue(
// // // // //         text: newText,
// // // // //         selection: TextSelection.collapsed(
// // // // //             offset: cursorPosition + 1), // Move cursor after the new line
// // // // //       );
// // // // //     }
// // // // //   }

// // // // // // Helper function to get the indentation of the current line
// // // // //   String _getIndentation(String text) {
// // // // //     int lastLineBreak = text.lastIndexOf('\n');
// // // // //     if (lastLineBreak == -1) {
// // // // //       return ''; // No previous line, no indentation
// // // // //     }

// // // // //     String lastLine = text.substring(lastLineBreak + 1);
// // // // //     String indentation = '';
// // // // //     for (int i = 0; i < lastLine.length; i++) {
// // // // //       if (lastLine[i] == ' ') {
// // // // //         indentation += ' ';
// // // // //       } else {
// // // // //         break;
// // // // //       }
// // // // //     }

// // // // //     return indentation;
// // // // //   }

// // // // //   void _handleTabKey() {
// // // // //     setState(() {
// // // // //       int cursorPosition = widget.controller.selection.baseOffset;

// // // // //       // Insert 4 spaces (for tab size)
// // // // //       String updatedText = widget.controller.text;
// // // // //       updatedText =
// // // // //           updatedText.replaceRange(cursorPosition, cursorPosition, '    ');

// // // // //       // Update the controller with new text and move the cursor accordingly
// // // // //       widget.controller.value = TextEditingValue(
// // // // //         text: updatedText,
// // // // //         selection: TextSelection.collapsed(
// // // // //             offset: cursorPosition + 4), // Move cursor after tab
// // // // //       );
// // // // //     });
// // // // //   }

// // // // //   // void _handleBraceInsertion(String character) {
// // // // //   //   String closingBrace = '';
// // // // //   //   switch (character) {
// // // // //   //     case '{':
// // // // //   //       closingBrace = '}';
// // // // //   //       break;
// // // // //   //     case '[':
// // // // //   //       closingBrace = ']';
// // // // //   //       break;
// // // // //   //     case '(':
// // // // //   //       closingBrace = ')';
// // // // //   //       break;
// // // // //   //     default:
// // // // //   //       return; // Do nothing if it's not an opening brace
// // // // //   //   }

// // // // //   //   setState(() {
// // // // //   //     int cursorPosition = widget.controller.selection.baseOffset;

// // // // //   //     // Insert the opening brace and matching closing brace
// // // // //   //     String updatedText = widget.controller.text;
// // // // //   //     updatedText = updatedText.replaceRange(
// // // // //   //         cursorPosition, cursorPosition, character + closingBrace);

// // // // //   //     // Update the controller and place the cursor between the braces
// // // // //   //     widget.controller.value = TextEditingValue(
// // // // //   //       text: updatedText,
// // // // //   //       selection: TextSelection.collapsed(
// // // // //   //           offset: cursorPosition + 1), // Place cursor between the braces
// // // // //   //     );
// // // // //   //   });
// // // // //   // }

// // // // //   // Handle the insertion of braces and quotes with matching pairs
// // // // // // void _handleBraceOrQuoteInsertion(String character) {
// // // // // //   String closingChar = '';
// // // // // //   switch (character) {
// // // // // //     case '{':
// // // // // //       closingChar = '}';
// // // // // //       break;
// // // // // //     case '[':
// // // // // //       closingChar = ']';
// // // // // //       break;
// // // // // //     case '(':
// // // // // //       closingChar = ')';
// // // // // //       break;
// // // // // //     case '"':
// // // // // //       closingChar = '"';
// // // // // //       break;
// // // // // //     case "'":
// // // // // //       closingChar = "'";
// // // // // //       break;
// // // // // //     default:
// // // // // //       return; // Do nothing if it's not an opening brace or quote
// // // // // //   }

// // // // // //   setState(() {
// // // // // //     int cursorPosition = widget.controller.selection.baseOffset;

// // // // // //     // Insert the opening brace/quote and matching closing brace/quote
// // // // // //     String updatedText = widget.controller.text;
// // // // // //     updatedText = updatedText.replaceRange(cursorPosition, cursorPosition, character + closingChar);

// // // // // //     // Update the controller and place the cursor between the braces/quotes
// // // // // //     widget.controller.value = TextEditingValue(
// // // // // //       text: updatedText,
// // // // // //       selection: TextSelection.collapsed(offset: cursorPosition + 1), // Place cursor between the quotes/braces
// // // // // //     );
// // // // // //   });
// // // // // // }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     widget.controller.removeListener(_onTextChanged);
// // // // //     _numberScroll?.dispose();
// // // // //     _codeScroll?.dispose();
// // // // //     _numberController?.dispose();
// // // // //     super.dispose();
// // // // //   }

// // // // //   void _onTextChanged() {
// // // // //     // Rebuild line number
// // // // //     final str = widget.controller.text.split('\n');
// // // // //     final buf = <String>[];

// // // // //     for (var k = 0; k < str.length; k++) {
// // // // //       buf.add((k + 1).toString());
// // // // //     }

// // // // //     _numberController?.text = buf.join('\n');

// // // // //     // Find longest line
// // // // //     longestLine = '';
// // // // //     for (var line in widget.controller.text.split('\n')) {
// // // // //       if (line.length > longestLine.length) {
// // // // //         longestLine = line;
// // // // //       }
// // // // //     }

// // // // //     setState(() {});
// // // // //   }

// // // // //   // Define the _wrapInScrollView method to handle horizontal scrolling
// // // // //   Widget _wrapInScrollView(
// // // // //     Widget codeField,
// // // // //     TextStyle textStyle,
// // // // //     double minWidth,
// // // // //   ) {
// // // // //     final leftPad = widget.lineNumberStyle.margin / 2;
// // // // //     final intrinsic = IntrinsicWidth(
// // // // //       child: Column(
// // // // //         mainAxisSize: MainAxisSize.min,
// // // // //         crossAxisAlignment: CrossAxisAlignment.stretch,
// // // // //         children: [
// // // // //           ConstrainedBox(
// // // // //             constraints: BoxConstraints(
// // // // //               maxHeight: 0,
// // // // //               minWidth: max(minWidth - leftPad, 0),
// // // // //             ),
// // // // //             child: Padding(
// // // // //               padding: const EdgeInsets.only(right: 16),
// // // // //               child: Text(longestLine, style: textStyle),
// // // // //             ), // Add extra padding
// // // // //           ),
// // // // //           widget.expands ? Expanded(child: codeField) : codeField,
// // // // //         ],
// // // // //       ),
// // // // //     );

// // // // //     return SingleChildScrollView(
// // // // //       padding: EdgeInsets.only(
// // // // //         left: leftPad,
// // // // //         right: widget.padding.right,
// // // // //       ),
// // // // //       scrollDirection: Axis.horizontal,

// // // // //       /// Prevents the horizontal scroll if horizontalScroll is false
// // // // //       physics:
// // // // //           widget.horizontalScroll ? null : const NeverScrollableScrollPhysics(),
// // // // //       child: intrinsic,
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     // Default color scheme
// // // // //     const rootKey = 'root';
// // // // //     final defaultBg = Colors.grey.shade900;
// // // // //     final defaultText = Colors.grey.shade200;

// // // // //     final styles = CodeTheme.of(context)?.styles;
// // // // //     Color? backgroundCol =
// // // // //         widget.background ?? styles?[rootKey]?.backgroundColor ?? defaultBg;

// // // // //     if (widget.decoration != null) {
// // // // //       backgroundCol = null;
// // // // //     }

// // // // //     TextStyle textStyle = widget.textStyle ?? const TextStyle();
// // // // //     textStyle = textStyle.copyWith(
// // // // //       color: textStyle.color ?? styles?[rootKey]?.color ?? defaultText,
// // // // //       fontSize: textStyle.fontSize ?? 16.0,
// // // // //     );

// // // // //     TextStyle numberTextStyle =
// // // // //         widget.lineNumberStyle.textStyle ?? const TextStyle();
// // // // //     final numberColor =
// // // // //         (styles?[rootKey]?.color ?? defaultText).withOpacity(0.7);

// // // // //     // Copy important attributes
// // // // //     numberTextStyle = numberTextStyle.copyWith(
// // // // //       color: numberTextStyle.color ?? numberColor,
// // // // //       fontSize: textStyle.fontSize,
// // // // //       fontFamily: textStyle.fontFamily,
// // // // //     );

// // // // //     final cursorColor =
// // // // //         widget.cursorColor ?? styles?[rootKey]?.color ?? defaultText;

// // // // //     TextField? lineNumberCol;
// // // // //     Container? numberCol;

// // // // //     if (widget.lineNumbers) {
// // // // //       lineNumberCol = TextField(
// // // // //         smartQuotesType: widget.smartQuotesType,
// // // // //         scrollPadding: widget.padding,
// // // // //         style: numberTextStyle,
// // // // //         controller: _numberController,
// // // // //         enabled: false,
// // // // //         minLines: widget.minLines,
// // // // //         maxLines: widget.maxLines,
// // // // //         selectionControls: widget.selectionControls,
// // // // //         expands: widget.expands,
// // // // //         scrollController: _numberScroll,
// // // // //         decoration: InputDecoration(
// // // // //           disabledBorder: InputBorder.none,
// // // // //           isDense: widget.isDense,
// // // // //         ),
// // // // //         textAlign: widget.lineNumberStyle.textAlign,
// // // // //       );

// // // // //       numberCol = Container(
// // // // //         width: widget.lineNumberStyle.width,
// // // // //         padding: EdgeInsets.only(
// // // // //           left: widget.padding.left,
// // // // //           right: widget.lineNumberStyle.margin / 2,
// // // // //         ),
// // // // //         color: widget.lineNumberStyle.background,
// // // // //         child: lineNumberCol,
// // // // //       );
// // // // //     }

// // // // //     final codeField = GestureDetector(
// // // // //       onSecondaryTap: () {
// // // // //         // Disable right-click context menu
// // // // //       },
// // // // //       child: TextField(
// // // // //         keyboardType: widget.keyboardType,
// // // // //         smartQuotesType: widget.smartQuotesType,
// // // // //         focusNode: _focusNode,
// // // // //         onTap: widget.onTap,
// // // // //         scrollPadding: widget.padding,
// // // // //         style: textStyle,
// // // // //         controller: widget.controller,
// // // // //         minLines: widget.minLines,
// // // // //         selectionControls: widget.selectionControls,
// // // // //         maxLines: widget.maxLines,
// // // // //         expands: widget.expands,
// // // // //         scrollController: _codeScroll,
// // // // //         decoration: InputDecoration(
// // // // //           disabledBorder: InputBorder.none,
// // // // //           border: InputBorder.none,
// // // // //           focusedBorder: InputBorder.none,
// // // // //           isDense: widget.isDense,
// // // // //         ),
// // // // //         cursorColor: cursorColor,
// // // // //         autocorrect: false,
// // // // //         enableSuggestions: false,
// // // // //         enabled: widget.enabled,
// // // // //         onChanged: widget.onChanged,
// // // // //         readOnly: widget.readOnly,
// // // // //       ),
// // // // //     );

// // // // //     final codeCol = Theme(
// // // // //       data: Theme.of(context).copyWith(
// // // // //         textSelectionTheme: widget.textSelectionTheme,
// // // // //       ),
// // // // //       child: LayoutBuilder(
// // // // //         builder: (BuildContext context, BoxConstraints constraints) {
// // // // //           // Control horizontal scrolling
// // // // //           return widget.wrap
// // // // //               ? codeField
// // // // //               : _wrapInScrollView(codeField, textStyle, constraints.maxWidth);
// // // // //         },
// // // // //       ),
// // // // //     );

// // // // //     return Container(
// // // // //       decoration: widget.decoration,
// // // // //       color: backgroundCol,
// // // // //       padding: !widget.lineNumbers ? const EdgeInsets.only(left: 8) : null,
// // // // //       child: Row(
// // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // //         children: [
// // // // //           if (widget.lineNumbers && numberCol != null) numberCol,
// // // // //           Expanded(child: codeCol),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // // import 'dart:math';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter/services.dart'; // For clipboard and key handling
// // // // // // import 'package:newtextfieldcompiler99/code_field/linked_scroll_controller.dart';
// // // // // // import '../code_theme/code_theme.dart';
// // // // // // import '../line_numbers/line_number_controller.dart';
// // // // // // import '../line_numbers/line_number_style.dart';
// // // // // // import 'code_controller.dart';

// // // // // // class CodeField extends StatefulWidget {
// // // // // //   final SmartQuotesType? smartQuotesType;
// // // // // //   final TextInputType? keyboardType;
// // // // // //   final int? minLines;
// // // // // //   final int? maxLines;
// // // // // //   final bool expands;
// // // // // //   final bool wrap;
// // // // // //   final CodeController controller;
// // // // // //   final LineNumberStyle lineNumberStyle;
// // // // // //   final Color? cursorColor;
// // // // // //   final TextStyle? textStyle;
// // // // // //   final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
// // // // // //   final bool? enabled;
// // // // // //   final void Function(String)? onChanged;
// // // // // //   final bool readOnly;
// // // // // //   final bool isDense;
// // // // // //   final TextSelectionControls? selectionControls;
// // // // // //   final Color? background;
// // // // // //   final EdgeInsets padding;
// // // // // //   final Decoration? decoration;
// // // // // //   final TextSelectionThemeData? textSelectionTheme;
// // // // // //   final FocusNode? focusNode;
// // // // // //   final void Function()? onTap;
// // // // // //   final bool lineNumbers;
// // // // // //   final bool horizontalScroll;

// // // // // //   const CodeField({
// // // // // //     Key? key,
// // // // // //     required this.controller,
// // // // // //     this.minLines,
// // // // // //     this.maxLines,
// // // // // //     this.expands = false,
// // // // // //     this.wrap = false,
// // // // // //     this.background,
// // // // // //     this.decoration,
// // // // // //     this.textStyle,
// // // // // //     this.padding = EdgeInsets.zero,
// // // // // //     this.lineNumberStyle = const LineNumberStyle(),
// // // // // //     this.enabled,
// // // // // //     this.onTap,
// // // // // //     this.readOnly = false,
// // // // // //     this.cursorColor,
// // // // // //     this.textSelectionTheme,
// // // // // //     this.lineNumberBuilder,
// // // // // //     this.focusNode,
// // // // // //     this.onChanged,
// // // // // //     this.isDense = false,
// // // // // //     this.smartQuotesType,
// // // // // //     this.keyboardType,
// // // // // //     this.lineNumbers = true,
// // // // // //     this.horizontalScroll = true,
// // // // // //     this.selectionControls,
// // // // // //   }) : super(key: key);

// // // // // //   @override
// // // // // //   State<CodeField> createState() => _CodeFieldState();
// // // // // // }

// // // // // // class _CodeFieldState extends State<CodeField> {
// // // // // //   LinkedScrollControllerGroup? _controllers;
// // // // // //   ScrollController? _numberScroll;
// // // // // //   ScrollController? _codeScroll;
// // // // // //   LineNumberController? _numberController;
// // // // // //   FocusNode? _focusNode;

// // // // // //   // Define the longestLine variable
// // // // // //   String longestLine = '';

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _controllers = LinkedScrollControllerGroup();
// // // // // //     _numberScroll = _controllers?.addAndGet();
// // // // // //     _codeScroll = _controllers?.addAndGet();
// // // // // //     _numberController = LineNumberController(widget.lineNumberBuilder);
// // // // // //     widget.controller.addListener(_onTextChanged);
// // // // // //     _focusNode = widget.focusNode ?? FocusNode();
// // // // // //     _focusNode!.onKey = _onKey;
// // // // // //     _focusNode!.attach(context, onKey: _onKey);

// // // // // //     _onTextChanged(); // Initial call to populate line numbers
// // // // // //   }

// // // // // //   // Override keyboard key events to handle Tab key and block copy/paste/cut
// // // // // //   KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
// // // // // //     if (widget.readOnly) {
// // // // // //       return KeyEventResult.ignored;
// // // // // //     }

// // // // // //     if (event is RawKeyDownEvent) {
// // // // // //       // Intercept the Tab key press to insert custom spaces for indentation
// // // // // //       if (event.logicalKey == LogicalKeyboardKey.tab) {
// // // // // //         setState(() {
// // // // // //           int cursorPosition = widget.controller.selection.baseOffset;

// // // // // //           // Insert 4 spaces (for tab size)
// // // // // //           String updatedText = widget.controller.text;
// // // // // //           updatedText =
// // // // // //               updatedText.replaceRange(cursorPosition, cursorPosition, '    ');

// // // // // //           // Update the controller with new text and move the cursor accordingly
// // // // // //           widget.controller.value = TextEditingValue(
// // // // // //             text: updatedText,
// // // // // //             selection: TextSelection.collapsed(
// // // // // //                 offset: cursorPosition + 4), // Move cursor after tab
// // // // // //           );
// // // // // //         });
// // // // // //         return KeyEventResult.handled; // Handle the Tab key event
// // // // // //       }

// // // // // //       // Intercept Ctrl + C (Copy)
// // // // // //       if (event.isControlPressed &&
// // // // // //           event.logicalKey == LogicalKeyboardKey.keyC) {
// // // // // //         return KeyEventResult.handled; // Block copy operation
// // // // // //       }

// // // // // //       // Intercept Ctrl + X (Cut)
// // // // // //       if (event.isControlPressed &&
// // // // // //           event.logicalKey == LogicalKeyboardKey.keyX) {
// // // // // //         return KeyEventResult.handled; // Block cut operation
// // // // // //       }

// // // // // //       // Intercept Ctrl + V (Paste)
// // // // // //       if (event.isControlPressed &&
// // // // // //           event.logicalKey == LogicalKeyboardKey.keyV) {
// // // // // //         Clipboard.setData(ClipboardData(text: '')); // Block paste operation
// // // // // //         return KeyEventResult.handled;
// // // // // //       }
// // // // // //     }

// // // // // //     // Let the controller handle other key events
// // // // // //     return widget.controller.onKey(event);
// // // // // //   }

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     widget.controller.removeListener(_onTextChanged);
// // // // // //     _numberScroll?.dispose();
// // // // // //     _codeScroll?.dispose();
// // // // // //     _numberController?.dispose();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   void _onTextChanged() {
// // // // // //     // Rebuild line number
// // // // // //     final str = widget.controller.text.split('\n');
// // // // // //     final buf = <String>[];

// // // // // //     for (var k = 0; k < str.length; k++) {
// // // // // //       buf.add((k + 1).toString());
// // // // // //     }

// // // // // //     _numberController?.text = buf.join('\n');

// // // // // //     // Find longest line
// // // // // //     longestLine = '';
// // // // // //     for (var line in widget.controller.text.split('\n')) {
// // // // // //       if (line.length > longestLine.length) {
// // // // // //         longestLine = line;
// // // // // //       }
// // // // // //     }

// // // // // //     setState(() {});
// // // // // //   }

// // // // // //   // Define the _wrapInScrollView method to handle horizontal scrolling
// // // // // //   Widget _wrapInScrollView(
// // // // // //     Widget codeField,
// // // // // //     TextStyle textStyle,
// // // // // //     double minWidth,
// // // // // //   ) {
// // // // // //     final leftPad = widget.lineNumberStyle.margin / 2;
// // // // // //     final intrinsic = IntrinsicWidth(
// // // // // //       child: Column(
// // // // // //         mainAxisSize: MainAxisSize.min,
// // // // // //         crossAxisAlignment: CrossAxisAlignment.stretch,
// // // // // //         children: [
// // // // // //           ConstrainedBox(
// // // // // //             constraints: BoxConstraints(
// // // // // //               maxHeight: 0,
// // // // // //               minWidth: max(minWidth - leftPad, 0),
// // // // // //             ),
// // // // // //             child: Padding(
// // // // // //               padding: const EdgeInsets.only(right: 16),
// // // // // //               child: Text(longestLine, style: textStyle),
// // // // // //             ), // Add extra padding
// // // // // //           ),
// // // // // //           widget.expands ? Expanded(child: codeField) : codeField,
// // // // // //         ],
// // // // // //       ),
// // // // // //     );

// // // // // //     return SingleChildScrollView(
// // // // // //       padding: EdgeInsets.only(
// // // // // //         left: leftPad,
// // // // // //         right: widget.padding.right,
// // // // // //       ),
// // // // // //       scrollDirection: Axis.horizontal,

// // // // // //       /// Prevents the horizontal scroll if horizontalScroll is false
// // // // // //       physics:
// // // // // //           widget.horizontalScroll ? null : const NeverScrollableScrollPhysics(),
// // // // // //       child: intrinsic,
// // // // // //     );
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     // Default color scheme
// // // // // //     const rootKey = 'root';
// // // // // //     final defaultBg = Colors.grey.shade900;
// // // // // //     final defaultText = Colors.grey.shade200;

// // // // // //     final styles = CodeTheme.of(context)?.styles;
// // // // // //     Color? backgroundCol =
// // // // // //         widget.background ?? styles?[rootKey]?.backgroundColor ?? defaultBg;

// // // // // //     if (widget.decoration != null) {
// // // // // //       backgroundCol = null;
// // // // // //     }

// // // // // //     TextStyle textStyle = widget.textStyle ?? const TextStyle();
// // // // // //     textStyle = textStyle.copyWith(
// // // // // //       color: textStyle.color ?? styles?[rootKey]?.color ?? defaultText,
// // // // // //       fontSize: textStyle.fontSize ?? 16.0,
// // // // // //     );

// // // // // //     TextStyle numberTextStyle =
// // // // // //         widget.lineNumberStyle.textStyle ?? const TextStyle();
// // // // // //     final numberColor =
// // // // // //         (styles?[rootKey]?.color ?? defaultText).withOpacity(0.7);

// // // // // //     // Copy important attributes
// // // // // //     numberTextStyle = numberTextStyle.copyWith(
// // // // // //       color: numberTextStyle.color ?? numberColor,
// // // // // //       fontSize: textStyle.fontSize,
// // // // // //       fontFamily: textStyle.fontFamily,
// // // // // //     );

// // // // // //     final cursorColor =
// // // // // //         widget.cursorColor ?? styles?[rootKey]?.color ?? defaultText;

// // // // // //     TextField? lineNumberCol;
// // // // // //     Container? numberCol;

// // // // // //     if (widget.lineNumbers) {
// // // // // //       lineNumberCol = TextField(
// // // // // //         smartQuotesType: widget.smartQuotesType,
// // // // // //         scrollPadding: widget.padding,
// // // // // //         style: numberTextStyle,
// // // // // //         controller: _numberController,
// // // // // //         enabled: false,
// // // // // //         minLines: widget.minLines,
// // // // // //         maxLines: widget.maxLines,
// // // // // //         selectionControls: widget.selectionControls,
// // // // // //         expands: widget.expands,
// // // // // //         scrollController: _numberScroll,
// // // // // //         decoration: InputDecoration(
// // // // // //           disabledBorder: InputBorder.none,
// // // // // //           isDense: widget.isDense,
// // // // // //         ),
// // // // // //         textAlign: widget.lineNumberStyle.textAlign,
// // // // // //       );

// // // // // //       numberCol = Container(
// // // // // //         width: widget.lineNumberStyle.width,
// // // // // //         padding: EdgeInsets.only(
// // // // // //           left: widget.padding.left,
// // // // // //           right: widget.lineNumberStyle.margin / 2,
// // // // // //         ),
// // // // // //         color: widget.lineNumberStyle.background,
// // // // // //         child: lineNumberCol,
// // // // // //       );
// // // // // //     }

// // // // // //     final codeField = GestureDetector(
// // // // // //       onSecondaryTap: () {
// // // // // //         // Disable right-click context menu
// // // // // //       },
// // // // // //       child: TextField(
// // // // // //         keyboardType: widget.keyboardType,
// // // // // //         smartQuotesType: widget.smartQuotesType,
// // // // // //         focusNode: _focusNode,
// // // // // //         onTap: widget.onTap,
// // // // // //         scrollPadding: widget.padding,
// // // // // //         style: textStyle,
// // // // // //         controller: widget.controller,
// // // // // //         minLines: widget.minLines,
// // // // // //         selectionControls: widget.selectionControls,
// // // // // //         maxLines: widget.maxLines,
// // // // // //         expands: widget.expands,
// // // // // //         scrollController: _codeScroll,
// // // // // //         decoration: InputDecoration(
// // // // // //           disabledBorder: InputBorder.none,
// // // // // //           border: InputBorder.none,
// // // // // //           focusedBorder: InputBorder.none,
// // // // // //           isDense: widget.isDense,
// // // // // //         ),
// // // // // //         cursorColor: cursorColor,
// // // // // //         autocorrect: false,
// // // // // //         enableSuggestions: false,
// // // // // //         enabled: widget.enabled,
// // // // // //         onChanged: widget.onChanged,
// // // // // //         readOnly: widget.readOnly,
// // // // // //       ),
// // // // // //     );

// // // // // //     final codeCol = Theme(
// // // // // //       data: Theme.of(context).copyWith(
// // // // // //         textSelectionTheme: widget.textSelectionTheme,
// // // // // //       ),
// // // // // //       child: LayoutBuilder(
// // // // // //         builder: (BuildContext context, BoxConstraints constraints) {
// // // // // //           // Control horizontal scrolling
// // // // // //           return widget.wrap
// // // // // //               ? codeField
// // // // // //               : _wrapInScrollView(codeField, textStyle, constraints.maxWidth);
// // // // // //         },
// // // // // //       ),
// // // // // //     );

// // // // // //     return Container(
// // // // // //       decoration: widget.decoration,
// // // // // //       color: backgroundCol,
// // // // // //       padding: !widget.lineNumbers ? const EdgeInsets.only(left: 8) : null,
// // // // // //       child: Row(
// // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //         children: [
// // // // // //           if (widget.lineNumbers && numberCol != null) numberCol,
// // // // // //           Expanded(child: codeCol),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // // import 'dart:async';
// // // // // // // import 'dart:math';
// // // // // // // import 'package:flutter/material.dart';
// // // // // // // // import 'package:linked_scroll_controller/linked_scroll_controller.dart';
// // // // // // // import 'package:flutter/services.dart'; // For clipboard and key handling
// // // // // // // import 'package:newtextfieldcompiler99/code_field/linked_scroll_controller.dart';

// // // // // // // import '../code_theme/code_theme.dart';
// // // // // // // import '../line_numbers/line_number_controller.dart';
// // // // // // // import '../line_numbers/line_number_style.dart';
// // // // // // // import 'code_controller.dart';

// // // // // // // class CodeField extends StatefulWidget {
// // // // // // //   final SmartQuotesType? smartQuotesType;
// // // // // // //   final TextInputType? keyboardType;
// // // // // // //   final int? minLines;
// // // // // // //   final int? maxLines;
// // // // // // //   final bool expands;
// // // // // // //   final bool wrap;
// // // // // // //   final CodeController controller;
// // // // // // //   final LineNumberStyle lineNumberStyle;
// // // // // // //   final Color? cursorColor;
// // // // // // //   final TextStyle? textStyle;
// // // // // // //   final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
// // // // // // //   final bool? enabled;
// // // // // // //   final void Function(String)? onChanged;
// // // // // // //   final bool readOnly;
// // // // // // //   final bool isDense;
// // // // // // //   final TextSelectionControls? selectionControls;
// // // // // // //   final Color? background;
// // // // // // //   final EdgeInsets padding;
// // // // // // //   final Decoration? decoration;
// // // // // // //   final TextSelectionThemeData? textSelectionTheme;
// // // // // // //   final FocusNode? focusNode;
// // // // // // //   final void Function()? onTap;
// // // // // // //   final bool lineNumbers;
// // // // // // //   final bool horizontalScroll;

// // // // // // //   const CodeField({
// // // // // // //     Key? key,
// // // // // // //     required this.controller,
// // // // // // //     this.minLines,
// // // // // // //     this.maxLines,
// // // // // // //     this.expands = false,
// // // // // // //     this.wrap = false,
// // // // // // //     this.background,
// // // // // // //     this.decoration,
// // // // // // //     this.textStyle,
// // // // // // //     this.padding = EdgeInsets.zero,
// // // // // // //     this.lineNumberStyle = const LineNumberStyle(),
// // // // // // //     this.enabled,
// // // // // // //     this.onTap,
// // // // // // //     this.readOnly = false,
// // // // // // //     this.cursorColor,
// // // // // // //     this.textSelectionTheme,
// // // // // // //     this.lineNumberBuilder,
// // // // // // //     this.focusNode,
// // // // // // //     this.onChanged,
// // // // // // //     this.isDense = false,
// // // // // // //     this.smartQuotesType,
// // // // // // //     this.keyboardType,
// // // // // // //     this.lineNumbers = true,
// // // // // // //     this.horizontalScroll = true,
// // // // // // //     this.selectionControls,
// // // // // // //   }) : super(key: key);

// // // // // // //   @override
// // // // // // //   State<CodeField> createState() => _CodeFieldState();
// // // // // // // }

// // // // // // // class _CodeFieldState extends State<CodeField> {
// // // // // // //   LinkedScrollControllerGroup? _controllers;
// // // // // // //   ScrollController? _numberScroll;
// // // // // // //   ScrollController? _codeScroll;
// // // // // // //   LineNumberController? _numberController;
// // // // // // //   FocusNode? _focusNode;

// // // // // // //   // Define the longestLine variable
// // // // // // //   String longestLine = '';

// // // // // // //   @override
// // // // // // //   void initState() {
// // // // // // //     super.initState();
// // // // // // //     _controllers = LinkedScrollControllerGroup();
// // // // // // //     _numberScroll = _controllers?.addAndGet();
// // // // // // //     _codeScroll = _controllers?.addAndGet();
// // // // // // //     _numberController = LineNumberController(widget.lineNumberBuilder);
// // // // // // //     widget.controller.addListener(_onTextChanged);
// // // // // // //     _focusNode = widget.focusNode ?? FocusNode();
// // // // // // //     _focusNode!.onKey = _onKey;
// // // // // // //     _focusNode!.attach(context, onKey: _onKey);

// // // // // // //     _onTextChanged(); // Initial call to populate line numbers
// // // // // // //   }

// // // // // // //   // Override keyboard key events to block copy/paste/cut
// // // // // // //   KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
// // // // // // //     if (widget.readOnly) {
// // // // // // //       return KeyEventResult.ignored;
// // // // // // //     }

// // // // // // //     // Intercept Ctrl + C (Copy)
// // // // // // //     if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyC) {
// // // // // // //       // Block copy operation
// // // // // // //       return KeyEventResult.handled;
// // // // // // //     }

// // // // // // //     // Intercept Ctrl + X (Cut)
// // // // // // //     if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyX) {
// // // // // // //       // Block cut operation
// // // // // // //       return KeyEventResult.handled;
// // // // // // //     }

// // // // // // //     // Intercept Ctrl + V (Paste)
// // // // // // //     if (event.isControlPressed && event.logicalKey == LogicalKeyboardKey.keyV) {
// // // // // // //       // Block paste by clearing the clipboard or rejecting paste action
// // // // // // //       Clipboard.setData(ClipboardData(text: ''));
// // // // // // //       return KeyEventResult.handled;
// // // // // // //     }

// // // // // // //     // Let the controller handle other key events
// // // // // // //     return widget.controller.onKey(event);
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   void dispose() {
// // // // // // //     widget.controller.removeListener(_onTextChanged);
// // // // // // //     _numberScroll?.dispose();
// // // // // // //     _codeScroll?.dispose();
// // // // // // //     _numberController?.dispose();
// // // // // // //     super.dispose();
// // // // // // //   }

// // // // // // //   void _onTextChanged() {
// // // // // // //     // Rebuild line number
// // // // // // //     final str = widget.controller.text.split('\n');
// // // // // // //     final buf = <String>[];

// // // // // // //     for (var k = 0; k < str.length; k++) {
// // // // // // //       buf.add((k + 1).toString());
// // // // // // //     }

// // // // // // //     _numberController?.text = buf.join('\n');

// // // // // // //     // Find longest line
// // // // // // //     longestLine = '';
// // // // // // //     for (var line in widget.controller.text.split('\n')) {
// // // // // // //       if (line.length > longestLine.length) {
// // // // // // //         longestLine = line;
// // // // // // //       }
// // // // // // //     }

// // // // // // //     setState(() {});
// // // // // // //   }

// // // // // // //   // Define the _wrapInScrollView method to handle horizontal scrolling
// // // // // // //   Widget _wrapInScrollView(
// // // // // // //     Widget codeField,
// // // // // // //     TextStyle textStyle,
// // // // // // //     double minWidth,
// // // // // // //   ) {
// // // // // // //     final leftPad = widget.lineNumberStyle.margin / 2;
// // // // // // //     final intrinsic = IntrinsicWidth(
// // // // // // //       child: Column(
// // // // // // //         mainAxisSize: MainAxisSize.min,
// // // // // // //         crossAxisAlignment: CrossAxisAlignment.stretch,
// // // // // // //         children: [
// // // // // // //           ConstrainedBox(
// // // // // // //             constraints: BoxConstraints(
// // // // // // //               maxHeight: 0,
// // // // // // //               minWidth: max(minWidth - leftPad, 0),
// // // // // // //             ),
// // // // // // //             child: Padding(
// // // // // // //               padding: const EdgeInsets.only(right: 16),
// // // // // // //               child: Text(longestLine, style: textStyle),
// // // // // // //             ), // Add extra padding
// // // // // // //           ),
// // // // // // //           widget.expands ? Expanded(child: codeField) : codeField,
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );

// // // // // // //     return SingleChildScrollView(
// // // // // // //       padding: EdgeInsets.only(
// // // // // // //         left: leftPad,
// // // // // // //         right: widget.padding.right,
// // // // // // //       ),
// // // // // // //       scrollDirection: Axis.horizontal,

// // // // // // //       /// Prevents the horizontal scroll if horizontalScroll is false
// // // // // // //       physics:
// // // // // // //           widget.horizontalScroll ? null : const NeverScrollableScrollPhysics(),
// // // // // // //       child: intrinsic,
// // // // // // //     );
// // // // // // //   }

// // // // // // //   @override
// // // // // // //   Widget build(BuildContext context) {
// // // // // // //     // Default color scheme
// // // // // // //     const rootKey = 'root';
// // // // // // //     final defaultBg = Colors.grey.shade900;
// // // // // // //     final defaultText = Colors.grey.shade200;

// // // // // // //     final styles = CodeTheme.of(context)?.styles;
// // // // // // //     Color? backgroundCol =
// // // // // // //         widget.background ?? styles?[rootKey]?.backgroundColor ?? defaultBg;

// // // // // // //     if (widget.decoration != null) {
// // // // // // //       backgroundCol = null;
// // // // // // //     }

// // // // // // //     TextStyle textStyle = widget.textStyle ?? const TextStyle();
// // // // // // //     textStyle = textStyle.copyWith(
// // // // // // //       color: textStyle.color ?? styles?[rootKey]?.color ?? defaultText,
// // // // // // //       fontSize: textStyle.fontSize ?? 16.0,
// // // // // // //     );

// // // // // // //     TextStyle numberTextStyle =
// // // // // // //         widget.lineNumberStyle.textStyle ?? const TextStyle();
// // // // // // //     final numberColor =
// // // // // // //         (styles?[rootKey]?.color ?? defaultText).withOpacity(0.7);

// // // // // // //     // Copy important attributes
// // // // // // //     numberTextStyle = numberTextStyle.copyWith(
// // // // // // //       color: numberTextStyle.color ?? numberColor,
// // // // // // //       fontSize: textStyle.fontSize,
// // // // // // //       fontFamily: textStyle.fontFamily,
// // // // // // //     );

// // // // // // //     final cursorColor =
// // // // // // //         widget.cursorColor ?? styles?[rootKey]?.color ?? defaultText;

// // // // // // //     TextField? lineNumberCol;
// // // // // // //     Container? numberCol;

// // // // // // //     if (widget.lineNumbers) {
// // // // // // //       lineNumberCol = TextField(
// // // // // // //         smartQuotesType: widget.smartQuotesType,
// // // // // // //         scrollPadding: widget.padding,
// // // // // // //         style: numberTextStyle,
// // // // // // //         controller: _numberController,
// // // // // // //         enabled: false,
// // // // // // //         minLines: widget.minLines,
// // // // // // //         maxLines: widget.maxLines,
// // // // // // //         selectionControls: widget.selectionControls,
// // // // // // //         expands: widget.expands,
// // // // // // //         scrollController: _numberScroll,
// // // // // // //         decoration: InputDecoration(
// // // // // // //           disabledBorder: InputBorder.none,
// // // // // // //           isDense: widget.isDense,
// // // // // // //         ),
// // // // // // //         textAlign: widget.lineNumberStyle.textAlign,
// // // // // // //       );

// // // // // // //       numberCol = Container(
// // // // // // //         width: widget.lineNumberStyle.width,
// // // // // // //         padding: EdgeInsets.only(
// // // // // // //           left: widget.padding.left,
// // // // // // //           right: widget.lineNumberStyle.margin / 2,
// // // // // // //         ),
// // // // // // //         color: widget.lineNumberStyle.background,
// // // // // // //         child: lineNumberCol,
// // // // // // //       );
// // // // // // //     }

// // // // // // //     final codeField = GestureDetector(
// // // // // // //       onSecondaryTap: () {
// // // // // // //         // Disable right-click context menu
// // // // // // //       },
// // // // // // //       child: TextField(
// // // // // // //         keyboardType: widget.keyboardType,
// // // // // // //         smartQuotesType: widget.smartQuotesType,
// // // // // // //         focusNode: _focusNode,
// // // // // // //         onTap: widget.onTap,
// // // // // // //         scrollPadding: widget.padding,
// // // // // // //         style: textStyle,
// // // // // // //         controller: widget.controller,
// // // // // // //         minLines: widget.minLines,
// // // // // // //         selectionControls: widget.selectionControls,
// // // // // // //         maxLines: widget.maxLines,
// // // // // // //         expands: widget.expands,
// // // // // // //         scrollController: _codeScroll,
// // // // // // //         decoration: InputDecoration(
// // // // // // //           disabledBorder: InputBorder.none,
// // // // // // //           border: InputBorder.none,
// // // // // // //           focusedBorder: InputBorder.none,
// // // // // // //           isDense: widget.isDense,
// // // // // // //         ),
// // // // // // //         cursorColor: cursorColor,
// // // // // // //         autocorrect: false,
// // // // // // //         enableSuggestions: false,
// // // // // // //         enabled: widget.enabled,
// // // // // // //         onChanged: widget.onChanged,
// // // // // // //         readOnly: widget.readOnly,
// // // // // // //       ),
// // // // // // //     );

// // // // // // //     final codeCol = Theme(
// // // // // // //       data: Theme.of(context).copyWith(
// // // // // // //         textSelectionTheme: widget.textSelectionTheme,
// // // // // // //       ),
// // // // // // //       child: LayoutBuilder(
// // // // // // //         builder: (BuildContext context, BoxConstraints constraints) {
// // // // // // //           // Control horizontal scrolling
// // // // // // //           return widget.wrap
// // // // // // //               ? codeField
// // // // // // //               : _wrapInScrollView(codeField, textStyle, constraints.maxWidth);
// // // // // // //         },
// // // // // // //       ),
// // // // // // //     );

// // // // // // //     return Container(
// // // // // // //       decoration: widget.decoration,
// // // // // // //       color: backgroundCol,
// // // // // // //       padding: !widget.lineNumbers ? const EdgeInsets.only(left: 8) : null,
// // // // // // //       child: Row(
// // // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // // //         children: [
// // // // // // //           if (widget.lineNumbers && numberCol != null) numberCol,
// // // // // // //           Expanded(child: codeCol),
// // // // // // //         ],
// // // // // // //       ),
// // // // // // //     );
// // // // // // //   }
// // // // // // // }
// // // // // // import 'dart:math';
// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter/services.dart'; // For clipboard and key handling
// // // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/clipboard_manager.dart';
// // // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// // // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/linked_scroll_controller.dart';
// // // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_theme/code_theme.dart';
// // // // // // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_controller.dart';
// // // // // // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';

// // // // // // class CodeField extends StatefulWidget {
// // // // // //   final SmartQuotesType? smartQuotesType;
// // // // // //   final TextInputType? keyboardType;
// // // // // //   final int? minLines;
// // // // // //   final int? maxLines;
// // // // // //   final bool expands;
// // // // // //   final bool wrap;
// // // // // //   final CodeController controller;
// // // // // //   final LineNumberStyle lineNumberStyle;
// // // // // //   final Color? cursorColor;
// // // // // //   final TextStyle? textStyle;
// // // // // //   final TextSpan Function(int, TextStyle?)? lineNumberBuilder;
// // // // // //   final bool? enabled;
// // // // // //   final void Function(String)? onChanged;
// // // // // //   final bool readOnly;
// // // // // //   final bool isDense;
// // // // // //   final TextSelectionControls? selectionControls;
// // // // // //   final Color? background;
// // // // // //   final EdgeInsets padding;
// // // // // //   final Decoration? decoration;
// // // // // //   final TextSelectionThemeData? textSelectionTheme;
// // // // // //   final FocusNode? focusNode;
// // // // // //   final void Function()? onTap;
// // // // // //   final bool lineNumbers;
// // // // // //   final bool horizontalScroll;

// // // // // //   const CodeField({
// // // // // //     Key? key,
// // // // // //     required this.controller,
// // // // // //     this.minLines,
// // // // // //     this.maxLines,
// // // // // //     this.expands = false,
// // // // // //     this.wrap = false,
// // // // // //     this.background,
// // // // // //     this.decoration,
// // // // // //     this.textStyle,
// // // // // //     this.padding = EdgeInsets.zero,
// // // // // //     this.lineNumberStyle = const LineNumberStyle(),
// // // // // //     this.enabled,
// // // // // //     this.onTap,
// // // // // //     this.readOnly = false,
// // // // // //     this.cursorColor,
// // // // // //     this.textSelectionTheme,
// // // // // //     this.lineNumberBuilder,
// // // // // //     this.focusNode,
// // // // // //     this.onChanged,
// // // // // //     this.isDense = false,
// // // // // //     this.smartQuotesType,
// // // // // //     this.keyboardType,
// // // // // //     this.lineNumbers = true,
// // // // // //     this.horizontalScroll = true,
// // // // // //     this.selectionControls,
// // // // // //   }) : super(key: key);

// // // // // //   @override
// // // // // //   State<CodeField> createState() => _CodeFieldState();
// // // // // // }

// // // // // // class _CodeFieldState extends State<CodeField> {
// // // // // //   LinkedScrollControllerGroup? _controllers;
// // // // // //   ScrollController? _numberScroll;
// // // // // //   ScrollController? _codeScroll;
// // // // // //   LineNumberController? _numberController;
// // // // // //   FocusNode? _focusNode;

// // // // // //   final ClipboardManager _clipboardManager = ClipboardManager();

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     _controllers = LinkedScrollControllerGroup();
// // // // // //     _numberScroll = _controllers?.addAndGet();
// // // // // //     _codeScroll = _controllers?.addAndGet();
// // // // // //     _numberController = LineNumberController(widget.lineNumberBuilder);
// // // // // //     widget.controller.addListener(_onTextChanged);
// // // // // //     _focusNode = widget.focusNode ?? FocusNode();
// // // // // //     _focusNode!.onKey = _onKey;
// // // // // //     _focusNode!.attach(context, onKey: _onKey);

// // // // // //     _onTextChanged(); // Initial call to populate line numbers
// // // // // //   }

// // // // // //   KeyEventResult _onKey(FocusNode node, RawKeyEvent event) {
// // // // // //     if (widget.readOnly) {
// // // // // //       return KeyEventResult.ignored;
// // // // // //     }

// // // // // //     if (event is RawKeyDownEvent) {
// // // // // //       // Intercept Ctrl+H to display clipboard history
// // // // // //       if (event.isControlPressed &&
// // // // // //           event.logicalKey == LogicalKeyboardKey.keyH) {
// // // // // //         _showClipboardHistory();
// // // // // //         return KeyEventResult.handled;
// // // // // //       }

// // // // // //       // Handle Ctrl+C (Copy), Ctrl+X (Cut), and Ctrl+V (Paste) using global clipboard
// // // // // //       if (event.isControlPressed) {
// // // // // //         if (event.logicalKey == LogicalKeyboardKey.keyC) {
// // // // // //           _clipboardManager.addToClipboard(
// // // // // //               widget.controller.selection.textInside(widget.controller.text));
// // // // // //           return KeyEventResult.handled;
// // // // // //         }

// // // // // //         if (event.logicalKey == LogicalKeyboardKey.keyX) {
// // // // // //           _clipboardManager.addToClipboard(
// // // // // //               widget.controller.selection.textInside(widget.controller.text));
// // // // // //           widget.controller.text = widget.controller.text.replaceRange(
// // // // // //             widget.controller.selection.start,
// // // // // //             widget.controller.selection.end,
// // // // // //             '',
// // // // // //           );
// // // // // //           return KeyEventResult.handled;
// // // // // //         }

// // // // // //         if (event.logicalKey == LogicalKeyboardKey.keyV) {
// // // // // //           final pasteText = _clipboardManager.internalClipboard;
// // // // // //           final updatedText = widget.controller.text.replaceRange(
// // // // // //             widget.controller.selection.start,
// // // // // //             widget.controller.selection.end,
// // // // // //             pasteText,
// // // // // //           );
// // // // // //           widget.controller.value = TextEditingValue(
// // // // // //             text: updatedText,
// // // // // //             selection: TextSelection.collapsed(
// // // // // //               offset: widget.controller.selection.start + pasteText.length,
// // // // // //             ),
// // // // // //           );
// // // // // //           return KeyEventResult.handled;
// // // // // //         }
// // // // // //       }
// // // // // //     }

// // // // // //     // Let the controller handle other key events
// // // // // //     return widget.controller.onKey(event);
// // // // // //   }

// // // // // //   void _showClipboardHistory() {
// // // // // //     showDialog(
// // // // // //       context: context,
// // // // // //       builder: (BuildContext context) {
// // // // // //         return StatefulBuilder(
// // // // // //           builder: (BuildContext context, StateSetter setState) {
// // // // // //             return AlertDialog(
// // // // // //               title: const Text('Clipboard History'),
// // // // // //               content: SizedBox(
// // // // // //                 width: double.maxFinite,
// // // // // //                 height: 400,
// // // // // //                 child: SingleChildScrollView(
// // // // // //                   child: Column(
// // // // // //                     mainAxisSize: MainAxisSize.min,
// // // // // //                     children: _clipboardManager.clipboardHistory
// // // // // //                         .asMap()
// // // // // //                         .entries
// // // // // //                         .map((entry) => Container(
// // // // // //                               color: entry.key % 2 == 0
// // // // // //                                   ? Colors.grey[200]
// // // // // //                                   : Colors.white,
// // // // // //                               child: ListTile(
// // // // // //                                 title: Text(
// // // // // //                                   entry.value,
// // // // // //                                   maxLines: 3,
// // // // // //                                   overflow: TextOverflow.ellipsis,
// // // // // //                                 ),
// // // // // //                                 trailing: IconButton(
// // // // // //                                   icon: Icon(Icons.delete, color: Colors.red),
// // // // // //                                   onPressed: () {
// // // // // //                                     setState(() {
// // // // // //                                       _clipboardManager
// // // // // //                                           .deleteFromClipboardHistory(
// // // // // //                                               entry.key);
// // // // // //                                     });
// // // // // //                                   },
// // // // // //                                 ),
// // // // // //                                 onTap: () {
// // // // // //                                   _clipboardManager.addToClipboard(entry.value);
// // // // // //                                   _pasteFromInternalClipboard();
// // // // // //                                   Navigator.of(context).pop();
// // // // // //                                 },
// // // // // //                               ),
// // // // // //                             ))
// // // // // //                         .toList(),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ),
// // // // // //               actions: <Widget>[
// // // // // //                 TextButton(
// // // // // //                   child: const Text('Close'),
// // // // // //                   onPressed: () {
// // // // // //                     Navigator.of(context).pop();
// // // // // //                   },
// // // // // //                 ),
// // // // // //               ],
// // // // // //             );
// // // // // //           },
// // // // // //         );
// // // // // //       },
// // // // // //     );
// // // // // //   }

// // // // // //   void _pasteFromInternalClipboard() {
// // // // // //     final pasteText = _clipboardManager.internalClipboard;
// // // // // //     final cursorPosition = widget.controller.selection.start;
// // // // // //     final updatedText = widget.controller.text.replaceRange(
// // // // // //       cursorPosition,
// // // // // //       cursorPosition,
// // // // // //       pasteText,
// // // // // //     );
// // // // // //     widget.controller.value = TextEditingValue(
// // // // // //       text: updatedText,
// // // // // //       selection: TextSelection.collapsed(
// // // // // //         offset: cursorPosition + pasteText.length,
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     widget.controller.removeListener(_onTextChanged);
// // // // // //     _numberScroll?.dispose();
// // // // // //     _codeScroll?.dispose();
// // // // // //     _numberController?.dispose();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   void _onTextChanged() {
// // // // // //     // Rebuild line number
// // // // // //     final str = widget.controller.text.split('\n');
// // // // // //     final buf = <String>[];

// // // // // //     for (var k = 0; k < str.length; k++) {
// // // // // //       buf.add((k + 1).toString());
// // // // // //     }

// // // // // //     _numberController?.text = buf.join('\n');
// // // // // //     setState(() {});
// // // // // //   }

// // // // // //   Widget _wrapInScrollView(
// // // // // //     Widget codeField,
// // // // // //     TextStyle textStyle,
// // // // // //     double minWidth,
// // // // // //   ) {
// // // // // //     final leftPad = widget.lineNumberStyle.margin / 2;
// // // // // //     final intrinsic = IntrinsicWidth(
// // // // // //       child: Column(
// // // // // //         mainAxisSize: MainAxisSize.min,
// // // // // //         crossAxisAlignment: CrossAxisAlignment.stretch,
// // // // // //         children: [
// // // // // //           ConstrainedBox(
// // // // // //             constraints: BoxConstraints(
// // // // // //               maxHeight: 0,
// // // // // //               minWidth: max(minWidth - leftPad, 0),
// // // // // //             ),
// // // // // //             child: Padding(
// // // // // //               padding: const EdgeInsets.only(right: 16),
// // // // // //               child:
// // // // // //                   Text(_clipboardManager.internalClipboard, style: textStyle),
// // // // // //             ),
// // // // // //           ),
// // // // // //           widget.expands ? Expanded(child: codeField) : codeField,
// // // // // //         ],
// // // // // //       ),
// // // // // //     );

// // // // // //     return SingleChildScrollView(
// // // // // //       padding: EdgeInsets.only(
// // // // // //         left: leftPad,
// // // // // //         right: widget.padding.right,
// // // // // //       ),
// // // // // //       scrollDirection: Axis.horizontal,
// // // // // //       physics:
// // // // // //           widget.horizontalScroll ? null : const NeverScrollableScrollPhysics(),
// // // // // //       child: intrinsic,
// // // // // //     );
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     const rootKey = 'root';
// // // // // //     final defaultBg = Colors.grey.shade900;
// // // // // //     final defaultText = Colors.grey.shade200;

// // // // // //     final styles = CodeTheme.of(context)?.styles;
// // // // // //     Color? backgroundCol =
// // // // // //         widget.background ?? styles?[rootKey]?.backgroundColor ?? defaultBg;

// // // // // //     if (widget.decoration != null) {
// // // // // //       backgroundCol = null;
// // // // // //     }

// // // // // //     TextStyle textStyle = widget.textStyle ?? const TextStyle();
// // // // // //     textStyle = textStyle.copyWith(
// // // // // //       color: textStyle.color ?? styles?[rootKey]?.color ?? defaultText,
// // // // // //       fontSize: textStyle.fontSize ?? 16.0,
// // // // // //     );

// // // // // //     TextStyle numberTextStyle =
// // // // // //         widget.lineNumberStyle.textStyle ?? const TextStyle();
// // // // // //     final numberColor =
// // // // // //         (styles?[rootKey]?.color ?? defaultText).withOpacity(0.7);

// // // // // //     numberTextStyle = numberTextStyle.copyWith(
// // // // // //       color: numberTextStyle.color ?? numberColor,
// // // // // //       fontSize: textStyle.fontSize,
// // // // // //       fontFamily: textStyle.fontFamily,
// // // // // //     );

// // // // // //     final cursorColor =
// // // // // //         widget.cursorColor ?? styles?[rootKey]?.color ?? defaultText;

// // // // // //     TextField? lineNumberCol;
// // // // // //     Container? numberCol;

// // // // // //     if (widget.lineNumbers) {
// // // // // //       lineNumberCol = TextField(
// // // // // //         smartQuotesType: widget.smartQuotesType,
// // // // // //         scrollPadding: widget.padding,
// // // // // //         style: numberTextStyle,
// // // // // //         controller: _numberController,
// // // // // //         enabled: false,
// // // // // //         minLines: widget.minLines,
// // // // // //         maxLines: widget.maxLines,
// // // // // //         selectionControls: widget.selectionControls,
// // // // // //         expands: widget.expands,
// // // // // //         scrollController: _numberScroll,
// // // // // //         decoration: InputDecoration(
// // // // // //           disabledBorder: InputBorder.none,
// // // // // //           isDense: widget.isDense,
// // // // // //         ),
// // // // // //         textAlign: widget.lineNumberStyle.textAlign,
// // // // // //       );

// // // // // //       numberCol = Container(
// // // // // //         width: widget.lineNumberStyle.width,
// // // // // //         padding: EdgeInsets.only(
// // // // // //           left: widget.padding.left,
// // // // // //           right: widget.lineNumberStyle.margin / 2,
// // // // // //         ),
// // // // // //         color: widget.lineNumberStyle.background,
// // // // // //         child: lineNumberCol,
// // // // // //       );
// // // // // //     }

// // // // // //     final codeField = GestureDetector(
// // // // // //       onSecondaryTap: () {},
// // // // // //       child: TextField(
// // // // // //         keyboardType: widget.keyboardType,
// // // // // //         smartQuotesType: widget.smartQuotesType,
// // // // // //         focusNode: _focusNode,
// // // // // //         onTap: widget.onTap,
// // // // // //         scrollPadding: widget.padding,
// // // // // //         style: textStyle,
// // // // // //         controller: widget.controller,
// // // // // //         minLines: widget.minLines,
// // // // // //         selectionControls: widget.selectionControls,
// // // // // //         maxLines: widget.maxLines,
// // // // // //         expands: widget.expands,
// // // // // //         scrollController: _codeScroll,
// // // // // //         decoration: InputDecoration(
// // // // // //           disabledBorder: InputBorder.none,
// // // // // //           border: InputBorder.none,
// // // // // //           focusedBorder: InputBorder.none,
// // // // // //           isDense: widget.isDense,
// // // // // //         ),
// // // // // //         cursorColor: cursorColor,
// // // // // //         autocorrect: false,
// // // // // //         enableSuggestions: false,
// // // // // //         enabled: widget.enabled,
// // // // // //         onChanged: widget.onChanged,
// // // // // //         readOnly: widget.readOnly,
// // // // // //       ),
// // // // // //     );

// // // // // //     final codeCol = Theme(
// // // // // //       data: Theme.of(context).copyWith(
// // // // // //         textSelectionTheme: widget.textSelectionTheme,
// // // // // //       ),
// // // // // //       child: LayoutBuilder(
// // // // // //         builder: (BuildContext context, BoxConstraints constraints) {
// // // // // //           return widget.wrap
// // // // // //               ? codeField
// // // // // //               : _wrapInScrollView(codeField, textStyle, constraints.maxWidth);
// // // // // //         },
// // // // // //       ),
// // // // // //     );

// // // // // //     return Container(
// // // // // //       decoration: widget.decoration,
// // // // // //       color: backgroundCol,
// // // // // //       padding: !widget.lineNumbers ? const EdgeInsets.only(left: 8) : null,
// // // // // //       child: Row(
// // // // // //         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //         children: [
// // // // // //           if (widget.lineNumbers && numberCol != null) numberCol,
// // // // // //           Expanded(child: codeCol),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
