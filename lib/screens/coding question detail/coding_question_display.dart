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
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _codeController = CodeController(
      text: '// Start typing your code here...\n',
      language:
          dart, // Set this to the appropriate syntax highlighting language
    );
    _selectedLanguage = widget.question['allowed_languages'].isNotEmpty
        ? widget.question['allowed_languages'][0]
        : null;
  }

  @override
  void dispose() {
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // Future<void> _runCode() async {
  //   if (_selectedLanguage == null) {
  //     print("No language selected");
  //     return;
  //   }

  //   final String code = _codeController.text.trim();
  //   final List<Map<String, String>> testCases = widget.question['test_cases']
  //       .map<Map<String, String>>((testCase) => {
  //             'input': testCase['input'].toString().trim(),
  //             'output': testCase['output'].toString().trim(),
  //           })
  //       .toList();

  //   // Correctly format the JSON request body
  //   final Map<String, dynamic> requestBody = {
  //     'language': _selectedLanguage!.toLowerCase(),
  //     'code': code,
  //     'testcases': testCases,
  //   };

  //   print('Request Body: ${jsonEncode(requestBody)}'); // For debugging

  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://localhost:8084/compile'), // Use proxy if necessary
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Response: ${response.body}');
  //       final List<dynamic> responseBody = jsonDecode(response.body);
  //       setState(() {
  //         testResults = responseBody.map((result) {
  //           return TestCaseResult(
  //             testCase: result['input'],
  //             expectedResult: result['expected_output'],
  //             actualResult: result['actual_output'],
  //             passed: result['success'],
  //           );
  //         }).toList();
  //       });
  //       _scrollToResults();
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //     }
  //   } catch (error) {
  //     print('Error sending request: $error');
  //   }
  // }

  // Future<void> _runCode() async {
  //   // if (_selectedLanguage == null) {
  //   //   print("No language selected");
  //   //   return;
  //   // }
  //   Uri endpoint;
  //   switch (_selectedLanguage!.toLowerCase()) {
  //     case 'python':
  //       endpoint = Uri.parse('http://localhost:8084/compile');
  //       break;
  //     case 'java':
  //       endpoint = Uri.parse('http://localhost:8083/compile');
  //       break;
  //     case 'cpp':
  //       endpoint = Uri.parse('http://localhost:8081/compile');
  //       break;
  //     case 'c':
  //       endpoint = Uri.parse('http://localhost:8082/compile');
  //       break;
  //     default:
  //       print("Unsupported language selected");
  //       return;
  //   }
  //   print('Selected Endpoint URL: $endpoint');

  //   final String code = _codeController.text.trim();
  //   final List<Map<String, String>> testCases = widget.question['test_cases']
  //       .map<Map<String, String>>((testCase) => {
  //             'input': testCase['input'].toString().trim() +
  //                 '\n', // Ensure newline in input
  //             'output': testCase['output'].toString().trim() +
  //                 '\n', // Ensure newline in output
  //           })
  //       .toList();

  //   // Correct JSON request body with formatted newline characters
  //   final Map<String, dynamic> requestBody = {
  //     'language': _selectedLanguage!.toLowerCase(),
  //     'code': code,
  //     'testcases': testCases,
  //   };

  //   print('Request Body: ${jsonEncode(requestBody)}'); // Debugging purpose

  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://localhost:8084/compile'), // Update URL if necessary
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Response: ${response.body}');
  //       final List<dynamic> responseBody = jsonDecode(response.body);
  //       setState(() {
  //         testResults = responseBody.map((result) {
  //           return TestCaseResult(
  //             testCase: result['input'],
  //             expectedResult: result['expected_output'],
  //             actualResult: result['actual_output'],
  //             passed: result['success'],
  //           );
  //         }).toList();
  //       });
  //       _scrollToResults();
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //     }
  //   } catch (error) {
  //     print('Error sending request: $error');
  //   }
  // }

  // Future<void> _runCode() async {
  //   if (_selectedLanguage == null) {
  //     print("No language selected");
  //     return;
  //   }

  //   Uri endpoint;
  //   switch (_selectedLanguage!.toLowerCase()) {
  //     case 'python':
  //       endpoint = Uri.parse('http://localhost:8084/compile');
  //       break;
  //     case 'java':
  //       endpoint = Uri.parse('http://localhost:8083/compile');
  //       break;
  //     case 'cpp':
  //       endpoint = Uri.parse('http://localhost:8081/compile');
  //       break;
  //     case 'c':
  //       endpoint = Uri.parse('http://localhost:8082/compile');
  //       break;
  //     default:
  //       print("Unsupported language selected");
  //       return;
  //   }

  //   print('Selected Endpoint URL: $endpoint');

  //   final String code = _codeController.text.trim();
  //   final List<Map<String, String>> testCases = widget.question['test_cases']
  //       .map<Map<String, String>>((testCase) => {
  //             'input': testCase['input'].toString().trim() +
  //                 '\n', // Ensure newline in input
  //             'output': testCase['output'].toString().trim() +
  //                 '\n', // Ensure newline in output
  //           })
  //       .toList();

  //   // Correct JSON request body with formatted newline characters
  //   final Map<String, dynamic> requestBody = {
  //     'language': _selectedLanguage!.toLowerCase(),
  //     'code': code,
  //     'testcases': testCases,
  //   };

  //   print('Request Body: ${jsonEncode(requestBody)}'); // Debugging purpose

  //   try {
  //     // Use the selected endpoint instead of a hardcoded URL
  //     final response = await http.post(
  //       endpoint,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Response: ${response.body}');
  //       final List<dynamic> responseBody = jsonDecode(response.body);
  //       setState(() {
  //         testResults = responseBody.map((result) {
  //           return TestCaseResult(
  //             testCase: result['input'],
  //             expectedResult: result['expected_output'],
  //             actualResult: result['actual_output'],
  //             passed: result['success'],
  //           );
  //         }).toList();
  //       });
  //       _scrollToResults();
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //     }
  //   } catch (error) {
  //     print('Error sending request: $error');
  //   }
  // }

  // Future<void> _runCode() async {
  //   Uri endpoint;
  //   switch (_selectedLanguage!.toLowerCase()) {
  //     case 'python':
  //       endpoint = Uri.parse('http://localhost:8084/compile');
  //       break;
  //     case 'java':
  //       endpoint = Uri.parse('http://localhost:8083/compile');
  //       break;
  //     case 'cpp':
  //       endpoint = Uri.parse('http://localhost:8081/compile');
  //       break;
  //     case 'c':
  //       endpoint = Uri.parse('http://localhost:8082/compile');
  //       break;
  //     default:
  //       print("Unsupported language selected");
  //       return;
  //   }
  //   print('Selected Endpoint URL: $endpoint');

  //   final String code = _codeController.text.trim();
  //   final List<Map<String, String>> testCases = widget.question['test_cases']
  //       .map<Map<String, String>>((testCase) => {
  //             'input': testCase['input'].toString().trim() + '\n',
  //             'output': testCase['output'].toString().trim() + '\n',
  //           })
  //       .toList();

  //   final Map<String, dynamic> requestBody = {
  //     'language': _selectedLanguage!.toLowerCase(),
  //     'code': code,
  //     'testcases': testCases,
  //   };

  //   print('Request Body: ${jsonEncode(requestBody)}');

  //   try {
  //     final response = await http.post(
  //       endpoint,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Response: ${response.body}');
  //       final List<dynamic> responseBody = jsonDecode(response.body);
  //       setState(() {
  //         testResults = responseBody.map((result) {
  //           final bool isSuccess = result['success'];
  //           return TestCaseResult(
  //             testCase: result['input'],
  //             expectedResult: result['expected_output'],
  //             actualResult: result['actual_output'],
  //             passed: isSuccess,
  //             // errorMessage: isSuccess
  //             errorMessage: result['error'] // Add error message if present

  //                 ? null
  //                 : 'Expected: ${result['expected_output']}\nGot: ${result['actual_output']}', // Customize error message
  //           );
  //         }).toList();
  //       });
  //       _scrollToResults();
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //     }
  //   } catch (error) {
  //     print('Error sending request: $error');
  //   }
  // }

  // Future<void> _runCode() async {
  //   Uri endpoint;
  //   switch (_selectedLanguage!.toLowerCase()) {
  //     case 'python':
  //       endpoint = Uri.parse('http://localhost:8084/compile');
  //       break;
  //     case 'java':
  //       endpoint = Uri.parse('http://localhost:8083/compile');
  //       break;
  //     case 'cpp':
  //       endpoint = Uri.parse('http://localhost:8081/compile');
  //       break;
  //     case 'c':
  //       endpoint = Uri.parse('http://localhost:8082/compile');
  //       break;
  //     default:
  //       print("Unsupported language selected");
  //       return;
  //   }
  //   print('Selected Endpoint URL: $endpoint');

  //   final String code = _codeController.text.trim();
  //   final List<Map<String, String>> testCases = widget.question['test_cases']
  //       .map<Map<String, String>>((testCase) => {
  //             'input': testCase['input'].toString().trim() + '\n',
  //             'output': testCase['output'].toString().trim() + '\n',
  //           })
  //       .toList();

  //   final Map<String, dynamic> requestBody = {
  //     'language': _selectedLanguage!.toLowerCase(),
  //     'code': code,
  //     'testcases': testCases,
  //   };

  //   print('Request Body: ${jsonEncode(requestBody)}');

  //   try {
  //     final response = await http.post(
  //       endpoint,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Response: ${response.body}');
  //       final List<dynamic> responseBody = jsonDecode(response.body);
  //       setState(() {
  //         testResults = responseBody.map((result) {
  //           final bool isSuccess =
  //               result['success'] ?? false; // Default to false if null
  //           final String? error = result['error']; // Can be null if no error

  //           return TestCaseResult(
  //             testCase: result['input'],
  //             expectedResult: result['expected_output'],
  //             actualResult: result['actual_output'] ?? '',
  //             passed: isSuccess,
  //             errorMessage: error,
  //           );
  //         }).toList();
  //       });
  //       _scrollToResults();
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //     }
  //   } catch (error) {
  //     print('Error sending request: $error');
  //   }
  // }

  // Future<void> _runCode() async {
  //   Uri endpoint;
  //   switch (_selectedLanguage!.toLowerCase()) {
  //     case 'python':
  //       endpoint = Uri.parse('http://localhost:8084/compile');
  //       break;
  //     case 'java':
  //       endpoint = Uri.parse('http://localhost:8083/compile');
  //       break;
  //     case 'cpp':
  //       endpoint = Uri.parse('http://localhost:8081/compile');
  //       break;
  //     case 'c':
  //       endpoint = Uri.parse('http://localhost:8082/compile');
  //       break;
  //     default:
  //       print("Unsupported language selected");
  //       return;
  //   }
  //   print('Selected Endpoint URL: $endpoint');

  //   final String code = _codeController.text.trim();
  //   final List<Map<String, String>> testCases = widget.question['test_cases']
  //       .map<Map<String, String>>((testCase) => {
  //             'input': testCase['input'].toString().trim() + '\n',
  //             'output': testCase['output'].toString().trim() + '\n',
  //           })
  //       .toList();

  //   final Map<String, dynamic> requestBody = {
  //     'language': _selectedLanguage!.toLowerCase(),
  //     'code': code,
  //     'testcases': testCases,
  //   };

  //   print('Request Body: ${jsonEncode(requestBody)}');

  //   try {
  //     final response = await http.post(
  //       endpoint,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       print('Response: ${response.body}');
  //       final List<dynamic> responseBody = jsonDecode(response.body);
  //       setState(() {
  //         testResults = responseBody.map((result) {
  //           final bool isSuccess = result['success'] ?? false;
  //           final String? error = result['error'];

  //           return TestCaseResult(
  //             testCase: result['input'],
  //             expectedResult: result['expected_output'],
  //             actualResult: result['actual_output'] ?? '',
  //             passed: isSuccess,
  //             errorMessage: error, // Capture error message
  //           );
  //         }).toList();
  //       });
  //       _scrollToResults();
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //       print('Backend Error Response: ${response.body}');
  //     }
  //   } catch (error) {
  //     print('Error sending request: $error');
  //   }
  // }

  // Future<void> _runCode() async {
  //   if (_selectedLanguage == null || _codeController.text.trim().isEmpty) {
  //     print("No valid code provided or language not selected");
  //     return;
  //   }

  //   Uri endpoint;
  //   switch (_selectedLanguage!.toLowerCase()) {
  //     case 'python':
  //       endpoint = Uri.parse('http://localhost:8084/compile');
  //       break;
  //     case 'java':
  //       endpoint = Uri.parse('http://localhost:8083/compile');
  //       break;
  //     case 'cpp':
  //       endpoint = Uri.parse('http://localhost:8081/compile');
  //       break;
  //     case 'c':
  //       endpoint = Uri.parse('http://localhost:8082/compile');
  //       break;
  //     default:
  //       print("Unsupported language selected");
  //       return;
  //   }

  //   print('Selected Endpoint URL: $endpoint');

  //   final String code = _codeController.text.trim();
  //   final List<Map<String, String>> testCases = widget.question['test_cases']
  //       .map<Map<String, String>>((testCase) => {
  //             'input': testCase['input'].toString().trim() + '\n',
  //             'output': testCase['output'].toString().trim() + '\n',
  //           })
  //       .toList();

  //   final Map<String, dynamic> requestBody = {
  //     'language': _selectedLanguage!.toLowerCase(),
  //     'code': code,
  //     'testcases': testCases,
  //   };

  //   print('Request Body: ${jsonEncode(requestBody)}');

  //   try {
  //     final response = await http.post(
  //       endpoint,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode(requestBody),
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> responseBody = jsonDecode(response.body);
  //       setState(() {
  //         testResults = responseBody.map((result) {
  //           return TestCaseResult(
  //             testCase: result['input'],
  //             expectedResult: result['expected_output'],
  //             actualResult: result['actual_output'] ?? '',
  //             passed: result['success'] ?? false,
  //             errorMessage:
  //                 result['error'] ?? '', // Store error message if present
  //           );
  //         }).toList();
  //       });
  //       _scrollToResults();
  //     } else {
  //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
  //       print('Backend Error Response: ${response.body}');
  //     }
  //   } catch (error) {
  //     print('Error sending request: $error');
  //   }
  // }

  Future<void> _runCode() async {
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
    final List<Map<String, String>> testCases = widget.question['test_cases']
        .map<Map<String, String>>((testCase) => {
              'input': testCase['input'].toString().trim() + '\n',
              'output': testCase['output'].toString().trim() + '\n',
            })
        .toList();

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
              expectedResult: result['expected_output'],
              actualResult: result['actual_output'] ?? '',
              passed: result['success'] ?? false,
              errorMessage: result['error'] ?? '', // Capture error if present
            );
          }).toList();
        });
        _scrollToResults();
      } else {
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        print('Backend Error Response: ${response.body}');
        // Handle backend error for 400 or other status codes
        setState(() {
          testResults = [
            TestCaseResult(
              testCase: '',
              expectedResult: '',
              actualResult: '',
              passed: false,
              errorMessage: jsonDecode(response.body)['error'], // Display error
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

  // View typed code in a new page
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
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 16),
                    Text("Description",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.question['description'],
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text("Input Format",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.question['input_format'],
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text("Output Format",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(widget.question['output_format'],
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text("Constraints",
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
                    DropdownButton<String>(
                      value: _selectedLanguage,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedLanguage = newValue;
                        });
                      },
                      items: (widget.question['allowed_languages']
                              as List<dynamic>)
                          .cast<String>()
                          .map<DropdownMenuItem<String>>((String language) {
                        return DropdownMenuItem<String>(
                          value: language,
                          child: Text(language),
                        );
                      }).toList(),
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
                    ElevatedButton(
                      onPressed: _runCode, // Execute the code when pressed
                      child: Text('Run Code'),
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

// Model for test case result
// class TestCaseResult {
//   final String testCase;
//   final String expectedResult;
//   final String actualResult;
//   final bool passed;

//   TestCaseResult({
//     required this.testCase,
//     required this.expectedResult,
//     required this.actualResult,
//     required this.passed,
//   });
// }

class TestCaseResult {
  final String testCase;
  final String expectedResult;
  final String actualResult;
  final bool passed;
  final String errorMessage; // Add errorMessage field

  TestCaseResult({
    required this.testCase,
    required this.expectedResult,
    required this.actualResult,
    required this.passed,
    this.errorMessage = '', // Define errorMessage as an optional parameter
  });
}

// // Widget to display test case results in a table
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
//             return Row(
//               children: [
//                 Expanded(child: Text("Input: ${result.testCase}")),
//                 Expanded(child: Text("Expected: ${result.expectedResult}")),
//                 Expanded(child: Text("Actual: ${result.actualResult}")),
//                 Expanded(child: Text(result.passed ? "Passed" : "Failed")),
//               ],
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }
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
//                     Expanded(child: Text("Expected: ${result.expectedResult}")),
//                     Expanded(child: Text("Actual: ${result.actualResult}")),
//                     Expanded(child: Text(result.passed ? "Passed" : "Failed")),
//                   ],
//                 ),
//                 if (!result.passed && result.errorMessage != null)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 16.0),
//                     child: Text(
//                       // result.errorMessage!,
//                       "Error: ${result.errorMessage}",
//                       style: TextStyle(color: Colors.red, fontSize: 14),
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
//                     Expanded(child: Text("Expected: ${result.expectedResult}")),
//                     Expanded(child: Text("Actual: ${result.actualResult}")),
//                     Expanded(
//                         child: Text(
//                       result.passed ? "Passed" : "Failed",
//                       style: TextStyle(
//                         color: result.passed ? Colors.green : Colors.red,
//                       ),
//                     )),
//                   ],
//                 ),
//                 if (!result.passed && result.errorMessage.isNotEmpty)
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
                    Expanded(child: Text("Expected: ${result.expectedResult}")),
                    Expanded(child: Text("Actual: ${result.actualResult}")),
                    Expanded(
                        child: Text(
                      result.passed ? "Passed" : "Failed",
                      style: TextStyle(
                        color: result.passed ? Colors.green : Colors.red,
                      ),
                    )),
                  ],
                ),
                if (!result.passed && result.errorMessage.isNotEmpty)
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

// Page to display typed code
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

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
// import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
// import 'dart:html' as html;

// import 'package:highlight/languages/dart.dart'; // Syntax highlighting for Dart

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
//   String? _selectedLanguage;

//   @override
//   void initState() {
//     super.initState();
//     _codeController = CodeController(
//       text: '// Start typing your Dart code here...\n',
//       language: dart, // Change the language to the required one
//     );
//     _selectedLanguage = widget.question['allowed_languages'].isNotEmpty
//         ? widget.question['allowed_languages'][0]
//         : null;
//   }

//   @override
//   void dispose() {
//     _codeController.dispose();
//     _focusNode.dispose();
//     super.dispose();
//   }

//   // Simulate running test cases
//   void _runTestCases({int numberOfCases = 3}) {
//     setState(() {
//       testResults = []; // Clear previous results
//       for (int i = 1; i <= numberOfCases; i++) {
//         testResults.add(TestCaseResult(
//           testCase: "Test Case $i",
//           expectedResult: "Expected Output $i",
//           actualResult: "Actual Output $i",
//           passed: i % 2 == 0, // Random pass/fail for demonstration
//         ));
//       }
//     });
//     _scrollToResults();
//   }

//   // Run all test cases
//   void _submitTestCases() {
//     _runTestCases(numberOfCases: 30); // Simulate running all test cases
//   }

//   // Scroll to results after test cases
//   void _scrollToResults() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _rightPanelScrollController.animateTo(
//         _rightPanelScrollController.position.maxScrollExtent,
//         duration: Duration(milliseconds: 500),
//         curve: Curves.easeOut,
//       );
//     });
//   }

//   // View typed code in a new page
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.question['title']),
//       ),
//       body: Row(
//         children: [
//           // Left Panel: Question details
//           Expanded(
//             flex: 2,
//             child: Padding(
//               padding: EdgeInsets.all(16.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(widget.question['title'],
//                         style: TextStyle(
//                             fontSize: 24, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 16),
//                     Text("Description",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),
//                     Text(widget.question['description'],
//                         style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 16),
//                     Text("Input Format",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),
//                     Text(widget.question['input_format'],
//                         style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 16),
//                     Text("Output Format",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),
//                     Text(widget.question['output_format'],
//                         style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 16),
//                     Text("Test Cases",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: List<Widget>.generate(
//                         widget.question['test_cases'].length,
//                         (index) {
//                           final testCase = widget.question['test_cases'][index];
//                           return Card(
//                             margin: EdgeInsets.symmetric(vertical: 8),
//                             child: Padding(
//                               padding: const EdgeInsets.all(12.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text("Input: ${testCase['input']}",
//                                       style: TextStyle(fontSize: 16)),
//                                   Text("Output: ${testCase['output']}",
//                                       style: TextStyle(fontSize: 16)),
//                                   if (testCase['is_public'])
//                                     Text(
//                                         "Explanation: ${testCase['explanation'] ?? ''}",
//                                         style: TextStyle(fontSize: 16)),
//                                 ],
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     // Constraints
//                     Text("Constraints",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),
//                     Text(widget.question['constraints'],
//                         style: TextStyle(fontSize: 16)),
//                     SizedBox(height: 16),
//                     // Solutions
//                     Text("Solution(s)",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),

//                     // Column(
//                     //   crossAxisAlignment: CrossAxisAlignment.start,
//                     //   children: widget.question['solutions'] != null
//                     //       ? List<Widget>.generate(
//                     //           widget.question['solutions'].length,
//                     //           (index) {
//                     //             final solution =
//                     //                 widget.question['solutions'][index];
//                     //             return Padding(
//                     //               padding: EdgeInsets.symmetric(vertical: 8),
//                     //               child: Text(
//                     //                 "${index + 1}. ${solution['language']}: ${solution['code']} \nYouTube Link: ${solution['youtube_link']}",
//                     //                 style: TextStyle(fontSize: 16),
//                     //               ),
//                     //             );
//                     //           },
//                     //         )
//                     //       : [
//                     //           Text("No solutions available.",
//                     //               style: TextStyle(fontSize: 16))
//                     //         ],
//                     // ),

//                     // Column(
//                     //   crossAxisAlignment: CrossAxisAlignment.start,
//                     //   children: (widget.question['solutions'] != null &&
//                     //           widget.question['solutions'] is List)
//                     //       ? List<Widget>.generate(
//                     //           widget.question['solutions'].length,
//                     //           (index) {
//                     //             final solution =
//                     //                 widget.question['solutions'][index];
//                     //             return Padding(
//                     //               padding: EdgeInsets.symmetric(vertical: 8),
//                     //               child: Column(
//                     //                 crossAxisAlignment:
//                     //                     CrossAxisAlignment.start,
//                     //                 children: [
//                     //                   Text(
//                     //                     "Solution ${index + 1}:",
//                     //                     style: TextStyle(
//                     //                         fontSize: 18,
//                     //                         fontWeight: FontWeight.bold),
//                     //                   ),
//                     //                   Text(
//                     //                     "Language: ${solution['language']}",
//                     //                     style: TextStyle(fontSize: 16),
//                     //                   ),
//                     //                   Text(
//                     //                     "Code: ${solution['code']}",
//                     //                     style: TextStyle(
//                     //                         fontSize: 16,
//                     //                         fontFamily: 'monospace'),
//                     //                   ),
//                     //                   if (solution['youtube_link'] != null &&
//                     //                       solution['youtube_link']!.isNotEmpty)
//                     //                     Text(
//                     //                       "YouTube Link: ${solution['youtube_link']}",
//                     //                       style: TextStyle(
//                     //                           fontSize: 16, color: Colors.blue),
//                     //                     ),
//                     //                   Divider(
//                     //                       thickness: 1,
//                     //                       color: Colors
//                     //                           .grey), // Divider between solutions
//                     //                 ],
//                     //               ),
//                     //             );
//                     //           },
//                     //         )
//                     //       : [
//                     //           Text("No solutions available.",
//                     //               style: TextStyle(fontSize: 16))
//                     //         ],
//                     // ),

//                     // Column(
//                     //   crossAxisAlignment: CrossAxisAlignment.start,
//                     //   children: () {
//                     //     // Step 1: Print the full question data to check if solutions is present
//                     //     print("Full question data: ${widget.question}");

//                     //     // Step 2: Check if solutions is null
//                     //     if (widget.question['solutions'] == null) {
//                     //       print("Solutions is null");
//                     //       return [
//                     //         Text("No solutions available.",
//                     //             style: TextStyle(fontSize: 16))
//                     //       ];
//                     //     }

//                     //     // Step 3: Check if solutions is a List
//                     //     if (widget.question['solutions'] is! List) {
//                     //       print(
//                     //           "Solutions is not a List. It is: ${widget.question['solutions'].runtimeType}");
//                     //       return [
//                     //         Text("No solutions available.",
//                     //             style: TextStyle(fontSize: 16))
//                     //       ];
//                     //     }

//                     //     // Step 4: Check if solutions is empty
//                     //     if ((widget.question['solutions'] as List).isEmpty) {
//                     //       print("Solutions list is empty");
//                     //       return [
//                     //         Text("No solutions available.",
//                     //             style: TextStyle(fontSize: 16))
//                     //       ];
//                     //     }

//                     //     // Step 5: If solutions is not empty, print each solution to confirm structure
//                     //     print("Solutions found:");
//                     //     for (var solution in widget.question['solutions']) {
//                     //       print("Solution: $solution");
//                     //     }

//                     //     // Display each solution
//                     //     return List<Widget>.generate(
//                     //       widget.question['solutions'].length,
//                     //       (index) {
//                     //         final solution =
//                     //             widget.question['solutions'][index];
//                     //         return Padding(
//                     //           padding: EdgeInsets.symmetric(vertical: 8),
//                     //           child: Column(
//                     //             crossAxisAlignment: CrossAxisAlignment.start,
//                     //             children: [
//                     //               Text(
//                     //                 "Solution ${index + 1}:",
//                     //                 style: TextStyle(
//                     //                     fontSize: 18,
//                     //                     fontWeight: FontWeight.bold),
//                     //               ),
//                     //               Text(
//                     //                 "Language: ${solution['language']}",
//                     //                 style: TextStyle(fontSize: 16),
//                     //               ),
//                     //               Text(
//                     //                 "Code: ${solution['code']}",
//                     //                 style: TextStyle(
//                     //                     fontSize: 16, fontFamily: 'monospace'),
//                     //               ),
//                     //               if (solution['youtube_link'] != null &&
//                     //                   solution['youtube_link']!.isNotEmpty)
//                     //                 Text(
//                     //                   "YouTube Link: ${solution['youtube_link']}",
//                     //                   style: TextStyle(
//                     //                       fontSize: 16, color: Colors.blue),
//                     //                 ),
//                     //               Divider(thickness: 1, color: Colors.grey),
//                     //             ],
//                     //           ),
//                     //         );
//                     //       },
//                     //     );
//                     //   }(),
//                     // ),

//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         // Display Solutions Section
//                         Text(
//                           "Solutions",
//                           style: TextStyle(
//                               fontSize: 18, fontWeight: FontWeight.bold),
//                         ),
//                         SizedBox(height: 8),

//                         // Check if solutions are available and display them
//                         if (widget.question['solutions'] != null &&
//                             widget.question['solutions'] is List)
//                           ...List<Widget>.generate(
//                             widget.question['solutions'].length,
//                             (index) {
//                               final solution =
//                                   widget.question['solutions'][index];
//                               return Padding(
//                                 padding: EdgeInsets.symmetric(vertical: 8),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "Solution ${index + 1}:",
//                                       style: TextStyle(
//                                           fontSize: 18,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                     Text(
//                                       "Language: ${solution['language']}",
//                                       style: TextStyle(fontSize: 16),
//                                     ),
//                                     Text(
//                                       "Code: ${solution['code']}",
//                                       style: TextStyle(
//                                           fontSize: 16,
//                                           fontFamily: 'monospace'),
//                                     ),
//                                     if (solution['youtube_link'] != null &&
//                                         solution['youtube_link']!.isNotEmpty)
//                                       Text(
//                                         "YouTube Link: ${solution['youtube_link']}",
//                                         style: TextStyle(
//                                             fontSize: 16, color: Colors.blue),
//                                       ),
//                                     Divider(thickness: 1, color: Colors.grey),
//                                   ],
//                                 ),
//                               );
//                             },
//                           )
//                         else
//                           // Fallback message if no solutions are available
//                           Text(
//                             "No solutions available.",
//                             style: TextStyle(fontSize: 16),
//                           ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           VerticalDivider(
//               width: 1, color: Colors.grey), // Divider between panels

//           // Right Panel: Code editor and results
//           Expanded(
//             flex: 3,
//             child: SingleChildScrollView(
//               controller: _rightPanelScrollController,
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Column(
//                   children: [
//                     Text("Select Language",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),
//                     DropdownButton<String>(
//                       value: _selectedLanguage,
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           _selectedLanguage = newValue;
//                           // TODO: Update the syntax highlighting language based on _selectedLanguage
//                         });
//                       },
//                       items: (widget.question['allowed_languages']
//                               as List<dynamic>)
//                           .cast<String>()
//                           .map<DropdownMenuItem<String>>((String language) {
//                         return DropdownMenuItem<String>(
//                           value: language,
//                           child: Text(language),
//                         );
//                       }).toList(),
//                     ),
//                     Container(
//                       height: MediaQuery.of(context).size.height /
//                           2, // Half screen height for code editor
//                       child: CodeField(
//                         controller: _codeController,
//                         focusNode: _focusNode,
//                         textStyle: TextStyle(
//                             fontFamily: 'SourceCodePro',
//                             fontSize: 16,
//                             color: Colors.white),
//                         cursorColor: Colors.white,
//                         background: Colors.black,
//                         expands: true,
//                         wrap: false,
//                         lineNumberStyle: LineNumberStyle(
//                           width: 40,
//                           margin: 8,
//                           textStyle: TextStyle(
//                               color: Colors.grey.shade600, fontSize: 16),
//                           background: Colors.grey.shade900,
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 16),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton(
//                           onPressed: () {
//                             _runTestCases(); // Run selected test cases
//                           },
//                           child: Text('Run'),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             _submitTestCases(); // Run all test cases
//                           },
//                           child: Text('Submit'),
//                         ),
//                         ElevatedButton(
//                           onPressed: () {
//                             _navigateToCodeDisplay(context); // View typed code
//                           },
//                           child: Text('View Code'),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 16),
//                     if (testResults.isNotEmpty)
//                       TestCaseResultsTable(testResults: testResults),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Model for test case result
// class TestCaseResult {
//   final String testCase;
//   final String expectedResult;
//   final String actualResult;
//   final bool passed;

//   TestCaseResult(
//       {required this.testCase,
//       required this.expectedResult,
//       required this.actualResult,
//       required this.passed});
// }

// // Widget to display test case results in a table
// class TestCaseResultsTable extends StatelessWidget {
//   final List<TestCaseResult> testResults;

//   TestCaseResultsTable({required this.testResults});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildTableHeaderRow(),
//         Divider(thickness: 2),
//         Column(
//           children:
//               testResults.map((result) => _buildTableRow(result)).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildTableHeaderRow() {
//     return Row(
//       children: [
//         _buildTableCell('Test Case', isHeader: true),
//         _buildTableCell('Expected Result', isHeader: true),
//         _buildTableCell('Actual Result', isHeader: true),
//         _buildTableCell('Passed', isHeader: true),
//       ],
//     );
//   }

//   Widget _buildTableRow(TestCaseResult result) {
//     return Row(
//       children: [
//         _buildTableCell(result.testCase),
//         _buildTableCell(result.expectedResult),
//         _buildTableCell(result.actualResult),
//         _buildTableCell(result.passed ? 'Yes' : 'No'),
//       ],
//     );
//   }

//   Widget _buildTableCell(String content, {bool isHeader = false}) {
//     return Expanded(
//       child: Container(
//         padding: EdgeInsets.all(8.0),
//         margin: EdgeInsets.all(2.0),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           color: isHeader ? Colors.grey.shade300 : Colors.white,
//         ),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Text(
//             content,
//             style: TextStyle(
//                 fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
//                 color: isHeader ? Colors.black : Colors.grey.shade800),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // Page to display typed code
// class DisplayCodePage extends StatelessWidget {
//   final String code;

//   DisplayCodePage({required this.code});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Your Code'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Text(
//           code,
//           style: TextStyle(
//               fontFamily: 'SourceCodePro', fontSize: 16, color: Colors.black),
//         ),
//       ),
//     );
//   }
// }
// // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
// // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
// // import 'package:flutter/material.dart';
// // import 'package:http/http.dart' as http;
// // import 'dart:convert';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
// // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
// // import 'dart:html' as html;

// // import 'package:highlight/languages/dart.dart'; // Syntax highlighting for Dart
// // class CodingQuestionDetailPage extends StatefulWidget {
// //   final Map<String, dynamic> question;

// //   const CodingQuestionDetailPage({Key? key, required this.question})
// //       : super(key: key);

// //   @override
// //   State<CodingQuestionDetailPage> createState() =>
// //       _CodingQuestionDetailPageState();
// // }

// // class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage> {
// //   late TextEditingController _codeController;
// //   final FocusNode _focusNode = FocusNode();
// //   List<TestCaseResult> testResults = [];
// //   final ScrollController _rightPanelScrollController = ScrollController();
// //   String? _selectedLanguage;
// //   // late CodeController _codeController;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _codeController =
// //         TextEditingController(text: '// Start typing your code here...\n');
// //     _selectedLanguage = widget.question['allowed_languages'].isNotEmpty
// //         ? widget.question['allowed_languages'][0]
// //         : null;
// //   }

// //   @override
// //   void dispose() {
// //     _codeController.dispose();
// //     _focusNode.dispose();
// //     super.dispose();
// //   }

// //   // Function to send code to the Docker API and get results
// //   Future<void> _runCode() async {
// //     if (_selectedLanguage == null) {
// //       print("No language selected");
// //       return;
// //     }

// //     final String code = _codeController.text;

// //     // Format test cases to ensure they are in correct Map<String, String> format
// //     final List<Map<String, String>> testCases =
// //         widget.question['test_cases'].map<Map<String, String>>((testCase) {
// //       return {
// //         'input': testCase['input'].toString(),
// //         'output': testCase['output'].toString(),
// //       };
// //     }).toList();

// //     // Log the formatted data
// //     print("Sending code execution request with:");
// //     print("Language: $_selectedLanguage");
// //     print("Code: $code");
// //     print("Test cases: $testCases");

// //     // API request body
// //     final Map<String, dynamic> requestBody = {
// //       'language': _selectedLanguage!
// //           .toLowerCase(), // Convert to lowercase to match API requirements
// //       'code': code,
// //       'testcases': testCases,
// //     };

// //     try {
// //       // Make POST request to Docker API
// //       final response = await http.post(
// //         Uri.parse('http://localhost:8080/run'),
// //         headers: {'Content-Type': 'application/json'},
// //         body: jsonEncode(requestBody),
// //       );

// //       // Check if response is successful
// //       if (response.statusCode == 200) {
// //         // Parse JSON response
// //         final List<dynamic> responseBody = jsonDecode(response.body);

// //         // Log response body
// //         print("Response from Docker API:");
// //         print(responseBody);

// //         // Update test results
// //         setState(() {
// //           testResults = responseBody.map((result) {
// //             return TestCaseResult(
// //               testCase: result['input'],
// //               expectedResult: result['expected_output'],
// //               actualResult: result['actual_output'],
// //               passed: result['success'],
// //             );
// //           }).toList();
// //         });

// //         // Scroll to display results
// //         _scrollToResults();
// //       } else {
// //         print('Error: ${response.statusCode} - ${response.reasonPhrase}');
// //       }
// //     } catch (error) {
// //       print('Error sending request: $error');
// //     }
// //   }

// //   // Scroll to results after test cases
// //   void _scrollToResults() {
// //     WidgetsBinding.instance.addPostFrameCallback((_) {
// //       _rightPanelScrollController.animateTo(
// //         _rightPanelScrollController.position.maxScrollExtent,
// //         duration: Duration(milliseconds: 500),
// //         curve: Curves.easeOut,
// //       );
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text(widget.question['title']),
// //       ),
// //       body: Row(
// //         children: [
// //           // Left Panel: Question details
// //           Expanded(
// //             flex: 2,
// //             child: Padding(
// //               padding: EdgeInsets.all(16.0),
// //               child: SingleChildScrollView(
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   children: [
// //                     Text(widget.question['title'],
// //                         style: TextStyle(
// //                             fontSize: 24, fontWeight: FontWeight.bold)),
// //                     SizedBox(height: 16),
// //                     Text("Description",
// //                         style: TextStyle(
// //                             fontSize: 18, fontWeight: FontWeight.bold)),
// //                     Text(widget.question['description'],
// //                         style: TextStyle(fontSize: 16)),
// //                     SizedBox(height: 16),
// //                     Text("Input Format",
// //                         style: TextStyle(
// //                             fontSize: 18, fontWeight: FontWeight.bold)),
// //                     Text(widget.question['input_format'],
// //                         style: TextStyle(fontSize: 16)),
// //                     SizedBox(height: 16),
// //                     Text("Output Format",
// //                         style: TextStyle(
// //                             fontSize: 18, fontWeight: FontWeight.bold)),
// //                     Text(widget.question['output_format'],
// //                         style: TextStyle(fontSize: 16)),
// //                     SizedBox(height: 16),
// //                     Text("Constraints",
// //                         style: TextStyle(
// //                             fontSize: 18, fontWeight: FontWeight.bold)),
// //                     Text(widget.question['constraints'],
// //                         style: TextStyle(fontSize: 16)),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //           VerticalDivider(width: 1, color: Colors.grey),

// //           // Right Panel: Code editor and results
// //           Expanded(
// //             flex: 3,
// //             child: SingleChildScrollView(
// //               controller: _rightPanelScrollController,
// //               child: Padding(
// //                 padding: EdgeInsets.all(16.0),
// //                 child: Column(
// //                   children: [
// //                     Text("Select Language",
// //                         style: TextStyle(
// //                             fontSize: 18, fontWeight: FontWeight.bold)),
// //                     DropdownButton<String>(
// //                       value: _selectedLanguage,
// //                       onChanged: (String? newValue) {
// //                         setState(() {
// //                           _selectedLanguage = newValue;
// //                         });
// //                       },
// //                       items: (widget.question['allowed_languages']
// //                               as List<dynamic>)
// //                           .cast<String>()
// //                           .map<DropdownMenuItem<String>>((String language) {
// //                         return DropdownMenuItem<String>(
// //                           value: language,
// //                           child: Text(language),
// //                         );
// //                       }).toList(),
// //                     ),
// //                     Container(
// //                       height: MediaQuery.of(context).size.height /
// //                           2, // Half screen height for code editor
// //                       child: CodeField(
// //                         controller: _codeController,
// //                         focusNode: _focusNode,
// //                         textStyle: TextStyle(
// //                             fontFamily: 'SourceCodePro',
// //                             fontSize: 16,
// //                             color: Colors.white),
// //                         cursorColor: Colors.white,
// //                         background: Colors.black,
// //                         expands: true,
// //                         wrap: false,
// //                         lineNumberStyle: LineNumberStyle(
// //                           width: 40,
// //                           margin: 8,
// //                           textStyle: TextStyle(
// //                               color: Colors.grey.shade600, fontSize: 16),
// //                           background: Colors.grey.shade900,
// //                         ),
// //                       ),
// //                     ),
// //                     // Container(
// //                     //   height: MediaQuery.of(context).size.height / 2,
// //                     //   child: TextField(
// //                     //     controller: _codeController,
// //                     //     focusNode: _focusNode,
// //                     //     maxLines: null,
// //                     //     decoration: InputDecoration(
// //                     //       hintText: 'Write your code here...',
// //                     //       filled: true,
// //                     //       fillColor: Colors.black,
// //                     //     ),
// //                     //     style: TextStyle(
// //                     //         fontSize: 16,
// //                     //         color: Colors.white,
// //                     //         fontFamily: 'monospace'),
// //                     //   ),
// //                     // ),
// //                     SizedBox(height: 16),
// //                     ElevatedButton(
// //                       onPressed: _runCode, // Execute the code when pressed
// //                       child: Text('Run Code'),
// //                     ),
// //                     SizedBox(height: 16),
// //                     if (testResults.isNotEmpty)
// //                       TestCaseResultsTable(testResults: testResults),
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // Model for test case result
// // class TestCaseResult {
// //   final String testCase;
// //   final String expectedResult;
// //   final String actualResult;
// //   final bool passed;

// //   TestCaseResult({
// //     required this.testCase,
// //     required this.expectedResult,
// //     required this.actualResult,
// //     required this.passed,
// //   });
// // }

// // // Widget to display test case results in a table
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
// //             return Row(
// //               children: [
// //                 Expanded(child: Text("Input: ${result.testCase}")),
// //                 Expanded(child: Text("Expected: ${result.expectedResult}")),
// //                 Expanded(child: Text("Actual: ${result.actualResult}")),
// //                 Expanded(child: Text(result.passed ? "Passed" : "Failed")),
// //               ],
// //             );
// //           }).toList(),
// //         ),
// //       ],
// //     );
// //   }
// // }

// // // import 'package:flutter/material.dart';
// // // import 'package:http/http.dart' as http; // Add this for making HTTP requests
// // // import 'dart:convert';

// // // class CodingQuestionDetailPage extends StatefulWidget {
// // //   final Map<String, dynamic> question;

// // //   const CodingQuestionDetailPage({Key? key, required this.question})
// // //       : super(key: key);

// // //   @override
// // //   State<CodingQuestionDetailPage> createState() =>
// // //       _CodingQuestionDetailPageState();
// // // }

// // // class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage> {
// // //   late TextEditingController _codeController;
// // //   final FocusNode _focusNode = FocusNode();
// // //   List<TestCaseResult> testResults = [];
// // //   final ScrollController _rightPanelScrollController = ScrollController();
// // //   String? _selectedLanguage;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _codeController =
// // //         TextEditingController(text: '// Start typing your code here...\n');
// // //     _selectedLanguage = widget.question['allowed_languages'].isNotEmpty
// // //         ? widget.question['allowed_languages'][0]
// // //         : null;
// // //   }

// // //   @override
// // //   void dispose() {
// // //     _codeController.dispose();
// // //     _focusNode.dispose();
// // //     super.dispose();
// // //   }

// // //   // Function to send code to the Docker API and get results
// // //   Future<void> _runCode() async {
// // //     if (_selectedLanguage == null) return;

// // //     final String code = _codeController.text;
// // //     final List<Map<String, String>> testCases = List<Map<String, String>>.from(
// // //       widget.question['test_cases'].map((testCase) => {
// // //             'input': testCase['input'],
// // //             'output': testCase['output'],
// // //           }),
// // //     );

// // //     // API request body
// // //     final Map<String, dynamic> requestBody = {
// // //       'language': _selectedLanguage!
// // //           .toLowerCase(), // Convert to lowercase to match API requirements
// // //       'code': code,
// // //       'testcases': testCases,
// // //     };

// // //     try {
// // //       // Make POST request to Docker API
// // //       final response = await http.post(
// // //         Uri.parse('http://localhost:8080/run'),
// // //         headers: {'Content-Type': 'application/json'},
// // //         body: jsonEncode(requestBody),
// // //       );

// // //       // Check if response is successful
// // //       if (response.statusCode == 200) {
// // //         // Parse JSON response
// // //         final List<dynamic> responseBody = jsonDecode(response.body);

// // //         // Update test results
// // //         setState(() {
// // //           testResults = responseBody.map((result) {
// // //             return TestCaseResult(
// // //               testCase: result['input'],
// // //               expectedResult: result['expected_output'],
// // //               actualResult: result['actual_output'],
// // //               passed: result['success'],
// // //             );
// // //           }).toList();
// // //         });

// // //         // Scroll to display results
// // //         _scrollToResults();
// // //       } else {
// // //         print('Error: ${response.statusCode} - ${response.reasonPhrase}');
// // //       }
// // //     } catch (error) {
// // //       print('Error sending request: $error');
// // //     }
// // //   }

// // //   // Scroll to results after test cases
// // //   void _scrollToResults() {
// // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // //       _rightPanelScrollController.animateTo(
// // //         _rightPanelScrollController.position.maxScrollExtent,
// // //         duration: Duration(milliseconds: 500),
// // //         curve: Curves.easeOut,
// // //       );
// // //     });
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text(widget.question['title']),
// // //       ),
// // //       body: Row(
// // //         children: [
// // //           // Left Panel: Question details
// // //           Expanded(
// // //             flex: 2,
// // //             child: Padding(
// // //               padding: EdgeInsets.all(16.0),
// // //               child: SingleChildScrollView(
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   children: [
// // //                     Text(widget.question['title'],
// // //                         style: TextStyle(
// // //                             fontSize: 24, fontWeight: FontWeight.bold)),
// // //                     SizedBox(height: 16),
// // //                     Text("Description",
// // //                         style: TextStyle(
// // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // //                     Text(widget.question['description'],
// // //                         style: TextStyle(fontSize: 16)),
// // //                     SizedBox(height: 16),
// // //                     Text("Input Format",
// // //                         style: TextStyle(
// // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // //                     Text(widget.question['input_format'],
// // //                         style: TextStyle(fontSize: 16)),
// // //                     SizedBox(height: 16),
// // //                     Text("Output Format",
// // //                         style: TextStyle(
// // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // //                     Text(widget.question['output_format'],
// // //                         style: TextStyle(fontSize: 16)),
// // //                     SizedBox(height: 16),
// // //                     Text("Constraints",
// // //                         style: TextStyle(
// // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // //                     Text(widget.question['constraints'],
// // //                         style: TextStyle(fontSize: 16)),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //           VerticalDivider(
// // //               width: 1, color: Colors.grey), // Divider between panels

// // //           // Right Panel: Code editor and results
// // //           Expanded(
// // //             flex: 3,
// // //             child: SingleChildScrollView(
// // //               controller: _rightPanelScrollController,
// // //               child: Padding(
// // //                 padding: EdgeInsets.all(16.0),
// // //                 child: Column(
// // //                   children: [
// // //                     Text("Select Language",
// // //                         style: TextStyle(
// // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // //                     DropdownButton<String>(
// // //                       value: _selectedLanguage,
// // //                       onChanged: (String? newValue) {
// // //                         setState(() {
// // //                           _selectedLanguage = newValue;
// // //                         });
// // //                       },
// // //                       items: (widget.question['allowed_languages']
// // //                               as List<dynamic>)
// // //                           .cast<String>()
// // //                           .map<DropdownMenuItem<String>>((String language) {
// // //                         return DropdownMenuItem<String>(
// // //                           value: language,
// // //                           child: Text(language),
// // //                         );
// // //                       }).toList(),
// // //                     ),
// // //                     Container(
// // //                       height: MediaQuery.of(context).size.height / 2,
// // //                       child: TextField(
// // //                         controller: _codeController,
// // //                         focusNode: _focusNode,
// // //                         maxLines: null,
// // //                         decoration: InputDecoration(
// // //                           hintText: 'Write your code here...',
// // //                           filled: true,
// // //                           fillColor: Colors.black,
// // //                         ),
// // //                         style: TextStyle(
// // //                             fontSize: 16,
// // //                             color: Colors.white,
// // //                             fontFamily: 'monospace'),
// // //                       ),
// // //                     ),
// // //                     SizedBox(height: 16),
// // //                     ElevatedButton(
// // //                       onPressed: _runCode, // Execute the code when pressed
// // //                       child: Text('Run Code'),
// // //                     ),
// // //                     SizedBox(height: 16),
// // //                     if (testResults.isNotEmpty)
// // //                       TestCaseResultsTable(testResults: testResults),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }

// // // // Model for test case result
// // // class TestCaseResult {
// // //   final String testCase;
// // //   final String expectedResult;
// // //   final String actualResult;
// // //   final bool passed;

// // //   TestCaseResult({
// // //     required this.testCase,
// // //     required this.expectedResult,
// // //     required this.actualResult,
// // //     required this.passed,
// // //   });
// // // }

// // // // Widget to display test case results in a table
// // // class TestCaseResultsTable extends StatelessWidget {
// // //   final List<TestCaseResult> testResults;

// // //   TestCaseResultsTable({required this.testResults});

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text("Test Results",
// // //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // //         Divider(thickness: 2),
// // //         Column(
// // //           children: testResults.map((result) {
// // //             return Row(
// // //               children: [
// // //                 Expanded(child: Text("Input: ${result.testCase}")),
// // //                 Expanded(child: Text("Expected: ${result.expectedResult}")),
// // //                 Expanded(child: Text("Actual: ${result.actualResult}")),
// // //                 Expanded(child: Text(result.passed ? "Passed" : "Failed")),
// // //               ],
// // //             );
// // //           }).toList(),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // // }




// // // // // import 'package:flutter/material.dart';

// // // // // class CodingQuestionDetailPage extends StatefulWidget {
// // // // //   final Map<String, dynamic> question;

// // // // //   const CodingQuestionDetailPage({Key? key, required this.question})
// // // // //       : super(key: key);

// // // // //   @override
// // // // //   State<CodingQuestionDetailPage> createState() =>
// // // // //       _CodingQuestionDetailPageState();
// // // // // }

// // // // // class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage> {
// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     TextEditingController _codeController = TextEditingController();

// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         title: Text(widget.question['title']),
// // // // //       ),
// // // // //       body: Row(
// // // // //         children: [
// // // // //           // Left Side: Question details
// // // // //           Expanded(
// // // // //             flex: 2,
// // // // //             child: Padding(
// // // // //               padding: EdgeInsets.all(16.0),
// // // // //               child: SingleChildScrollView(
// // // // //                 child: Column(
// // // // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                   children: [
// // // // //                     Text(
// // // // //                       widget.question['title'],
// // // // //                       style:
// // // // //                           TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
// // // // //                     ),
// // // // //                     SizedBox(height: 16),
// // // // //                     Text("Description",
// // // // //                         style: TextStyle(
// // // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                     SizedBox(height: 8),
// // // // //                     Text(widget.question['description'],
// // // // //                         style: TextStyle(fontSize: 16)),
// // // // //                     SizedBox(height: 16),
// // // // //                     Text("Input Format",
// // // // //                         style: TextStyle(
// // // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                     SizedBox(height: 8),
// // // // //                     Text(widget.question['input_format'],
// // // // //                         style: TextStyle(fontSize: 16)),
// // // // //                     SizedBox(height: 16),
// // // // //                     Text("Output Format",
// // // // //                         style: TextStyle(
// // // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                     SizedBox(height: 8),
// // // // //                     Text(widget.question['output_format'],
// // // // //                         style: TextStyle(fontSize: 16)),
// // // // //                     SizedBox(height: 16),
// // // // //                     Text("Test Cases",
// // // // //                         style: TextStyle(
// // // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
                    // SizedBox(height: 8),
                    // Column(
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: List<Widget>.generate(
                    //     widget.question['test_cases'].length,
                    //     (index) {
                    //       final testCase = widget.question['test_cases'][index];
                    //       return Card(
                    //         margin: EdgeInsets.symmetric(vertical: 8),
                    //         child: Padding(
                    //           padding: const EdgeInsets.all(12.0),
                    //           child: Column(
                    //             crossAxisAlignment: CrossAxisAlignment.start,
                    //             children: [
                    //               Text("Input: ${testCase['input']}",
                    //                   style: TextStyle(fontSize: 16)),
                    //               Text("Output: ${testCase['output']}",
                    //                   style: TextStyle(fontSize: 16)),
                    //               if (testCase['is_public'])
                    //                 Text(
                    //                     "Explanation: ${testCase['explanation'] ?? ''}",
                    //                     style: TextStyle(fontSize: 16)),
                    //             ],
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
// // // // //                     SizedBox(height: 16),
// // // // //                     Text("Constraints",
// // // // //                         style: TextStyle(
// // // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                     SizedBox(height: 8),
// // // // //                     Text(widget.question['constraints'],
// // // // //                         style: TextStyle(fontSize: 16)),
                    // SizedBox(height: 16),
                    // Text("Difficulty",
                    //     style: TextStyle(
                    //         fontSize: 18, fontWeight: FontWeight.bold)),
                    // SizedBox(height: 8),
                    // Text(widget.question['difficulty'],
                    //     style: TextStyle(fontSize: 16)),
                    // SizedBox(height: 16),
// // // // //                     Text("Allowed Languages",
// // // // //                         style: TextStyle(
// // // // //                             fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                     SizedBox(height: 8),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: List<Widget>.generate(
//                         widget.question['allowed_languages'].length,
//                         (index) => Text(
//                           "- ${widget.question['allowed_languages'][index]}",
//                           style: TextStyle(fontSize: 16),
//                         ),
//                       ),
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //           VerticalDivider(
// // // // //               width: 1,
// // // // //               color: Colors.grey), // Divider between question and code editor

// // // // //           // Right Side: Code editor and action buttons
// // // // //           Expanded(
// // // // //             flex: 3,
// // // // //             child: Padding(
// // // // //               padding: EdgeInsets.all(16.0),
// // // // //               child: Column(
// // // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                 children: [
// // // // //                   Text("Code Editor",
// // // // //                       style:
// // // // //                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                   SizedBox(height: 8),
// // // // //                   Expanded(
// // // // //                     child: Container(
// // // // //                       decoration: BoxDecoration(
// // // // //                         color: Colors.black12,
// // // // //                         borderRadius: BorderRadius.circular(8),
// // // // //                       ),
// // // // //                       padding: EdgeInsets.all(8.0),
// // // // //                       child: TextField(
// // // // //                         controller: _codeController,
// // // // //                         maxLines: null,
// // // // //                         decoration: InputDecoration.collapsed(
// // // // //                           hintText: 'Write your code here...',
// // // // //                         ),
// // // // //                         style: TextStyle(fontSize: 16, fontFamily: 'monospace'),
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                   SizedBox(height: 16),
// // // // //                   Row(
// // // // //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // // // //                     children: [
// // // // //                       ElevatedButton(
// // // // //                         onPressed: () {
// // // // //                           // Add logic to test the code
// // // // //                           print(
// // // // //                               "Test button pressed with code: ${_codeController.text}");
// // // // //                         },
// // // // //                         child: Text("Test"),
// // // // //                       ),
// // // // //                       ElevatedButton(
// // // // //                         onPressed: () {
// // // // //                           // Add logic to run the code
// // // // //                           print(
// // // // //                               "Run button pressed with code: ${_codeController.text}");
// // // // //                         },
// // // // //                         child: Text("Run"),
// // // // //                       ),
// // // // //                       ElevatedButton(
// // // // //                         onPressed: () {
// // // // //                           // Add logic to submit the code
// // // // //                           print(
// // // // //                               "Submit button pressed with code: ${_codeController.text}");
// // // // //                         },
// // // // //                         child: Text("Submit"),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }
// // // // // }
