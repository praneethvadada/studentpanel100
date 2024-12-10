// import 'package:flutter/material.dart';
// import 'package:studentpanel100/services/api_service.dart';

// class MCQQuestionWidget extends StatefulWidget {
//   final Map<String, dynamic> mcqQuestion;

//   const MCQQuestionWidget({Key? key, required this.mcqQuestion})
//       : super(key: key);

//   @override
//   _MCQQuestionWidgetState createState() => _MCQQuestionWidgetState();
// }

// class _MCQQuestionWidgetState extends State<MCQQuestionWidget> {
//   List<int> selectedAnswers = [];
//   bool isSubmitted = false;

//   @override
//   void initState() {
//     super.initState();
//     loadInitialState();
//   }

//   void loadInitialState() {
//     final question = widget.mcqQuestion;
//     selectedAnswers = question['submitted_options'] != null
//         ? List<int>.from(question['submitted_options'])
//         : [];
//     isSubmitted = question['is_attempted'] ?? false;
//   }

//   // Future<void> submitAssessmentMcqAnswer() async {
//   //   final question = widget.mcqQuestion;
//   //   final correctAnswers = question['correct_answers'] ?? [];
//   //   bool isAnswerCorrect = false;
//   //   int points = 0;

//   //   // Map difficulty levels to points
//   //   final difficultyMapping = {
//   //     'Level1': 100,
//   //     'Level2': 200,
//   //     'Level3': 300,
//   //     'Level4': 400,
//   //     'Level5': 500,
//   //   };
//   //   points = difficultyMapping[question['difficulty']] ?? 100;

//   //   // Check if the answer is correct
//   //   if (question['is_single_answer'] == true) {
//   //     // Single answer
//   //     isAnswerCorrect = selectedAnswers.isNotEmpty &&
//   //         correctAnswers.contains(question['options'][selectedAnswers[0]]);
//   //   } else {
//   //     // Multiple answers
//   //     isAnswerCorrect = selectedAnswers.length == correctAnswers.length &&
//   //         selectedAnswers.every(
//   //             (index) => correctAnswers.contains(question['options'][index]));
//   //   }

//   //   // Assign points only if the answer is correct
//   //   if (!isAnswerCorrect) {
//   //     points = 0;
//   //   }

//   //   final data = {
//   //     'round_id': question['round_id'],
//   //     'question_id': question['id'],
//   //     'submitted_options': selectedAnswers,
//   //     'points': points,
//   //   };

//   //   try {
//   //     final response = await ApiService.postData(
//   //       '/assessment-mcq-question-submit',
//   //       data,
//   //       context,
//   //     );
//   //     setState(() {
//   //       isSubmitted = true;
//   //       question['is_attempted'] = true;
//   //       question['points'] = points;
//   //     });
//   //     print("[DEBUG] MCQ Answer submitted successfully: $response");
//   //   } catch (error) {
//   //     print("[DEBUG] Error submitting MCQ Answer: $error");
//   //   }
//   // }

//   Future<void> submitAssessmentMcqAnswer() async {
//     final question = widget.mcqQuestion;
//     final correctAnswers = question['correct_answers'] ?? [];
//     bool isAnswerCorrect = false;
//     int points = 0;

//     // Map difficulty levels to points
//     final difficultyMapping = {
//       'Level1': 100,
//       'Level2': 200,
//       'Level3': 300,
//       'Level4': 400,
//       'Level5': 500,
//     };
//     points = difficultyMapping[question['difficulty']] ?? 100;

//     // Check if the answer is correct
//     if (question['is_single_answer'] == true) {
//       // Single answer
//       isAnswerCorrect = selectedAnswers.isNotEmpty &&
//           correctAnswers.contains(question['options'][selectedAnswers[0]]);
//     } else {
//       // Multiple answers
//       isAnswerCorrect = selectedAnswers.length == correctAnswers.length &&
//           selectedAnswers.every(
//               (index) => correctAnswers.contains(question['options'][index]));
//     }

//     // Assign points only if the answer is correct
//     if (!isAnswerCorrect) {
//       points = 0;
//     }

//     // Get student_id from the API or JWT
//     final studentId = await ApiService.getStudentIdFromToken();

//     final data = {
//       'student_id': studentId, // Ensure student_id is included
//       'round_id': question['round_id'],
//       'question_id': question['id'],
//       'submitted_options': selectedAnswers,
//       'points': points,
//     };

//     try {
//       final response = await ApiService.postData(
//         '/assessment-mcq-question-submit',
//         data,
//         context,
//       );
//       setState(() {
//         isSubmitted = true;
//         question['is_attempted'] = true;
//         question['points'] = points;
//       });
//       print("[DEBUG] MCQ Answer submitted successfully: $response");
//     } catch (error) {
//       print("[DEBUG] Error submitting MCQ Answer: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final question = widget.mcqQuestion;
//     final isSingleAnswer = question['is_single_answer'] ?? false;
//     final correctAnswers = question['correct_answers'] ?? [];

//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Question Title
//             Text(
//               question['title'],
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),

//             // Options
//             ...List<Widget>.generate(
//               question['options'].length,
//               (optionIndex) {
//                 final option = question['options'][optionIndex];
//                 final isCorrect = correctAnswers.contains(option);
//                 final isSelected = selectedAnswers.contains(optionIndex);

//                 // Determine background color
//                 Color? backgroundColor;
//                 if (isSubmitted) {
//                   if (isSelected && isCorrect) {
//                     backgroundColor =
//                         const Color(0Xffdaf3e8); // Correct selection
//                   } else if (isSelected && !isCorrect) {
//                     backgroundColor =
//                         const Color(0Xfffee5e7); // Incorrect selection
//                   } else if (isCorrect) {
//                     backgroundColor = const Color(0Xffdaf3e8); // Correct option
//                   }
//                 }

//                 return Container(
//                   color: backgroundColor,
//                   child: ListTile(
//                     leading: isSingleAnswer
//                         ? Radio<int>(
//                             value: optionIndex,
//                             groupValue: selectedAnswers.isNotEmpty
//                                 ? selectedAnswers[0]
//                                 : -1,
//                             onChanged: isSubmitted
//                                 ? null
//                                 : (value) {
//                                     setState(() {
//                                       selectedAnswers = [value!];
//                                     });
//                                   },
//                           )
//                         : Checkbox(
//                             value: selectedAnswers.contains(optionIndex),
//                             onChanged: isSubmitted
//                                 ? null
//                                 : (value) {
//                                     setState(() {
//                                       if (value == true) {
//                                         selectedAnswers.add(optionIndex);
//                                       } else {
//                                         selectedAnswers.remove(optionIndex);
//                                       }
//                                     });
//                                   },
//                           ),
//                     title: Text(option),
//                   ),
//                 );
//               },
//             ),

//             const SizedBox(height: 16),

//             // Submit Button
//             if (!isSubmitted)
//               ElevatedButton(
//                 onPressed: submitAssessmentMcqAnswer,
//                 child: const Text('Submit'),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:studentpanel100/services/api_service.dart';

// // class MCQQuestionWidget extends StatefulWidget {
// //   final Map<String, dynamic> mcqQuestion;

// //   const MCQQuestionWidget({Key? key, required this.mcqQuestion})
// //       : super(key: key);

// //   @override
// //   _MCQQuestionWidgetState createState() => _MCQQuestionWidgetState();
// // }

// // class _MCQQuestionWidgetState extends State<MCQQuestionWidget> {
// //   List<int> selectedAnswers = [];
// //   bool isSubmitted = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     loadInitialState();
// //   }

// //   void loadInitialState() {
// //     final question = widget.mcqQuestion;
// //     selectedAnswers = question['submitted_options'] != null
// //         ? List<int>.from(question['submitted_options'])
// //         : [];
// //     isSubmitted = question['is_attempted'] ?? false;
// //   }

// //   // Future<void> submitAnswer() async {
// //   //   final question = widget.mcqQuestion;
// //   //   final correctAnswers = question['correct_answers'] ?? [];
// //   //   bool isAnswerCorrect = false;

// //   //   // Check if the answer is correct
// //   //   if (question['is_single_answer'] == true) {
// //   //     isAnswerCorrect = selectedAnswers.isNotEmpty &&
// //   //         correctAnswers.contains(question['options'][selectedAnswers[0]]);
// //   //   } else {
// //   //     isAnswerCorrect = selectedAnswers.length == correctAnswers.length &&
// //   //         selectedAnswers.every(
// //   //             (index) => correctAnswers.contains(question['options'][index]));
// //   //   }

// //   //   setState(() {
// //   //     isSubmitted = true;
// //   //     question['is_attempted'] = true;
// //   //   });

// //   //   ScaffoldMessenger.of(context).showSnackBar(
// //   //     SnackBar(
// //   //       content:
// //   //           Text(isAnswerCorrect ? 'Correct Answer!' : 'Incorrect Answer.'),
// //   //       backgroundColor: isAnswerCorrect ? Colors.green : Colors.red,
// //   //     ),
// //   //   );
// //   // }

// // Future<void> submitAssessmentMcqAnswer() async {
// //   final question = widget.questions[currentIndex];
// //   final correctAnswers = question['correct_answers'] ?? [];
// //   bool isAnswerCorrect = false;
// //   int points = 0;

// //   // Determine Points Based on Difficulty
// //   final difficultyMapping = {
// //     'Level1': 100,
// //     'Level2': 200,
// //     'Level3': 300,
// //     'Level4': 400,
// //     'Level5': 500,
// //   };
// //   points = difficultyMapping[question['difficulty']] ?? 100;

// //   // Check if the Answer is Correct
// //   if (question['is_single_answer'] == 1) {
// //     // Single Answer
// //     isAnswerCorrect = selectedAnswers.isNotEmpty &&
// //         correctAnswers.contains(question['options'][selectedAnswers[0]]);
// //   } else {
// //     // Multiple Answers
// //     isAnswerCorrect = selectedAnswers.length == correctAnswers.length &&
// //         selectedAnswers.every(
// //             (index) => correctAnswers.contains(question['options'][index]));
// //   }

// //   // Assign Points Only if the Answer is Correct
// //   if (!isAnswerCorrect) {
// //     points = 0;
// //   }

// //   final data = {
// //     'round_id': question['round_id'],
// //     'question_id': question['id'],
// //     'submitted_options': selectedAnswers,
// //     'points': points,
// //   };

// //   try {
// //     final response = await ApiService.postData(
// //       '/assessment-mcq-question-submit', // Use the new API endpoint
// //       data,
// //       context,
// //     );
// //     setState(() {
// //       isSubmitted = true;
// //       question['is_attempted'] = true; // Update State
// //       question['points'] = points;
// //     });
// //     print("[DEBUG] MCQ Answer submitted successfully: $response");
// //   } catch (error) {
// //     print("[DEBUG] Error submitting MCQ Answer: $error");
// //   }
// // }

// //   @override
// //   Widget build(BuildContext context) {
// //     final question = widget.mcqQuestion;
// //     final isSingleAnswer = question['is_single_answer'] ?? false;
// //     final correctAnswers = question['correct_answers'] ?? [];

// //     return Card(
// //       margin: const EdgeInsets.all(8.0),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // Question Title
// //             Text(
// //               question['title'],
// //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 8),

// //             // Options
// //             ...List<Widget>.generate(
// //               question['options'].length,
// //               (optionIndex) {
// //                 final option = question['options'][optionIndex];
// //                 final isCorrect = correctAnswers.contains(option);
// //                 final isSelected = selectedAnswers.contains(optionIndex);

// //                 // Determine Background Color
// //                 Color? backgroundColor;
// //                 if (isSubmitted) {
// //                   if (isSelected && isCorrect) {
// //                     backgroundColor =
// //                         const Color(0Xffdaf3e8); // Correct Selection
// //                   } else if (isSelected && !isCorrect) {
// //                     backgroundColor =
// //                         const Color(0Xfffee5e7); // Incorrect Selection
// //                   } else if (isCorrect) {
// //                     backgroundColor = const Color(0Xffdaf3e8); // Correct Option
// //                   }
// //                 }

// //                 return Container(
// //                   color: backgroundColor,
// //                   child: ListTile(
// //                     leading: isSingleAnswer
// //                         ? Radio<int>(
// //                             value: optionIndex,
// //                             groupValue: selectedAnswers.isNotEmpty
// //                                 ? selectedAnswers[0]
// //                                 : -1,
// //                             onChanged: isSubmitted
// //                                 ? null // Disable after submission
// //                                 : (value) {
// //                                     setState(() {
// //                                       selectedAnswers = [value!];
// //                                     });
// //                                   },
// //                           )
// //                         : Checkbox(
// //                             value: selectedAnswers.contains(optionIndex),
// //                             onChanged: isSubmitted
// //                                 ? null // Disable after submission
// //                                 : (value) {
// //                                     setState(() {
// //                                       if (value == true) {
// //                                         selectedAnswers.add(optionIndex);
// //                                       } else {
// //                                         selectedAnswers.remove(optionIndex);
// //                                       }
// //                                     });
// //                                   },
// //                           ),
// //                     title: Text(option),
// //                   ),
// //                 );
// //               },
// //             ),

// //             const SizedBox(height: 16),

// //             // Submit Button
// //             if (!isSubmitted)
// //               ElevatedButton(
// //                 onPressed: submitAssessmentMcqAnswer,
// //                 child: const Text('Submit'),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }

// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:studentpanel100/services/api_service.dart';
// // import 'dart:async';
// // import 'package:flutter/material.dart';
// // import 'package:intl/intl.dart';
// // import 'package:studentpanel100/services/api_service.dart';



// // class McqQuestionDetailPage extends StatefulWidget {
// //   final List<dynamic> questions;
// //   final int currentIndex;

// //   const McqQuestionDetailPage({
// //     Key? key,
// //     required this.questions,
// //     required this.currentIndex,
// //   }) : super(key: key);

// //   @override
// //   _McqQuestionDetailPageState createState() => _McqQuestionDetailPageState();
// // }

// // class _McqQuestionDetailPageState extends State<McqQuestionDetailPage> {
// //   late int currentIndex;
// //   List<int> selectedAnswers = [];
// //   bool isSubmitted = false;
// //   bool isMarked = false;
// //   bool isReported = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     currentIndex = widget.currentIndex;
// //     loadQuestionState();
// //   }

// //   void loadQuestionState() {
// //     final question = widget.questions[currentIndex];
// //     selectedAnswers = question['submitted_options'] != null
// //         ? List<int>.from(question['submitted_options'])
// //         : [];
// //     isSubmitted = question['is_attempted'] ?? false;
// //   }

// //   Future<void> submitAnswer() async {
// //     final question = widget.questions[currentIndex];
// //     final correctAnswers = question['correct_answers'] ?? [];
// //     bool isAnswerCorrect = false;
// //     int points = 0;

// //     // Determine Points Based on Difficulty
// //     switch (question['difficulty']) {
// //       case 'Level1':
// //         points = 100;
// //         break;
// //       case 'Level2':
// //         points = 200;
// //         break;
// //       case 'Level3':
// //         points = 300;
// //         break;
// //       case 'Level4':
// //         points = 400;
// //         break;
// //       case 'Level5':
// //         points = 500;
// //         break;
// //       default:
// //         points = 100;
// //     }

// //     // Check if the Answer is Correct
// //     if (question['is_single_answer'] == true) {
// //       // Single Answer
// //       isAnswerCorrect = selectedAnswers.isNotEmpty &&
// //           correctAnswers.contains(question['options'][selectedAnswers[0]]);
// //     } else {
// //       // Multiple Answers
// //       isAnswerCorrect = selectedAnswers.length == correctAnswers.length &&
// //           selectedAnswers.every(
// //               (index) => correctAnswers.contains(question['options'][index]));
// //     }

// //     // Assign Points Only if the Answer is Correct
// //     if (!isAnswerCorrect) {
// //       points = 0;
// //     }

// //     final data = {
// //       'student_id': await ApiService.getStudentIdFromToken(),
// //       'domain_id': question['mcqdomain_id'],
// //       'question_id': question['id'],
// //       'submitted_options': selectedAnswers,
// //       'points': points,
// //     };

// //     try {
// //       await ApiService.postData('/submit-answer', data, context);
// //       setState(() {
// //         isSubmitted = true;
// //         question['is_attempted'] = true; // Update State
// //         question['points'] = points;
// //       });
// //     } catch (error) {
// //       print("Error submitting answer: $error");
// //     }
// //   }

// //   void navigateToNextQuestion() {
// //     if (currentIndex < widget.questions.length - 1) {
// //       setState(() {
// //         currentIndex++;
// //         loadQuestionState();
// //       });
// //     }
// //   }

// //   void navigateToPreviousQuestion() {
// //     if (currentIndex > 0) {
// //       setState(() {
// //         currentIndex--;
// //         loadQuestionState();
// //       });
// //     }
// //   }

// //   void navigateToQuestion(int index) {
// //     setState(() {
// //       currentIndex = index;
// //       loadQuestionState();
// //     });
// //   }

// //   Future<void> toggleMarkQuestion() async {
// //     final question = widget.questions[currentIndex];
// //     final data = {
// //       // 'student_id': /* Add logic to get student_id from token */,
// //       "student_id": await ApiService.getStudentIdFromToken(),
// //       'domain_id': question['mcqdomain_id'],
// //       'question_id': question['id'],
// //       'marked': !isMarked,
// //     };

// //     try {
// //       await ApiService.postData('/mark-question', data, context);
// //       setState(() {
// //         isMarked = !isMarked;
// //         question['marked'] = isMarked ? 1 : 0;
// //       });
// //     } catch (error) {
// //       print("Error marking question: $error");
// //     }
// //   }

// //   Future<void> reportQuestion() async {
// //     TextEditingController reportController = TextEditingController();
// //     final question = widget.questions[currentIndex];

// //     showDialog(
// //       context: context,
// //       builder: (context) {
// //         return AlertDialog(
// //           title: Text("Report Question"),
// //           content: TextField(
// //             controller: reportController,
// //             decoration: InputDecoration(hintText: "Enter report reason"),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.of(context).pop(),
// //               child: Text("Cancel"),
// //             ),
// //             TextButton(
// //               onPressed: () async {
// //                 Navigator.of(context).pop();
// //                 final data = {
// //                   // 'student_id': /* Add logic to get student_id from token */,
// //                   "student_id": await ApiService.getStudentIdFromToken(),
// //                   'domain_id': question['mcqdomain_id'],
// //                   'question_id': question['id'],
// //                   'is_reported': true,
// //                   'reported_text': reportController.text,
// //                 };

// //                 try {
// //                   await ApiService.postData('/report-question', data, context);
// //                   setState(() {
// //                     isReported = true;
// //                     question['is_reported'] = 1;
// //                     question['reported_text'] = reportController.text;
// //                   });
// //                 } catch (error) {
// //                   print("Error reporting question: $error");
// //                 }
// //               },
// //               child: Text("Submit"),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final question = widget.questions[currentIndex];
// //     final isSingleAnswer = question['is_single_answer'] ?? false;
// //     final correctAnswers = question['correct_answers'] ?? [];
// //     final codeSnippets = question['code_snippets'] ?? '';
// //     final points = question['points'] ?? 0;

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: Text('Question ${currentIndex + 1}'),
// //       ),
// //       body: Row(
// //         children: [
// //           Container(
// //             width: MediaQuery.of(context).size.width * 0.05,
// //             height: MediaQuery.of(context).size.height * 0.95,
// //             child: Padding(
// //               padding: const EdgeInsets.all(8.0),
// //               child: Container(
// //                 height: 250,
// //                 width: 250,
// //                 child: ListView.builder(
// //                   itemCount: widget.questions.length,
// //                   itemBuilder: (context, index) {
// //                     bool isQuestionSubmitted =
// //                         widget.questions[index]['is_attempted'] == true;
// //                     return ElevatedButton(
// //                       onPressed: () => navigateToQuestion(index),
// //                       style: ElevatedButton.styleFrom(
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: new BorderRadius.circular(30.0),
// //                         ),
// //                         backgroundColor: index == currentIndex
// //                             ? const Color.fromARGB(255, 199, 105, 240)
// //                             : isQuestionSubmitted
// //                                 ? const Color.fromARGB(255, 239, 221, 247)
// //                                 : const Color.fromARGB(255, 253, 252, 252),
// //                         padding: const EdgeInsets.all(8.0),
// //                       ),
// //                       child: Text(
// //                         '${index + 1}',
// //                         style: TextStyle(
// //                           color:
// //                               isQuestionSubmitted ? Colors.black : Colors.black,
// //                         ),
// //                       ),
// //                     );
// //                   },
// //                 ),
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: Padding(
// //               padding: const EdgeInsets.all(16.0),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // Question Title
// //                   Text(
// //                     question['title'],
// //                     style: const TextStyle(
// //                       fontSize: 18,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),

// //                   // Points Scored
// //                   if (isSubmitted)
// //                     Text(
// //                       'Points scored: $points',
// //                       style: const TextStyle(
// //                         fontSize: 16,
// //                         color: Colors.green,
// //                       ),
// //                     ),
// //                   const SizedBox(height: 10),

// //                   // Code Snippets
// //                   if (codeSnippets.isNotEmpty)
// //                     Container(
// //                       padding: const EdgeInsets.all(8.0),
// //                       color: Colors.grey[200],
// //                       child: Text(
// //                         codeSnippets,
// //                         style: const TextStyle(
// //                           fontFamily: 'monospace',
// //                           fontSize: 14,
// //                         ),
// //                       ),
// //                     ),
// //                   const SizedBox(height: 10),

// //                   // Options
// //                   ...List<Widget>.generate(
// //                     question['options'].length,
// //                     (optionIndex) {
// //                       final option = question['options'][optionIndex];
// //                       final isCorrect = correctAnswers.contains(option);
// //                       final isSelected = selectedAnswers.contains(optionIndex);

// //                       // Determine Background Color
// //                       Color? backgroundColor;
// //                       if (isSubmitted) {
// //                         if (isSelected && isCorrect) {
// //                           backgroundColor =
// //                               Color(0Xffdaf3e8); // Correct Selection
// //                         } else if (isSelected && !isCorrect) {
// //                           backgroundColor =
// //                               Color(0Xfffee5e7); // Incorrect Selection
// //                         } else if (isCorrect) {
// //                           backgroundColor = Color(0Xffdaf3e8); // Correct Option
// //                         }
// //                       }

// //                       return Container(
// //                         color: backgroundColor,
// //                         child: ListTile(
// //                           leading: isSingleAnswer
// //                               ? Radio<int>(
// //                                   value: optionIndex,
// //                                   groupValue: selectedAnswers.isNotEmpty
// //                                       ? selectedAnswers[0]
// //                                       : -1,
// //                                   onChanged: isSubmitted
// //                                       ? null // Disable after submission
// //                                       : (value) {
// //                                           setState(() {
// //                                             selectedAnswers = [value!];
// //                                           });
// //                                         },
// //                                 )
// //                               : Checkbox(
// //                                   value: selectedAnswers.contains(optionIndex),
// //                                   onChanged: isSubmitted
// //                                       ? null // Disable after submission
// //                                       : (value) {
// //                                           setState(() {
// //                                             if (value == true) {
// //                                               selectedAnswers.add(optionIndex);
// //                                             } else {
// //                                               selectedAnswers
// //                                                   .remove(optionIndex);
// //                                             }
// //                                           });
// //                                         },
// //                                 ),
// //                           title: Text(option),
// //                         ),
// //                       );
// //                     },
// //                   ),

// //                   const SizedBox(height: 20),

// //                   // Submit Button
// //                   if (!isSubmitted)
// //                     ElevatedButton(
// //                       onPressed: () async {
// //                         await submitAnswer();
// //                       },
// //                       child: const Text('Submit'),
// //                     ),
// //                   const SizedBox(height: 10),

// //                   // Navigation Buttons
// //                   Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       ElevatedButton(
// //                         onPressed: currentIndex > 0
// //                             ? () {
// //                                 setState(() {
// //                                   currentIndex--;
// //                                   loadQuestionState();
// //                                 });
// //                               }
// //                             : null,
// //                         child: const Text('Back'),
// //                       ),
// //                       ElevatedButton(
// //                         onPressed: currentIndex < widget.questions.length - 1
// //                             ? () {
// //                                 setState(() {
// //                                   currentIndex++;
// //                                   loadQuestionState();
// //                                 });
// //                               }
// //                             : null,
// //                         child: const Text('Next'),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // // class QuestionsScreen extends FullScreenEnforcedPage {
// // //   final List<dynamic> questions;

// // //   const QuestionsScreen({Key? key, required this.questions}) : super(key: key);

// // //   @override
// // //   _QuestionsScreenState createState() => _QuestionsScreenState();
// // // }

// // // class _QuestionsScreenState
// // //     extends FullScreenEnforcedPageState<QuestionsScreen> {
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: const Text('Questions'),
// // //       ),
// // //       body: isExamMode
// // //           ? ListView.builder(
// // //               itemCount: widget.questions.length,
// // //               itemBuilder: (context, index) {
// // //                 final question = widget.questions[index];
// // //                 if (question['codingQuestion'] != null) {
// // //                   return ListTile(
// // //                     title:
// // //                         Text('Coding: ${question['codingQuestion']['title']}'),
// // //                     subtitle: Text(question['codingQuestion']['description']),
// // //                   );
// // //                 } else if (question['mcqQuestion'] != null) {
// // //                   return ListTile(
// // //                     title: Text('MCQ: ${question['mcqQuestion']['title']}'),
// // //                     subtitle: Text(
// // //                         'Options: ${question['mcqQuestion']['options'].join(', ')}'),
// // //                   );
// // //                 } else {
// // //                   return const ListTile(
// // //                     title: Text('Unknown Question Type'),
// // //                   );
// // //                 }
// // //               },
// // //             )
// // //           : _buildBlankScreen(),
// // //     );
// // //   }

// // //   Widget _buildBlankScreen() {
// // //     return Center(
// // //       child: Column(
// // //         children: [
// // //           const Text(
// // //             'Screen Blank - Please return to full-screen mode',
// // //             style: TextStyle(fontSize: 18, color: Colors.red),
// // //           ),
// // //           const SizedBox(height: 20),
// // //           ElevatedButton(
// // //             onPressed: () {
// // //               if (fullscreenExitCount < 4) {
// // //                 _enterFullScreenMode();
// // //                 _restoreExamContent();
// // //               } else {
// // //                 _terminateExam(
// // //                     'Exam terminated due to multiple exits from full-screen mode.');
// // //               }
// // //             },
// // //             child: const Text('Return to Full-Screen'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }


// // // // import 'package:flutter/material.dart';
// // // // import 'package:intl/intl.dart';
// // // // import 'package:studentpanel100/services/api_service.dart';
// // // // import 'dart:async';
// // // // import 'package:flutter/material.dart';
// // // // import 'package:intl/intl.dart';
// // // // import 'package:studentpanel100/services/api_service.dart';

// // // // class RoundsScreen extends StatefulWidget {
// // // //   final int assessmentId;
// // // //   final String assessmentTitle;
// // // //   final int assessmentDurationMinutes;

// // // //   const RoundsScreen({
// // // //     Key? key,
// // // //     required this.assessmentId,
// // // //     required this.assessmentTitle,
// // // //     required this.assessmentDurationMinutes,
// // // //   }) : super(key: key);

// // // //   @override
// // // //   _RoundsScreenState createState() => _RoundsScreenState();
// // // // }

// // // // class _RoundsScreenState extends State<RoundsScreen> {
// // // //   late Timer _timer;
// // // //   Duration _remainingTime = Duration.zero;
// // // //   bool _isTimeUp = false;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     // Initialize the timer with the assessment duration
// // // //     _remainingTime = Duration(minutes: widget.assessmentDurationMinutes);
// // // //     _startTimer();
// // // //   }

// // // //   void _startTimer() {
// // // //     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
// // // //       if (_remainingTime.inSeconds <= 0) {
// // // //         setState(() {
// // // //           _isTimeUp = true;
// // // //           timer.cancel();
// // // //         });
// // // //       } else {
// // // //         setState(() {
// // // //           _remainingTime -= const Duration(seconds: 1);
// // // //         });
// // // //       }
// // // //     });
// // // //   }

// // // //   Future<List<dynamic>> _fetchRounds() async {
// // // //     return await ApiService().fetchRoundsByAssessmentId(widget.assessmentId);
// // // //   }

// // // //   Future<void> _fetchAndOpenQuestions(dynamic roundId) async {
// // // //     try {
// // // //       // Convert roundId to an integer if it's a string
// // // //       if (roundId is String) {
// // // //         roundId = int.parse(roundId); // Convert string to integer
// // // //       }

// // // //       // Fetch questions from the API
// // // //       final questions = await ApiService().fetchQuestionsByRoundId(roundId);

// // // //       if (questions != null && questions.isNotEmpty) {
// // // //         Navigator.push(
// // // //           context,
// // // //           MaterialPageRoute(
// // // //             builder: (context) => QuestionsScreen(questions: questions),
// // // //           ),
// // // //         );
// // // //       } else {
// // // //         ScaffoldMessenger.of(context).showSnackBar(
// // // //           const SnackBar(content: Text("No questions found for this round")),
// // // //         );
// // // //       }
// // // //     } catch (error) {
// // // //       ScaffoldMessenger.of(context).showSnackBar(
// // // //         SnackBar(content: Text("Failed to load questions: $error")),
// // // //       );
// // // //     }
// // // //   }

// // // //   @override
// // // //   void dispose() {
// // // //     _timer.cancel();
// // // //     super.dispose();
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       appBar: AppBar(
// // // //         title: Text('${widget.assessmentTitle} Rounds'),
// // // //       ),
// // // //       body: Column(
// // // //         children: [
// // // //           if (!_isTimeUp)
// // // //             Padding(
// // // //               padding: const EdgeInsets.all(16.0),
// // // //               child: Text(
// // // //                 'Time Remaining: ${_formatDuration(_remainingTime)}',
// // // //                 style:
// // // //                     const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// // // //               ),
// // // //             ),
// // // //           if (_isTimeUp)
// // // //             const Center(
// // // //               child: Text(
// // // //                 'Time is up!',
// // // //                 style: TextStyle(
// // // //                     fontSize: 20,
// // // //                     fontWeight: FontWeight.bold,
// // // //                     color: Colors.red),
// // // //               ),
// // // //             ),
// // // //           Expanded(
// // // //             child: FutureBuilder<List<dynamic>>(
// // // //               future: _fetchRounds(),
// // // //               builder: (context, snapshot) {
// // // //                 if (snapshot.connectionState == ConnectionState.waiting) {
// // // //                   return const Center(child: CircularProgressIndicator());
// // // //                 } else if (snapshot.hasError) {
// // // //                   return Center(child: Text('Error: ${snapshot.error}'));
// // // //                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
// // // //                   return const Center(child: Text('No rounds found.'));
// // // //                 } else {
// // // //                   final rounds = snapshot.data!;
// // // //                   return ListView.builder(
// // // //                     itemCount: rounds.length,
// // // //                     itemBuilder: (context, index) {
// // // //                       final round = rounds[index];
// // // //                       return ListTile(
// // // //                         title: Text('Round ${round['round_order']}'),
// // // //                         subtitle: Text(round['round_type']),
// // // //                         onTap: () {
// // // //                           _fetchAndOpenQuestions(round['id']);
// // // //                         },
// // // //                       );
// // // //                     },
// // // //                   );
// // // //                 }
// // // //               },
// // // //             ),
// // // //           ),
// // // //         ],
// // // //       ),
// // // //     );
// // // //   }

// // // //   String _formatDuration(Duration duration) {
// // // //     final minutes = duration.inMinutes % 60;
// // // //     final seconds = duration.inSeconds % 60;
// // // //     return '${duration.inHours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
// // // //   }
// // // // }
// // // // // import 'dart:async';
// // // // // import 'dart:ui';
// // // // // import 'dart:html' as html;
// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:flutter/services.dart';
// // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
// // // // // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
// // // // // import 'package:http/http.dart' as http;
// // // // // import 'package:studentpanel100/utils/shared_prefs.dart';
// // // // // import 'dart:convert';
// // // // // import 'package:studentpanel100/widgets/arrows_ui.dart';

// // // // // class CodingQuestionDetailPage extends StatefulWidget {
// // // // //   final Map<String, dynamic> question;

// // // // //   const CodingQuestionDetailPage({Key? key, required this.question})
// // // // //       : super(key: key);

// // // // //   @override
// // // // //   State<CodingQuestionDetailPage> createState() =>
// // // // //       _CodingQuestionDetailPageState();
// // // // // }

// // // // // class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage>
// // // // //     with SingleTickerProviderStateMixin {
// // // // //   late CodeController _codeController;
// // // // //   final FocusNode _focusNode = FocusNode();
// // // // //   List<TestCaseResult> testResults = [];
// // // // //   final ScrollController _rightPanelScrollController = ScrollController();
// // // // //   String? _selectedLanguage = "Please select a Language";
// // // // //   TextEditingController _customInputController = TextEditingController();
// // // // //   bool _iscustomInputfieldVisible = false;
// // // // //   double _dividerPosition = 0.5;
// // // // //   late TabController _tabController;
// // // // //   // Timer? _debounce;
// // // // //   // Timer? _autoSaveTimer;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     // _codeController.addListener(() {
// // // // //     //   if (_debounce?.isActive ?? false) _debounce?.cancel();
// // // // //     //   _debounce = Timer(const Duration(seconds: 2), () {
// // // // //     //     _autoSaveCode(_codeController.text.trim());
// // // // //     //   });
// // // // //     // }
// // // // //     // );

// // // // //     // // Start a timer for periodic auto-save
// // // // //     // _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
// // // // //     //   _autoSaveCode(_codeController.text.trim());
// // // // //     // });

// // // // //     // Attach beforeunload listener
// // // // //     // window.onBeforeUnload.listen((event) {
// // // // //     //   _autoSaveCode(_codeController.text.trim());
// // // // //     // });

// // // // //     // html.window.onBeforeUnload.listen((event) {
// // // // //     //   _autoSaveCode(_codeController.text.trim());
// // // // //     // });
// // // // //     print("[DEBUG] CodingQuestionDetailPage initState called");
// // // // //     _tabController = TabController(length: 3, vsync: this);
// // // // //     _codeController = CodeController(text: '''
// // // // // ***************************************************
// // // // // ***************  Select a Language  ***************
// // // // // ***************************************************
// // // // // ''');
// // // // //     _focusNode.addListener(() {
// // // // //       if (_focusNode.hasFocus) {
// // // // //         RawKeyboard.instance.addListener(_handleKeyPress);
// // // // //       } else {
// // // // //         RawKeyboard.instance.removeListener(_handleKeyPress);
// // // // //       }
// // // // //     });
// // // // //   }

// // // // //   @override
// // // // //   void dispose() {
// // // // //     print("[DEBUG] CodingQuestionDetailPage dispose called");

// // // // //     _tabController.dispose();
// // // // //     _codeController.dispose();
// // // // //     _focusNode.dispose();
// // // // //     _customInputController.dispose();
// // // // //     // _debounce?.cancel();
// // // // //     // _autoSaveTimer?.cancel();
// // // // //     super.dispose();
// // // // //   }

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();

// // // // // //     // Initialize _codeController first
// // // // // //     _codeController = CodeController(text: '''
// // // // // // ***************************************************
// // // // // // ***************  Select a Language  ***************
// // // // // // ***************************************************
// // // // // // ''');

// // // // // //     // Add listener for auto-save
// // // // // //     _codeController.addListener(() {
// // // // // //       if (_debounce?.isActive ?? false) _debounce?.cancel();
// // // // // //       _debounce = Timer(const Duration(seconds: 2), () {
// // // // // //         _autoSaveCode(_codeController.text.trim());
// // // // // //       });
// // // // // //     });

// // // // // //     // Start a timer for periodic auto-save
// // // // // //     _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
// // // // // //       _autoSaveCode(_codeController.text.trim());
// // // // // //     });

// // // // // //     // Attach beforeunload listener
// // // // // //     html.window.onBeforeUnload.listen((event) {
// // // // // //       _autoSaveCode(_codeController.text.trim());
// // // // // //     });

// // // // // //     print("[DEBUG] CodingQuestionDetailPage initState called");
// // // // // //     _tabController = TabController(length: 3, vsync: this);

// // // // // //     // Initialize _focusNode listener
// // // // // //     _focusNode.addListener(() {
// // // // // //       if (_focusNode.hasFocus) {
// // // // // //         RawKeyboard.instance.addListener(_handleKeyPress);
// // // // // //       } else {
// // // // // //         RawKeyboard.instance.removeListener(_handleKeyPress);
// // // // // //       }
// // // // // //     });
// // // // // //   }

// // // // //   void _handleKeyPress(RawKeyEvent event) {
// // // // //     if (event.isControlPressed &&
// // // // //         event.logicalKey == LogicalKeyboardKey.slash) {
// // // // //       _commentSelectedLines();
// // // // //     }
// // // // //   }

// // // // //   void _setStarterCode(String language) {
// // // // //     String starterCode;
// // // // //     switch (language.toLowerCase()) {
// // // // //       case 'python':
// // // // //         starterCode = '# Please Start Writing your Code here\n';
// // // // //         break;
// // // // //       case 'java':
// // // // //         starterCode = '''
// // // // // public class Main {
// // // // //     public static void main(String[] args) {
// // // // //         // Please Start Writing your Code from here
// // // // //     }
// // // // // }
// // // // // ''';
// // // // //         break;
// // // // //       case 'c':
// // // // //         starterCode = '// Please Start Writing your Code here\n';
// // // // //         break;
// // // // //       case 'cpp':
// // // // //         starterCode = '// Please Start Writing your Code here\n';
// // // // //         break;
// // // // //       default:
// // // // //         starterCode = '// Please Start Writing your Code here\n';
// // // // //     }
// // // // //     _codeController.text = starterCode;
// // // // //   }

// // // // //   void _commentSelectedLines() {
// // // // //     final selection = _codeController.selection;
// // // // //     final text = _codeController.text;
// // // // //     final commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

// // // // //     if (selection.isCollapsed) {
// // // // //       int lineStart = selection.start;
// // // // //       int lineEnd = selection.start;

// // // // //       while (lineStart > 0 && text[lineStart - 1] != '\n') lineStart--;
// // // // //       while (lineEnd < text.length && text[lineEnd] != '\n') lineEnd++;

// // // // //       final lineText = text.substring(lineStart, lineEnd);
// // // // //       final isCommented = lineText.trimLeft().startsWith(commentSyntax);

// // // // //       final newLineText = isCommented
// // // // //           ? lineText.replaceFirst(commentSyntax, '').trimLeft()
// // // // //           : '$commentSyntax $lineText';

// // // // //       final newText = text.replaceRange(lineStart, lineEnd, newLineText);
// // // // //       _codeController.value = _codeController.value.copyWith(
// // // // //         text: newText,
// // // // //         selection: TextSelection.collapsed(
// // // // //             offset: isCommented
// // // // //                 ? selection.start - commentSyntax.length - 1
// // // // //                 : selection.start + commentSyntax.length + 1),
// // // // //       );
// // // // //     } else {
// // // // //       final selectedText = text.substring(selection.start, selection.end);
// // // // //       final lines = selectedText.split('\n');
// // // // //       final allLinesCommented =
// // // // //           lines.every((line) => line.trimLeft().startsWith(commentSyntax));

// // // // //       final commentedLines = lines.map((line) {
// // // // //         return allLinesCommented
// // // // //             ? line.replaceFirst(commentSyntax, '').trimLeft()
// // // // //             : '$commentSyntax $line';
// // // // //       }).join('\n');

// // // // //       final newText =
// // // // //           text.replaceRange(selection.start, selection.end, commentedLines);

// // // // //       _codeController.value = _codeController.value.copyWith(
// // // // //         text: newText,
// // // // //         selection: TextSelection(
// // // // //           baseOffset: selection.start,
// // // // //           extentOffset: selection.start + commentedLines.length,
// // // // //         ),
// // // // //       );
// // // // //     }
// // // // //   }

// // // // //   Widget buildQuestionPanel() {
// // // // //     return Padding(
// // // // //       padding: EdgeInsets.all(16.0),
// // // // //       child: SingleChildScrollView(
// // // // //         child: Column(
// // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //           children: [
// // // // //             Text(widget.question['title'],
// // // // //                 style:
// // // // //                     const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // // // //             const SizedBox(height: 16),
// // // // //             const Text("Description",
// // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //             Text(widget.question['description'],
// // // // //                 style: TextStyle(fontSize: 16)),
// // // // //             const SizedBox(height: 16),
// // // // //             const Text("Input Format",
// // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //             Text(widget.question['input_format'],
// // // // //                 style: TextStyle(fontSize: 16)),
// // // // //             SizedBox(height: 16),
// // // // //             const Text("Output Format",
// // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //             Text(widget.question['output_format'],
// // // // //                 style: TextStyle(fontSize: 16)),
// // // // //             SizedBox(height: 16),
// // // // //             const Text("Constraints",
// // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //             Text(widget.question['constraints'],
// // // // //                 style: TextStyle(fontSize: 16)),
// // // // //             SizedBox(height: 8),
// // // // //             Column(
// // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // //               children: List<Widget>.generate(
// // // // //                 widget.question['test_cases'].length,
// // // // //                 (index) {
// // // // //                   final testCase = widget.question['test_cases'][index];
// // // // //                   return Card(
// // // // //                     margin: EdgeInsets.symmetric(vertical: 8),
// // // // //                     child: Padding(
// // // // //                       padding: const EdgeInsets.all(12.0),
// // // // //                       child: Column(
// // // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                         children: [
// // // // //                           Text("Input: ${testCase['input']}",
// // // // //                               style: TextStyle(fontSize: 16)),
// // // // //                           Text("Output: ${testCase['output']}",
// // // // //                               style: TextStyle(fontSize: 16)),
// // // // //                           if (testCase['is_public'])
// // // // //                             Text(
// // // // //                                 "Explanation: ${testCase['explanation'] ?? ''}",
// // // // //                                 style: TextStyle(fontSize: 16)),
// // // // //                         ],
// // // // //                       ),
// // // // //                     ),
// // // // //                   );
// // // // //                 },
// // // // //               ),
// // // // //             ),
// // // // //             SizedBox(height: 16),
// // // // //             Text("Difficulty",
// // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //             SizedBox(height: 8),
// // // // //             Text(widget.question['difficulty'], style: TextStyle(fontSize: 16)),
// // // // //             SizedBox(height: 16),
// // // // //             Text("Hello"),
// // // // //             if (widget.question['solutions'] != null &&
// // // // //                 widget.question['solutions'].isNotEmpty)
// // // // //               Column(
// // // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                 children: [
// // // // //                   SizedBox(height: 16),
// // // // //                   Text("Solutions",
// // // // //                       style:
// // // // //                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                   ...List<Widget>.generate(
// // // // //                     widget.question['solutions'].length,
// // // // //                     (index) {
// // // // //                       final solution = widget.question['solutions'][index];
// // // // //                       return Card(
// // // // //                         margin: EdgeInsets.symmetric(vertical: 8),
// // // // //                         child: Padding(
// // // // //                           padding: const EdgeInsets.all(12.0),
// // // // //                           child: Column(
// // // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                             children: [
// // // // //                               Text(
// // // // //                                 "Language: ${solution['language']}",
// // // // //                                 style: TextStyle(fontSize: 16),
// // // // //                               ),
// // // // //                               Text(
// // // // //                                 "Code:",
// // // // //                                 style: TextStyle(
// // // // //                                     fontSize: 16, fontWeight: FontWeight.bold),
// // // // //                               ),
// // // // //                               Container(
// // // // //                                 width: double.infinity,
// // // // //                                 color: Colors.black12,
// // // // //                                 child: Padding(
// // // // //                                   padding: EdgeInsets.all(8.0),
// // // // //                                   child: Text(
// // // // //                                     solution['code'],
// // // // //                                     style: TextStyle(
// // // // //                                         fontFamily: 'RobotoMono', fontSize: 14),
// // // // //                                   ),
// // // // //                                 ),
// // // // //                               ),
// // // // //                               if (solution['youtube_link'] != null)
// // // // //                                 Text(
// // // // //                                   "YouTube Link: ${solution['youtube_link']}",
// // // // //                                   style: TextStyle(fontSize: 16),
// // // // //                                 ),
// // // // //                             ],
// // // // //                           ),
// // // // //                         ),
// // // // //                       );
// // // // //                     },
// // // // //                   ),
// // // // //                 ],
// // // // //               ),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget codefieldbox() {
// // // // //     return Expanded(
// // // // //       child: Container(
// // // // //         // width: rightPanelWidth,
// // // // //         height: MediaQuery.of(context).size.height * 2,
// // // // //         color: Colors.white,
// // // // //         child: SingleChildScrollView(
// // // // //           controller: _rightPanelScrollController,
// // // // //           child: Padding(
// // // // //             padding: EdgeInsets.all(16.0),
// // // // //             child: Column(
// // // // //               children: [
// // // // //                 Text("Select Language",
// // // // //                     style:
// // // // //                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                 DropdownButton<String>(
// // // // //                   value: _selectedLanguage,
// // // // //                   onChanged: (String? newValue) {
// // // // //                     if (newValue != null &&
// // // // //                         newValue != "Please select a Language") {
// // // // //                       if (_selectedLanguage != "Please select a Language") {
// // // // //                         // Show alert if a language was previously selected
// // // // //                         showDialog(
// // // // //                           context: context,
// // // // //                           builder: (BuildContext context) {
// // // // //                             return AlertDialog(
// // // // //                               title: Text("Change Language"),
// // // // //                               content: Text(
// // // // //                                   "Changing the language will remove the current code. Do you want to proceed?"),
// // // // //                               actions: [
// // // // //                                 TextButton(
// // // // //                                   child: Text("Cancel"),
// // // // //                                   onPressed: () {
// // // // //                                     Navigator.of(context)
// // // // //                                         .pop(); // Close the dialog
// // // // //                                   },
// // // // //                                 ),
// // // // //                                 TextButton(
// // // // //                                   child: Text("Proceed"),
// // // // //                                   onPressed: () {
// // // // //                                     // Proceed with changing the language and setting starter code
// // // // //                                     setState(() {
// // // // //                                       _selectedLanguage = newValue;
// // // // //                                       _setStarterCode(newValue);
// // // // //                                     });
// // // // //                                     Navigator.of(context)
// // // // //                                         .pop(); // Close the dialog
// // // // //                                   },
// // // // //                                 ),
// // // // //                               ],
// // // // //                             );
// // // // //                           },
// // // // //                         );
// // // // //                       } else {
// // // // //                         // Directly set language and starter code if no language was selected previously
// // // // //                         setState(() {
// // // // //                           _selectedLanguage = newValue;
// // // // //                           _setStarterCode(newValue);
// // // // //                         });
// // // // //                       }
// // // // //                     }
// // // // //                   },
// // // // //                   items: [
// // // // //                     DropdownMenuItem<String>(
// // // // //                       value: "Please select a Language",
// // // // //                       child: Text("Please select a Language"),
// // // // //                     ),
// // // // //                     ...widget.question['allowed_languages']
// // // // //                         .cast<String>()
// // // // //                         .map<DropdownMenuItem<String>>((String language) {
// // // // //                       return DropdownMenuItem<String>(
// // // // //                         value: language,
// // // // //                         child: Text(language),
// // // // //                       );
// // // // //                     }).toList(),
// // // // //                   ],
// // // // //                 ),
// // // // //                 Focus(
// // // // //                   focusNode: _focusNode, // Attach the focus node to Focus only
// // // // //                   onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
// // // // //                     if (keyEvent is KeyDownEvent) {
// // // // //                       final keysPressed =
// // // // //                           HardwareKeyboard.instance.logicalKeysPressed;

// // // // //                       // Check for Ctrl + / shortcut
// // // // //                       if (keysPressed
// // // // //                               .contains(LogicalKeyboardKey.controlLeft) &&
// // // // //                           keysPressed.contains(LogicalKeyboardKey.slash)) {
// // // // //                         _commentSelectedLines();
// // // // //                         return KeyEventResult.handled;
// // // // //                       }
// // // // //                     }
// // // // //                     return KeyEventResult.ignored;
// // // // //                   },
// // // // //                   child: Container(
// // // // //                     // height: 200,
// // // // //                     height: MediaQuery.of(context).size.height / 1.7,
// // // // //                     child: CodeField(
// // // // //                       controller: _codeController,
// // // // //                       focusNode: FocusNode(),
// // // // //                       textStyle: TextStyle(
// // // // //                         fontFamily: 'RobotoMono',
// // // // //                         fontSize: 16,
// // // // //                         color: Colors.white,
// // // // //                       ),
// // // // //                       cursorColor: Colors.white,
// // // // //                       background: Colors.black,
// // // // //                       expands: true,
// // // // //                       wrap: false,
// // // // //                       lineNumberStyle: LineNumberStyle(
// // // // //                         width: 40,
// // // // //                         margin: 8,
// // // // //                         textStyle: TextStyle(
// // // // //                           color: Colors.grey.shade600,
// // // // //                           fontSize: 16,
// // // // //                         ),
// // // // //                         background: Colors.grey.shade900,
// // // // //                       ),
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //                 SizedBox(height: 16),
// // // // //                 Row(
// // // // //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // // // //                   children: [
// // // // //                     ElevatedButton(
// // // // //                       onPressed: () {
// // // // //                         _runCode(
// // // // //                           allTestCases: false,
// // // // //                           mode: 'run',
// // // // //                         );
// // // // //                       },
// // // // //                       child: Text('Run'),
// // // // //                     ),
// // // // //                     ElevatedButton(
// // // // //                       onPressed: () {
// // // // //                         _runCode(
// // // // //                           allTestCases: true,
// // // // //                           mode: 'submit',
// // // // //                         );
// // // // //                       },
// // // // //                       child: Text('Submit'),
// // // // //                     ),
// // // // //                     ElevatedButton(
// // // // //                       onPressed: _toggleInputFieldVisibility,
// // // // //                       child: Text('Custom Input'),
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //                 SizedBox(height: 16),
// // // // //                 AnimatedCrossFade(
// // // // //                   duration: Duration(milliseconds: 300),
// // // // //                   firstChild: SizedBox.shrink(),
// // // // //                   secondChild: Column(
// // // // //                     children: [
// // // // //                       Container(
// // // // //                         // height: 250,
// // // // //                         width: MediaQuery.of(context).size.width * 0.25,
// // // // //                         child: TextField(
// // // // //                           minLines: 5,
// // // // //                           maxLines: 5,
// // // // //                           controller: _customInputController,
// // // // //                           decoration: InputDecoration(
// // // // //                             hintText: "Enter custom input",
// // // // //                             hintStyle: TextStyle(color: Colors.white54),
// // // // //                             filled: true,
// // // // //                             fillColor: Colors.black,
// // // // //                             border: OutlineInputBorder(),
// // // // //                           ),
// // // // //                           style: TextStyle(color: Colors.white),
// // // // //                         ),
// // // // //                       ),
// // // // //                       SizedBox(height: 10),
// // // // //                       ElevatedButton(
// // // // //                         onPressed: () {
// // // // //                           _runCode(
// // // // //                             allTestCases: false,
// // // // //                             customInput: _customInputController.text,
// // // // //                             mode: 'run',
// // // // //                           );
// // // // //                         },
// // // // //                         child: Text('Run Custom Input'),
// // // // //                       ),
// // // // //                     ],
// // // // //                   ),
// // // // //                   crossFadeState: _iscustomInputfieldVisible
// // // // //                       ? CrossFadeState.showSecond
// // // // //                       : CrossFadeState.showFirst,
// // // // //                 ),
// // // // //                 SizedBox(height: 16),
// // // // //                 if (testResults.isNotEmpty)
// // // // //                   TestCaseResultsTable(testResults: testResults),
// // // // //               ],
// // // // //             ),
// // // // //           ),
// // // // //         ),
// // // // //       ),
// // // // //       // );
// // // // //       // },
// // // // //     );
// // // // //   }

// // // // //   Widget buildCodeEditorPanel() {
// // // // //     return Padding(
// // // // //       padding: EdgeInsets.all(16.0),
// // // // //       child: Column(
// // // // //         children: [
// // // // //           Text("Select Language",
// // // // //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //           DropdownButton<String>(
// // // // //             value: _selectedLanguage,
// // // // //             onChanged: (String? newValue) {
// // // // //               if (newValue != null && newValue != "Please select a Language") {
// // // // //                 if (_selectedLanguage != "Please select a Language") {
// // // // //                   // Show alert if a language was previously selected
// // // // //                   showDialog(
// // // // //                     context: context,
// // // // //                     builder: (BuildContext context) {
// // // // //                       return AlertDialog(
// // // // //                         title: Text("Change Language"),
// // // // //                         content: Text(
// // // // //                             "Changing the language will remove the current code. Do you want to proceed?"),
// // // // //                         actions: [
// // // // //                           TextButton(
// // // // //                             child: Text("Cancel"),
// // // // //                             onPressed: () {
// // // // //                               Navigator.of(context).pop(); // Close the dialog
// // // // //                             },
// // // // //                           ),
// // // // //                           TextButton(
// // // // //                             child: Text("Proceed"),
// // // // //                             onPressed: () {
// // // // //                               // Proceed with changing the language and setting starter code
// // // // //                               setState(() {
// // // // //                                 _selectedLanguage = newValue;
// // // // //                                 _setStarterCode(newValue);
// // // // //                               });
// // // // //                               Navigator.of(context).pop(); // Close the dialog
// // // // //                             },
// // // // //                           ),
// // // // //                         ],
// // // // //                       );
// // // // //                     },
// // // // //                   );
// // // // //                 } else {
// // // // //                   // Directly set language and starter code if no language was selected previously
// // // // //                   setState(() {
// // // // //                     _selectedLanguage = newValue;
// // // // //                     _setStarterCode(newValue);
// // // // //                   });
// // // // //                 }
// // // // //               }
// // // // //             },
// // // // //             items: [
// // // // //               DropdownMenuItem<String>(
// // // // //                 value: "Please select a Language",
// // // // //                 child: Text("Please select a Language"),
// // // // //               ),
// // // // //               ...widget.question['allowed_languages']
// // // // //                   .cast<String>()
// // // // //                   .map<DropdownMenuItem<String>>((String language) {
// // // // //                 return DropdownMenuItem<String>(
// // // // //                   value: language,
// // // // //                   child: Text(language),
// // // // //                 );
// // // // //               }).toList(),
// // // // //             ],
// // // // //           ),
// // // // //           Expanded(
// // // // //             child: Focus(
// // // // //               focusNode: _focusNode, // Attach the focus node to Focus only
// // // // //               onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
// // // // //                 if (keyEvent is KeyDownEvent) {
// // // // //                   final keysPressed =
// // // // //                       HardwareKeyboard.instance.logicalKeysPressed;

// // // // //                   // Check for Ctrl + / shortcut
// // // // //                   if (keysPressed.contains(LogicalKeyboardKey.controlLeft) &&
// // // // //                       keysPressed.contains(LogicalKeyboardKey.slash)) {
// // // // //                     _commentSelectedLines();
// // // // //                     return KeyEventResult.handled;
// // // // //                   }
// // // // //                 }
// // // // //                 return KeyEventResult.ignored;
// // // // //               },
// // // // //               child: Container(
// // // // //                 // height: 200,
// // // // //                 height: MediaQuery.of(context).size.height / 3.5,
// // // // //                 child: CodeField(
// // // // //                   controller: _codeController,
// // // // //                   focusNode: FocusNode(),
// // // // //                   textStyle: TextStyle(
// // // // //                     fontFamily: 'RobotoMono',
// // // // //                     fontSize: 16,
// // // // //                     color: Colors.white,
// // // // //                   ),
// // // // //                   cursorColor: Colors.white,
// // // // //                   background: Colors.black,
// // // // //                   expands: true,
// // // // //                   wrap: false,
// // // // //                   lineNumberStyle: LineNumberStyle(
// // // // //                     width: 40,
// // // // //                     margin: 8,
// // // // //                     textStyle: TextStyle(
// // // // //                       color: Colors.grey.shade600,
// // // // //                       fontSize: 16,
// // // // //                     ),
// // // // //                     background: Colors.grey.shade900,
// // // // //                   ),
// // // // //                 ),
// // // // //               ),
// // // // //             ),
// // // // //           ),
// // // // //         ],
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   // Future<void> _runCode(
// // // // //   //     {required bool allTestCases, String? customInput}) async {
// // // // //   //   if (_selectedLanguage == null || _codeController.text.trim().isEmpty) {
// // // // //   //     print("No valid code provided or language not selected");
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   Uri endpoint;
// // // // //   //   switch (_selectedLanguage!.toLowerCase()) {
// // // // //   //     case 'python':
// // // // //   //       endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //   //       break;
// // // // //   //     case 'java':
// // // // //   //       endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //   //       break;
// // // // //   //     case 'cpp':
// // // // //   //       endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //   //       break;
// // // // //   //     case 'c':
// // // // //   //       endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //   //       break;
// // // // //   //     default:
// // // // //   //       print("Unsupported language selected");
// // // // //   //       return;
// // // // //   //   }

// // // // //   //   print('Selected Endpoint URL: $endpoint');

// // // // //   //   final String code = _codeController.text.trim();
// // // // //   //   List<Map<String, String>> testCases;

// // // // //   //   // Determine which test cases to send based on the button clicked
// // // // //   //   if (customInput != null) {
// // // // //   //     testCases = [
// // // // //   //       {
// // // // //   //         'input': customInput.trim() + '\n',
// // // // //   //         'output': '', // No expected output for custom input
// // // // //   //       },
// // // // //   //     ];
// // // // //   //   } else if (allTestCases) {
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   } else {
// // // // //   //     // Run only public test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .where((testCase) => testCase['is_public'] == true)
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   }

// // // // //   //   final Map<String, dynamic> requestBody = {
// // // // //   //     'language': _selectedLanguage!.toLowerCase(),
// // // // //   //     'code': code,
// // // // //   //     'testcases': testCases,
// // // // //   //   };

// // // // //   //   print('Request Body: ${jsonEncode(requestBody)}');

// // // // //   //   try {
// // // // //   //     final response = await http.post(
// // // // //   //       endpoint,
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       final List<dynamic> responseBody = jsonDecode(response.body);
// // // // //   //       setState(() {
// // // // //   //         testResults = responseBody.map((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'],
// // // // //   //             expectedResult: result['expected_output'] ?? '',
// // // // //   //             actualResult: result['actual_output'] ?? '',
// // // // //   //             passed: result['success'] ?? false,
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });
// // // // //   //       _scrollToResults();
// // // // //   //     } else {
// // // // //   //       print('Error: ${response.statusCode} - ${response.reasonPhrase}');
// // // // //   //       print('Backend Error Response: ${response.body}');
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: jsonDecode(response.body)['error'],
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print('Error sending request: $error');
// // // // //   //   }
// // // // //   // }

// // // // //   // Future<void> _runCode({
// // // // //   //   required bool allTestCases,
// // // // //   //   String? customInput,
// // // // //   // }) async {
// // // // //   //   // Ensure a language is selected and code is provided
// // // // //   //   if (_selectedLanguage == null ||
// // // // //   //       _selectedLanguage == "Please select a Language") {
// // // // //   //     print("[DEBUG] No valid language selected");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please select a programming language.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   if (_codeController.text.trim().isEmpty) {
// // // // //   //     print("[DEBUG] Code editor is empty");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please provide some code.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   // Determine the endpoint URL based on the selected language
// // // // //   //   Uri endpoint;
// // // // //   //   switch (_selectedLanguage!.toLowerCase()) {
// // // // //   //     case 'python':
// // // // //   //       endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //   //       break;
// // // // //   //     case 'java':
// // // // //   //       endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //   //       break;
// // // // //   //     case 'cpp':
// // // // //   //       endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //   //       break;
// // // // //   //     case 'c':
// // // // //   //       endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //   //       break;
// // // // //   //     default:
// // // // //   //       print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Unsupported programming language selected.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //   }

// // // // //   //   print("[DEBUG] Selected Endpoint: $endpoint");

// // // // //   //   // Collect the code and test cases
// // // // //   //   final String code = _codeController.text.trim();
// // // // //   //   List<Map<String, String>> testCases;

// // // // //   //   if (customInput != null) {
// // // // //   //     // Run custom input provided by the user
// // // // //   //     testCases = [
// // // // //   //       {
// // // // //   //         'input': customInput.trim() + '\n',
// // // // //   //         'output': '', // Custom input doesn't have an expected output
// // // // //   //       },
// // // // //   //     ];
// // // // //   //   } else if (allTestCases) {
// // // // //   //     // Run all test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   } else {
// // // // //   //     // Run only public test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .where((testCase) => testCase['is_public'] == true)
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   }

// // // // //   //   // Prepare the request payload
// // // // //   //   final Map<String, dynamic> requestBody = {
// // // // //   //     'language': _selectedLanguage!.toLowerCase(),
// // // // //   //     'code': code,
// // // // //   //     'testcases': testCases,
// // // // //   //   };

// // // // //   //   print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

// // // // //   //   try {
// // // // //   //     // Make the HTTP POST request
// // // // //   //     final response = await http.post(
// // // // //   //       endpoint,
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       print("[DEBUG] Response Body: ${response.body}");
// // // // //   //       final List<dynamic> responseBody = jsonDecode(response.body);

// // // // //   //       // Map the response to test results
// // // // //   //       setState(() {
// // // // //   //         testResults = responseBody.map((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'] ?? '',
// // // // //   //             expectedResult: result['expected_output'] ?? '',
// // // // //   //             actualResult: result['actual_output'] ?? '',
// // // // //   //             passed: result['success'] ?? false,
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });

// // // // //   //       // Scroll to the test results
// // // // //   //       _scrollToResults();
// // // // //   //     } else {
// // // // //   //       print("[DEBUG] Error Response Body: ${response.body}");
// // // // //   //       final errorResponse = jsonDecode(response.body);

// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage:
// // // // //   //                 errorResponse['message'] ?? 'Unknown error occurred.',
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] HTTP Request Error: $error");

// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Failed to connect to the server. Please try again.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //   }
// // // // //   // }

// // // // //   // Future<void> _runCode({
// // // // //   //   required bool allTestCases,
// // // // //   //   String? customInput,
// // // // //   // }) async {
// // // // //   //   // Ensure a language is selected and code is provided
// // // // //   //   if (_selectedLanguage == null ||
// // // // //   //       _selectedLanguage == "Please select a Language") {
// // // // //   //     print("[DEBUG] No valid language selected");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please select a programming language.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }
// // // // //   //   final token = await SharedPrefs.getToken();

// // // // //   //   if (_codeController.text.trim().isEmpty) {
// // // // //   //     print("[DEBUG] Code editor is empty");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please provide some code.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   // Determine the endpoint URL based on the selected language
// // // // //   //   Uri endpoint;
// // // // //   //   switch (_selectedLanguage!.toLowerCase()) {
// // // // //   //     case 'python':
// // // // //   //       endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //   //       break;
// // // // //   //     case 'java':
// // // // //   //       endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //   //       break;
// // // // //   //     case 'cpp':
// // // // //   //       endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //   //       break;
// // // // //   //     case 'c':
// // // // //   //       endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //   //       break;
// // // // //   //     default:
// // // // //   //       print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Unsupported programming language selected.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //   }

// // // // //   //   print("[DEBUG] Selected Endpoint: $endpoint");

// // // // //   //   // Collect the code and test cases
// // // // //   //   final String code = _codeController.text.trim();
// // // // //   //   List<Map<String, String>> testCases;

// // // // //   //   if (customInput != null) {
// // // // //   //     // Run custom input provided by the user
// // // // //   //     testCases = [
// // // // //   //       {
// // // // //   //         'input': customInput.trim() + '\n',
// // // // //   //         'output': '', // Custom input doesn't have an expected output
// // // // //   //       },
// // // // //   //     ];
// // // // //   //   } else if (allTestCases) {
// // // // //   //     // Run all test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   } else {
// // // // //   //     // Run only public test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .where((testCase) => testCase['is_public'] == true)
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   }

// // // // //   //   // Prepare the request payload
// // // // //   //   final Map<String, dynamic> requestBody = {
// // // // //   //     'language': _selectedLanguage!.toLowerCase(),
// // // // //   //     'code': code,
// // // // //   //     'testcases': testCases,
// // // // //   //   };

// // // // //   //   print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

// // // // //   //   try {
// // // // //   //     // Make the HTTP POST request
// // // // //   //     final response = await http.post(
// // // // //   //       endpoint,
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       print("[DEBUG] Response Body: ${response.body}");
// // // // //   //       final List<dynamic> responseBody = jsonDecode(response.body);

// // // // //   //       // Map the response to test results
// // // // //   //       setState(() {
// // // // //   //         testResults = responseBody.map((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'] ?? '',
// // // // //   //             expectedResult: result['expected_output'] ?? '',
// // // // //   //             actualResult: result['actual_output'] ?? '',
// // // // //   //             passed: result['success'] ?? false,
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });

// // // // //   //       // Debug: Send test results to the backend for storage
// // // // //   //       final backendRequest = {
// // // // //   //         "domain_id": widget.question["codingquestiondomain_id"],
// // // // //   //         "question_id": widget.question["id"],
// // // // //   //         "language": _selectedLanguage,
// // // // //   //         "solution_code": code,
// // // // //   //         "test_results": responseBody,
// // // // //   //       };

// // // // //   //       print("[DEBUG] Backend Request Payload: ${jsonEncode(backendRequest)}");

// // // // //   //       final backendResponse = await http.post(
// // // // //   //         Uri.parse(
// // // // //   //             "http://localhost:3000/students/practice-coding-question-submit"),
// // // // //   //         headers: {
// // // // //   //           'Content-Type': 'application/json',
// // // // //   //           "Authorization": "Bearer $token",
// // // // //   //         },
// // // // //   //         body: jsonEncode(backendRequest),
// // // // //   //       );

// // // // //   //       print(
// // // // //   //           "[DEBUG] Backend Response: ${backendResponse.statusCode} - ${backendResponse.body}");

// // // // //   //       if (backendResponse.statusCode == 201) {
// // // // //   //         print("[DEBUG] Submission stored successfully in the backend.");
// // // // //   //       } else {
// // // // //   //         print(
// // // // //   //             "[DEBUG] Error storing submission in backend: ${backendResponse.body}");
// // // // //   //       }

// // // // //   //       // Scroll to the test results
// // // // //   //       _scrollToResults();
// // // // //   //     } else {
// // // // //   //       print("[DEBUG] Error Response Body: ${response.body}");
// // // // //   //       final errorResponse = jsonDecode(response.body);

// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage:
// // // // //   //                 errorResponse['message'] ?? 'Unknown error occurred.',
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] HTTP Request Error: $error");

// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Failed to connect to the server. Please try again.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //   }
// // // // //   // }

// // // // // // Future<void> _runCode({
// // // // // //   required bool allTestCases,
// // // // // //   String? customInput,
// // // // // // }) async {
// // // // // //   // Ensure a language is selected and code is provided
// // // // // //   if (_selectedLanguage == null ||
// // // // // //       _selectedLanguage == "Please select a Language") {
// // // // // //     print("[DEBUG] No valid language selected");
// // // // // //     setState(() {
// // // // // //       testResults = [
// // // // // //         TestCaseResult(
// // // // // //           testCase: '',
// // // // // //           expectedResult: '',
// // // // // //           actualResult: '',
// // // // // //           passed: false,
// // // // // //           errorMessage: "Please select a programming language.",
// // // // // //         ),
// // // // // //       ];
// // // // // //     });
// // // // // //     return;
// // // // // //   }
// // // // // //   final token = await SharedPrefs.getToken();

// // // // // //   if (_codeController.text.trim().isEmpty) {
// // // // // //     print("[DEBUG] Code editor is empty");
// // // // // //     setState(() {
// // // // // //       testResults = [
// // // // // //         TestCaseResult(
// // // // // //           testCase: '',
// // // // // //           expectedResult: '',
// // // // // //           actualResult: '',
// // // // // //           passed: false,
// // // // // //           errorMessage: "Please provide some code.",
// // // // // //         ),
// // // // // //       ];
// // // // // //     });
// // // // // //     return;
// // // // // //   }

// // // // // //   // Determine the endpoint URL based on the selected language
// // // // // //   Uri endpoint;
// // // // // //   switch (_selectedLanguage!.toLowerCase()) {
// // // // // //     case 'python':
// // // // // //       endpoint = Uri.parse('http://localhost:8084/compile');
// // // // // //       break;
// // // // // //     case 'java':
// // // // // //       endpoint = Uri.parse('http://localhost:8083/compile');
// // // // // //       break;
// // // // // //     case 'cpp':
// // // // // //       endpoint = Uri.parse('http://localhost:8081/compile');
// // // // // //       break;
// // // // // //     case 'c':
// // // // // //       endpoint = Uri.parse('http://localhost:8082/compile');
// // // // // //       break;
// // // // // //     default:
// // // // // //       print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // // //       setState(() {
// // // // // //         testResults = [
// // // // // //           TestCaseResult(
// // // // // //             testCase: '',
// // // // // //             expectedResult: '',
// // // // // //             actualResult: '',
// // // // // //             passed: false,
// // // // // //             errorMessage: "Unsupported programming language selected.",
// // // // // //           ),
// // // // // //         ];
// // // // // //       });
// // // // // //       return;
// // // // // //   }

// // // // // //   print("[DEBUG] Selected Endpoint: $endpoint");

// // // // // //   // Collect the code and test cases
// // // // // //   final String code = _codeController.text.trim();
// // // // // //   List<Map<String, String>> testCases;

// // // // // //   if (customInput != null) {
// // // // // //     // Run custom input provided by the user
// // // // // //     testCases = [
// // // // // //       {
// // // // // //         'input': customInput.trim() + '\n',
// // // // // //         'output': '', // Custom input doesn't have an expected output
// // // // // //       },
// // // // // //     ];
// // // // // //   } else if (allTestCases) {
// // // // // //     // Run all test cases
// // // // // //     testCases = widget.question['test_cases']
// // // // // //         .map<Map<String, String>>((testCase) => {
// // // // // //               'input': testCase['input'].toString().trim() + '\n',
// // // // // //               'output': testCase['output'].toString().trim(),
// // // // // //             })
// // // // // //         .toList();
// // // // // //   } else {
// // // // // //     // Run only public test cases
// // // // // //     testCases = widget.question['test_cases']
// // // // // //         .where((testCase) => testCase['is_public'] == true)
// // // // // //         .map<Map<String, String>>((testCase) => {
// // // // // //               'input': testCase['input'].toString().trim() + '\n',
// // // // // //               'output': testCase['output'].toString().trim(),
// // // // // //             })
// // // // // //         .toList();
// // // // // //   }

// // // // // //   // Prepare the request payload
// // // // // //   final Map<String, dynamic> requestBody = {
// // // // // //     'language': _selectedLanguage!.toLowerCase(),
// // // // // //     'code': code,
// // // // // //     'testcases': testCases,
// // // // // //   };

// // // // // //   print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

// // // // // //   try {
// // // // // //     // Make the HTTP POST request
// // // // // //     final response = await http.post(
// // // // // //       endpoint,
// // // // // //       headers: {'Content-Type': 'application/json'},
// // // // // //       body: jsonEncode(requestBody),
// // // // // //     );

// // // // // //     print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // // //     if (response.statusCode == 200) {
// // // // // //       print("[DEBUG] Response Body: ${response.body}");
// // // // // //       final List<dynamic> responseBody = jsonDecode(response.body);

// // // // // //       // Send to backend for storage
// // // // // //       final backendRequest = {
// // // // // //         "domain_id": widget.question["codingquestiondomain_id"],
// // // // // //         "question_id": widget.question["id"],
// // // // // //         "language": _selectedLanguage,
// // // // // //         "solution_code": code,
// // // // // //         "test_results": responseBody,
// // // // // //       };

// // // // // //       print("[DEBUG] Backend Request Payload: ${jsonEncode(backendRequest)}");

// // // // // //       final backendResponse = await http.post(
// // // // // //         Uri.parse("http://localhost:3000/students/practice-coding-question-submit"),
// // // // // //         headers: {
// // // // // //           'Content-Type': 'application/json',
// // // // // //           "Authorization": "Bearer $token",
// // // // // //         },
// // // // // //         body: jsonEncode(backendRequest),
// // // // // //       );

// // // // // //       print("[DEBUG] Backend Response: ${backendResponse.statusCode} - ${backendResponse.body}");

// // // // // //       if (backendResponse.statusCode == 201) {
// // // // // //         print("[DEBUG] Submission stored successfully in the backend.");
// // // // // //       } else {
// // // // // //         print("[DEBUG] Error storing submission in backend: ${backendResponse.body}");
// // // // // //       }
// // // // // //     } else {
// // // // // //       print("[DEBUG] Error Response Body: ${response.body}");
// // // // // //     }
// // // // // //   } catch (error) {
// // // // // //     print("[DEBUG] HTTP Request Error: $error");
// // // // // //   }
// // // // // // }

// // // // //   // Future<void> _runCode(
// // // // //   //     {required bool allTestCases, String? customInput}) async {
// // // // //   //   // Ensure a language is selected and code is provided
// // // // //   //   if (_selectedLanguage == null ||
// // // // //   //       _selectedLanguage == "Please select a Language") {
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please select a programming language.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   if (_codeController.text.trim().isEmpty) {
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please provide some code.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   final token = await SharedPrefs.getToken();
// // // // //   //   final String code = _codeController.text.trim();

// // // // //   //   // Prepare the request payload
// // // // //   //   final Map<String, dynamic> requestBody = {
// // // // //   //     'language': _selectedLanguage!.toLowerCase(),
// // // // //   //     'code': code,
// // // // //   //     'testcases': widget.question['test_cases'].map((testCase) {
// // // // //   //       return {
// // // // //   //         'input': testCase['input'].toString(),
// // // // //   //         'output': testCase['output'].toString(),
// // // // //   //       };
// // // // //   //     }).toList(),
// // // // //   //   };

// // // // //   //   try {
// // // // //   //     final response = await http.post(
// // // // //   //       Uri.parse('http://localhost:8084/compile'),
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       final List<dynamic> testResultsResponse = jsonDecode(response.body);

// // // // //   //       // Map test results to the UI model
// // // // //   //       setState(() {
// // // // //   //         testResults = testResultsResponse.map((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'],
// // // // //   //             expectedResult: result['expected_output'],
// // // // //   //             actualResult: result['actual_output'],
// // // // //   //             passed: result['success'],
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });

// // // // //   //       // Submit the test results to the backend
// // // // //   //       final backendRequest = {
// // // // //   //         'domain_id': widget.question['codingquestiondomain_id'],
// // // // //   //         'question_id': widget.question['id'],
// // // // //   //         'language': _selectedLanguage,
// // // // //   //         'solution_code': code,
// // // // //   //         'test_results': testResultsResponse,
// // // // //   //       };

// // // // //   //       final backendResponse = await http.post(
// // // // //   //         Uri.parse(
// // // // //   //             'http://localhost:3000/students/practice-coding-question-submit'),
// // // // //   //         headers: {
// // // // //   //           'Content-Type': 'application/json',
// // // // //   //           'Authorization': 'Bearer $token',
// // // // //   //         },
// // // // //   //         body: jsonEncode(backendRequest),
// // // // //   //       );

// // // // //   //       if (backendResponse.statusCode == 201) {
// // // // //   //         print("[DEBUG] Submission stored successfully.");
// // // // //   //       } else {
// // // // //   //         print("[DEBUG] Error storing submission: ${backendResponse.body}");
// // // // //   //       }
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] Error: $error");
// // // // //   //   }
// // // // //   // }

// // // // //   // Future<void> _runCode({
// // // // //   //   required bool allTestCases,
// // // // //   //   String? customInput,
// // // // //   // }) async {
// // // // //   //   // Ensure a language is selected
// // // // //   //   if (_selectedLanguage == null ||
// // // // //   //       _selectedLanguage == "Please select a Language") {
// // // // //   //     print("[DEBUG] No valid language selected");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please select a programming language.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   // Ensure code is provided
// // // // //   //   if (_codeController.text.trim().isEmpty) {
// // // // //   //     print("[DEBUG] Code editor is empty");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please provide some code.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   // Retrieve JWT token
// // // // //   //   final token = await SharedPrefs.getToken();
// // // // //   //   final String code = _codeController.text.trim();

// // // // //   //   // Handle Custom Input
// // // // //   //   if (customInput != null) {
// // // // //   //     final Map<String, dynamic> customInputRequest = {
// // // // //   //       'language': _selectedLanguage!.toLowerCase(),
// // // // //   //       'solution_code': code,
// // // // //   //       'custom_input': customInput.trim(),
// // // // //   //     };

// // // // //   //     try {
// // // // //   //       // Send custom input request to backend
// // // // //   //       final response = await http.post(
// // // // //   //         Uri.parse(
// // // // //   //             'http://localhost:3000/students/practice-coding-question-submit'),
// // // // //   //         headers: {
// // // // //   //           'Content-Type': 'application/json',
// // // // //   //           'Authorization': 'Bearer $token',
// // // // //   //         },
// // // // //   //         body: jsonEncode(customInputRequest),
// // // // //   //       );

// // // // //   //       // Process response
// // // // //   //       if (response.statusCode == 200) {
// // // // //   //         final responseBody = jsonDecode(response.body);

// // // // //   //         print(
// // // // //   //             "[DEBUG] Custom Input Output: ${responseBody['actual_output']}");

// // // // //   //         // Display the output of custom input
// // // // //   //         setState(() {
// // // // //   //           testResults = [
// // // // //   //             TestCaseResult(
// // // // //   //               testCase: customInput,
// // // // //   //               expectedResult: '',
// // // // //   //               actualResult: responseBody['actual_output'],
// // // // //   //               passed: true,
// // // // //   //               errorMessage: responseBody['error'] ?? '',
// // // // //   //             ),
// // // // //   //           ];
// // // // //   //         });
// // // // //   //       } else {
// // // // //   //         print("[DEBUG] Custom Input Error: ${response.body}");
// // // // //   //         final errorResponse = jsonDecode(response.body);

// // // // //   //         setState(() {
// // // // //   //           testResults = [
// // // // //   //             TestCaseResult(
// // // // //   //               testCase: customInput,
// // // // //   //               expectedResult: '',
// // // // //   //               actualResult: '',
// // // // //   //               passed: false,
// // // // //   //               errorMessage:
// // // // //   //                   errorResponse['message'] ?? 'Unknown error occurred.',
// // // // //   //             ),
// // // // //   //           ];
// // // // //   //         });
// // // // //   //       }
// // // // //   //     } catch (error) {
// // // // //   //       print("[DEBUG] Error Executing Custom Input: $error");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: customInput,
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage:
// // // // //   //                 "Failed to connect to the server. Please try again.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   // Prepare request payload for test cases
// // // // //   //   Uri endpoint;
// // // // //   //   switch (_selectedLanguage!.toLowerCase()) {
// // // // //   //     case 'python':
// // // // //   //       endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //   //       break;
// // // // //   //     case 'java':
// // // // //   //       endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //   //       break;
// // // // //   //     case 'cpp':
// // // // //   //       endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //   //       break;
// // // // //   //     case 'c':
// // // // //   //       endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //   //       break;
// // // // //   //     default:
// // // // //   //       print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Unsupported programming language selected.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //   }

// // // // //   //   List<Map<String, String>> testCases;
// // // // //   //   if (allTestCases) {
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   } else {
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .where((testCase) => testCase['is_public'] == true)
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   }

// // // // //   //   // Prepare request payload
// // // // //   //   final Map<String, dynamic> requestBody = {
// // // // //   //     'language': _selectedLanguage!.toLowerCase(),
// // // // //   //     'code': code,
// // // // //   //     'testcases': testCases,
// // // // //   //   };

// // // // //   //   try {
// // // // //   //     // Send request to Docker API
// // // // //   //     final response = await http.post(
// // // // //   //       endpoint,
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       final responseBody = jsonDecode(response.body);

// // // // //   //       print("[DEBUG] Test Case Results: $responseBody");

// // // // //   //       // Display test results in the UI
// // // // //   //       setState(() {
// // // // //   //         testResults = responseBody.map((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'] ?? '',
// // // // //   //             expectedResult: result['expected_output'] ?? '',
// // // // //   //             actualResult: result['actual_output'] ?? '',
// // // // //   //             passed: result['success'] ?? false,
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });
// // // // //   //     } else {
// // // // //   //       print("[DEBUG] Error Response Body: ${response.body}");
// // // // //   //       final errorResponse = jsonDecode(response.body);

// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage:
// // // // //   //                 errorResponse['message'] ?? 'Unknown error occurred.',
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] Error Executing Test Cases: $error");

// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Failed to connect to the server. Please try again.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //   }
// // // // //   // }

// // // // //   // Future<void> _runCode({
// // // // //   //   required bool allTestCases,
// // // // //   //   String? customInput,
// // // // //   // }) async {
// // // // //   //   // Ensure a language is selected and code is provided
// // // // //   //   if (_selectedLanguage == null ||
// // // // //   //       _selectedLanguage == "Please select a Language") {
// // // // //   //     print("[DEBUG] No valid language selected");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please select a programming language.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   final token = await SharedPrefs.getToken();

// // // // //   //   if (_codeController.text.trim().isEmpty) {
// // // // //   //     print("[DEBUG] Code editor is empty");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please provide some code.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   // Determine the endpoint URL based on the selected language
// // // // //   //   Uri endpoint;
// // // // //   //   switch (_selectedLanguage!.toLowerCase()) {
// // // // //   //     case 'python':
// // // // //   //       endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //   //       break;
// // // // //   //     case 'java':
// // // // //   //       endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //   //       break;
// // // // //   //     case 'cpp':
// // // // //   //       endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //   //       break;
// // // // //   //     case 'c':
// // // // //   //       endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //   //       break;
// // // // //   //     default:
// // // // //   //       print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Unsupported programming language selected.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //   }

// // // // //   //   print("[DEBUG] Selected Endpoint: $endpoint");

// // // // //   //   // Collect the code and test cases
// // // // //   //   final String code = _codeController.text.trim();
// // // // //   //   List<Map<String, String>> testCases;

// // // // //   //   if (customInput != null) {
// // // // //   //     // Run custom input provided by the user
// // // // //   //     testCases = [
// // // // //   //       {
// // // // //   //         'input': customInput.trim() + '\n',
// // // // //   //         'output': '', // Custom input doesn't have an expected output
// // // // //   //       },
// // // // //   //     ];
// // // // //   //   } else if (allTestCases) {
// // // // //   //     // Run all test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   } else {
// // // // //   //     // Run only public test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .where((testCase) => testCase['is_public'] == true)
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   }

// // // // //   //   final Map<String, dynamic> requestBody = {
// // // // //   //     'language': _selectedLanguage!.toLowerCase(),
// // // // //   //     'code': code,
// // // // //   //     'testcases': testCases,
// // // // //   //     'is_custom_input':
// // // // //   //         customInput != null, // Indicate if this is custom input
// // // // //   //   };

// // // // //   //   print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

// // // // //   //   try {
// // // // //   //     final response = await http.post(
// // // // //   //       endpoint,
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       print("[DEBUG] Response Body: ${response.body}");
// // // // //   //       final List<dynamic> responseBody = jsonDecode(response.body);

// // // // //   //       setState(() {
// // // // //   //         testResults = responseBody.map<TestCaseResult>((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'] ?? '',
// // // // //   //             expectedResult: result['expected_output'] ?? '',
// // // // //   //             actualResult: result['actual_output'] ?? '',
// // // // //   //             passed: result['success'] ?? false,
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //             isCustomInput: customInput != null,
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });

// // // // //   //       _scrollToResults();
// // // // //   //     } else {
// // // // //   //       print("[DEBUG] Error Response Body: ${response.body}");
// // // // //   //       final errorResponse = jsonDecode(response.body);

// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage:
// // // // //   //                 errorResponse['message'] ?? 'Unknown error occurred.',
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] HTTP Request Error: $error");

// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Failed to connect to the server. Please try again.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //   }
// // // // //   // }

// // // // //   // Future<void> _runCode({
// // // // //   //   required bool allTestCases,
// // // // //   //   String? customInput,
// // // // //   // }) async {
// // // // //   //   // Ensure a language is selected and code is provided
// // // // //   //   if (_selectedLanguage == null ||
// // // // //   //       _selectedLanguage == "Please select a Language") {
// // // // //   //     print("[DEBUG] No valid language selected");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please select a programming language.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   // final token = await SharedPrefs.getToken();

// // // // //   //   if (_codeController.text.trim().isEmpty) {
// // // // //   //     print("[DEBUG] Code editor is empty");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please provide some code.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   // Determine the endpoint URL based on the selected language
// // // // //   //   Uri endpoint;
// // // // //   //   switch (_selectedLanguage!.toLowerCase()) {
// // // // //   //     case 'python':
// // // // //   //       endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //   //       break;
// // // // //   //     case 'java':
// // // // //   //       endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //   //       break;
// // // // //   //     case 'cpp':
// // // // //   //       endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //   //       break;
// // // // //   //     case 'c':
// // // // //   //       endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //   //       break;
// // // // //   //     default:
// // // // //   //       print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Unsupported programming language selected.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //   }

// // // // //   //   print("[DEBUG] Selected Endpoint: $endpoint");

// // // // //   //   // Collect the code and test cases
// // // // //   //   final String code = _codeController.text.trim();
// // // // //   //   List<Map<String, String>> testCases;

// // // // //   //   if (customInput != null) {
// // // // //   //     // Run custom input provided by the user
// // // // //   //     testCases = [
// // // // //   //       {
// // // // //   //         'input': customInput.trim() + '\n',
// // // // //   //         'output': '', // Custom input doesn't have an expected output
// // // // //   //       },
// // // // //   //     ];
// // // // //   //   } else if (allTestCases) {
// // // // //   //     // Run all test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   } else {
// // // // //   //     // Run only public test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .where((testCase) => testCase['is_public'] == true)
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   }

// // // // //   //   final Map<String, dynamic> requestBody = {
// // // // //   //     'language': _selectedLanguage!.toLowerCase(),
// // // // //   //     'code': code,
// // // // //   //     'testcases': testCases,
// // // // //   //     'is_custom_input':customInput != null, // Indicate if this is custom input
// // // // //   //           'mode': customInput != null ? 'run' : 'submit', // Add mode

// // // // //   //   };

// // // // //   //   print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

// // // // //   //   try {
// // // // //   //     // Send request to the compiler
// // // // //   //     final response = await http.post(
// // // // //   //       endpoint,
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       print("[DEBUG] Response Body: ${response.body}");
// // // // //   //       final List<dynamic> responseBody = jsonDecode(response.body);

// // // // //   //       // Map response to testResults and handle both custom and regular inputs
// // // // //   //       setState(() {
// // // // //   //         testResults = responseBody.map<TestCaseResult>((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'] ?? '',
// // // // //   //             expectedResult: result['expected_output'] ?? '',
// // // // //   //             actualResult: result['actual_output'] ?? '',
// // // // //   //             passed: result['success'] ?? false,
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //             isCustomInput: customInput != null,
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });

// // // // //   //       // If not custom input, send test results to backend for storage
// // // // //   //       if (customInput == null || customInput.isEmpty) {
// // // // //   //         final backendRequest = {
// // // // //   //           "domain_id": widget.question["codingquestiondomain_id"],
// // // // //   //           "question_id": widget.question["id"],
// // // // //   //           "language": _selectedLanguage,
// // // // //   //           "solution_code": code,
// // // // //   //           "test_results": responseBody,
// // // // //   //           "mode": "submit",
// // // // //   //         };

// // // // //   //         print(
// // // // //   //             "[DEBUG] Backend Request Payload: ${jsonEncode(backendRequest)}");

// // // // //   //         final backendResponse = await http.post(
// // // // //   //           Uri.parse(
// // // // //   //               "http://localhost:3000/students/practice-coding-question-submit"),
// // // // //   //           headers: {
// // // // //   //             'Content-Type': 'application/json',
// // // // //   //             "Authorization": "Bearer $token",
// // // // //   //           },
// // // // //   //           body: jsonEncode(backendRequest),
// // // // //   //         );

// // // // //   //         print(
// // // // //   //             "[DEBUG] Backend Response: ${backendResponse.statusCode} - ${backendResponse.body}");

// // // // //   //         if (backendResponse.statusCode != 201) {
// // // // //   //           print("[DEBUG] Backend Submission Error: ${backendResponse.body}");
// // // // //   //         }
// // // // //   //       }

// // // // //   //       _scrollToResults();
// // // // //   //     } else {
// // // // //   //       print("[DEBUG] Error Response Body: ${response.body}");
// // // // //   //       final errorResponse = jsonDecode(response.body);

// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage:
// // // // //   //                 errorResponse['message'] ?? 'Compilation error occurred',
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }

// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] HTTP Request Error: $error");

// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Failed to connect to the server. Please try again.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //   }
// // // // //   // }

// // // // //   // Future<void> _runCode({
// // // // //   //   required bool allTestCases,
// // // // //   //   String? customInput,
// // // // //   // }) async {
// // // // //   //   try {
// // // // //   //     // Ensure a language is selected and code is provided
// // // // //   //     if (_selectedLanguage == null ||
// // // // //   //         _selectedLanguage == "Please select a Language") {
// // // // //   //       print("[DEBUG] No valid language selected");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Please select a programming language.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //     }
// // // // //   //     final token = await SharedPrefs.getToken();

// // // // //   //     if (_codeController.text.trim().isEmpty) {
// // // // //   //       print("[DEBUG] Code editor is empty");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Please provide some code.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //     }

// // // // //   //     // Determine the endpoint URL based on the selected language
// // // // //   //     Uri endpoint;
// // // // //   //     switch (_selectedLanguage!.toLowerCase()) {
// // // // //   //       case 'python':
// // // // //   //         endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //   //         break;
// // // // //   //       case 'java':
// // // // //   //         endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //   //         break;
// // // // //   //       case 'cpp':
// // // // //   //         endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //   //         break;
// // // // //   //       case 'c':
// // // // //   //         endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //   //         break;
// // // // //   //       default:
// // // // //   //         print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // //   //         setState(() {
// // // // //   //           testResults = [
// // // // //   //             TestCaseResult(
// // // // //   //               testCase: '',
// // // // //   //               expectedResult: '',
// // // // //   //               actualResult: '',
// // // // //   //               passed: false,
// // // // //   //               errorMessage: "Unsupported programming language selected.",
// // // // //   //             ),
// // // // //   //           ];
// // // // //   //         });
// // // // //   //         return;
// // // // //   //     }

// // // // //   //     print("[DEBUG] Selected Endpoint: $endpoint");

// // // // //   //     // Prepare code and test cases
// // // // //   //     final String code = _codeController.text.trim();
// // // // //   //     List<Map<String, String>> testCases;

// // // // //   //     if (customInput != null) {
// // // // //   //       // Custom input provided by the user
// // // // //   //       testCases = [
// // // // //   //         {
// // // // //   //           'input': customInput.trim() + '\n',
// // // // //   //           'output': '', // Custom input doesn't have an expected output
// // // // //   //         },
// // // // //   //       ];
// // // // //   //     } else if (allTestCases) {
// // // // //   //       // All test cases
// // // // //   //       testCases = widget.question['test_cases']
// // // // //   //           .map<Map<String, String>>((testCase) => {
// // // // //   //                 'input': testCase['input'].toString().trim() + '\n',
// // // // //   //                 'output': testCase['output'].toString().trim(),
// // // // //   //               })
// // // // //   //           .toList();
// // // // //   //     } else {
// // // // //   //       // Only public test cases
// // // // //   //       testCases = widget.question['test_cases']
// // // // //   //           .where((testCase) => testCase['is_public'] == true)
// // // // //   //           .map<Map<String, String>>((testCase) => {
// // // // //   //                 'input': testCase['input'].toString().trim() + '\n',
// // // // //   //                 'output': testCase['output'].toString().trim(),
// // // // //   //               })
// // // // //   //           .toList();
// // // // //   //     }

// // // // //   //     final Map<String, dynamic> requestBody = {
// // // // //   //       'language': _selectedLanguage!.toLowerCase(),
// // // // //   //       'code': code,
// // // // //   //       'testcases': testCases,
// // // // //   //       'is_custom_input': customInput != null,
// // // // //   //       'mode': customInput != null ? 'run' : 'submit', // Add mode
// // // // //   //     };

// // // // //   //     print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

// // // // //   //     // Send request to the compiler
// // // // //   //     final response = await http.post(
// // // // //   //       endpoint,
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       print("[DEBUG] Response Body: ${response.body}");
// // // // //   //       final List<dynamic> responseBody = jsonDecode(response.body);

// // // // //   //       // Update test results in the UI
// // // // //   //       setState(() {
// // // // //   //         testResults = responseBody.map<TestCaseResult>((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'] ?? '',
// // // // //   //             expectedResult: result['expected_output'] ?? '',
// // // // //   //             actualResult: result['actual_output'] ?? '',
// // // // //   //             passed: result['success'] ?? false,
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //             isCustomInput: customInput != null,
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });

// // // // //   //       // If not a custom input, send results to the backend for storage
// // // // //   //       if (customInput == null || customInput.isEmpty) {
// // // // //   //         final backendRequest = {
// // // // //   //           "domain_id": widget.question["codingquestiondomain_id"],
// // // // //   //           "question_id": widget.question["id"],
// // // // //   //           "language": _selectedLanguage,
// // // // //   //           "solution_code": code,
// // // // //   //           "test_results": responseBody,
// // // // //   //           "mode": "submit",
// // // // //   //         };

// // // // //   //         print(
// // // // //   //             "[DEBUG] Backend Request Payload: ${jsonEncode(backendRequest)}");

// // // // //   //         final backendResponse = await http.post(
// // // // //   //           Uri.parse(
// // // // //   //               "http://localhost:3000/students/practice-coding-question-submit"),
// // // // //   //           headers: {
// // // // //   //             'Content-Type': 'application/json',
// // // // //   //             "Authorization": "Bearer $token",
// // // // //   //           },
// // // // //   //           body: jsonEncode(backendRequest),
// // // // //   //         );

// // // // //   //         print(
// // // // //   //             "[DEBUG] Backend Response: ${backendResponse.statusCode} - ${backendResponse.body}");

// // // // //   //         if (backendResponse.statusCode != 201) {
// // // // //   //           print("[DEBUG] Backend Submission Error: ${backendResponse.body}");
// // // // //   //         }
// // // // //   //       }

// // // // //   //       _scrollToResults();
// // // // //   //     } else {
// // // // //   //       print("[DEBUG] Error Response Body: ${response.body}");
// // // // //   //       final errorResponse = jsonDecode(response.body);

// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage:
// // // // //   //                 errorResponse['message'] ?? 'Compilation error occurred',
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] HTTP Request Error: $error");

// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Failed to connect to the server. Please try again.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //   }
// // // // //   // }

// // // // //   // Future<void> _runCode({
// // // // //   //   required bool allTestCases,
// // // // //   //   String? customInput,
// // // // //   //   required String mode, // Add mode parameter to differentiate actions
// // // // //   // }) async {
// // // // //   //   try {
// // // // //   //     // Ensure a language is selected and code is provided
// // // // //   //     if (_selectedLanguage == null ||
// // // // //   //         _selectedLanguage == "Please select a Language") {
// // // // //   //       print("[DEBUG] No valid language selected");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Please select a programming language.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //     }
// // // // //   //     final token = await SharedPrefs.getToken();

// // // // //   //     if (_codeController.text.trim().isEmpty) {
// // // // //   //       print("[DEBUG] Code editor is empty");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Please provide some code.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //     }

// // // // //   //     // Determine the endpoint URL based on the selected language
// // // // //   //     Uri endpoint;
// // // // //   //     switch (_selectedLanguage!.toLowerCase()) {
// // // // //   //       case 'python':
// // // // //   //         endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //   //         break;
// // // // //   //       case 'java':
// // // // //   //         endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //   //         break;
// // // // //   //       case 'cpp':
// // // // //   //         endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //   //         break;
// // // // //   //       case 'c':
// // // // //   //         endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //   //         break;
// // // // //   //       default:
// // // // //   //         print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // //   //         setState(() {
// // // // //   //           testResults = [
// // // // //   //             TestCaseResult(
// // // // //   //               testCase: '',
// // // // //   //               expectedResult: '',
// // // // //   //               actualResult: '',
// // // // //   //               passed: false,
// // // // //   //               errorMessage: "Unsupported programming language selected.",
// // // // //   //             ),
// // // // //   //           ];
// // // // //   //         });
// // // // //   //         return;
// // // // //   //     }

// // // // //   //     print("[DEBUG] Selected Endpoint: $endpoint");

// // // // //   //     // Prepare code and test cases
// // // // //   //     final String code = _codeController.text.trim();
// // // // //   //     List<Map<String, String>> testCases;

// // // // //   //     if (customInput != null) {
// // // // //   //       // Custom input provided by the user
// // // // //   //       testCases = [
// // // // //   //         {
// // // // //   //           'input': customInput.trim() + '\n',
// // // // //   //           'output': '', // Custom input doesn't have an expected output
// // // // //   //         },
// // // // //   //       ];
// // // // //   //     } else if (allTestCases) {
// // // // //   //       // All test cases
// // // // //   //       testCases = widget.question['test_cases']
// // // // //   //           .map<Map<String, String>>((testCase) => {
// // // // //   //                 'input': testCase['input'].toString().trim() + '\n',
// // // // //   //                 'output': testCase['output'].toString().trim(),
// // // // //   //               })
// // // // //   //           .toList();
// // // // //   //     } else {
// // // // //   //       // Only public test cases
// // // // //   //       testCases = widget.question['test_cases']
// // // // //   //           .where((testCase) => testCase['is_public'] == true)
// // // // //   //           .map<Map<String, String>>((testCase) => {
// // // // //   //                 'input': testCase['input'].toString().trim() + '\n',
// // // // //   //                 'output': testCase['output'].toString().trim(),
// // // // //   //               })
// // // // //   //           .toList();
// // // // //   //     }

// // // // //   //     final Map<String, dynamic> requestBody = {
// // // // //   //       'language': _selectedLanguage!.toLowerCase(),
// // // // //   //       'code': code,
// // // // //   //       'testcases': testCases,
// // // // //   //       'is_custom_input': customInput != null,
// // // // //   //       'mode': mode, // Use the passed mode
// // // // //   //     };

// // // // //   //     print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

// // // // //   //     // Send request to the compiler
// // // // //   //     final response = await http.post(
// // // // //   //       endpoint,
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       print("[DEBUG] Response Body: ${response.body}");
// // // // //   //       final List<dynamic> responseBody = jsonDecode(response.body);

// // // // //   //       // Update test results in the UI
// // // // //   //       setState(() {
// // // // //   //         testResults = responseBody.map<TestCaseResult>((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'] ?? '',
// // // // //   //             expectedResult: result['expected_output'] ?? '',
// // // // //   //             actualResult: result['actual_output'] ?? '',
// // // // //   //             passed: result['success'] ?? false,
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //             isCustomInput: customInput != null,
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });

// // // // //   //       // Only send to backend for "submit" mode
// // // // //   //       if (mode == "submit") {
// // // // //   //         final backendRequest = {
// // // // //   //           "domain_id": widget.question["codingquestiondomain_id"],
// // // // //   //           "question_id": widget.question["id"],
// // // // //   //           "language": _selectedLanguage,
// // // // //   //           "solution_code": code,
// // // // //   //           "test_results": responseBody,
// // // // //   //           "mode": mode,
// // // // //   //         };

// // // // //   //         print(
// // // // //   //             "[DEBUG] Backend Request Payload: ${jsonEncode(backendRequest)}");

// // // // //   //         final backendResponse = await http.post(
// // // // //   //           Uri.parse(
// // // // //   //               "http://localhost:3000/students/practice-coding-question-submit"),
// // // // //   //           headers: {
// // // // //   //             'Content-Type': 'application/json',
// // // // //   //             "Authorization": "Bearer $token",
// // // // //   //           },
// // // // //   //           body: jsonEncode(backendRequest),
// // // // //   //         );

// // // // //   //         print(
// // // // //   //             "[DEBUG] Backend Response: ${backendResponse.statusCode} - ${backendResponse.body}");

// // // // //   //         if (backendResponse.statusCode != 201) {
// // // // //   //           print("[DEBUG] Backend Submission Error: ${backendResponse.body}");
// // // // //   //         }
// // // // //   //       }

// // // // //   //       _scrollToResults();
// // // // //   //     } else {
// // // // //   //       print("[DEBUG] Error Response Body: ${response.body}");
// // // // //   //       final errorResponse = jsonDecode(response.body);

// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage:
// // // // //   //                 errorResponse['message'] ?? 'Compilation error occurred',
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] HTTP Request Error: $error");

// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Failed to connect to the server. Please try again.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //   }
// // // // //   // }

// // // // //   // Future<void> _runCode({
// // // // //   //   required bool allTestCases,
// // // // //   //   String? customInput,
// // // // //   // }) async {
// // // // //   //   // Ensure a language is selected and code is provided
// // // // //   //   if (_selectedLanguage == null ||
// // // // //   //       _selectedLanguage == "Please select a Language") {
// // // // //   //     print("[DEBUG] No valid language selected");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please select a programming language.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   final token = await SharedPrefs.getToken();

// // // // //   //   if (_codeController.text.trim().isEmpty) {
// // // // //   //     print("[DEBUG] Code editor is empty");
// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Please provide some code.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //     return;
// // // // //   //   }

// // // // //   //   // Determine the endpoint URL based on the selected language
// // // // //   //   Uri endpoint;
// // // // //   //   switch (_selectedLanguage!.toLowerCase()) {
// // // // //   //     case 'python':
// // // // //   //       endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //   //       break;
// // // // //   //     case 'java':
// // // // //   //       endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //   //       break;
// // // // //   //     case 'cpp':
// // // // //   //       endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //   //       break;
// // // // //   //     case 'c':
// // // // //   //       endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //   //       break;
// // // // //   //     default:
// // // // //   //       print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage: "Unsupported programming language selected.",
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //       return;
// // // // //   //   }

// // // // //   //   print("[DEBUG] Selected Endpoint: $endpoint");

// // // // //   //   // Collect the code and test cases
// // // // //   //   final String code = _codeController.text.trim();
// // // // //   //   List<Map<String, String>> testCases;

// // // // //   //   if (customInput != null) {
// // // // //   //     // Run custom input provided by the user
// // // // //   //     testCases = [
// // // // //   //       {
// // // // //   //         'input': customInput.trim() + '\n',
// // // // //   //         'output': '', // Custom input doesn't have an expected output
// // // // //   //       },
// // // // //   //     ];
// // // // //   //   } else if (allTestCases) {
// // // // //   //     // Run all test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   } else {
// // // // //   //     // Run only public test cases
// // // // //   //     testCases = widget.question['test_cases']
// // // // //   //         .where((testCase) => testCase['is_public'] == true)
// // // // //   //         .map<Map<String, String>>((testCase) => {
// // // // //   //               'input': testCase['input'].toString().trim() + '\n',
// // // // //   //               'output': testCase['output'].toString().trim(),
// // // // //   //             })
// // // // //   //         .toList();
// // // // //   //   }

// // // // //   //   final Map<String, dynamic> requestBody = {
// // // // //   //     'language': _selectedLanguage!.toLowerCase(),
// // // // //   //     'code': code,
// // // // //   //     'testcases': testCases,
// // // // //   //     'is_custom_input':
// // // // //   //         customInput != null, // Indicate if this is custom input
// // // // //   //   };

// // // // //   //   print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

// // // // //   //   try {
// // // // //   //     // Send request to the compiler
// // // // //   //     final response = await http.post(
// // // // //   //       endpoint,
// // // // //   //       headers: {'Content-Type': 'application/json'},
// // // // //   //       body: jsonEncode(requestBody),
// // // // //   //     );

// // // // //   //     print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       print("[DEBUG] Response Body: ${response.body}");
// // // // //   //       final List<dynamic> responseBody = jsonDecode(response.body);

// // // // //   //       // Map response to testResults and handle both custom and regular inputs
// // // // //   //       setState(() {
// // // // //   //         testResults = responseBody.map<TestCaseResult>((result) {
// // // // //   //           return TestCaseResult(
// // // // //   //             testCase: result['input'] ?? '',
// // // // //   //             expectedResult: result['expected_output'] ?? '',
// // // // //   //             actualResult: result['actual_output'] ?? '',
// // // // //   //             passed: result['success'] ?? false,
// // // // //   //             errorMessage: result['error'] ?? '',
// // // // //   //             isCustomInput: customInput != null,
// // // // //   //           );
// // // // //   //         }).toList();
// // // // //   //       });

// // // // //   //       // If not custom input, send test results to backend for storage
// // // // //   //       if (customInput == null || customInput.isEmpty) {
// // // // //   //         final backendRequest = {
// // // // //   //           "domain_id": widget.question["codingquestiondomain_id"],
// // // // //   //           "question_id": widget.question["id"],
// // // // //   //           "language": _selectedLanguage,
// // // // //   //           "solution_code": code,
// // // // //   //           "test_results": responseBody,
// // // // //   //         };

// // // // //   //         print(
// // // // //   //             "[DEBUG] Backend Request Payload: ${jsonEncode(backendRequest)}");

// // // // //   //         final backendResponse = await http.post(
// // // // //   //           Uri.parse(
// // // // //   //               "http://localhost:3000/students/practice-coding-question-submit"),
// // // // //   //           headers: {
// // // // //   //             'Content-Type': 'application/json',
// // // // //   //             "Authorization": "Bearer $token",
// // // // //   //           },
// // // // //   //           body: jsonEncode(backendRequest),
// // // // //   //         );

// // // // //   //         print(
// // // // //   //             "[DEBUG] Backend Response: ${backendResponse.statusCode} - ${backendResponse.body}");

// // // // //   //         if (backendResponse.statusCode != 201) {
// // // // //   //           print("[DEBUG] Backend Submission Error: ${backendResponse.body}");
// // // // //   //         }
// // // // //   //       }

// // // // //   //       _scrollToResults();
// // // // //   //     } else {
// // // // //   //       print("[DEBUG] Error Response Body: ${response.body}");
// // // // //   //       final errorResponse = jsonDecode(response.body);

// // // // //   //       setState(() {
// // // // //   //         testResults = [
// // // // //   //           TestCaseResult(
// // // // //   //             testCase: '',
// // // // //   //             expectedResult: '',
// // // // //   //             actualResult: '',
// // // // //   //             passed: false,
// // // // //   //             errorMessage:
// // // // //   //                 errorResponse['message'] ?? 'Unknown error occurred.',
// // // // //   //           ),
// // // // //   //         ];
// // // // //   //       });
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] HTTP Request Error: $error");

// // // // //   //     setState(() {
// // // // //   //       testResults = [
// // // // //   //         TestCaseResult(
// // // // //   //           testCase: '',
// // // // //   //           expectedResult: '',
// // // // //   //           actualResult: '',
// // // // //   //           passed: false,
// // // // //   //           errorMessage: "Failed to connect to the server. Please try again.",
// // // // //   //         ),
// // // // //   //       ];
// // // // //   //     });
// // // // //   //   }
// // // // //   // }

// // // // //   Future<void> _runCode({
// // // // //     required bool allTestCases,
// // // // //     String? customInput,
// // // // //     required String mode, // Add mode parameter to differentiate actions
// // // // //   }) async {
// // // // //     try {
// // // // //       // Ensure a language is selected and code is provided
// // // // //       if (_selectedLanguage == null ||
// // // // //           _selectedLanguage == "Please select a Language") {
// // // // //         print("[DEBUG] No valid language selected");
// // // // //         setState(() {
// // // // //           testResults = [
// // // // //             TestCaseResult(
// // // // //               testCase: '',
// // // // //               expectedResult: '',
// // // // //               actualResult: '',
// // // // //               passed: false,
// // // // //               errorMessage: "Please select a programming language.",
// // // // //             ),
// // // // //           ];
// // // // //         });
// // // // //         return;
// // // // //       }

// // // // //       if (_codeController.text.trim().isEmpty) {
// // // // //         print("[DEBUG] Code editor is empty");
// // // // //         setState(() {
// // // // //           testResults = [
// // // // //             TestCaseResult(
// // // // //               testCase: '',
// // // // //               expectedResult: '',
// // // // //               actualResult: '',
// // // // //               passed: false,
// // // // //               errorMessage: "Please provide some code.",
// // // // //             ),
// // // // //           ];
// // // // //         });
// // // // //         return;
// // // // //       }

// // // // //       // Determine the endpoint URL based on the selected language
// // // // //       Uri endpoint;
// // // // //       switch (_selectedLanguage!.toLowerCase()) {
// // // // //         case 'python':
// // // // //           endpoint = Uri.parse('http://localhost:8084/compile');
// // // // //           break;
// // // // //         case 'java':
// // // // //           endpoint = Uri.parse('http://localhost:8083/compile');
// // // // //           break;
// // // // //         case 'cpp':
// // // // //           endpoint = Uri.parse('http://localhost:8081/compile');
// // // // //           break;
// // // // //         case 'c':
// // // // //           endpoint = Uri.parse('http://localhost:8082/compile');
// // // // //           break;
// // // // //         default:
// // // // //           print("[DEBUG] Unsupported language selected: $_selectedLanguage");
// // // // //           setState(() {
// // // // //             testResults = [
// // // // //               TestCaseResult(
// // // // //                 testCase: '',
// // // // //                 expectedResult: '',
// // // // //                 actualResult: '',
// // // // //                 passed: false,
// // // // //                 errorMessage: "Unsupported programming language selected.",
// // // // //               ),
// // // // //             ];
// // // // //           });
// // // // //           return;
// // // // //       }

// // // // //       print("[DEBUG] Selected Endpoint: $endpoint");

// // // // //       // Prepare code and test cases
// // // // //       final String code = _codeController.text.trim();
// // // // //       List<Map<String, String>> testCases;

// // // // //       if (customInput != null) {
// // // // //         // Custom input provided by the user
// // // // //         testCases = [
// // // // //           {
// // // // //             'input': customInput.trim() + '\n',
// // // // //             'output': '', // Custom input doesn't have an expected output
// // // // //           },
// // // // //         ];
// // // // //       } else if (allTestCases) {
// // // // //         // All test cases
// // // // //         testCases = widget.question['test_cases']
// // // // //             .map<Map<String, String>>((testCase) => {
// // // // //                   'input': testCase['input'].toString().trim() + '\n',
// // // // //                   'output': testCase['output'].toString().trim(),
// // // // //                 })
// // // // //             .toList();
// // // // //       } else {
// // // // //         // Only public test cases
// // // // //         testCases = widget.question['test_cases']
// // // // //             .where((testCase) => testCase['is_public'] == true)
// // // // //             .map<Map<String, String>>((testCase) => {
// // // // //                   'input': testCase['input'].toString().trim() + '\n',
// // // // //                   'output': testCase['output'].toString().trim(),
// // // // //                 })
// // // // //             .toList();
// // // // //       }

// // // // //       final Map<String, dynamic> requestBody = {
// // // // //         'language': _selectedLanguage!.toLowerCase(),
// // // // //         'code': code,
// // // // //         'testcases': testCases,
// // // // //         'is_custom_input': customInput != null,
// // // // //         'mode': mode, // Use the passed mode
// // // // //       };

// // // // //       print("[DEBUG] Request Body: ${jsonEncode(requestBody)}");

// // // // //       // Send request to the compiler
// // // // //       final response = await http.post(
// // // // //         endpoint,
// // // // //         headers: {'Content-Type': 'application/json'},
// // // // //         body: jsonEncode(requestBody),
// // // // //       );

// // // // //       print("[DEBUG] Response Status Code: ${response.statusCode}");

// // // // //       if (response.statusCode == 200) {
// // // // //         print("[DEBUG] Response Body: ${response.body}");
// // // // //         final List<dynamic> responseBody = jsonDecode(response.body);

// // // // //         // Update test results in the UI
// // // // //         setState(() {
// // // // //           testResults = responseBody.map<TestCaseResult>((result) {
// // // // //             return TestCaseResult(
// // // // //               testCase: result['input'] ?? '',
// // // // //               expectedResult: result['expected_output'] ?? '',
// // // // //               actualResult: result['actual_output'] ?? '',
// // // // //               passed: result['success'] ?? false,
// // // // //               errorMessage: result['error'] ?? '',
// // // // //               isCustomInput: customInput != null,
// // // // //             );
// // // // //           }).toList();
// // // // //         });

// // // // //         // Only send to backend for "submit" mode
// // // // //         if (mode == "submit") {
// // // // //           final backendRequest = {
// // // // //             "domain_id": widget.question["codingquestiondomain_id"],
// // // // //             "question_id": widget.question["id"],
// // // // //             "language": _selectedLanguage,
// // // // //             "solution_code": code,
// // // // //             "test_results": responseBody,
// // // // //             "mode": mode,
// // // // //           };
// // // // //           print("[DEBUG] Question Object: ${widget.question}");

// // // // //           if (widget.question["codingquestiondomain_id"] == null) {
// // // // //             print("[DEBUG] Missing domain_id in question object");
// // // // //             return;
// // // // //           }

// // // // //           print(
// // // // //               "[DEBUG] Backend Requesttttttttt Payload: ${jsonEncode(backendRequest)}");
// // // // //           final token = await SharedPrefs.getToken();
// // // // //           final backendResponse = await http.post(
// // // // //             Uri.parse(
// // // // //                 "http://localhost:3000/students/practice-coding-question-submit"),
// // // // //             headers: {
// // // // //               'Content-Type': 'application/json',
// // // // //               "Authorization": "Bearer $token",
// // // // //             },
// // // // //             body: jsonEncode(backendRequest),
// // // // //           );

// // // // //           print(
// // // // //               "[DEBUG] Backend Response: ${backendResponse.statusCode} - ${backendResponse.body}");

// // // // //           if (backendResponse.statusCode != 201) {
// // // // //             print("[DEBUG] Backend Submission Error: ${backendResponse.body}");
// // // // //           }
// // // // //         }

// // // // //         _scrollToResults();
// // // // //       } else {
// // // // //         print("[DEBUG] Error Response Body: ${response.body}");
// // // // //         final errorResponse = jsonDecode(response.body);

// // // // //         setState(() {
// // // // //           testResults = [
// // // // //             TestCaseResult(
// // // // //               testCase: '',
// // // // //               expectedResult: '',
// // // // //               actualResult: '',
// // // // //               passed: false,
// // // // //               errorMessage:
// // // // //                   errorResponse['message'] ?? 'Compilation error occurred',
// // // // //             ),
// // // // //           ];
// // // // //         });
// // // // //       }
// // // // //     } catch (error) {
// // // // //       print("[DEBUG] HTTP Request Error: $error");

// // // // //       setState(() {
// // // // //         testResults = [
// // // // //           TestCaseResult(
// // // // //             testCase: '',
// // // // //             expectedResult: '',
// // // // //             actualResult: '',
// // // // //             passed: false,
// // // // //             errorMessage: "Failed to connect to the server. Please try again.",
// // // // //           ),
// // // // //         ];
// // // // //       });
// // // // //     }
// // // // //   }

// // // // //   void _scrollToResults() {
// // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // //       _rightPanelScrollController.animateTo(
// // // // //         _rightPanelScrollController.position.maxScrollExtent,
// // // // //         duration: Duration(milliseconds: 500),
// // // // //         curve: Curves.easeOut,
// // // // //       );
// // // // //     });
// // // // //   }

// // // // //   void _toggleInputFieldVisibility() {
// // // // //     setState(() {
// // // // //       _iscustomInputfieldVisible = !_iscustomInputfieldVisible;
// // // // //     });
// // // // //   }

// // // // //   // Future<void> _autoSaveCode(String code) async {
// // // // //   //   try {
// // // // //   //     final token = await SharedPrefs.getToken();

// // // // //   //     // API request to save the code
// // // // //   //     final response = await http.post(
// // // // //   //       Uri.parse('http://localhost:3000/students/auto-save-code'),
// // // // //   //       headers: {
// // // // //   //         'Content-Type': 'application/json',
// // // // //   //         "Authorization": "Bearer $token",
// // // // //   //       },
// // // // //   //       body: jsonEncode({
// // // // //   //         "domain_id": widget.question["codingquestiondomain_id"],
// // // // //   //         "solution_code": code,
// // // // //   //         "question_id": widget.question["id"],

// // // // //   //         "language": _selectedLanguage,
// // // // //   //       }),
// // // // //   //     );

// // // // //   //     if (response.statusCode == 200) {
// // // // //   //       print("[DEBUG] Code auto-saved successfully");
// // // // //   //     } else {
// // // // //   //       print("[DEBUG] Failed to auto-save code: ${response.body}");
// // // // //   //     }
// // // // //   //   } catch (error) {
// // // // //   //     print("[DEBUG] Auto-save error: $error");
// // // // //   //   }
// // // // //   // }

// // // // //   Widget buildOutputPanel() {
// // // // //     return Padding(
// // // // //       padding: EdgeInsets.all(16.0),
// // // // //       child: SingleChildScrollView(
// // // // //         child: Column(
// // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //           children: [
// // // // //             Row(
// // // // //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // // // //               children: [
// // // // //                 ElevatedButton(
// // // // //                   onPressed: () {
// // // // //                     _runCode(
// // // // //                       allTestCases: false,
// // // // //                       mode: 'run',
// // // // //                     );
// // // // //                   },
// // // // //                   child: Text('Run'),
// // // // //                 ),
// // // // //                 ElevatedButton(
// // // // //                   onPressed: () {
// // // // //                     _runCode(
// // // // //                       allTestCases: true,
// // // // //                       mode: 'submit',
// // // // //                     );
// // // // //                   },
// // // // //                   child: Text('Submit'),
// // // // //                 ),
// // // // //                 ElevatedButton(
// // // // //                   onPressed: _toggleInputFieldVisibility,
// // // // //                   child: Text('Custom Input'),
// // // // //                 ),
// // // // //               ],
// // // // //             ),
// // // // //             SizedBox(height: 16),
// // // // //             if (testResults.isNotEmpty)
// // // // //               TestCaseResultsTable(testResults: testResults),
// // // // //           ],
// // // // //         ),
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   Widget buildMobileView() {
// // // // //     return Column(
// // // // //       children: [
// // // // //         Expanded(
// // // // //           child: TabBarView(
// // // // //             controller: _tabController,
// // // // //             children: [
// // // // //               buildQuestionPanel(),
// // // // //               buildCodeEditorPanel(),
// // // // //               buildOutputPanel(),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       ],
// // // // //     );
// // // // //   }

// // // // //   Widget buildDesktopView() {
// // // // //     return Scaffold(
// // // // //       body: LayoutBuilder(
// // // // //         builder: (context, constraints) {
// // // // //           final screenWidth = constraints.maxWidth;

// // // // //           // Calculate the width of the panels based on the divider position
// // // // //           final leftPanelWidth = screenWidth * _dividerPosition;
// // // // //           final rightPanelWidth = screenWidth * (1 - _dividerPosition);
// // // // //           return Row(
// // // // //             children: [
// // // // //               // Expanded(child: buildQuestionPanel()),

// // // // //               Container(
// // // // //                 width: leftPanelWidth,
// // // // //                 child: Padding(
// // // // //                   padding: EdgeInsets.all(16.0),
// // // // //                   child: SingleChildScrollView(
// // // // //                     child: Column(
// // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                       children: [
// // // // //                         Text(widget.question['title'],
// // // // //                             style: const TextStyle(
// // // // //                                 fontSize: 24, fontWeight: FontWeight.bold)),
// // // // //                         const SizedBox(height: 16),
// // // // //                         const Text("Description",
// // // // //                             style: TextStyle(
// // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                         Text(widget.question['description'],
// // // // //                             style: TextStyle(fontSize: 16)),
// // // // //                         const SizedBox(height: 16),
// // // // //                         const Text("Input Format",
// // // // //                             style: TextStyle(
// // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                         Text(widget.question['input_format'],
// // // // //                             style: TextStyle(fontSize: 16)),
// // // // //                         SizedBox(height: 16),
// // // // //                         const Text("Output Format",
// // // // //                             style: TextStyle(
// // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                         Text(widget.question['output_format'],
// // // // //                             style: TextStyle(fontSize: 16)),
// // // // //                         SizedBox(height: 16),
// // // // //                         const Text("Constraints",
// // // // //                             style: TextStyle(
// // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                         Text(widget.question['constraints'],
// // // // //                             style: TextStyle(fontSize: 16)),
// // // // //                         SizedBox(height: 8),
// // // // //                         Column(
// // // // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                           children: List<Widget>.generate(
// // // // //                             widget.question['test_cases'].length,
// // // // //                             (index) {
// // // // //                               final testCase =
// // // // //                                   widget.question['test_cases'][index];
// // // // //                               return Card(
// // // // //                                 margin: EdgeInsets.symmetric(vertical: 8),
// // // // //                                 child: Padding(
// // // // //                                   padding: const EdgeInsets.all(12.0),
// // // // //                                   child: Column(
// // // // //                                     crossAxisAlignment:
// // // // //                                         CrossAxisAlignment.start,
// // // // //                                     children: [
// // // // //                                       Text("Input: ${testCase['input']}",
// // // // //                                           style: TextStyle(fontSize: 16)),
// // // // //                                       Text("Output: ${testCase['output']}",
// // // // //                                           style: TextStyle(fontSize: 16)),
// // // // //                                       if (testCase['is_public'])
// // // // //                                         Text(
// // // // //                                             "Explanation: ${testCase['explanation'] ?? ''}",
// // // // //                                             style: TextStyle(fontSize: 16)),
// // // // //                                     ],
// // // // //                                   ),
// // // // //                                 ),
// // // // //                               );
// // // // //                             },
// // // // //                           ),
// // // // //                         ),
// // // // //                         SizedBox(height: 16),
// // // // //                         Text("Difficulty",
// // // // //                             style: TextStyle(
// // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //                         SizedBox(height: 8),
// // // // //                         Text(widget.question['difficulty'],
// // // // //                             style: TextStyle(fontSize: 16)),
// // // // //                         SizedBox(height: 16),
// // // // //                         if (widget.question['solutions'] != null &&
// // // // //                             widget.question['solutions'].isNotEmpty)
// // // // //                           Column(
// // // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // // //                             children: [
// // // // //                               SizedBox(height: 16),
// // // // //                               Text("Solutions",
// // // // //                                   style: TextStyle(
// // // // //                                       fontSize: 18,
// // // // //                                       fontWeight: FontWeight.bold)),
// // // // //                               ...List<Widget>.generate(
// // // // //                                 widget.question['solutions'].length,
// // // // //                                 (index) {
// // // // //                                   final solution =
// // // // //                                       widget.question['solutions'][index];
// // // // //                                   return Card(
// // // // //                                     margin: EdgeInsets.symmetric(vertical: 8),
// // // // //                                     child: Padding(
// // // // //                                       padding: const EdgeInsets.all(12.0),
// // // // //                                       child: Column(
// // // // //                                         crossAxisAlignment:
// // // // //                                             CrossAxisAlignment.start,
// // // // //                                         children: [
// // // // //                                           Text(
// // // // //                                             "Language: ${solution['language']}",
// // // // //                                             style: TextStyle(fontSize: 16),
// // // // //                                           ),
// // // // //                                           Text(
// // // // //                                             "Code:",
// // // // //                                             style: TextStyle(
// // // // //                                                 fontSize: 16,
// // // // //                                                 fontWeight: FontWeight.bold),
// // // // //                                           ),
// // // // //                                           Container(
// // // // //                                             width: double.infinity,
// // // // //                                             color: Colors.black12,
// // // // //                                             child: Padding(
// // // // //                                               padding: EdgeInsets.all(8.0),
// // // // //                                               child: Text(
// // // // //                                                 solution['code'],
// // // // //                                                 style: TextStyle(
// // // // //                                                     fontFamily: 'RobotoMono',
// // // // //                                                     fontSize: 14),
// // // // //                                               ),
// // // // //                                             ),
// // // // //                                           ),
// // // // //                                           if (solution['youtube_link'] != null)
// // // // //                                             Text(
// // // // //                                               "YouTube Link: ${solution['youtube_link']}",
// // // // //                                               style: TextStyle(fontSize: 16),
// // // // //                                             ),
// // // // //                                         ],
// // // // //                                       ),
// // // // //                                     ),
// // // // //                                   );
// // // // //                                 },
// // // // //                               ),
// // // // //                             ],
// // // // //                           ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ),

// // // // //               GestureDetector(
// // // // //                 behavior: HitTestBehavior.translucent,
// // // // //                 onHorizontalDragUpdate: (details) {
// // // // //                   setState(() {
// // // // //                     _dividerPosition += details.delta.dx / screenWidth;
// // // // //                     // Limit the position between 0.35 (35%) and 0.55 (55%)
// // // // //                     _dividerPosition = _dividerPosition.clamp(0.28, 0.55);
// // // // //                   });
// // // // //                 },
// // // // //                 child: Container(
// // // // //                   color: Colors.transparent,
// // // // //                   width: 22,
// // // // //                   child: Center(
// // // // //                     child: Row(
// // // // //                       children: [
// // // // //                         Container(
// // // // //                           height: 5,
// // // // //                           width: 10,
// // // // //                           color: Colors.transparent,
// // // // //                           child: CustomPaint(
// // // // //                             painter: LeftArrowPainter(
// // // // //                               strokeColor: Colors.grey,
// // // // //                               strokeWidth: 0,
// // // // //                               paintingStyle: PaintingStyle.fill,
// // // // //                             ),
// // // // //                             child: const SizedBox(
// // // // //                               height: 5,
// // // // //                               width: 10,
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                         Container(
// // // // //                           height: double.infinity,
// // // // //                           width: 2,
// // // // //                           decoration: BoxDecoration(
// // // // //                             color: Colors.grey,
// // // // //                             borderRadius: BorderRadius.circular(2),
// // // // //                           ),
// // // // //                         ),
// // // // //                         Container(
// // // // //                           height: 5,
// // // // //                           width: 10,
// // // // //                           color: Colors.transparent,
// // // // //                           child: CustomPaint(
// // // // //                             painter: RightArrowPainter(
// // // // //                               strokeColor: Colors.grey,
// // // // //                               strokeWidth: 0,
// // // // //                               paintingStyle: PaintingStyle.fill,
// // // // //                             ),
// // // // //                             child: const SizedBox(
// // // // //                               height: 5,
// // // // //                               width: 10,
// // // // //                             ),
// // // // //                           ),
// // // // //                         ),
// // // // //                       ],
// // // // //                     ),
// // // // //                   ),
// // // // //                 ),
// // // // //               ),
// // // // //               Expanded(child: codefieldbox()),
// // // // //             ],
// // // // //           );
// // // // //         },
// // // // //       ),
// // // // //     );
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     final bool isMobile = MediaQuery.of(context).size.width < 600;

// // // // //     return Scaffold(
// // // // //       appBar: AppBar(
// // // // //         leading: IconButton(
// // // // //             onPressed: () {
// // // // //               Navigator.pop(context, true); // Return true if changes are made
// // // // //             },
// // // // //             icon: Icon(Icons.arrow_back)),
// // // // //         title: Text(widget.question['title']),
// // // // //         bottom: isMobile
// // // // //             ? TabBar(controller: _tabController, tabs: [
// // // // //                 Tab(text: "Question"),
// // // // //                 Tab(text: "Code"),
// // // // //                 Tab(text: "Output")
// // // // //               ])
// // // // //             : null,
// // // // //       ),
// // // // //       body: isMobile ? buildMobileView() : buildDesktopView(),
// // // // //     );
// // // // //   }
// // // // // }

// // // // // class TestCaseResult {
// // // // //   final String testCase;
// // // // //   final String expectedResult;
// // // // //   final String actualResult;
// // // // //   final bool passed;
// // // // //   final String errorMessage;
// // // // //   final bool isCustomInput;
// // // // //   TestCaseResult({
// // // // //     required this.testCase,
// // // // //     required this.expectedResult,
// // // // //     required this.actualResult,
// // // // //     required this.passed,
// // // // //     this.errorMessage = '',
// // // // //     this.isCustomInput = false,
// // // // //   });
// // // // // }

// // // // // // class TestCaseResultsTable extends StatelessWidget {
// // // // // //   final List<TestCaseResult> testResults;

// // // // // //   TestCaseResultsTable({required this.testResults});

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Column(
// // // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //       children: [
// // // // // //         Text("Test Results",
// // // // // //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //         Divider(thickness: 2),
// // // // // //         Column(
// // // // // //           children: testResults.map((result) {
// // // // // //             return Column(
// // // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //               children: [
// // // // // //                 Row(
// // // // // //                   children: [
// // // // // //                     Expanded(child: Text("Input: ${result.testCase}")),
// // // // // //                     Expanded(child: Text("Output: ${result.actualResult}")),
// // // // // //                     Expanded(
// // // // // //                       child: Text(
// // // // // //                         result.isCustomInput
// // // // // //                             ? "-"
// // // // // //                             : "Expected: ${result.expectedResult}",
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                     Expanded(
// // // // // //                       child: Text(
// // // // // //                         result.isCustomInput
// // // // // //                             ? "-"
// // // // // //                             : (result.passed ? "Passed" : "Failed"),
// // // // // //                         style: TextStyle(
// // // // // //                           color: result.isCustomInput
// // // // // //                               ? Colors.black
// // // // // //                               : (result.passed ? Colors.green : Colors.red),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //                 if (result.errorMessage.isNotEmpty)
// // // // // //                   Padding(
// // // // // //                     padding: const EdgeInsets.only(top: 4.0),
// // // // // //                     child: Text(
// // // // // //                       "Error: ${result.errorMessage}",
// // // // // //                       style: TextStyle(
// // // // // //                           color: Colors.red, fontStyle: FontStyle.italic),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 Divider(thickness: 1),
// // // // // //               ],
// // // // // //             );
// // // // // //           }).toList(),
// // // // // //         ),
// // // // // //       ],
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // class TestCaseResultsTable extends StatelessWidget {
// // // // //   final List<TestCaseResult> testResults;

// // // // //   TestCaseResultsTable({required this.testResults});

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     return Column(
// // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // //       children: [
// // // // //         Text("Test Results",
// // // // //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // //         Divider(thickness: 2),
// // // // //         Column(
// // // // //           children: testResults.map((result) {
// // // // //             return Column(
// // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // //               children: [
// // // // //                 Row(
// // // // //                   children: [
// // // // //                     Expanded(
// // // // //                       child: Text(
// // // // //                         "Input: ${result.testCase}",
// // // // //                         style: TextStyle(fontWeight: FontWeight.bold),
// // // // //                       ),
// // // // //                     ),
// // // // //                     Expanded(
// // // // //                       child: Text(
// // // // //                         "Output: ${result.actualResult}",
// // // // //                         style: TextStyle(fontWeight: FontWeight.bold),
// // // // //                       ),
// // // // //                     ),
// // // // //                     if (!result.isCustomInput)
// // // // //                       Expanded(
// // // // //                         child: Text(
// // // // //                           "Expected: ${result.expectedResult}",
// // // // //                           style: TextStyle(color: Colors.grey),
// // // // //                         ),
// // // // //                       ),
// // // // //                     Expanded(
// // // // //                       child: Text(
// // // // //                         result.isCustomInput
// // // // //                             ? "Custom Run"
// // // // //                             : (result.passed ? "Passed" : "Failed"),
// // // // //                         style: TextStyle(
// // // // //                           color: result.isCustomInput
// // // // //                               ? Colors.blue
// // // // //                               : (result.passed ? Colors.green : Colors.red),
// // // // //                         ),
// // // // //                       ),
// // // // //                     ),
// // // // //                   ],
// // // // //                 ),
// // // // //                 if (result.errorMessage.isNotEmpty)
// // // // //                   Padding(
// // // // //                     padding: const EdgeInsets.only(top: 4.0),
// // // // //                     child: Text(
// // // // //                       "Error: ${result.errorMessage}",
// // // // //                       style: TextStyle(
// // // // //                           color: Colors.red, fontStyle: FontStyle.italic),
// // // // //                     ),
// // // // //                   ),
// // // // //                 Divider(thickness: 1),
// // // // //               ],
// // // // //             );
// // // // //           }).toList(),
// // // // //         ),
// // // // //       ],
// // // // //     );
// // // // //   }
// // // // // }


// // // // // // import 'package:flutter/material.dart';
// // // // // // import 'package:flutter/services.dart';
// // // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_controller.dart';
// // // // // // import 'package:studentpanel100/package%20for%20code%20editor/code_field/code_field.dart';
// // // // // // import 'package:studentpanel100/package%20for%20code%20editor/line_numbers/line_number_style.dart';
// // // // // // import 'package:http/http.dart' as http;
// // // // // // import 'dart:convert';
// // // // // // import 'package:studentpanel100/widgets/arrows_ui.dart';

// // // // // // class CodingQuestionDetailPage extends StatefulWidget {
// // // // // //   final Map<String, dynamic> question;

// // // // // //   const CodingQuestionDetailPage({Key? key, required this.question})
// // // // // //       : super(key: key);

// // // // // //   @override
// // // // // //   State<CodingQuestionDetailPage> createState() =>
// // // // // //       _CodingQuestionDetailPageState();
// // // // // // }

// // // // // // class _CodingQuestionDetailPageState extends State<CodingQuestionDetailPage>
// // // // // //     with SingleTickerProviderStateMixin {
// // // // // //   late CodeController _codeController;
// // // // // //   final FocusNode _focusNode = FocusNode();
// // // // // //   List<TestCaseResult> testResults = [];
// // // // // //   final ScrollController _rightPanelScrollController = ScrollController();
// // // // // //   String? _selectedLanguage = "Please select a Language";
// // // // // //   TextEditingController _customInputController = TextEditingController();
// // // // // //   bool _iscustomInputfieldVisible = false;
// // // // // //   double _dividerPosition = 0.5;
// // // // // //   late TabController _tabController;

// // // // // //   @override
// // // // // //   void initState() {
// // // // // //     super.initState();
// // // // // //     print("[DEBUG] CodingQuestionDetailPage initState called");
// // // // // //     _tabController = TabController(length: 3, vsync: this);
// // // // // //     _codeController = CodeController(text: '''
// // // // // // ***************************************************
// // // // // // ***************  Select a Language  ***************
// // // // // // ***************************************************
// // // // // // ''');
// // // // // //     _focusNode.addListener(() {
// // // // // //       if (_focusNode.hasFocus) {
// // // // // //         RawKeyboard.instance.addListener(_handleKeyPress);
// // // // // //       } else {
// // // // // //         RawKeyboard.instance.removeListener(_handleKeyPress);
// // // // // //       }
// // // // // //     });
// // // // // //   }

// // // // // //   @override
// // // // // //   void dispose() {
// // // // // //     print("[DEBUG] CodingQuestionDetailPage dispose called");

// // // // // //     _tabController.dispose();
// // // // // //     _codeController.dispose();
// // // // // //     _focusNode.dispose();
// // // // // //     _customInputController.dispose();
// // // // // //     super.dispose();
// // // // // //   }

// // // // // //   void _handleKeyPress(RawKeyEvent event) {
// // // // // //     if (event.isControlPressed &&
// // // // // //         event.logicalKey == LogicalKeyboardKey.slash) {
// // // // // //       _commentSelectedLines();
// // // // // //     }
// // // // // //   }

// // // // // //   void _setStarterCode(String language) {
// // // // // //     String starterCode;
// // // // // //     switch (language.toLowerCase()) {
// // // // // //       case 'python':
// // // // // //         starterCode = '# Please Start Writing your Code here\n';
// // // // // //         break;
// // // // // //       case 'java':
// // // // // //         starterCode = '''
// // // // // // public class Main {
// // // // // //     public static void main(String[] args) {
// // // // // //         // Please Start Writing your Code from here
// // // // // //     }
// // // // // // }
// // // // // // ''';
// // // // // //         break;
// // // // // //       case 'c':
// // // // // //         starterCode = '// Please Start Writing your Code here\n';
// // // // // //         break;
// // // // // //       case 'cpp':
// // // // // //         starterCode = '// Please Start Writing your Code here\n';
// // // // // //         break;
// // // // // //       default:
// // // // // //         starterCode = '// Please Start Writing your Code here\n';
// // // // // //     }
// // // // // //     _codeController.text = starterCode;
// // // // // //   }

// // // // // //   void _commentSelectedLines() {
// // // // // //     final selection = _codeController.selection;
// // // // // //     final text = _codeController.text;
// // // // // //     final commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

// // // // // //     if (selection.isCollapsed) {
// // // // // //       int lineStart = selection.start;
// // // // // //       int lineEnd = selection.start;

// // // // // //       while (lineStart > 0 && text[lineStart - 1] != '\n') lineStart--;
// // // // // //       while (lineEnd < text.length && text[lineEnd] != '\n') lineEnd++;

// // // // // //       final lineText = text.substring(lineStart, lineEnd);
// // // // // //       final isCommented = lineText.trimLeft().startsWith(commentSyntax);

// // // // // //       final newLineText = isCommented
// // // // // //           ? lineText.replaceFirst(commentSyntax, '').trimLeft()
// // // // // //           : '$commentSyntax $lineText';

// // // // // //       final newText = text.replaceRange(lineStart, lineEnd, newLineText);
// // // // // //       _codeController.value = _codeController.value.copyWith(
// // // // // //         text: newText,
// // // // // //         selection: TextSelection.collapsed(
// // // // // //             offset: isCommented
// // // // // //                 ? selection.start - commentSyntax.length - 1
// // // // // //                 : selection.start + commentSyntax.length + 1),
// // // // // //       );
// // // // // //     } else {
// // // // // //       final selectedText = text.substring(selection.start, selection.end);
// // // // // //       final lines = selectedText.split('\n');
// // // // // //       final allLinesCommented =
// // // // // //           lines.every((line) => line.trimLeft().startsWith(commentSyntax));

// // // // // //       final commentedLines = lines.map((line) {
// // // // // //         return allLinesCommented
// // // // // //             ? line.replaceFirst(commentSyntax, '').trimLeft()
// // // // // //             : '$commentSyntax $line';
// // // // // //       }).join('\n');

// // // // // //       final newText =
// // // // // //           text.replaceRange(selection.start, selection.end, commentedLines);

// // // // // //       _codeController.value = _codeController.value.copyWith(
// // // // // //         text: newText,
// // // // // //         selection: TextSelection(
// // // // // //           baseOffset: selection.start,
// // // // // //           extentOffset: selection.start + commentedLines.length,
// // // // // //         ),
// // // // // //       );
// // // // // //     }
// // // // // //   }

// // // // // //   Widget buildQuestionPanel() {
// // // // // //     return Padding(
// // // // // //       padding: EdgeInsets.all(16.0),
// // // // // //       child: SingleChildScrollView(
// // // // // //         child: Column(
// // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //           children: [
// // // // // //             Text(widget.question['title'],
// // // // // //                 style:
// // // // // //                     const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
// // // // // //             const SizedBox(height: 16),
// // // // // //             const Text("Description",
// // // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //             Text(widget.question['description'],
// // // // // //                 style: TextStyle(fontSize: 16)),
// // // // // //             const SizedBox(height: 16),
// // // // // //             const Text("Input Format",
// // // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //             Text(widget.question['input_format'],
// // // // // //                 style: TextStyle(fontSize: 16)),
// // // // // //             SizedBox(height: 16),
// // // // // //             const Text("Output Format",
// // // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //             Text(widget.question['output_format'],
// // // // // //                 style: TextStyle(fontSize: 16)),
// // // // // //             SizedBox(height: 16),
// // // // // //             const Text("Constraints",
// // // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //             Text(widget.question['constraints'],
// // // // // //                 style: TextStyle(fontSize: 16)),
// // // // // //             SizedBox(height: 8),
// // // // // //             Column(
// // // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //               children: List<Widget>.generate(
// // // // // //                 widget.question['test_cases'].length,
// // // // // //                 (index) {
// // // // // //                   final testCase = widget.question['test_cases'][index];
// // // // // //                   return Card(
// // // // // //                     margin: EdgeInsets.symmetric(vertical: 8),
// // // // // //                     child: Padding(
// // // // // //                       padding: const EdgeInsets.all(12.0),
// // // // // //                       child: Column(
// // // // // //                         crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                         children: [
// // // // // //                           Text("Input: ${testCase['input']}",
// // // // // //                               style: TextStyle(fontSize: 16)),
// // // // // //                           Text("Output: ${testCase['output']}",
// // // // // //                               style: TextStyle(fontSize: 16)),
// // // // // //                           if (testCase['is_public'])
// // // // // //                             Text(
// // // // // //                                 "Explanation: ${testCase['explanation'] ?? ''}",
// // // // // //                                 style: TextStyle(fontSize: 16)),
// // // // // //                         ],
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   );
// // // // // //                 },
// // // // // //               ),
// // // // // //             ),
// // // // // //             SizedBox(height: 16),
// // // // // //             Text("Difficulty",
// // // // // //                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //             SizedBox(height: 8),
// // // // // //             Text(widget.question['difficulty'], style: TextStyle(fontSize: 16)),
// // // // // //             SizedBox(height: 16),
// // // // // //             Text("Hello"),
// // // // // //             if (widget.question['solutions'] != null &&
// // // // // //                 widget.question['solutions'].isNotEmpty)
// // // // // //               Column(
// // // // // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                 children: [
// // // // // //                   SizedBox(height: 16),
// // // // // //                   Text("Solutions",
// // // // // //                       style:
// // // // // //                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //                   ...List<Widget>.generate(
// // // // // //                     widget.question['solutions'].length,
// // // // // //                     (index) {
// // // // // //                       final solution = widget.question['solutions'][index];
// // // // // //                       return Card(
// // // // // //                         margin: EdgeInsets.symmetric(vertical: 8),
// // // // // //                         child: Padding(
// // // // // //                           padding: const EdgeInsets.all(12.0),
// // // // // //                           child: Column(
// // // // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                             children: [
// // // // // //                               Text(
// // // // // //                                 "Language: ${solution['language']}",
// // // // // //                                 style: TextStyle(fontSize: 16),
// // // // // //                               ),
// // // // // //                               Text(
// // // // // //                                 "Code:",
// // // // // //                                 style: TextStyle(
// // // // // //                                     fontSize: 16, fontWeight: FontWeight.bold),
// // // // // //                               ),
// // // // // //                               Container(
// // // // // //                                 width: double.infinity,
// // // // // //                                 color: Colors.black12,
// // // // // //                                 child: Padding(
// // // // // //                                   padding: EdgeInsets.all(8.0),
// // // // // //                                   child: Text(
// // // // // //                                     solution['code'],
// // // // // //                                     style: TextStyle(
// // // // // //                                         fontFamily: 'RobotoMono', fontSize: 14),
// // // // // //                                   ),
// // // // // //                                 ),
// // // // // //                               ),
// // // // // //                               if (solution['youtube_link'] != null)
// // // // // //                                 Text(
// // // // // //                                   "YouTube Link: ${solution['youtube_link']}",
// // // // // //                                   style: TextStyle(fontSize: 16),
// // // // // //                                 ),
// // // // // //                             ],
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       );
// // // // // //                     },
// // // // // //                   ),
// // // // // //                 ],
// // // // // //               ),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget codefieldbox() {
// // // // // //     return Expanded(
// // // // // //       child: Container(
// // // // // //         // width: rightPanelWidth,
// // // // // //         height: MediaQuery.of(context).size.height * 2,
// // // // // //         color: Colors.white,
// // // // // //         child: SingleChildScrollView(
// // // // // //           controller: _rightPanelScrollController,
// // // // // //           child: Padding(
// // // // // //             padding: EdgeInsets.all(16.0),
// // // // // //             child: Column(
// // // // // //               children: [
// // // // // //                 Text("Select Language",
// // // // // //                     style:
// // // // // //                         TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //                 DropdownButton<String>(
// // // // // //                   value: _selectedLanguage,
// // // // // //                   onChanged: (String? newValue) {
// // // // // //                     if (newValue != null &&
// // // // // //                         newValue != "Please select a Language") {
// // // // // //                       if (_selectedLanguage != "Please select a Language") {
// // // // // //                         // Show alert if a language was previously selected
// // // // // //                         showDialog(
// // // // // //                           context: context,
// // // // // //                           builder: (BuildContext context) {
// // // // // //                             return AlertDialog(
// // // // // //                               title: Text("Change Language"),
// // // // // //                               content: Text(
// // // // // //                                   "Changing the language will remove the current code. Do you want to proceed?"),
// // // // // //                               actions: [
// // // // // //                                 TextButton(
// // // // // //                                   child: Text("Cancel"),
// // // // // //                                   onPressed: () {
// // // // // //                                     Navigator.of(context)
// // // // // //                                         .pop(); // Close the dialog
// // // // // //                                   },
// // // // // //                                 ),
// // // // // //                                 TextButton(
// // // // // //                                   child: Text("Proceed"),
// // // // // //                                   onPressed: () {
// // // // // //                                     // Proceed with changing the language and setting starter code
// // // // // //                                     setState(() {
// // // // // //                                       _selectedLanguage = newValue;
// // // // // //                                       _setStarterCode(newValue);
// // // // // //                                     });
// // // // // //                                     Navigator.of(context)
// // // // // //                                         .pop(); // Close the dialog
// // // // // //                                   },
// // // // // //                                 ),
// // // // // //                               ],
// // // // // //                             );
// // // // // //                           },
// // // // // //                         );
// // // // // //                       } else {
// // // // // //                         // Directly set language and starter code if no language was selected previously
// // // // // //                         setState(() {
// // // // // //                           _selectedLanguage = newValue;
// // // // // //                           _setStarterCode(newValue);
// // // // // //                         });
// // // // // //                       }
// // // // // //                     }
// // // // // //                   },
// // // // // //                   items: [
// // // // // //                     DropdownMenuItem<String>(
// // // // // //                       value: "Please select a Language",
// // // // // //                       child: Text("Please select a Language"),
// // // // // //                     ),
// // // // // //                     ...widget.question['allowed_languages']
// // // // // //                         .cast<String>()
// // // // // //                         .map<DropdownMenuItem<String>>((String language) {
// // // // // //                       return DropdownMenuItem<String>(
// // // // // //                         value: language,
// // // // // //                         child: Text(language),
// // // // // //                       );
// // // // // //                     }).toList(),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //                 Focus(
// // // // // //                   focusNode: _focusNode, // Attach the focus node to Focus only
// // // // // //                   onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
// // // // // //                     if (keyEvent is KeyDownEvent) {
// // // // // //                       final keysPressed =
// // // // // //                           HardwareKeyboard.instance.logicalKeysPressed;

// // // // // //                       // Check for Ctrl + / shortcut
// // // // // //                       if (keysPressed
// // // // // //                               .contains(LogicalKeyboardKey.controlLeft) &&
// // // // // //                           keysPressed.contains(LogicalKeyboardKey.slash)) {
// // // // // //                         _commentSelectedLines();
// // // // // //                         return KeyEventResult.handled;
// // // // // //                       }
// // // // // //                     }
// // // // // //                     return KeyEventResult.ignored;
// // // // // //                   },
// // // // // //                   child: Container(
// // // // // //                     // height: 200,
// // // // // //                     height: MediaQuery.of(context).size.height / 1.7,
// // // // // //                     child: CodeField(
// // // // // //                       controller: _codeController,
// // // // // //                       focusNode: FocusNode(),
// // // // // //                       textStyle: TextStyle(
// // // // // //                         fontFamily: 'RobotoMono',
// // // // // //                         fontSize: 16,
// // // // // //                         color: Colors.white,
// // // // // //                       ),
// // // // // //                       cursorColor: Colors.white,
// // // // // //                       background: Colors.black,
// // // // // //                       expands: true,
// // // // // //                       wrap: false,
// // // // // //                       lineNumberStyle: LineNumberStyle(
// // // // // //                         width: 40,
// // // // // //                         margin: 8,
// // // // // //                         textStyle: TextStyle(
// // // // // //                           color: Colors.grey.shade600,
// // // // // //                           fontSize: 16,
// // // // // //                         ),
// // // // // //                         background: Colors.grey.shade900,
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //                 SizedBox(height: 16),
// // // // // //                 Row(
// // // // // //                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // // // // //                   children: [
// // // // // //                     ElevatedButton(
// // // // // //                       onPressed: () {
// // // // // //                         _runCode(allTestCases: false);
// // // // // //                       },
// // // // // //                       child: Text('Run'),
// // // // // //                     ),
// // // // // //                     ElevatedButton(
// // // // // //                       onPressed: () {
// // // // // //                         _runCode(allTestCases: true);
// // // // // //                       },
// // // // // //                       child: Text('Submit'),
// // // // // //                     ),
// // // // // //                     ElevatedButton(
// // // // // //                       onPressed: _toggleInputFieldVisibility,
// // // // // //                       child: Text('Custom Input'),
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //                 SizedBox(height: 16),
// // // // // //                 AnimatedCrossFade(
// // // // // //                   duration: Duration(milliseconds: 300),
// // // // // //                   firstChild: SizedBox.shrink(),
// // // // // //                   secondChild: Column(
// // // // // //                     children: [
// // // // // //                       Container(
// // // // // //                         // height: 250,
// // // // // //                         width: MediaQuery.of(context).size.width * 0.25,
// // // // // //                         child: TextField(
// // // // // //                           minLines: 5,
// // // // // //                           maxLines: 5,
// // // // // //                           controller: _customInputController,
// // // // // //                           decoration: InputDecoration(
// // // // // //                             hintText: "Enter custom input",
// // // // // //                             hintStyle: TextStyle(color: Colors.white54),
// // // // // //                             filled: true,
// // // // // //                             fillColor: Colors.black,
// // // // // //                             border: OutlineInputBorder(),
// // // // // //                           ),
// // // // // //                           style: TextStyle(color: Colors.white),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                       SizedBox(height: 10),
// // // // // //                       ElevatedButton(
// // // // // //                         onPressed: () {
// // // // // //                           _runCode(
// // // // // //                             allTestCases: false,
// // // // // //                             customInput: _customInputController.text,
// // // // // //                           );
// // // // // //                         },
// // // // // //                         child: Text('Run Custom Input'),
// // // // // //                       ),
// // // // // //                     ],
// // // // // //                   ),
// // // // // //                   crossFadeState: _iscustomInputfieldVisible
// // // // // //                       ? CrossFadeState.showSecond
// // // // // //                       : CrossFadeState.showFirst,
// // // // // //                 ),
// // // // // //                 SizedBox(height: 16),
// // // // // //                 if (testResults.isNotEmpty)
// // // // // //                   TestCaseResultsTable(testResults: testResults),
// // // // // //               ],
// // // // // //             ),
// // // // // //           ),
// // // // // //         ),
// // // // // //       ),
// // // // // //       // );
// // // // // //       // },
// // // // // //     );
// // // // // //   }

// // // // // //   Widget buildCodeEditorPanel() {
// // // // // //     return Padding(
// // // // // //       padding: EdgeInsets.all(16.0),
// // // // // //       child: Column(
// // // // // //         children: [
// // // // // //           Text("Select Language",
// // // // // //               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //           DropdownButton<String>(
// // // // // //             value: _selectedLanguage,
// // // // // //             onChanged: (String? newValue) {
// // // // // //               if (newValue != null && newValue != "Please select a Language") {
// // // // // //                 if (_selectedLanguage != "Please select a Language") {
// // // // // //                   // Show alert if a language was previously selected
// // // // // //                   showDialog(
// // // // // //                     context: context,
// // // // // //                     builder: (BuildContext context) {
// // // // // //                       return AlertDialog(
// // // // // //                         title: Text("Change Language"),
// // // // // //                         content: Text(
// // // // // //                             "Changing the language will remove the current code. Do you want to proceed?"),
// // // // // //                         actions: [
// // // // // //                           TextButton(
// // // // // //                             child: Text("Cancel"),
// // // // // //                             onPressed: () {
// // // // // //                               Navigator.of(context).pop(); // Close the dialog
// // // // // //                             },
// // // // // //                           ),
// // // // // //                           TextButton(
// // // // // //                             child: Text("Proceed"),
// // // // // //                             onPressed: () {
// // // // // //                               // Proceed with changing the language and setting starter code
// // // // // //                               setState(() {
// // // // // //                                 _selectedLanguage = newValue;
// // // // // //                                 _setStarterCode(newValue);
// // // // // //                               });
// // // // // //                               Navigator.of(context).pop(); // Close the dialog
// // // // // //                             },
// // // // // //                           ),
// // // // // //                         ],
// // // // // //                       );
// // // // // //                     },
// // // // // //                   );
// // // // // //                 } else {
// // // // // //                   // Directly set language and starter code if no language was selected previously
// // // // // //                   setState(() {
// // // // // //                     _selectedLanguage = newValue;
// // // // // //                     _setStarterCode(newValue);
// // // // // //                   });
// // // // // //                 }
// // // // // //               }
// // // // // //             },
// // // // // //             items: [
// // // // // //               DropdownMenuItem<String>(
// // // // // //                 value: "Please select a Language",
// // // // // //                 child: Text("Please select a Language"),
// // // // // //               ),
// // // // // //               ...widget.question['allowed_languages']
// // // // // //                   .cast<String>()
// // // // // //                   .map<DropdownMenuItem<String>>((String language) {
// // // // // //                 return DropdownMenuItem<String>(
// // // // // //                   value: language,
// // // // // //                   child: Text(language),
// // // // // //                 );
// // // // // //               }).toList(),
// // // // // //             ],
// // // // // //           ),
// // // // // //           Expanded(
// // // // // //             child: Focus(
// // // // // //               focusNode: _focusNode, // Attach the focus node to Focus only
// // // // // //               onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
// // // // // //                 if (keyEvent is KeyDownEvent) {
// // // // // //                   final keysPressed =
// // // // // //                       HardwareKeyboard.instance.logicalKeysPressed;

// // // // // //                   // Check for Ctrl + / shortcut
// // // // // //                   if (keysPressed.contains(LogicalKeyboardKey.controlLeft) &&
// // // // // //                       keysPressed.contains(LogicalKeyboardKey.slash)) {
// // // // // //                     _commentSelectedLines();
// // // // // //                     return KeyEventResult.handled;
// // // // // //                   }
// // // // // //                 }
// // // // // //                 return KeyEventResult.ignored;
// // // // // //               },
// // // // // //               child: Container(
// // // // // //                 // height: 200,
// // // // // //                 height: MediaQuery.of(context).size.height / 3.5,
// // // // // //                 child: CodeField(
// // // // // //                   controller: _codeController,
// // // // // //                   focusNode: FocusNode(),
// // // // // //                   textStyle: TextStyle(
// // // // // //                     fontFamily: 'RobotoMono',
// // // // // //                     fontSize: 16,
// // // // // //                     color: Colors.white,
// // // // // //                   ),
// // // // // //                   cursorColor: Colors.white,
// // // // // //                   background: Colors.black,
// // // // // //                   expands: true,
// // // // // //                   wrap: false,
// // // // // //                   lineNumberStyle: LineNumberStyle(
// // // // // //                     width: 40,
// // // // // //                     margin: 8,
// // // // // //                     textStyle: TextStyle(
// // // // // //                       color: Colors.grey.shade600,
// // // // // //                       fontSize: 16,
// // // // // //                     ),
// // // // // //                     background: Colors.grey.shade900,
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ),
// // // // // //             ),
// // // // // //           ),
// // // // // //         ],
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Future<void> _runCode(
// // // // // //       {required bool allTestCases, String? customInput}) async {
// // // // // //     if (_selectedLanguage == null || _codeController.text.trim().isEmpty) {
// // // // // //       print("No valid code provided or language not selected");
// // // // // //       return;
// // // // // //     }

// // // // // //     Uri endpoint;
// // // // // //     switch (_selectedLanguage!.toLowerCase()) {
// // // // // //       case 'python':
// // // // // //         endpoint = Uri.parse('http://localhost:8084/compile');
// // // // // //         break;
// // // // // //       case 'java':
// // // // // //         endpoint = Uri.parse('http://localhost:8083/compile');
// // // // // //         break;
// // // // // //       case 'cpp':
// // // // // //         endpoint = Uri.parse('http://localhost:8081/compile');
// // // // // //         break;
// // // // // //       case 'c':
// // // // // //         endpoint = Uri.parse('http://localhost:8082/compile');
// // // // // //         break;
// // // // // //       default:
// // // // // //         print("Unsupported language selected");
// // // // // //         return;
// // // // // //     }

// // // // // //     print('Selected Endpoint URL: $endpoint');

// // // // // //     final String code = _codeController.text.trim();
// // // // // //     List<Map<String, String>> testCases;

// // // // // //     // Determine which test cases to send based on the button clicked
// // // // // //     if (customInput != null) {
// // // // // //       testCases = [
// // // // // //         {
// // // // // //           'input': customInput.trim() + '\n',
// // // // // //           'output': '', // No expected output for custom input
// // // // // //         },
// // // // // //       ];
// // // // // //     } else if (allTestCases) {
// // // // // //       testCases = widget.question['test_cases']
// // // // // //           .map<Map<String, String>>((testCase) => {
// // // // // //                 'input': testCase['input'].toString().trim() + '\n',
// // // // // //                 'output': testCase['output'].toString().trim(),
// // // // // //               })
// // // // // //           .toList();
// // // // // //     } else {
// // // // // //       // Run only public test cases
// // // // // //       testCases = widget.question['test_cases']
// // // // // //           .where((testCase) => testCase['is_public'] == true)
// // // // // //           .map<Map<String, String>>((testCase) => {
// // // // // //                 'input': testCase['input'].toString().trim() + '\n',
// // // // // //                 'output': testCase['output'].toString().trim(),
// // // // // //               })
// // // // // //           .toList();
// // // // // //     }

// // // // // //     final Map<String, dynamic> requestBody = {
// // // // // //       'language': _selectedLanguage!.toLowerCase(),
// // // // // //       'code': code,
// // // // // //       'testcases': testCases,
// // // // // //     };

// // // // // //     print('Request Body: ${jsonEncode(requestBody)}');

// // // // // //     try {
// // // // // //       final response = await http.post(
// // // // // //         endpoint,
// // // // // //         headers: {'Content-Type': 'application/json'},
// // // // // //         body: jsonEncode(requestBody),
// // // // // //       );

// // // // // //       if (response.statusCode == 200) {
// // // // // //         final List<dynamic> responseBody = jsonDecode(response.body);
// // // // // //         setState(() {
// // // // // //           testResults = responseBody.map((result) {
// // // // // //             return TestCaseResult(
// // // // // //               testCase: result['input'],
// // // // // //               expectedResult: result['expected_output'] ?? '',
// // // // // //               actualResult: result['actual_output'] ?? '',
// // // // // //               passed: result['success'] ?? false,
// // // // // //               errorMessage: result['error'] ?? '',
// // // // // //             );
// // // // // //           }).toList();
// // // // // //         });
// // // // // //         _scrollToResults();
// // // // // //       } else {
// // // // // //         print('Error: ${response.statusCode} - ${response.reasonPhrase}');
// // // // // //         print('Backend Error Response: ${response.body}');
// // // // // //         setState(() {
// // // // // //           testResults = [
// // // // // //             TestCaseResult(
// // // // // //               testCase: '',
// // // // // //               expectedResult: '',
// // // // // //               actualResult: '',
// // // // // //               passed: false,
// // // // // //               errorMessage: jsonDecode(response.body)['error'],
// // // // // //             ),
// // // // // //           ];
// // // // // //         });
// // // // // //       }
// // // // // //     } catch (error) {
// // // // // //       print('Error sending request: $error');
// // // // // //     }
// // // // // //   }

// // // // // //   void _scrollToResults() {
// // // // // //     WidgetsBinding.instance.addPostFrameCallback((_) {
// // // // // //       _rightPanelScrollController.animateTo(
// // // // // //         _rightPanelScrollController.position.maxScrollExtent,
// // // // // //         duration: Duration(milliseconds: 500),
// // // // // //         curve: Curves.easeOut,
// // // // // //       );
// // // // // //     });
// // // // // //   }

// // // // // //   void _navigateToCodeDisplay(BuildContext context) {
// // // // // //     Navigator.push(
// // // // // //       context,
// // // // // //       MaterialPageRoute(
// // // // // //         builder: (context) => DisplayCodePage(
// // // // // //           code: _codeController.text,
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   void _toggleInputFieldVisibility() {
// // // // // //     setState(() {
// // // // // //       _iscustomInputfieldVisible = !_iscustomInputfieldVisible;
// // // // // //     });
// // // // // //   }

// // // // // //   Widget buildOutputPanel() {
// // // // // //     return Padding(
// // // // // //       padding: EdgeInsets.all(16.0),
// // // // // //       child: SingleChildScrollView(
// // // // // //         child: Column(
// // // // // //           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //           children: [
// // // // // //             Row(
// // // // // //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// // // // // //               children: [
// // // // // //                 ElevatedButton(
// // // // // //                   onPressed: () {
// // // // // //                     _runCode(allTestCases: false);
// // // // // //                   },
// // // // // //                   child: Text('Run'),
// // // // // //                 ),
// // // // // //                 ElevatedButton(
// // // // // //                   onPressed: () {
// // // // // //                     _runCode(allTestCases: true);
// // // // // //                   },
// // // // // //                   child: Text('Submit'),
// // // // // //                 ),
// // // // // //                 ElevatedButton(
// // // // // //                   onPressed: _toggleInputFieldVisibility,
// // // // // //                   child: Text('Custom Input'),
// // // // // //                 ),
// // // // // //               ],
// // // // // //             ),
// // // // // //             SizedBox(height: 16),
// // // // // //             if (testResults.isNotEmpty)
// // // // // //               TestCaseResultsTable(testResults: testResults),
// // // // // //           ],
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   Widget buildMobileView() {
// // // // // //     return Column(
// // // // // //       children: [
// // // // // //         Expanded(
// // // // // //           child: TabBarView(
// // // // // //             controller: _tabController,
// // // // // //             children: [
// // // // // //               buildQuestionPanel(),
// // // // // //               buildCodeEditorPanel(),
// // // // // //               buildOutputPanel(),
// // // // // //             ],
// // // // // //           ),
// // // // // //         ),
// // // // // //       ],
// // // // // //     );
// // // // // //   }

// // // // // //   Widget buildDesktopView() {
// // // // // //     return Scaffold(
// // // // // //       body: LayoutBuilder(
// // // // // //         builder: (context, constraints) {
// // // // // //           final screenWidth = constraints.maxWidth;

// // // // // //           // Calculate the width of the panels based on the divider position
// // // // // //           final leftPanelWidth = screenWidth * _dividerPosition;
// // // // // //           final rightPanelWidth = screenWidth * (1 - _dividerPosition);
// // // // // //           return Row(
// // // // // //             children: [
// // // // // //               // Expanded(child: buildQuestionPanel()),

// // // // // //               Container(
// // // // // //                 width: leftPanelWidth,
// // // // // //                 child: Padding(
// // // // // //                   padding: EdgeInsets.all(16.0),
// // // // // //                   child: SingleChildScrollView(
// // // // // //                     child: Column(
// // // // // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                       children: [
// // // // // //                         Text(widget.question['title'],
// // // // // //                             style: const TextStyle(
// // // // // //                                 fontSize: 24, fontWeight: FontWeight.bold)),
// // // // // //                         const SizedBox(height: 16),
// // // // // //                         const Text("Description",
// // // // // //                             style: TextStyle(
// // // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //                         Text(widget.question['description'],
// // // // // //                             style: TextStyle(fontSize: 16)),
// // // // // //                         const SizedBox(height: 16),
// // // // // //                         const Text("Input Format",
// // // // // //                             style: TextStyle(
// // // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //                         Text(widget.question['input_format'],
// // // // // //                             style: TextStyle(fontSize: 16)),
// // // // // //                         SizedBox(height: 16),
// // // // // //                         const Text("Output Format",
// // // // // //                             style: TextStyle(
// // // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //                         Text(widget.question['output_format'],
// // // // // //                             style: TextStyle(fontSize: 16)),
// // // // // //                         SizedBox(height: 16),
// // // // // //                         const Text("Constraints",
// // // // // //                             style: TextStyle(
// // // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //                         Text(widget.question['constraints'],
// // // // // //                             style: TextStyle(fontSize: 16)),
// // // // // //                         SizedBox(height: 8),
// // // // // //                         Column(
// // // // // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                           children: List<Widget>.generate(
// // // // // //                             widget.question['test_cases'].length,
// // // // // //                             (index) {
// // // // // //                               final testCase =
// // // // // //                                   widget.question['test_cases'][index];
// // // // // //                               return Card(
// // // // // //                                 margin: EdgeInsets.symmetric(vertical: 8),
// // // // // //                                 child: Padding(
// // // // // //                                   padding: const EdgeInsets.all(12.0),
// // // // // //                                   child: Column(
// // // // // //                                     crossAxisAlignment:
// // // // // //                                         CrossAxisAlignment.start,
// // // // // //                                     children: [
// // // // // //                                       Text("Input: ${testCase['input']}",
// // // // // //                                           style: TextStyle(fontSize: 16)),
// // // // // //                                       Text("Output: ${testCase['output']}",
// // // // // //                                           style: TextStyle(fontSize: 16)),
// // // // // //                                       if (testCase['is_public'])
// // // // // //                                         Text(
// // // // // //                                             "Explanation: ${testCase['explanation'] ?? ''}",
// // // // // //                                             style: TextStyle(fontSize: 16)),
// // // // // //                                     ],
// // // // // //                                   ),
// // // // // //                                 ),
// // // // // //                               );
// // // // // //                             },
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         SizedBox(height: 16),
// // // // // //                         Text("Difficulty",
// // // // // //                             style: TextStyle(
// // // // // //                                 fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //                         SizedBox(height: 8),
// // // // // //                         Text(widget.question['difficulty'],
// // // // // //                             style: TextStyle(fontSize: 16)),
// // // // // //                         SizedBox(height: 16),
// // // // // //                         if (widget.question['solutions'] != null &&
// // // // // //                             widget.question['solutions'].isNotEmpty)
// // // // // //                           Column(
// // // // // //                             crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //                             children: [
// // // // // //                               SizedBox(height: 16),
// // // // // //                               Text("Solutions",
// // // // // //                                   style: TextStyle(
// // // // // //                                       fontSize: 18,
// // // // // //                                       fontWeight: FontWeight.bold)),
// // // // // //                               ...List<Widget>.generate(
// // // // // //                                 widget.question['solutions'].length,
// // // // // //                                 (index) {
// // // // // //                                   final solution =
// // // // // //                                       widget.question['solutions'][index];
// // // // // //                                   return Card(
// // // // // //                                     margin: EdgeInsets.symmetric(vertical: 8),
// // // // // //                                     child: Padding(
// // // // // //                                       padding: const EdgeInsets.all(12.0),
// // // // // //                                       child: Column(
// // // // // //                                         crossAxisAlignment:
// // // // // //                                             CrossAxisAlignment.start,
// // // // // //                                         children: [
// // // // // //                                           Text(
// // // // // //                                             "Language: ${solution['language']}",
// // // // // //                                             style: TextStyle(fontSize: 16),
// // // // // //                                           ),
// // // // // //                                           Text(
// // // // // //                                             "Code:",
// // // // // //                                             style: TextStyle(
// // // // // //                                                 fontSize: 16,
// // // // // //                                                 fontWeight: FontWeight.bold),
// // // // // //                                           ),
// // // // // //                                           Container(
// // // // // //                                             width: double.infinity,
// // // // // //                                             color: Colors.black12,
// // // // // //                                             child: Padding(
// // // // // //                                               padding: EdgeInsets.all(8.0),
// // // // // //                                               child: Text(
// // // // // //                                                 solution['code'],
// // // // // //                                                 style: TextStyle(
// // // // // //                                                     fontFamily: 'RobotoMono',
// // // // // //                                                     fontSize: 14),
// // // // // //                                               ),
// // // // // //                                             ),
// // // // // //                                           ),
// // // // // //                                           if (solution['youtube_link'] != null)
// // // // // //                                             Text(
// // // // // //                                               "YouTube Link: ${solution['youtube_link']}",
// // // // // //                                               style: TextStyle(fontSize: 16),
// // // // // //                                             ),
// // // // // //                                         ],
// // // // // //                                       ),
// // // // // //                                     ),
// // // // // //                                   );
// // // // // //                                 },
// // // // // //                               ),
// // // // // //                             ],
// // // // // //                           ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ),

// // // // // //               GestureDetector(
// // // // // //                 behavior: HitTestBehavior.translucent,
// // // // // //                 onHorizontalDragUpdate: (details) {
// // // // // //                   setState(() {
// // // // // //                     _dividerPosition += details.delta.dx / screenWidth;
// // // // // //                     // Limit the position between 0.35 (35%) and 0.55 (55%)
// // // // // //                     _dividerPosition = _dividerPosition.clamp(0.28, 0.55);
// // // // // //                   });
// // // // // //                 },
// // // // // //                 child: Container(
// // // // // //                   color: Colors.transparent,
// // // // // //                   width: 22,
// // // // // //                   child: Center(
// // // // // //                     child: Row(
// // // // // //                       children: [
// // // // // //                         Container(
// // // // // //                           height: 5,
// // // // // //                           width: 10,
// // // // // //                           color: Colors.transparent,
// // // // // //                           child: CustomPaint(
// // // // // //                             painter: LeftArrowPainter(
// // // // // //                               strokeColor: Colors.grey,
// // // // // //                               strokeWidth: 0,
// // // // // //                               paintingStyle: PaintingStyle.fill,
// // // // // //                             ),
// // // // // //                             child: const SizedBox(
// // // // // //                               height: 5,
// // // // // //                               width: 10,
// // // // // //                             ),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         Container(
// // // // // //                           height: double.infinity,
// // // // // //                           width: 2,
// // // // // //                           decoration: BoxDecoration(
// // // // // //                             color: Colors.grey,
// // // // // //                             borderRadius: BorderRadius.circular(2),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                         Container(
// // // // // //                           height: 5,
// // // // // //                           width: 10,
// // // // // //                           color: Colors.transparent,
// // // // // //                           child: CustomPaint(
// // // // // //                             painter: RightArrowPainter(
// // // // // //                               strokeColor: Colors.grey,
// // // // // //                               strokeWidth: 0,
// // // // // //                               paintingStyle: PaintingStyle.fill,
// // // // // //                             ),
// // // // // //                             child: const SizedBox(
// // // // // //                               height: 5,
// // // // // //                               width: 10,
// // // // // //                             ),
// // // // // //                           ),
// // // // // //                         ),
// // // // // //                       ],
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 ),
// // // // // //               ),
// // // // // //               Expanded(child: codefieldbox()),
// // // // // //             ],
// // // // // //           );
// // // // // //         },
// // // // // //       ),
// // // // // //     );
// // // // // //   }

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     final bool isMobile = MediaQuery.of(context).size.width < 600;

// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(
// // // // // //         title: Text(widget.question['title']),
// // // // // //         bottom: isMobile
// // // // // //             ? TabBar(controller: _tabController, tabs: [
// // // // // //                 Tab(text: "Question"),
// // // // // //                 Tab(text: "Code"),
// // // // // //                 Tab(text: "Output")
// // // // // //               ])
// // // // // //             : null,
// // // // // //       ),
// // // // // //       body: isMobile ? buildMobileView() : buildDesktopView(),
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // class TestCaseResult {
// // // // // //   final String testCase;
// // // // // //   final String expectedResult;
// // // // // //   final String actualResult;
// // // // // //   final bool passed;
// // // // // //   final String errorMessage;
// // // // // //   final bool isCustomInput;
// // // // // //   TestCaseResult({
// // // // // //     required this.testCase,
// // // // // //     required this.expectedResult,
// // // // // //     required this.actualResult,
// // // // // //     required this.passed,
// // // // // //     this.errorMessage = '',
// // // // // //     this.isCustomInput = false,
// // // // // //   });
// // // // // // }

// // // // // // class TestCaseResultsTable extends StatelessWidget {
// // // // // //   final List<TestCaseResult> testResults;

// // // // // //   TestCaseResultsTable({required this.testResults});

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Column(
// // // // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //       children: [
// // // // // //         Text("Test Results",
// // // // // //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
// // // // // //         Divider(thickness: 2),
// // // // // //         Column(
// // // // // //           children: testResults.map((result) {
// // // // // //             return Column(
// // // // // //               crossAxisAlignment: CrossAxisAlignment.start,
// // // // // //               children: [
// // // // // //                 Row(
// // // // // //                   children: [
// // // // // //                     Expanded(child: Text("Input: ${result.testCase}")),
// // // // // //                     Expanded(child: Text("Output: ${result.actualResult}")),
// // // // // //                     Expanded(
// // // // // //                       child: Text(
// // // // // //                         result.isCustomInput
// // // // // //                             ? "-"
// // // // // //                             : "Expected: ${result.expectedResult}",
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                     Expanded(
// // // // // //                       child: Text(
// // // // // //                         result.isCustomInput
// // // // // //                             ? "-"
// // // // // //                             : (result.passed ? "Passed" : "Failed"),
// // // // // //                         style: TextStyle(
// // // // // //                           color: result.isCustomInput
// // // // // //                               ? Colors.black
// // // // // //                               : (result.passed ? Colors.green : Colors.red),
// // // // // //                         ),
// // // // // //                       ),
// // // // // //                     ),
// // // // // //                   ],
// // // // // //                 ),
// // // // // //                 if (result.errorMessage.isNotEmpty)
// // // // // //                   Padding(
// // // // // //                     padding: const EdgeInsets.only(top: 4.0),
// // // // // //                     child: Text(
// // // // // //                       "Error: ${result.errorMessage}",
// // // // // //                       style: TextStyle(
// // // // // //                           color: Colors.red, fontStyle: FontStyle.italic),
// // // // // //                     ),
// // // // // //                   ),
// // // // // //                 Divider(thickness: 1),
// // // // // //               ],
// // // // // //             );
// // // // // //           }).toList(),
// // // // // //         ),
// // // // // //       ],
// // // // // //     );
// // // // // //   }
// // // // // // }

// // // // // // class DisplayCodePage extends StatelessWidget {
// // // // // //   final String code;

// // // // // //   DisplayCodePage({required this.code});

// // // // // //   @override
// // // // // //   Widget build(BuildContext context) {
// // // // // //     return Scaffold(
// // // // // //       appBar: AppBar(
// // // // // //         title: const Text('Your Code'),
// // // // // //       ),
// // // // // //       body: Padding(
// // // // // //         padding: const EdgeInsets.all(16.0),
// // // // // //         child: Text(
// // // // // //           code,
// // // // // //           style: const TextStyle(
// // // // // //               fontFamily: 'SourceCodePro', fontSize: 16, color: Colors.black),
// // // // // //         ),
// // // // // //       ),
// // // // // //     );
// // // // // //   }
// // // // // // }
