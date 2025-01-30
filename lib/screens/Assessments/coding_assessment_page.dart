import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
import 'package:studentpanel100/utils/shared_prefs.dart';
import 'package:studentpanel100/widgets/arrows_ui.dart';

class CodingQuestionWidget extends StatefulWidget {
  final Map<String, dynamic> codingQuestion;
  final CodeController codeController;

  const CodingQuestionWidget({
    Key? key,
    required this.codingQuestion,
    required this.codeController,
  }) : super(key: key);

  @override
  State<CodingQuestionWidget> createState() => _CodingQuestionWidgetState();
}

class _CodingQuestionWidgetState extends State<CodingQuestionWidget>
    with SingleTickerProviderStateMixin {
  late CodeController _codeController;
  final FocusNode _focusNode = FocusNode();
  List<TestCaseResult> testResults = [];
  final ScrollController _rightPanelScrollController = ScrollController();
  String? _selectedLanguage = "Please select a Language";
  TextEditingController _customInputController = TextEditingController();
  bool _iscustomInputfieldVisible = false;
  double _dividerPosition = 0.5;
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Create a unique CodeController for this question
    final initialCode = widget.codingQuestion['solution_code'] ??
        '''
***************************************************
***************  Select a Language  ***************
***************************************************
''';

    _codeController = CodeController(text: initialCode);

    // Add a listener for changes in this specific CodeController
    _codeController.addListener(() {});

    _tabController = TabController(length: 3, vsync: this);

    // Set default language if not already set
    _selectedLanguage =
        widget.codingQuestion['language'] ?? "Please select a Language";

    // Set starter code if necessary
    if (widget.codingQuestion['solution_code'] == null &&
        _selectedLanguage != "Please select a Language") {
      _setStarterCode(_selectedLanguage!);
    }
    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_codeController.text.isNotEmpty && !_isLoading) {
        _saveCode();
      }
    });
    print(
        "[DEBUG] initState initialized for question ${widget.codingQuestion['id']}");
  }

  @override
  void dispose() {
    print("[DEBUG] CodingQuestionDetailPage dispose called");

    _tabController.dispose();
    _codeController.dispose();
    _focusNode.dispose();
    _customInputController.dispose();
    super.dispose();
  }

  Future<void> _fetchSavedCode() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final token = await SharedPrefs.getToken();
      final response = await http.get(
        Uri.parse(
            "http://13.201.69.118/assessments/fetch-code?question_id=${widget.codingQuestion['id']}&round_id=${widget.codingQuestion['round_id']}"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _codeController.text = data['solution_code'] ?? '';
          _selectedLanguage = data['language'] ?? "Please select a Language";
        });
      } else {
        print("[ERROR] Failed to fetch saved code: ${response.body}");
      }
    } catch (error) {
      print("[ERROR] Error fetching code: $error");
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveCode() async {
    try {
      final token = await SharedPrefs.getToken();
      final requestBody = {
        "question_id": widget.codingQuestion['id'],
        "round_id": widget.codingQuestion['round_id'],
        "solution_code": _codeController.text,
        "language": _selectedLanguage,
      };

      final response = await http.post(
        Uri.parse("http://13.201.69.118/assessments/save-code"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        print("[DEBUG] Code saved successfully.");
      } else {
        print("[ERROR] Failed to save code: ${response.body}");
      }
    } catch (error) {
      print("[ERROR] Error saving code: $error");
    }
  }

  void _handleKeyPress(RawKeyEvent event) {
    if (event.isControlPressed &&
        event.logicalKey == LogicalKeyboardKey.slash) {
      _commentSelectedLines();
    }
  }

  void _setStarterCode(String language) {
    String starterCode;

    switch (language.toLowerCase()) {
      case 'python':
        starterCode = '# Write your Python code here';
        break;
      case 'java':
        starterCode = '''
public class Main {
    public static void main(String[] args) {
        // Write your Java code here
    }
}
''';
        break;
      case 'c':
        starterCode = '''
#include <stdio.h>

int main() {
    // Write your C code here
    return 0;
}
''';
        break;
      case 'cpp':
      case 'c++':
        starterCode = '''
#include <iostream>
using namespace std;

int main() {
    // Write your C++ code here
    return 0;
}
''';
        break;
      default:
        starterCode = '// Unsupported language';
    }

    setState(() {
      _codeController.text = starterCode;
    });
  }

  void _commentSelectedLines() {
    final selection = _codeController.selection;
    final text = _codeController.text;
    final commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

    if (selection.isCollapsed) {
      int lineStart = selection.start;
      int lineEnd = selection.start;

      while (lineStart > 0 && text[lineStart - 1] != '\n') lineStart--;
      while (lineEnd < text.length && text[lineEnd] != '\n') lineEnd++;

      final lineText = text.substring(lineStart, lineEnd);
      final isCommented = lineText.trimLeft().startsWith(commentSyntax);

      final newLineText = isCommented
          ? lineText.replaceFirst(commentSyntax, '').trimLeft()
          : '$commentSyntax $lineText';

      final newText = text.replaceRange(lineStart, lineEnd, newLineText);
      _codeController.value = _codeController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
            offset: isCommented
                ? selection.start - commentSyntax.length - 1
                : selection.start + commentSyntax.length + 1),
      );
    } else {
      final selectedText = text.substring(selection.start, selection.end);
      final lines = selectedText.split('\n');
      final allLinesCommented =
          lines.every((line) => line.trimLeft().startsWith(commentSyntax));

      final commentedLines = lines.map((line) {
        return allLinesCommented
            ? line.replaceFirst(commentSyntax, '').trimLeft()
            : '$commentSyntax $line';
      }).join('\n');

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

  Widget buildQuestionPanel() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.codingQuestion['title'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.codingQuestion['description'],
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text("Input Format",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.codingQuestion['input_format'],
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            const Text("Output Format",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.codingQuestion['output_format'],
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            const Text("Constraints",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.codingQuestion['constraints'],
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(
                widget.codingQuestion['test_cases'].length,
                (index) {
                  final testCase = widget.codingQuestion['test_cases'][index];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text(widget.codingQuestion['difficulty'],
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text("Hello"),
            if (widget.codingQuestion['solutions'] != null &&
                widget.codingQuestion['solutions'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text("Solutions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...List<Widget>.generate(
                    widget.codingQuestion['solutions'].length,
                    (index) {
                      final solution =
                          widget.codingQuestion['solutions'][index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Language: ${solution['language']}",
                                style: TextStyle(fontSize: 16),
                              ),
                              Text(
                                "Code:",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: double.infinity,
                                color: Colors.black12,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    solution['code'],
                                    style: TextStyle(
                                        fontFamily: 'RobotoMono', fontSize: 14),
                                  ),
                                ),
                              ),
                              if (solution['youtube_link'] != null)
                                Text(
                                  "YouTube Link: ${solution['youtube_link']}",
                                  style: TextStyle(fontSize: 16),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget codefieldbox() {
    return Expanded(
      child: Container(
        // width: rightPanelWidth,
        height: MediaQuery.of(context).size.height * 2,
        color: Colors.white,
        child: SingleChildScrollView(
          controller: _rightPanelScrollController,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("Select Language",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                // DropdownButton<String>(
                //   value: _selectedLanguage,
                //   onChanged: (String? newValue) {
                //     if (newValue != null &&
                //         newValue != "Please select a Language") {
                //       if (_selectedLanguage != "Please select a Language") {
                //         // Show alert if a language was previously selected
                //         showDialog(
                //           context: context,
                //           builder: (BuildContext context) {
                //             return AlertDialog(
                //               title: Text("Change Language"),
                //               content: Text(
                //                   "Changing the language will remove the current code. Do you want to proceed?"),
                //               actions: [
                //                 TextButton(
                //                   child: Text("Cancel"),
                //                   onPressed: () {
                //                     Navigator.of(context)
                //                         .pop(); // Close the dialog
                //                   },
                //                 ),
                //                 TextButton(
                //                   child: Text("Proceed"),
                //                   onPressed: () {
                //                     // Proceed with changing the language and setting starter code
                //                     setState(() {
                //                       _selectedLanguage = newValue;
                //                       _setStarterCode(newValue);
                //                     });
                //                     Navigator.of(context)
                //                         .pop(); // Close the dialog
                //                   },
                //                 ),
                //               ],
                //             );
                //           },
                //         );
                //       } else {
                //         // Directly set language and starter code if no language was selected previously
                //         setState(() {
                //           _selectedLanguage = newValue;
                //           _setStarterCode(newValue);
                //         });
                //       }
                //     }
                //   },
                //   items: [
                //     DropdownMenuItem<String>(
                //       value: "Please select a Language",
                //       child: Text("Please select a Language"),
                //     ),
                //     ...widget.question['allowed_languages']
                //         .cast<String>()
                //         .map<DropdownMenuItem<String>>((String language) {
                //       return DropdownMenuItem<String>(
                //         value: language,
                //         child: Text(language),
                //       );
                //     }).toList(),
                //   ],
                // ),

                // DropdownButton<String>(
                //   value: _selectedLanguage,
                //   onChanged: (String? newValue) {
                //     if (newValue != null &&
                //         newValue != "Please select a Language") {
                //       if (_selectedLanguage != "Please select a Language") {
                //         // Show alert if a language was previously selected
                //         showDialog(
                //           context: context,
                //           builder: (BuildContext context) {
                //             return AlertDialog(
                //               title: Text("Change Language"),
                //               content: Text(
                //                   "Changing the language will remove the current code. Do you want to proceed?"),
                //               actions: [
                //                 TextButton(
                //                   child: Text("Cancel"),
                //                   onPressed: () {
                //                     Navigator.of(context)
                //                         .pop(); // Close the dialog
                //                   },
                //                 ),
                //                 TextButton(
                //                   child: Text("Proceed"),
                //                   onPressed: () {
                //                     // Proceed with changing the language and setting starter code
                //                     setState(() {
                //                       _selectedLanguage = newValue;
                //                       _setStarterCode(newValue);
                //                     });
                //                     Navigator.of(context)
                //                         .pop(); // Close the dialog
                //                   },
                //                 ),
                //               ],
                //             );
                //           },
                //         );
                //       } else {
                //         // Directly set language and starter code if no language was selected previously
                //         setState(() {
                //           _selectedLanguage = newValue;
                //           _setStarterCode(newValue);
                //         });
                //       }
                //     }
                //   },
                //   items: [
                //     DropdownMenuItem<String>(
                //       value: "Please select a Language",
                //       child: Text("Please select a Language"),
                //     ),
                //     ...widget.codingQuestion['allowed_languages']
                //         .cast<String>()
                //         .map<DropdownMenuItem<String>>((String language) {
                //       return DropdownMenuItem<String>(
                //         value: language,
                //         child: Text(language),
                //       );
                //     }).toList(),
                //   ],
                // ),

                // DropdownButton<String>(
                //   value: _selectedLanguage,
                //   onChanged: (String? newValue) {
                //     if (newValue != null &&
                //         newValue != "Please select a Language") {
                //       if (_selectedLanguage != "Please select a Language") {
                //         // Show confirmation dialog if a language was previously selected
                //         showDialog(
                //           context: context,
                //           builder: (BuildContext context) {
                //             return AlertDialog(
                //               title: Text("Change Language"),
                //               content: Text(
                //                 "Changing the language will remove the current code. Do you want to proceed?",
                //               ),
                //               actions: [
                //                 TextButton(
                //                   child: Text("Cancel"),
                //                   onPressed: () {
                //                     Navigator.of(context)
                //                         .pop(); // Close the dialog
                //                   },
                //                 ),
                //                 TextButton(
                //                   child: Text("Proceed"),
                //                   onPressed: () {
                //                     // Change language and set starter code
                //                     setState(() {
                //                       _selectedLanguage = newValue;
                //                       _setStarterCode(
                //                           newValue); // Function to set starter code
                //                     });
                //                     Navigator.of(context)
                //                         .pop(); // Close the dialog
                //                   },
                //                 ),
                //               ],
                //             );
                //           },
                //         );
                //       } else {
                //         // Directly set the language if none was selected previously
                //         setState(() {
                //           _selectedLanguage = newValue;
                //           _setStarterCode(
                //               newValue); // Function to set starter code
                //         });
                //       }
                //     }
                //   },
                //   items: [
                //     DropdownMenuItem<String>(
                //       value: "Please select a Language",
                //       child: Text("Please select a Language"),
                //     ),
                //     // Dynamically generate dropdown items based on allowed_languages
                //     ...?widget.codingQuestion['allowed_languages']
                //         ?.cast<String>()
                //         ?.map<DropdownMenuItem<String>>((String language) {
                //       return DropdownMenuItem<String>(
                //         value: language,
                //         child: Text(language),
                //       );
                //     }).toList(),
                //   ],
                // ),

                DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    if (newValue != null &&
                        newValue != "Please select a Language") {
                      if (_selectedLanguage != "Please select a Language") {
                        // Show confirmation dialog if a language was previously selected
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Change Language"),
                              content: Text(
                                "Changing the language will remove the current code. Do you want to proceed?",
                              ),
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
                                    // Change language and set starter code
                                    setState(() {
                                      _selectedLanguage = newValue;
                                      _setStarterCode(
                                          newValue); // Function to set starter code
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
                        // Directly set the language if none was selected previously
                        setState(() {
                          _selectedLanguage = newValue;
                          _setStarterCode(
                              newValue); // Function to set starter code
                        });
                      }
                    }
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: "Please select a Language",
                      child: Text("Please select a Language"),
                    ),
                    // Dynamically generate dropdown items based on allowed_languages
                    ...?widget.codingQuestion['allowed_languages']
                        ?.cast<String>()
                        ?.toSet() // Ensure uniqueness of items
                        ?.map<DropdownMenuItem<String>>((String language) {
                      return DropdownMenuItem<String>(
                        value: language
                            .toLowerCase(), // Normalize the language value
                        child: Text(language),
                      );
                    }).toList(),
                  ],
                ),

                Focus(
                  focusNode: _focusNode, // Attach the focus node to Focus only
                  onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
                    if (keyEvent is KeyDownEvent) {
                      final keysPressed =
                          HardwareKeyboard.instance.logicalKeysPressed;

                      // Check for Ctrl + / shortcut
                      if (keysPressed
                              .contains(LogicalKeyboardKey.controlLeft) &&
                          keysPressed.contains(LogicalKeyboardKey.slash)) {
                        _commentSelectedLines();
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: Container(
                    // height: 200,
                    height: MediaQuery.of(context).size.height / 1.7,
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
                        _runCode(
                          allTestCases: false,
                          mode: 'run',
                        );
                      },
                      child: Text('Run'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _runCode(
                          allTestCases: true,
                          mode: 'submit',
                        );
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
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: TextField(
                          minLines: 5,
                          maxLines: 5,
                          controller: _customInputController,
                          decoration: InputDecoration(
                            hintText: "Enter custom input",
                            hintStyle: TextStyle(color: Colors.white54),
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
                            mode: 'run',
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
      // );
      // },
    );
  }

  Widget buildCodeEditorPanel() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text("Select Language",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          // DropdownButton<String>(
          //   value: _selectedLanguage,
          //   onChanged: (String? newValue) {
          //     if (newValue != null && newValue != "Please select a Language") {
          //       if (_selectedLanguage != "Please select a Language") {
          //         // Show alert if a language was previously selected
          //         showDialog(
          //           context: context,
          //           builder: (BuildContext context) {
          //             return AlertDialog(
          //               title: Text("Change Language"),
          //               content: Text(
          //                   "Changing the language will remove the current code. Do you want to proceed?"),
          //               actions: [
          //                 TextButton(
          //                   child: Text("Cancel"),
          //                   onPressed: () {
          //                     Navigator.of(context).pop(); // Close the dialog
          //                   },
          //                 ),
          //                 TextButton(
          //                   child: Text("Proceed"),
          //                   onPressed: () {
          //                     // Proceed with changing the language and setting starter code
          //                     setState(() {
          //                       _selectedLanguage = newValue;
          //                       _setStarterCode(newValue);
          //                     });
          //                     Navigator.of(context).pop(); // Close the dialog
          //                   },
          //                 ),
          //               ],
          //             );
          //           },
          //         );
          //       } else {
          //         // Directly set language and starter code if no language was selected previously
          //         setState(() {
          //           _selectedLanguage = newValue;
          //           _setStarterCode(newValue);
          //         });
          //       }
          //     }
          //   },
          //   items: [
          //     DropdownMenuItem<String>(
          //       value: "Please select a Language",
          //       child: Text("Please select a Language"),
          //     ),
          //     ...widget.question['allowed_languages']
          //         .cast<String>()
          //         .map<DropdownMenuItem<String>>((String language) {
          //       return DropdownMenuItem<String>(
          //         value: language,
          //         child: Text(language),
          //       );
          //     }).toList(),
          //   ],
          // ),

          // DropdownButton<String>(
          //   value: _selectedLanguage,
          //   onChanged: (String? newValue) {
          //     if (newValue != null && newValue != "Please select a Language") {
          //       if (_selectedLanguage != "Please select a Language") {
          //         // Show alert if a language was previously selected
          //         showDialog(
          //           context: context,
          //           builder: (BuildContext context) {
          //             return AlertDialog(
          //               title: Text("Change Language"),
          //               content: Text(
          //                   "Changing the language will remove the current code. Do you want to proceed?"),
          //               actions: [
          //                 TextButton(
          //                   child: Text("Cancel"),
          //                   onPressed: () {
          //                     Navigator.of(context).pop(); // Close the dialog
          //                   },
          //                 ),
          //                 TextButton(
          //                   child: Text("Proceed"),
          //                   onPressed: () {
          //                     // Proceed with changing the language and setting starter code
          //                     setState(() {
          //                       _selectedLanguage = newValue;
          //                       _setStarterCode(newValue);
          //                     });
          //                     Navigator.of(context).pop(); // Close the dialog
          //                   },
          //                 ),
          //               ],
          //             );
          //           },
          //         );
          //       } else {
          //         // Directly set language and starter code if no language was selected previously
          //         setState(() {
          //           _selectedLanguage = newValue;
          //           _setStarterCode(newValue);
          //         });
          //       }
          //     }
          //   },
          //   items: [
          //     DropdownMenuItem<String>(
          //       value: "Please select a Language",
          //       child: Text("Please select a Language"),
          //     ),
          //     ...widget.codingQuestion['allowed_languages']
          //         .cast<String>()
          //         .map<DropdownMenuItem<String>>((String language) {
          //       return DropdownMenuItem<String>(
          //         value: language,
          //         child: Text(language),
          //       );
          //     }).toList(),
          //   ],
          // ),

          DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null && newValue != "Please select a Language") {
                if (_selectedLanguage != "Please select a Language") {
                  // Show confirmation dialog if a language was previously selected
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Change Language"),
                        content: Text(
                          "Changing the language will remove the current code. Do you want to proceed?",
                        ),
                        actions: [
                          TextButton(
                            child: Text("Cancel"),
                            onPressed: () {
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: Text("Proceed"),
                            onPressed: () {
                              // Change language and set starter code
                              setState(() {
                                _selectedLanguage = newValue;
                                _setStarterCode(
                                    newValue); // Function to set starter code
                              });
                              Navigator.of(context).pop(); // Close the dialog
                            },
                          ),
                        ],
                      );
                    },
                  );
                } else {
                  // Directly set the language if none was selected previously
                  setState(() {
                    _selectedLanguage = newValue;
                    _setStarterCode(newValue); // Function to set starter code
                  });
                }
              }
            },
            items: [
              DropdownMenuItem<String>(
                value: "Please select a Language",
                child: Text("Please select a Language"),
              ),
              // Dynamically generate dropdown items based on allowed_languages
              ...?widget.codingQuestion['allowed_languages']
                  ?.cast<String>()
                  ?.toSet() // Ensure uniqueness of items
                  ?.map<DropdownMenuItem<String>>((String language) {
                return DropdownMenuItem<String>(
                  value: language.toLowerCase(), // Normalize the language value
                  child: Text(language),
                );
              }).toList(),
            ],
          ),

          Expanded(
            child: Focus(
              focusNode: _focusNode, // Attach the focus node to Focus only
              onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
                if (keyEvent is KeyDownEvent) {
                  final keysPressed =
                      HardwareKeyboard.instance.logicalKeysPressed;
                  // Check for Ctrl + / shortcut
                  if (keysPressed.contains(LogicalKeyboardKey.controlLeft) &&
                      keysPressed.contains(LogicalKeyboardKey.slash)) {
                    _commentSelectedLines();
                    return KeyEventResult.handled;
                  }
                }
                return KeyEventResult.ignored;
              },
              child: Container(
                // height: 200,
                height: MediaQuery.of(context).size.height / 3.5,
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
          ),
        ],
      ),
    );
  }

  int _getPointsForDifficulty(String difficulty) {
    final difficultyMapping = {
      'Level1': 100,
      'Level2': 200,
      'Level3': 300,
      'Level4': 400,
      'Level5': 500,
    };
    return difficultyMapping[difficulty] ??
        0; // Default to 0 if difficulty is unknown
  }

  Future<void> _runCode({
    required bool allTestCases,
    String? customInput,
    required String mode, // "run" or "submit"
  }) async {
    try {
      print("[DEBUG] Starting _runCode with mode: $mode");

      // Validate language selection
      if (_selectedLanguage == null ||
          _selectedLanguage == "Please select a Language") {
        print("[DEBUG] No valid language selected");
        setState(() {
          testResults = [
            TestCaseResult(
              testCase: '',
              expectedResult: '',
              actualResult: '',
              passed: false,
              errorMessage: "Please select a programming language.",
            ),
          ];
        });
        return;
      }

      // Validate code input
      if (_codeController.text.trim().isEmpty) {
        print("[DEBUG] Code editor is empty");
        setState(() {
          testResults = [
            TestCaseResult(
              testCase: '',
              expectedResult: '',
              actualResult: '',
              passed: false,
              errorMessage: "Please provide some code.",
            ),
          ];
        });
        return;
      }

      // Validate question data
      print("[DEBUG] Validating question data");
      if (widget.codingQuestion['round_id'] == null ||
          widget.codingQuestion['id'] == null) {
        print("[DEBUG] Missing round_id or question_id in codingQuestion");
        setState(() {
          testResults = [
            TestCaseResult(
              testCase: '',
              expectedResult: '',
              actualResult: '',
              passed: false,
              errorMessage: "Invalid question data.",
            ),
          ];
        });
        return;
      }

      // Prepare test cases
      print("[DEBUG] Preparing test cases");
      final String code = _codeController.text.trim();
      List<Map<String, String>> testCases;

      if (customInput != null) {
        print("[DEBUG] Custom input provided");
        testCases = [
          {
            'input': customInput.trim() + '\n',
            'output': '', // Custom input doesn't have an expected output
          },
        ];
      } else if (allTestCases) {
        print("[DEBUG] Using all test cases");
        testCases = widget.codingQuestion['test_cases']
            .map<Map<String, String>>((testCase) => {
                  'input': testCase['input'].toString().trim() + '\n',
                  'output': testCase['output'].toString().trim(),
                })
            .toList();
      } else {
        print("[DEBUG] Using public test cases");
        testCases = widget.codingQuestion['test_cases']
            .where((testCase) => testCase['is_public'] == true)
            .map<Map<String, String>>((testCase) => {
                  'input': testCase['input'].toString().trim() + '\n',
                  'output': testCase['output'].toString().trim(),
                })
            .toList();
      }

      // Calculate points for the difficulty
      final points =
          _getPointsForDifficulty(widget.codingQuestion['difficulty']);

      // Add points to the request body
      final requestBody = {
        'language': _selectedLanguage!.toLowerCase(),
        'solution_code': code,
        'testcases': testCases,
        'round_id': widget.codingQuestion['round_id'],
        'question_id': widget.codingQuestion['id'],
        'question_points': points,
        'mode': mode, // "run" or "submit"
      };

      print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

      final token = await SharedPrefs.getToken();
      print("[DEBUG] Token retrieved: $token");

      final response = await http.post(
        Uri.parse(
            "http://13.201.69.118/assessments/assessment-coding-question-submit"),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(requestBody),
      );

      print("[DEBUG] Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseBody = jsonDecode(response.body);
        print("[DEBUG] Response Body: $responseBody");
        setState(() {
          testResults = responseBody['test_results']
              .map<TestCaseResult>((result) => TestCaseResult(
                    testCase: result['input'],
                    expectedResult: result['expected_output'],
                    actualResult: result['actual_output'],
                    passed: result['success'],
                    errorMessage: result['error'] ?? '',
                  ))
              .toList();
        });
        print("[DEBUG] Updated testResults: $testResults");
      } else {
        print("[DEBUG] Error Response: ${response.body}");
      }
      print("[DEBUG] Test Results: $testResults");
    } catch (error) {
      print("[DEBUG] Error in _runCode: $error");
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

  void _toggleInputFieldVisibility() {
    setState(() {
      _iscustomInputfieldVisible = !_iscustomInputfieldVisible;
    });
  }

  Widget buildOutputPanel() {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _runCode(
                      allTestCases: false,
                      mode: 'run',
                    );
                  },
                  child: Text('Run'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _runCode(
                      allTestCases: true,
                      mode: 'submit',
                    );
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
            if (testResults.isNotEmpty)
              TestCaseResultsTable(testResults: testResults),
          ],
        ),
      ),
    );
  }

  Widget buildMobileView() {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              buildQuestionPanel(),
              buildCodeEditorPanel(),
              buildOutputPanel(),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildDesktopView() {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;

          // Calculate the width of the panels based on the divider position
          final leftPanelWidth = screenWidth * _dividerPosition;
          final rightPanelWidth = screenWidth * (1 - _dividerPosition);
          return Row(
            children: [
              // Expanded(child: buildQuestionPanel()),

              Container(
                width: leftPanelWidth,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.codingQuestion['title'],
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        const Text("Description",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.codingQuestion['description'],
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 16),
                        const Text("Input Format",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.codingQuestion['input_format'],
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 16),
                        const Text("Output Format",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.codingQuestion['output_format'],
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 16),
                        const Text("Constraints",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(widget.codingQuestion['constraints'],
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List<Widget>.generate(
                            widget.codingQuestion['test_cases'].length,
                            (index) {
                              final testCase =
                                  widget.codingQuestion['test_cases'][index];
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
                        Text(widget.codingQuestion['difficulty'],
                            style: TextStyle(fontSize: 16)),
                        SizedBox(height: 16),
                        if (widget.codingQuestion['solutions'] != null &&
                            widget.codingQuestion['solutions'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              Text("Solutions",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              ...List<Widget>.generate(
                                widget.codingQuestion['solutions'].length,
                                (index) {
                                  final solution =
                                      widget.codingQuestion['solutions'][index];
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Language: ${solution['language']}",
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            "Code:",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            width: double.infinity,
                                            color: Colors.black12,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(
                                                solution['code'],
                                                style: TextStyle(
                                                    fontFamily: 'RobotoMono',
                                                    fontSize: 14),
                                              ),
                                            ),
                                          ),
                                          if (solution['youtube_link'] != null)
                                            Text(
                                              "YouTube Link: ${solution['youtube_link']}",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

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

              Expanded(child: codefieldbox()),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        // title: Text(widget.codingQuestion['title']),
        bottom: isMobile
            ? TabBar(controller: _tabController, tabs: [
                Tab(text: "Question"),
                Tab(text: "Code"),
                Tab(text: "Output")
              ])
            : null,
      ),
      body: isMobile ? buildMobileView() : buildDesktopView(),
    );
  }

  void _autoSave() {
    Timer.periodic(Duration(seconds: 10), (timer) {
      if (_codeController.text.isNotEmpty) {
        _saveCode();
      }
    });
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
                    Expanded(
                      child: Text(
                        "Input: ${result.testCase}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Output: ${result.actualResult}",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (!result.isCustomInput)
                      Expanded(
                        child: Text(
                          "Expected: ${result.expectedResult}",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    Expanded(
                      child: Text(
                        result.isCustomInput
                            ? "Custom Run"
                            : (result.passed ? "Passed" : "Failed"),
                        style: TextStyle(
                          color: result.isCustomInput
                              ? Colors.blue
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

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';
// import 'dart:ui';
// import 'dart:html' as html;
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
// import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
// import 'package:studentpanel100/utils/shared_prefs.dart';
// import 'package:studentpanel100/widgets/arrows_ui.dart';

// class CodingQuestionWidget extends StatefulWidget {
//   final Map<String, dynamic> codingQuestion;

//   const CodingQuestionWidget({Key? key, required this.codingQuestion})
//       : super(key: key);

//   @override
//   State<CodingQuestionWidget> createState() => _CodingQuestionWidgetState();
// }

// class _CodingQuestionWidgetState extends State<CodingQuestionWidget>
//     with SingleTickerProviderStateMixin {
//   late CodeController _codeController;
//   final FocusNode _focusNode = FocusNode();
//   List<TestCaseResult> testResults = [];
//   final ScrollController _rightPanelScrollController = ScrollController();
//   String? _selectedLanguage = "Please select a Language";
//   TextEditingController _customInputController = TextEditingController();
//   bool _iscustomInputfieldVisible = false;
//   double _dividerPosition = 0.5;
//   late TabController _tabController;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _initializeCodeController();

//     // Create a unique CodeController for this question
//     final initialCode = widget.codingQuestion['solution_code'] ??
//         '''
// ***************************************************
// ***************  Select a Language  ***************
// ***************************************************
// ''';

//     _codeController = CodeController(text: initialCode);

//     // Add a listener for changes in this specific CodeController
//     _codeController.addListener(() {});

//     _tabController = TabController(length: 3, vsync: this);

//     // Set default language if not already set
//     _selectedLanguage =
//         widget.codingQuestion['language'] ?? "Please select a Language";

//     // Set starter code if necessary
//     if (widget.codingQuestion['solution_code'] == null &&
//         _selectedLanguage != "Please select a Language") {
//       _setStarterCode(_selectedLanguage!);
//     }
//     Timer.periodic(const Duration(seconds: 5), (timer) {
//       if (_codeController.text.isNotEmpty && !_isLoading) {
//         _saveCode();
//       }
//     });
//     print(
//         "[DEBUG] initState initialized for question ${widget.codingQuestion['id']}");
//   }

//   @override
//   void dispose() {
//     print("[DEBUG] CodingQuestionDetailPage dispose called");

//     _tabController.dispose();
//     _codeController.dispose();
//     _focusNode.dispose();
//     _customInputController.dispose();
//     super.dispose();
//   }

//   Widget _buildEditor() {
//     if (_isLoading) {
//       return Center(child: CircularProgressIndicator());
//     }

//     return CodeField(
//       controller: _codeController,
//       textStyle: TextStyle(
//           fontFamily: 'RobotoMono', fontSize: 16, color: Colors.white),
//       background: Colors.black,
//       expands: true,
//       wrap: false,
//       lineNumberStyle: LineNumberStyle(
//         width: 40,
//         textStyle: TextStyle(color: Colors.grey),
//       ),
//     );
//   }

//   Future<void> _fetchSavedCode() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final token = await SharedPrefs.getToken();
//       final response = await http.get(
//         Uri.parse(
//             "http://13.201.69.118/assessments/fetch-code?question_id=${widget.codingQuestion['id']}&round_id=${widget.codingQuestion['round_id']}"),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           _codeController.text = data['solution_code'] ?? '';
//           _selectedLanguage = data['language'] ?? "Please select a Language";
//         });
//       } else {
//         print("[ERROR] Failed to fetch saved code: ${response.body}");
//       }
//     } catch (error) {
//       print("[ERROR] Error fetching code: $error");
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   // Future<void> _saveCode() async {
//   //   try {
//   //     final token = await SharedPrefs.getToken();
//   //     final requestBody = {
//   //       "question_id": widget.codingQuestion['id'],
//   //       "round_id": widget.codingQuestion['round_id'],
//   //       "solution_code": _codeController.text,
//   //       "language": _selectedLanguage,
//   //     };
//   //     final response = await http.post(
//   //       Uri.parse("http://13.201.69.118/assessments/save-code"),
//   //       headers: {
//   //         'Content-Type': 'application/json',
//   //         'Authorization': 'Bearer $token',
//   //       },
//   //       body: jsonEncode(requestBody),
//   //     );
//   //     if (response.statusCode == 200) {
//   //       print("[DEBUG] Code saved successfully.");
//   //     } else {
//   //       print("[ERROR] Failed to save code: ${response.body}");
//   //     }
//   //   } catch (error) {
//   //     print("[ERROR] Error saving code: $error");
//   //   }
//   // }

//   void _handleKeyPress(RawKeyEvent event) {
//     if (event.isControlPressed &&
//         event.logicalKey == LogicalKeyboardKey.slash) {
//       _commentSelectedLines();
//     }
//   }

//   void _setStarterCode(String language) {
//     String starterCode;

//     switch (language.toLowerCase()) {
//       case 'python':
//         starterCode = '# Write your Python code here';
//         break;
//       case 'java':
//         starterCode = '''
// public class Main {
//     public static void main(String[] args) {
//         // Write your Java code here
//     }
// }
// ''';
//         break;
//       case 'c':
//         starterCode = '''
// #include <stdio.h>

// int main() {
//     // Write your C code here
//     return 0;
// }
// ''';
//         break;
//       case 'cpp':
//       case 'c++':
//         starterCode = '''
// #include <iostream>
// using namespace std;

// int main() {
//     // Write your C++ code here
//     return 0;
// }
// ''';
//         break;
//       default:
//         starterCode = '// Unsupported language';
//     }

//     setState(() {
//       _codeController.text = starterCode;
//     });
//   }

//   void _commentSelectedLines() {
//     final selection = _codeController.selection;
//     final text = _codeController.text;
//     final commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

//     if (selection.isCollapsed) {
//       int lineStart = selection.start;
//       int lineEnd = selection.start;

//       while (lineStart > 0 && text[lineStart - 1] != '\n') lineStart--;
//       while (lineEnd < text.length && text[lineEnd] != '\n') lineEnd++;

//       final lineText = text.substring(lineStart, lineEnd);
//       final isCommented = lineText.trimLeft().startsWith(commentSyntax);

//       final newLineText = isCommented
//           ? lineText.replaceFirst(commentSyntax, '').trimLeft()
//           : '$commentSyntax $lineText';

//       final newText = text.replaceRange(lineStart, lineEnd, newLineText);
//       _codeController.value = _codeController.value.copyWith(
//         text: newText,
//         selection: TextSelection.collapsed(
//             offset: isCommented
//                 ? selection.start - commentSyntax.length - 1
//                 : selection.start + commentSyntax.length + 1),
//       );
//     } else {
//       final selectedText = text.substring(selection.start, selection.end);
//       final lines = selectedText.split('\n');
//       final allLinesCommented =
//           lines.every((line) => line.trimLeft().startsWith(commentSyntax));

//       final commentedLines = lines.map((line) {
//         return allLinesCommented
//             ? line.replaceFirst(commentSyntax, '').trimLeft()
//             : '$commentSyntax $line';
//       }).join('\n');

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

//   Widget buildQuestionPanel() {
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(widget.codingQuestion['title'],
//                 style:
//                     const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 16),
//             const Text("Description",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text(widget.codingQuestion['description'],
//                 style: TextStyle(fontSize: 16)),
//             const SizedBox(height: 16),
//             const Text("Input Format",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text(widget.codingQuestion['input_format'],
//                 style: TextStyle(fontSize: 16)),
//             SizedBox(height: 16),
//             const Text("Output Format",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text(widget.codingQuestion['output_format'],
//                 style: TextStyle(fontSize: 16)),
//             SizedBox(height: 16),
//             const Text("Constraints",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             Text(widget.codingQuestion['constraints'],
//                 style: TextStyle(fontSize: 16)),
//             SizedBox(height: 8),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: List<Widget>.generate(
//                 widget.codingQuestion['test_cases'].length,
//                 (index) {
//                   final testCase = widget.codingQuestion['test_cases'][index];
//                   return Card(
//                     margin: EdgeInsets.symmetric(vertical: 8),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text("Input: ${testCase['input']}",
//                               style: TextStyle(fontSize: 16)),
//                           Text("Output: ${testCase['output']}",
//                               style: TextStyle(fontSize: 16)),
//                           if (testCase['is_public'])
//                             Text(
//                                 "Explanation: ${testCase['explanation'] ?? ''}",
//                                 style: TextStyle(fontSize: 16)),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             SizedBox(height: 16),
//             Text("Difficulty",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             SizedBox(height: 8),
//             Text(widget.codingQuestion['difficulty'],
//                 style: TextStyle(fontSize: 16)),
//             SizedBox(height: 16),
//             Text("Hello"),
//             if (widget.codingQuestion['solutions'] != null &&
//                 widget.codingQuestion['solutions'].isNotEmpty)
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(height: 16),
//                   Text("Solutions",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   ...List<Widget>.generate(
//                     widget.codingQuestion['solutions'].length,
//                     (index) {
//                       final solution =
//                           widget.codingQuestion['solutions'][index];
//                       return Card(
//                         margin: EdgeInsets.symmetric(vertical: 8),
//                         child: Padding(
//                           padding: const EdgeInsets.all(12.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 "Language: ${solution['language']}",
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                               Text(
//                                 "Code:",
//                                 style: TextStyle(
//                                     fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                               Container(
//                                 width: double.infinity,
//                                 color: Colors.black12,
//                                 child: Padding(
//                                   padding: EdgeInsets.all(8.0),
//                                   child: Text(
//                                     solution['code'],
//                                     style: TextStyle(
//                                         fontFamily: 'RobotoMono', fontSize: 14),
//                                   ),
//                                 ),
//                               ),
//                               if (solution['youtube_link'] != null)
//                                 Text(
//                                   "YouTube Link: ${solution['youtube_link']}",
//                                   style: TextStyle(fontSize: 16),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget codefieldbox() {
//     return Expanded(
//       child: Container(
//         // width: rightPanelWidth,
//         height: MediaQuery.of(context).size.height * 2,
//         color: Colors.white,
//         child: SingleChildScrollView(
//           controller: _rightPanelScrollController,
//           child: Padding(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Text("Select Language",
//                     style:
//                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 // DropdownButton<String>(
//                 //   value: _selectedLanguage,
//                 //   onChanged: (String? newValue) {
//                 //     if (newValue != null &&
//                 //         newValue != "Please select a Language") {
//                 //       if (_selectedLanguage != "Please select a Language") {
//                 //         // Show alert if a language was previously selected
//                 //         showDialog(
//                 //           context: context,
//                 //           builder: (BuildContext context) {
//                 //             return AlertDialog(
//                 //               title: Text("Change Language"),
//                 //               content: Text(
//                 //                   "Changing the language will remove the current code. Do you want to proceed?"),
//                 //               actions: [
//                 //                 TextButton(
//                 //                   child: Text("Cancel"),
//                 //                   onPressed: () {
//                 //                     Navigator.of(context)
//                 //                         .pop(); // Close the dialog
//                 //                   },
//                 //                 ),
//                 //                 TextButton(
//                 //                   child: Text("Proceed"),
//                 //                   onPressed: () {
//                 //                     // Proceed with changing the language and setting starter code
//                 //                     setState(() {
//                 //                       _selectedLanguage = newValue;
//                 //                       _setStarterCode(newValue);
//                 //                     });
//                 //                     Navigator.of(context)
//                 //                         .pop(); // Close the dialog
//                 //                   },
//                 //                 ),
//                 //               ],
//                 //             );
//                 //           },
//                 //         );
//                 //       } else {
//                 //         // Directly set language and starter code if no language was selected previously
//                 //         setState(() {
//                 //           _selectedLanguage = newValue;
//                 //           _setStarterCode(newValue);
//                 //         });
//                 //       }
//                 //     }
//                 //   },
//                 //   items: [
//                 //     DropdownMenuItem<String>(
//                 //       value: "Please select a Language",
//                 //       child: Text("Please select a Language"),
//                 //     ),
//                 //     ...widget.question['allowed_languages']
//                 //         .cast<String>()
//                 //         .map<DropdownMenuItem<String>>((String language) {
//                 //       return DropdownMenuItem<String>(
//                 //         value: language,
//                 //         child: Text(language),
//                 //       );
//                 //     }).toList(),
//                 //   ],
//                 // ),

//                 // DropdownButton<String>(
//                 //   value: _selectedLanguage,
//                 //   onChanged: (String? newValue) {
//                 //     if (newValue != null &&
//                 //         newValue != "Please select a Language") {
//                 //       if (_selectedLanguage != "Please select a Language") {
//                 //         // Show alert if a language was previously selected
//                 //         showDialog(
//                 //           context: context,
//                 //           builder: (BuildContext context) {
//                 //             return AlertDialog(
//                 //               title: Text("Change Language"),
//                 //               content: Text(
//                 //                   "Changing the language will remove the current code. Do you want to proceed?"),
//                 //               actions: [
//                 //                 TextButton(
//                 //                   child: Text("Cancel"),
//                 //                   onPressed: () {
//                 //                     Navigator.of(context)
//                 //                         .pop(); // Close the dialog
//                 //                   },
//                 //                 ),
//                 //                 TextButton(
//                 //                   child: Text("Proceed"),
//                 //                   onPressed: () {
//                 //                     // Proceed with changing the language and setting starter code
//                 //                     setState(() {
//                 //                       _selectedLanguage = newValue;
//                 //                       _setStarterCode(newValue);
//                 //                     });
//                 //                     Navigator.of(context)
//                 //                         .pop(); // Close the dialog
//                 //                   },
//                 //                 ),
//                 //               ],
//                 //             );
//                 //           },
//                 //         );
//                 //       } else {
//                 //         // Directly set language and starter code if no language was selected previously
//                 //         setState(() {
//                 //           _selectedLanguage = newValue;
//                 //           _setStarterCode(newValue);
//                 //         });
//                 //       }
//                 //     }
//                 //   },
//                 //   items: [
//                 //     DropdownMenuItem<String>(
//                 //       value: "Please select a Language",
//                 //       child: Text("Please select a Language"),
//                 //     ),
//                 //     ...widget.codingQuestion['allowed_languages']
//                 //         .cast<String>()
//                 //         .map<DropdownMenuItem<String>>((String language) {
//                 //       return DropdownMenuItem<String>(
//                 //         value: language,
//                 //         child: Text(language),
//                 //       );
//                 //     }).toList(),
//                 //   ],
//                 // ),

//                 // DropdownButton<String>(
//                 //   value: _selectedLanguage,
//                 //   onChanged: (String? newValue) {
//                 //     if (newValue != null &&
//                 //         newValue != "Please select a Language") {
//                 //       if (_selectedLanguage != "Please select a Language") {
//                 //         // Show confirmation dialog if a language was previously selected
//                 //         showDialog(
//                 //           context: context,
//                 //           builder: (BuildContext context) {
//                 //             return AlertDialog(
//                 //               title: Text("Change Language"),
//                 //               content: Text(
//                 //                 "Changing the language will remove the current code. Do you want to proceed?",
//                 //               ),
//                 //               actions: [
//                 //                 TextButton(
//                 //                   child: Text("Cancel"),
//                 //                   onPressed: () {
//                 //                     Navigator.of(context)
//                 //                         .pop(); // Close the dialog
//                 //                   },
//                 //                 ),
//                 //                 TextButton(
//                 //                   child: Text("Proceed"),
//                 //                   onPressed: () {
//                 //                     // Change language and set starter code
//                 //                     setState(() {
//                 //                       _selectedLanguage = newValue;
//                 //                       _setStarterCode(
//                 //                           newValue); // Function to set starter code
//                 //                     });
//                 //                     Navigator.of(context)
//                 //                         .pop(); // Close the dialog
//                 //                   },
//                 //                 ),
//                 //               ],
//                 //             );
//                 //           },
//                 //         );
//                 //       } else {
//                 //         // Directly set the language if none was selected previously
//                 //         setState(() {
//                 //           _selectedLanguage = newValue;
//                 //           _setStarterCode(
//                 //               newValue); // Function to set starter code
//                 //         });
//                 //       }
//                 //     }
//                 //   },
//                 //   items: [
//                 //     DropdownMenuItem<String>(
//                 //       value: "Please select a Language",
//                 //       child: Text("Please select a Language"),
//                 //     ),
//                 //     // Dynamically generate dropdown items based on allowed_languages
//                 //     ...?widget.codingQuestion['allowed_languages']
//                 //         ?.cast<String>()
//                 //         ?.map<DropdownMenuItem<String>>((String language) {
//                 //       return DropdownMenuItem<String>(
//                 //         value: language,
//                 //         child: Text(language),
//                 //       );
//                 //     }).toList(),
//                 //   ],
//                 // ),

//                 DropdownButton<String>(
//                   value: _selectedLanguage,
//                   onChanged: (String? newValue) {
//                     if (newValue != null &&
//                         newValue != "Please select a Language") {
//                       if (_selectedLanguage != "Please select a Language") {
//                         // Show confirmation dialog if a language was previously selected
//                         showDialog(
//                           context: context,
//                           builder: (BuildContext context) {
//                             return AlertDialog(
//                               title: Text("Change Language"),
//                               content: Text(
//                                 "Changing the language will remove the current code. Do you want to proceed?",
//                               ),
//                               actions: [
//                                 TextButton(
//                                   child: Text("Cancel"),
//                                   onPressed: () {
//                                     Navigator.of(context)
//                                         .pop(); // Close the dialog
//                                   },
//                                 ),
//                                 TextButton(
//                                   child: Text("Proceed"),
//                                   onPressed: () {
//                                     // Change language and set starter code
//                                     setState(() {
//                                       _selectedLanguage = newValue;
//                                       _setStarterCode(
//                                           newValue); // Function to set starter code
//                                     });
//                                     Navigator.of(context)
//                                         .pop(); // Close the dialog
//                                   },
//                                 ),
//                               ],
//                             );
//                           },
//                         );
//                       } else {
//                         // Directly set the language if none was selected previously
//                         setState(() {
//                           _selectedLanguage = newValue;
//                           _setStarterCode(
//                               newValue); // Function to set starter code
//                         });
//                       }
//                     }
//                   },
//                   items: [
//                     DropdownMenuItem<String>(
//                       value: "Please select a Language",
//                       child: Text("Please select a Language"),
//                     ),
//                     // Dynamically generate dropdown items based on allowed_languages
//                     ...?widget.codingQuestion['allowed_languages']
//                         ?.cast<String>()
//                         ?.toSet() // Ensure uniqueness of items
//                         ?.map<DropdownMenuItem<String>>((String language) {
//                       return DropdownMenuItem<String>(
//                         value: language
//                             .toLowerCase(), // Normalize the language value
//                         child: Text(language),
//                       );
//                     }).toList(),
//                   ],
//                 ),

//                 Focus(
//                   focusNode: _focusNode, // Attach the focus node to Focus only
//                   onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
//                     if (keyEvent is KeyDownEvent) {
//                       final keysPressed =
//                           HardwareKeyboard.instance.logicalKeysPressed;

//                       // Check for Ctrl + / shortcut
//                       if (keysPressed
//                               .contains(LogicalKeyboardKey.controlLeft) &&
//                           keysPressed.contains(LogicalKeyboardKey.slash)) {
//                         _commentSelectedLines();
//                         return KeyEventResult.handled;
//                       }
//                     }
//                     return KeyEventResult.ignored;
//                   },
//                   child: Container(
//                     // height: 200,
//                     height: MediaQuery.of(context).size.height / 1.7,
//                     child: CodeField(
//                       controller: _codeController,
//                       focusNode: FocusNode(),
//                       textStyle: TextStyle(
//                         fontFamily: 'RobotoMono',
//                         fontSize: 16,
//                         color: Colors.white,
//                       ),
//                       cursorColor: Colors.white,
//                       background: Colors.black,
//                       expands: true,
//                       wrap: false,
//                       lineNumberStyle: LineNumberStyle(
//                         width: 40,
//                         margin: 8,
//                         textStyle: TextStyle(
//                           color: Colors.grey.shade600,
//                           fontSize: 16,
//                         ),
//                         background: Colors.grey.shade900,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     ElevatedButton(
//                       onPressed: () {
//                         _runCode(
//                           allTestCases: false,
//                           mode: 'run',
//                         );
//                       },
//                       child: Text('Run'),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         _runCode(
//                           allTestCases: true,
//                           mode: 'submit',
//                         );
//                       },
//                       child: Text('Submit'),
//                     ),
//                     ElevatedButton(
//                       onPressed: _toggleInputFieldVisibility,
//                       child: Text('Custom Input'),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16),
//                 AnimatedCrossFade(
//                   duration: Duration(milliseconds: 300),
//                   firstChild: SizedBox.shrink(),
//                   secondChild: Column(
//                     children: [
//                       Container(
//                         // height: 250,
//                         width: MediaQuery.of(context).size.width * 0.25,
//                         child: TextField(
//                           minLines: 5,
//                           maxLines: 5,
//                           controller: _customInputController,
//                           decoration: InputDecoration(
//                             hintText: "Enter custom input",
//                             hintStyle: TextStyle(color: Colors.white54),
//                             filled: true,
//                             fillColor: Colors.black,
//                             border: OutlineInputBorder(),
//                           ),
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ),
//                       SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: () {
//                           _runCode(
//                             allTestCases: false,
//                             customInput: _customInputController.text,
//                             mode: 'run',
//                           );
//                         },
//                         child: Text('Run Custom Input'),
//                       ),
//                     ],
//                   ),
//                   crossFadeState: _iscustomInputfieldVisible
//                       ? CrossFadeState.showSecond
//                       : CrossFadeState.showFirst,
//                 ),
//                 SizedBox(height: 16),
//                 if (testResults.isNotEmpty)
//                   TestCaseResultsTable(testResults: testResults),
//               ],
//             ),
//           ),
//         ),
//       ),
//       // );
//       // },
//     );
//   }

//   Widget buildCodeEditorPanel() {
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         children: [
//           Text("Select Language",
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           // DropdownButton<String>(
//           //   value: _selectedLanguage,
//           //   onChanged: (String? newValue) {
//           //     if (newValue != null && newValue != "Please select a Language") {
//           //       if (_selectedLanguage != "Please select a Language") {
//           //         // Show alert if a language was previously selected
//           //         showDialog(
//           //           context: context,
//           //           builder: (BuildContext context) {
//           //             return AlertDialog(
//           //               title: Text("Change Language"),
//           //               content: Text(
//           //                   "Changing the language will remove the current code. Do you want to proceed?"),
//           //               actions: [
//           //                 TextButton(
//           //                   child: Text("Cancel"),
//           //                   onPressed: () {
//           //                     Navigator.of(context).pop(); // Close the dialog
//           //                   },
//           //                 ),
//           //                 TextButton(
//           //                   child: Text("Proceed"),
//           //                   onPressed: () {
//           //                     // Proceed with changing the language and setting starter code
//           //                     setState(() {
//           //                       _selectedLanguage = newValue;
//           //                       _setStarterCode(newValue);
//           //                     });
//           //                     Navigator.of(context).pop(); // Close the dialog
//           //                   },
//           //                 ),
//           //               ],
//           //             );
//           //           },
//           //         );
//           //       } else {
//           //         // Directly set language and starter code if no language was selected previously
//           //         setState(() {
//           //           _selectedLanguage = newValue;
//           //           _setStarterCode(newValue);
//           //         });
//           //       }
//           //     }
//           //   },
//           //   items: [
//           //     DropdownMenuItem<String>(
//           //       value: "Please select a Language",
//           //       child: Text("Please select a Language"),
//           //     ),
//           //     ...widget.question['allowed_languages']
//           //         .cast<String>()
//           //         .map<DropdownMenuItem<String>>((String language) {
//           //       return DropdownMenuItem<String>(
//           //         value: language,
//           //         child: Text(language),
//           //       );
//           //     }).toList(),
//           //   ],
//           // ),

//           // DropdownButton<String>(
//           //   value: _selectedLanguage,
//           //   onChanged: (String? newValue) {
//           //     if (newValue != null && newValue != "Please select a Language") {
//           //       if (_selectedLanguage != "Please select a Language") {
//           //         // Show alert if a language was previously selected
//           //         showDialog(
//           //           context: context,
//           //           builder: (BuildContext context) {
//           //             return AlertDialog(
//           //               title: Text("Change Language"),
//           //               content: Text(
//           //                   "Changing the language will remove the current code. Do you want to proceed?"),
//           //               actions: [
//           //                 TextButton(
//           //                   child: Text("Cancel"),
//           //                   onPressed: () {
//           //                     Navigator.of(context).pop(); // Close the dialog
//           //                   },
//           //                 ),
//           //                 TextButton(
//           //                   child: Text("Proceed"),
//           //                   onPressed: () {
//           //                     // Proceed with changing the language and setting starter code
//           //                     setState(() {
//           //                       _selectedLanguage = newValue;
//           //                       _setStarterCode(newValue);
//           //                     });
//           //                     Navigator.of(context).pop(); // Close the dialog
//           //                   },
//           //                 ),
//           //               ],
//           //             );
//           //           },
//           //         );
//           //       } else {
//           //         // Directly set language and starter code if no language was selected previously
//           //         setState(() {
//           //           _selectedLanguage = newValue;
//           //           _setStarterCode(newValue);
//           //         });
//           //       }
//           //     }
//           //   },
//           //   items: [
//           //     DropdownMenuItem<String>(
//           //       value: "Please select a Language",
//           //       child: Text("Please select a Language"),
//           //     ),
//           //     ...widget.codingQuestion['allowed_languages']
//           //         .cast<String>()
//           //         .map<DropdownMenuItem<String>>((String language) {
//           //       return DropdownMenuItem<String>(
//           //         value: language,
//           //         child: Text(language),
//           //       );
//           //     }).toList(),
//           //   ],
//           // ),

//           DropdownButton<String>(
//             value: _selectedLanguage,
//             onChanged: (String? newValue) {
//               if (newValue != null && newValue != "Please select a Language") {
//                 if (_selectedLanguage != "Please select a Language") {
//                   // Show confirmation dialog if a language was previously selected
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text("Change Language"),
//                         content: Text(
//                           "Changing the language will remove the current code. Do you want to proceed?",
//                         ),
//                         actions: [
//                           TextButton(
//                             child: Text("Cancel"),
//                             onPressed: () {
//                               Navigator.of(context).pop(); // Close the dialog
//                             },
//                           ),
//                           TextButton(
//                             child: Text("Proceed"),
//                             onPressed: () {
//                               // Change language and set starter code
//                               setState(() {
//                                 _selectedLanguage = newValue;
//                                 _setStarterCode(
//                                     newValue); // Function to set starter code
//                               });
//                               Navigator.of(context).pop(); // Close the dialog
//                             },
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 } else {
//                   // Directly set the language if none was selected previously
//                   setState(() {
//                     _selectedLanguage = newValue;
//                     _setStarterCode(newValue); // Function to set starter code
//                   });
//                 }
//               }
//             },
//             items: [
//               DropdownMenuItem<String>(
//                 value: "Please select a Language",
//                 child: Text("Please select a Language"),
//               ),
//               // Dynamically generate dropdown items based on allowed_languages
//               ...?widget.codingQuestion['allowed_languages']
//                   ?.cast<String>()
//                   ?.toSet() // Ensure uniqueness of items
//                   ?.map<DropdownMenuItem<String>>((String language) {
//                 return DropdownMenuItem<String>(
//                   value: language.toLowerCase(), // Normalize the language value
//                   child: Text(language),
//                 );
//               }).toList(),
//             ],
//           ),

//           Expanded(
//             child: Focus(
//               focusNode: _focusNode, // Attach the focus node to Focus only
//               onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
//                 if (keyEvent is KeyDownEvent) {
//                   final keysPressed =
//                       HardwareKeyboard.instance.logicalKeysPressed;
//                   // Check for Ctrl + / shortcut
//                   if (keysPressed.contains(LogicalKeyboardKey.controlLeft) &&
//                       keysPressed.contains(LogicalKeyboardKey.slash)) {
//                     _commentSelectedLines();
//                     return KeyEventResult.handled;
//                   }
//                 }
//                 return KeyEventResult.ignored;
//               },
//               child: Container(
//                 // height: 200,
//                 height: MediaQuery.of(context).size.height / 3.5,
//                 child: CodeField(
//                   controller: _codeController,
//                   focusNode: FocusNode(),
//                   textStyle: TextStyle(
//                     fontFamily: 'RobotoMono',
//                     fontSize: 16,
//                     color: Colors.white,
//                   ),
//                   cursorColor: Colors.white,
//                   background: Colors.black,
//                   expands: true,
//                   wrap: false,
//                   lineNumberStyle: LineNumberStyle(
//                     width: 40,
//                     margin: 8,
//                     textStyle: TextStyle(
//                       color: Colors.grey.shade600,
//                       fontSize: 16,
//                     ),
//                     background: Colors.grey.shade900,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   int _getPointsForDifficulty(String difficulty) {
//     final difficultyMapping = {
//       'Level1': 100,
//       'Level2': 200,
//       'Level3': 300,
//       'Level4': 400,
//       'Level5': 500,
//     };
//     return difficultyMapping[difficulty] ??
//         0; // Default to 0 if difficulty is unknown
//   }

//   Future<void> _runCode({
//     required bool allTestCases,
//     String? customInput,
//     required String mode, // "run" or "submit"
//   }) async {
//     try {
//       print("[DEBUG] Starting _runCode with mode: $mode");

//       // Validate language selection
//       if (_selectedLanguage == null ||
//           _selectedLanguage == "Please select a Language") {
//         print("[DEBUG] No valid language selected");
//         setState(() {
//           testResults = [
//             TestCaseResult(
//               testCase: '',
//               expectedResult: '',
//               actualResult: '',
//               passed: false,
//               errorMessage: "Please select a programming language.",
//             ),
//           ];
//         });
//         return;
//       }

//       // Validate code input
//       if (_codeController.text.trim().isEmpty) {
//         print("[DEBUG] Code editor is empty");
//         setState(() {
//           testResults = [
//             TestCaseResult(
//               testCase: '',
//               expectedResult: '',
//               actualResult: '',
//               passed: false,
//               errorMessage: "Please provide some code.",
//             ),
//           ];
//         });
//         return;
//       }

//       // Validate question data
//       print("[DEBUG] Validating question data");
//       if (widget.codingQuestion['round_id'] == null ||
//           widget.codingQuestion['id'] == null) {
//         print("[DEBUG] Missing round_id or question_id in codingQuestion");
//         setState(() {
//           testResults = [
//             TestCaseResult(
//               testCase: '',
//               expectedResult: '',
//               actualResult: '',
//               passed: false,
//               errorMessage: "Invalid question data.",
//             ),
//           ];
//         });
//         return;
//       }

//       // Prepare test cases
//       print("[DEBUG] Preparing test cases");
//       final String code = _codeController.text.trim();
//       List<Map<String, String>> testCases;

//       if (customInput != null) {
//         print("[DEBUG] Custom input provided");
//         testCases = [
//           {
//             'input': customInput.trim() + '\n',
//             'output': '', // Custom input doesn't have an expected output
//           },
//         ];
//       } else if (allTestCases) {
//         print("[DEBUG] Using all test cases");
//         testCases = widget.codingQuestion['test_cases']
//             .map<Map<String, String>>((testCase) => {
//                   'input': testCase['input'].toString().trim() + '\n',
//                   'output': testCase['output'].toString().trim(),
//                 })
//             .toList();
//       } else {
//         print("[DEBUG] Using public test cases");
//         testCases = widget.codingQuestion['test_cases']
//             .where((testCase) => testCase['is_public'] == true)
//             .map<Map<String, String>>((testCase) => {
//                   'input': testCase['input'].toString().trim() + '\n',
//                   'output': testCase['output'].toString().trim(),
//                 })
//             .toList();
//       }

//       // Calculate points for the difficulty
//       final points =
//           _getPointsForDifficulty(widget.codingQuestion['difficulty']);

//       // Add points to the request body
//       final requestBody = {
//         'language': _selectedLanguage!.toLowerCase(),
//         'solution_code': code,
//         'testcases': testCases,
//         'round_id': widget.codingQuestion['round_id'],
//         'question_id': widget.codingQuestion['id'],
//         'question_points': points,
//         'mode': mode, // "run" or "submit"
//       };

//       print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

//       final token = await SharedPrefs.getToken();
//       print("[DEBUG] Token retrieved: $token");

//       final response = await http.post(
//         Uri.parse(
//             "http://13.201.69.118/assessments/assessment-coding-question-submit"),
//         headers: {
//           'Content-Type': 'application/json',
//           "Authorization": "Bearer $token",
//         },
//         body: jsonEncode(requestBody),
//       );

//       print("[DEBUG] Response Status Code: ${response.statusCode}");

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseBody = jsonDecode(response.body);
//         print("[DEBUG] Response Body: $responseBody");
//         setState(() {
//           testResults = responseBody['test_results']
//               .map<TestCaseResult>((result) => TestCaseResult(
//                     testCase: result['input'],
//                     expectedResult: result['expected_output'],
//                     actualResult: result['actual_output'],
//                     passed: result['success'],
//                     errorMessage: result['error'] ?? '',
//                   ))
//               .toList();
//         });
//         print("[DEBUG] Updated testResults: $testResults");
//       } else {
//         print("[DEBUG] Error Response: ${response.body}");
//       }
//       print("[DEBUG] Test Results: $testResults");
//     } catch (error) {
//       print("[DEBUG] Error in _runCode: $error");
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

//   void _toggleInputFieldVisibility() {
//     setState(() {
//       _iscustomInputfieldVisible = !_iscustomInputfieldVisible;
//     });
//   }

//   Widget buildOutputPanel() {
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     _runCode(
//                       allTestCases: false,
//                       mode: 'run',
//                     );
//                   },
//                   child: Text('Run'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     _runCode(
//                       allTestCases: true,
//                       mode: 'submit',
//                     );
//                   },
//                   child: Text('Submit'),
//                 ),
//                 ElevatedButton(
//                   onPressed: _toggleInputFieldVisibility,
//                   child: Text('Custom Input'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 16),
//             if (testResults.isNotEmpty)
//               TestCaseResultsTable(testResults: testResults),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildMobileView() {
//     return Column(
//       children: [
//         Expanded(
//           child: TabBarView(
//             controller: _tabController,
//             children: [
//               buildQuestionPanel(),
//               buildCodeEditorPanel(),
//               buildOutputPanel(),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildDesktopView() {
//     return Scaffold(
//       body: LayoutBuilder(
//         builder: (context, constraints) {
//           final screenWidth = constraints.maxWidth;

//           // Calculate the width of the panels based on the divider position
//           final leftPanelWidth = screenWidth * _dividerPosition;
//           final rightPanelWidth = screenWidth * (1 - _dividerPosition);
//           return Row(
//             children: [
//               // Expanded(child: buildQuestionPanel()),

//               Container(
//                 width: leftPanelWidth,
//                 child: Padding(
//                   padding: EdgeInsets.all(16.0),
//                   child: SingleChildScrollView(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(widget.codingQuestion['title'],
//                             style: const TextStyle(
//                                 fontSize: 24, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 16),
//                         const Text("Description",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text(widget.codingQuestion['description'],
//                             style: TextStyle(fontSize: 16)),
//                         const SizedBox(height: 16),
//                         const Text("Input Format",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text(widget.codingQuestion['input_format'],
//                             style: TextStyle(fontSize: 16)),
//                         SizedBox(height: 16),
//                         const Text("Output Format",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text(widget.codingQuestion['output_format'],
//                             style: TextStyle(fontSize: 16)),
//                         SizedBox(height: 16),
//                         const Text("Constraints",
//                             style: TextStyle(
//                                 fontSize: 18, fontWeight: FontWeight.bold)),
//                         Text(widget.codingQuestion['constraints'],
//                             style: TextStyle(fontSize: 16)),
//                         SizedBox(height: 8),
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: List<Widget>.generate(
//                             widget.codingQuestion['test_cases'].length,
//                             (index) {
//                               final testCase =
//                                   widget.codingQuestion['test_cases'][index];
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
//                         Text(widget.codingQuestion['difficulty'],
//                             style: TextStyle(fontSize: 16)),
//                         SizedBox(height: 16),
//                         if (widget.codingQuestion['solutions'] != null &&
//                             widget.codingQuestion['solutions'].isNotEmpty)
//                           Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               SizedBox(height: 16),
//                               Text("Solutions",
//                                   style: TextStyle(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold)),
//                               ...List<Widget>.generate(
//                                 widget.codingQuestion['solutions'].length,
//                                 (index) {
//                                   final solution =
//                                       widget.codingQuestion['solutions'][index];
//                                   return Card(
//                                     margin: EdgeInsets.symmetric(vertical: 8),
//                                     child: Padding(
//                                       padding: const EdgeInsets.all(12.0),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             "Language: ${solution['language']}",
//                                             style: TextStyle(fontSize: 16),
//                                           ),
//                                           Text(
//                                             "Code:",
//                                             style: TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.bold),
//                                           ),
//                                           Container(
//                                             width: double.infinity,
//                                             color: Colors.black12,
//                                             child: Padding(
//                                               padding: EdgeInsets.all(8.0),
//                                               child: Text(
//                                                 solution['code'],
//                                                 style: TextStyle(
//                                                     fontFamily: 'RobotoMono',
//                                                     fontSize: 14),
//                                               ),
//                                             ),
//                                           ),
//                                           if (solution['youtube_link'] != null)
//                                             Text(
//                                               "YouTube Link: ${solution['youtube_link']}",
//                                               style: TextStyle(fontSize: 16),
//                                             ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ],
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),

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

//               Expanded(child: codefieldbox()),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // Future<void> _saveCode() async {
//   //   try {
//   //     final token = await SharedPrefs.getToken();
//   //     final requestBody = {
//   //       "question_id": widget.codingQuestion['id'],
//   //       "round_id": widget.codingQuestion['round_id'],
//   //       "solution_code": _codeController.text,
//   //       "language": _selectedLanguage,
//   //     };
//   //     final response = await http.post(
//   //       Uri.parse("http://13.201.69.118/assessments/save-code"),
//   //       headers: {
//   //         'Content-Type': 'application/json',
//   //         'Authorization': 'Bearer $token',
//   //       },
//   //       body: jsonEncode(requestBody),
//   //     );
//   //     if (response.statusCode == 200) {
//   //       print("[DEBUG] Code saved successfully.");
//   //     } else {
//   //       print("[ERROR] Failed to save code: ${response.body}");
//   //     }
//   //   } catch (error) {
//   //     print("[ERROR] Error saving code: $error");
//   //   }
//   // }

//   Future<void> _saveCode() async {
//     final token = await SharedPrefs.getToken();
//     final requestBody = {
//       "question_id": widget.codingQuestion['id'],
//       "round_id": widget.codingQuestion['round_id'],
//       "solution_code": _codeController.text,
//       "language": _selectedLanguage,
//     };

//     try {
//       final response = await http.post(
//         Uri.parse("http://13.201.69.118/assessments/save-code"),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: jsonEncode(requestBody),
//       );

//       if (response.statusCode == 200) {
//         print("[DEBUG] Code saved successfully.");
//       } else {
//         print("[ERROR] Failed to save code: ${response.body}");
//       }
//     } catch (error) {
//       print("[ERROR] Error saving code: $error");
//     }
//   }

//   String _getStarterCode(String language) {
//     switch (language.toLowerCase()) {
//       case 'python':
//         return '# Write your Python code here';
//       case 'java':
//         return '''
// public class Main {
//     public static void main(String[] args) {
//         // Write your Java code here
//     }
// }
// ''';
//       case 'c':
//         return '''
// #include <stdio.h>

// int main() {
//     // Write your C code here
//     return 0;
// }
// ''';
//       case 'cpp':
//       case 'c++':
//         return '''
// #include <iostream>
// using namespace std;

// int main() {
//     // Write your C++ code here
//     return 0;
// }
// ''';
//       default:
//         return '// Unsupported language';
//     }
//   }

//   Future<void> _initializeCodeController() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final token = await SharedPrefs.getToken();
//       final response = await http.get(
//         Uri.parse(
//             "http://13.201.69.118/assessments/fetch-code?question_id=${widget.codingQuestion['id']}&round_id=${widget.codingQuestion['round_id']}"),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         String fetchedCode = data['solution_code'] ?? '';
//         String fetchedLanguage = data['language'] ?? "Please select a Language";

//         setState(() {
//           _selectedLanguage = fetchedLanguage;
//           _codeController = CodeController(
//             text: fetchedCode.isNotEmpty
//                 ? fetchedCode
//                 : _getStarterCode(fetchedLanguage),
//           );
//         });
//       } else {
//         String defaultLanguage =
//             widget.codingQuestion['allowed_languages']?.first ??
//                 "Please select a Language";
//         setState(() {
//           _selectedLanguage = defaultLanguage;
//           _codeController = CodeController(
//             text: _getStarterCode(defaultLanguage),
//           );
//         });
//       }
//     } catch (error) {
//       print("[ERROR] Error initializing CodeController: $error");
//       setState(() {
//         _codeController = CodeController(text: '// Error loading code');
//       });
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isMobile = MediaQuery.of(context).size.width < 600;

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         // title: Text(widget.codingQuestion['title']),
//         bottom: isMobile
//             ? TabBar(controller: _tabController, tabs: [
//                 Tab(text: "Question"),
//                 Tab(text: "Code"),
//                 Tab(text: "Output")
//               ])
//             : null,
//       ),
//       body: isMobile ? buildMobileView() : buildDesktopView(),
//     );
//   }

//   void _autoSave() {
//     Timer.periodic(Duration(seconds: 10), (timer) {
//       if (_codeController.text.isNotEmpty) {
//         _saveCode();
//       }
//     });
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
//                     Expanded(
//                       child: Text(
//                         "Input: ${result.testCase}",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     Expanded(
//                       child: Text(
//                         "Output: ${result.actualResult}",
//                         style: TextStyle(fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     if (!result.isCustomInput)
//                       Expanded(
//                         child: Text(
//                           "Expected: ${result.expectedResult}",
//                           style: TextStyle(color: Colors.grey),
//                         ),
//                       ),
//                     Expanded(
//                       child: Text(
//                         result.isCustomInput
//                             ? "Custom Run"
//                             : (result.passed ? "Passed" : "Failed"),
//                         style: TextStyle(
//                           color: result.isCustomInput
//                               ? Colors.blue
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
