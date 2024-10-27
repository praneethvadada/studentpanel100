import 'package:flutter/material.dart';

class CodingQuestionDetailPage extends StatelessWidget {
  final Map<String, dynamic> question;

  const CodingQuestionDetailPage({Key? key, required this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController _codeController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(question['title']),
      ),
      body: Row(
        children: [
          // Left Side: Question details
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question['title'],
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16),
                    Text("Description",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(question['description'],
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text("Input Format",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(question['input_format'],
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text("Output Format",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(question['output_format'],
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text("Test Cases",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List<Widget>.generate(
                        question['test_cases'].length,
                        (index) {
                          final testCase = question['test_cases'][index];
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
                    Text("Constraints",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(question['constraints'],
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text("Difficulty",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(question['difficulty'],
                        style: TextStyle(fontSize: 16)),
                    SizedBox(height: 16),
                    Text("Allowed Languages",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List<Widget>.generate(
                        question['allowed_languages'].length,
                        (index) => Text(
                          "- ${question['allowed_languages'][index]}",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          VerticalDivider(
              width: 1,
              color: Colors.grey), // Divider between question and code editor

          // Right Side: Code editor and action buttons
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Code Editor",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _codeController,
                        maxLines: null,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Write your code here...',
                        ),
                        style: TextStyle(fontSize: 16, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Add logic to test the code
                          print(
                              "Test button pressed with code: ${_codeController.text}");
                        },
                        child: Text("Test"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Add logic to run the code
                          print(
                              "Run button pressed with code: ${_codeController.text}");
                        },
                        child: Text("Run"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Add logic to submit the code
                          print(
                              "Submit button pressed with code: ${_codeController.text}");
                        },
                        child: Text("Submit"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';

// class CodingQuestionDetailPage extends StatelessWidget {
//   final Map<String, dynamic> question;

//   const CodingQuestionDetailPage({Key? key, required this.question})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(question['title']),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 question['title'],
//                 style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 "Description",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(question['description'], style: TextStyle(fontSize: 16)),
//               SizedBox(height: 16),
//               Text(
//                 "Input Format",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(question['input_format'], style: TextStyle(fontSize: 16)),
//               SizedBox(height: 16),
//               Text(
//                 "Output Format",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(question['output_format'], style: TextStyle(fontSize: 16)),
//               SizedBox(height: 16),
//               Text(
//                 "Test Cases",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: List<Widget>.generate(
//                   question['test_cases'].length,
//                   (index) {
//                     final testCase = question['test_cases'][index];
//                     return Card(
//                       margin: EdgeInsets.symmetric(vertical: 8),
//                       child: Padding(
//                         padding: const EdgeInsets.all(12.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Input: ${testCase['input']}",
//                                 style: TextStyle(fontSize: 16)),
//                             Text("Output: ${testCase['output']}",
//                                 style: TextStyle(fontSize: 16)),
//                             if (testCase['is_public'])
//                               Text(
//                                   "Explanation: ${testCase['explanation'] ?? ''}",
//                                   style: TextStyle(fontSize: 16)),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               SizedBox(height: 16),
//               Text(
//                 "Constraints",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(question['constraints'], style: TextStyle(fontSize: 16)),
//               SizedBox(height: 16),
//               Text(
//                 "Difficulty",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Text(question['difficulty'], style: TextStyle(fontSize: 16)),
//               SizedBox(height: 16),
//               Text(
//                 "Allowed Languages",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: List<Widget>.generate(
//                   question['allowed_languages'].length,
//                   (index) => Text(
//                     "- ${question['allowed_languages'][index]}",
//                     style: TextStyle(fontSize: 16),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
