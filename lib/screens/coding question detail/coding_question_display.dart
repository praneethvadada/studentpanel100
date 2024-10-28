import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:html' as html;
import 'package:highlight/languages/dart.dart'; // Syntax highlighting for Dart

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

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(text: "Select a Language");
    // _codeController = CodeController(
    //   text: '// Start typing your code here...\n',
    //   language:python, // Set this to the appropriate syntax highlighting language
    // );
    // _selectedLanguage = widget.question['allowed_languages'].isNotEmpty
    //     ? widget.question['allowed_languages'][0]
    //     : null;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    _customInputController.dispose();
    super.dispose();
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
      body: Row(
        children: [
          // Left Panel: Question details
          Expanded(
            flex: 2,
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
          VerticalDivider(width: 1, color: Colors.grey),

          // Right Panel: Code editor and results
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              controller: _rightPanelScrollController,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text("Select Language",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    // DropdownButton<String>(
                    //   value: _selectedLanguage,
                    //   onChanged: (String? newValue) {
                    //     setState(() {
                    //       _selectedLanguage = newValue;
                    //     });
                    //   },
                    //   items: (widget.question['allowed_languages']
                    //           as List<dynamic>)
                    //       .cast<String>()
                    //       .map<DropdownMenuItem<String>>((String language) {
                    //     return DropdownMenuItem<String>(
                    //       value: language,
                    //       child: Text(language),
                    //     );
                    //   }).toList(),
                    // ),

                    DropdownButton<String>(
                      value: _selectedLanguage,
                      onChanged: (String? newValue) {
                        if (newValue != null &&
                            newValue != "Please select a Language") {
                          setState(() {
                            _selectedLanguage = newValue;
                            _setStarterCode(newValue);
                          });
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
                    Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: CodeField(
                        controller: _codeController,
                        focusNode: _focusNode,
                        textStyle: TextStyle(
                            fontFamily: 'RobotoMono',
                            fontSize: 16,
                            color: Colors.white),
                        cursorColor: Colors.white,
                        background: Colors.black,
                        expands: true,
                        wrap: false,
                        lineNumberStyle: LineNumberStyle(
                          width: 40,
                          margin: 8,
                          textStyle: TextStyle(
                              color: Colors.grey.shade600, fontSize: 16),
                          background: Colors.grey.shade900,
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
                                allTestCases:
                                    false); // Run only public test cases
                          },
                          child: Text('Run'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _runCode(allTestCases: true); // Run all test cases
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
        ],
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
                    // Display "-" for "Expected" and "Pass/Fail" in custom inputs
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
                // Always display the error message if it exists
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
        title: Text('Your Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          code,
          style: TextStyle(
              fontFamily: 'SourceCodePro', fontSize: 16, color: Colors.black),
        ),
      ),
    );
  }
}
