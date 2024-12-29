import 'dart:async';
import 'dart:ui';
// import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
import 'package:http/http.dart' as http;
import 'package:studentpanel100/utils/shared_prefs.dart';
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

class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage>
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

//   @override
//   void initState() {
//     super.initState();
//     print("[DEBUG] CodingQuestionDetailPage initState called");
//     _tabController = TabController(length: 3, vsync: this);
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

  @override
  void initState() {
    super.initState();
    print("[DEBUG] CodingQuestionDetailPage initState called");
    _tabController = TabController(length: 3, vsync: this);

    // Initialize the code editor with fetched solution code or default text
    final initialCode = widget.question['solution_code'] ??
        '''
***************************************************
***************  Select a Language  ***************
***************************************************
''';
    _codeController = CodeController(text: initialCode);

    // Set the default selected language
    _selectedLanguage = widget.question['language'] ??
        "Please select a Language"; // Fallback to default text if no language is set

    // Set starter code for the selected language if solution_code is null
    if (widget.question['solution_code'] == null &&
        _selectedLanguage != "Please select a Language") {
      _setStarterCode(_selectedLanguage!);
    }

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
    print("[DEBUG] CodingQuestionDetailPage dispose called");

    _tabController.dispose();
    _codeController.dispose();
    _focusNode.dispose();
    _customInputController.dispose();
    super.dispose();
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
            Text(widget.question['title'],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Description",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.question['description'],
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            const Text("Input Format",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.question['input_format'],
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            const Text("Output Format",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.question['output_format'],
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            const Text("Constraints",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(widget.question['constraints'],
                style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List<Widget>.generate(
                widget.question['test_cases'].length,
                (index) {
                  final testCase = widget.question['test_cases'][index];
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
            Text(widget.question['difficulty'], style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text("Hello"),
            if (widget.question['solutions'] != null &&
                widget.question['solutions'].isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text("Solutions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ...List<Widget>.generate(
                    widget.question['solutions'].length,
                    (index) {
                      final solution = widget.question['solutions'][index];
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

                DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: (String? newValue) {
                    if (newValue != null &&
                        newValue != "Please select a Language") {
                      if (_selectedLanguage != "Please select a Language") {
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
                        .map<DropdownMenuItem<String>>((String language) {
                      return DropdownMenuItem<String>(
                        value: language,
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

          DropdownButton<String>(
            value: _selectedLanguage,
            onChanged: (String? newValue) {
              if (newValue != null && newValue != "Please select a Language") {
                if (_selectedLanguage != "Please select a Language") {
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
                              Navigator.of(context).pop(); // Close the dialog
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
                              Navigator.of(context).pop(); // Close the dialog
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
                  .map<DropdownMenuItem<String>>((String language) {
                return DropdownMenuItem<String>(
                  value: language,
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
    required String mode, // Add mode parameter to differentiate actions
  }) async {
    try {
      // Ensure a language is selected and code is provided
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

      // Determine the endpoint URL based on the selected language
      Uri endpoint;
      switch (_selectedLanguage!.toLowerCase()) {
        case 'python':
          endpoint = Uri.parse('http://145.223.22.18:8080/compile');
          // endpoint = Uri.parse('http://localhost:8084/compile');
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
          print("[DEBUG] Unsupported language selected: $_selectedLanguage");
          setState(() {
            testResults = [
              TestCaseResult(
                testCase: '',
                expectedResult: '',
                actualResult: '',
                passed: false,
                errorMessage: "Unsupported programming language selected.",
              ),
            ];
          });
          return;
      }

      print("[DEBUG] Selected Endpoint: $endpoint");

      // Prepare code and test cases
      final String code = _codeController.text.trim();
      List<Map<String, String>> testCases;

      if (customInput != null) {
        // Custom input provided by the user
        testCases = [
          {
            'input': customInput.trim() + '\n',
            'output': '', // Custom input doesn't have an expected output
          },
        ];
      } else if (allTestCases) {
        // All test cases
        testCases = widget.question['test_cases']
            .map<Map<String, String>>((testCase) => {
                  'input': testCase['input'].toString().trim() + '\n',
                  'output': testCase['output'].toString().trim(),
                })
            .toList();
      } else {
        // Only public test cases
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
        'is_custom_input': customInput != null,
        'mode': mode, // Use the passed mode
      };

      print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

      // Send request to the compiler
      final response = await http.post(
        endpoint,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print("[DEBUG] Response Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("[DEBUG] Response Body: ${response.body}");
        final List<dynamic> responseBody = jsonDecode(response.body);

        // Update test results in the UI
        setState(() {
          testResults = responseBody.map<TestCaseResult>((result) {
            return TestCaseResult(
              testCase: result['input'] ?? '',
              expectedResult: result['expected_output'] ?? '',
              actualResult: result['actual_output'] ?? '',
              passed: result['success'] ?? false,
              errorMessage: result['error'] ?? '',
              isCustomInput: customInput != null,
            );
          }).toList();
        });

        // Only send to backend for "submit" mode
        if (mode == "submit") {
          final questionPoints =
              _getPointsForDifficulty(widget.question["difficulty"] ?? '');

          final backendRequest = {
            "domain_id": widget.question["codingquestiondomain_id"],
            "question_id": widget.question["id"],
            "language": _selectedLanguage,
            "solution_code": code,
            "test_results": responseBody,
            "question_points": questionPoints,
            "mode": mode,
          };
          print("[DEBUG] Question Object: ${widget.question}");

          if (widget.question["codingquestiondomain_id"] == null) {
            print("[DEBUG] Missing domain_id in question object");
            return;
          }

          print(
              "[DEBUG] Backend Requesttttttttt Payload: ${jsonEncode(backendRequest)}");
          final token = await SharedPrefs.getToken();
          final backendResponse = await http.post(
            Uri.parse(
                "http://localhost:3000/students/practice-coding-question-submit"),
            headers: {
              'Content-Type': 'application/json',
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(backendRequest),
          );

          print(
              "[DEBUG] Backend Response: ${backendResponse.statusCode} - ${backendResponse.body}");

          if (backendResponse.statusCode != 201) {
            print("[DEBUG] Backend Submission Error: ${backendResponse.body}");
          }
        }

        _scrollToResults();
      } else {
        print("[DEBUG] Error Response Body: ${response.body}");
        final errorResponse = jsonDecode(response.body);

        setState(() {
          testResults = [
            TestCaseResult(
              testCase: '',
              expectedResult: '',
              actualResult: '',
              passed: false,
              errorMessage:
                  errorResponse['message'] ?? 'Compilation error occurred',
            ),
          ];
        });
      }
    } catch (error) {
      print("[DEBUG] HTTP Request Error: $error");

      setState(() {
        testResults = [
          TestCaseResult(
            testCase: '',
            expectedResult: '',
            actualResult: '',
            passed: false,
            errorMessage: "Failed to connect to the server. Please try again.",
          ),
        ];
      });
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
                        if (widget.question['solutions'] != null &&
                            widget.question['solutions'].isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 16),
                              Text("Solutions",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              ...List<Widget>.generate(
                                widget.question['solutions'].length,
                                (index) {
                                  final solution =
                                      widget.question['solutions'][index];
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
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context, true); // Return true if changes are made
            },
            icon: Icon(Icons.arrow_back)),
        title: Text(widget.question['title']),
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
