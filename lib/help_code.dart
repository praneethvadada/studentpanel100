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