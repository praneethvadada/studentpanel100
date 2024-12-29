import 'package:flutter/material.dart';
import 'package:studentpanel100/services/api_service.dart';
import 'package:studentpanel100/services/api_service.dart';

class MCQQuestionWidget extends StatefulWidget {
  final Map<String, dynamic> mcqQuestion;

  const MCQQuestionWidget({Key? key, required this.mcqQuestion})
      : super(key: key);

  @override
  _MCQQuestionWidgetState createState() => _MCQQuestionWidgetState();
}

class _MCQQuestionWidgetState extends State<MCQQuestionWidget> {
  List<int> get selectedAnswers => widget.mcqQuestion['selectedAnswers'] ?? [];
  set selectedAnswers(List<int> value) {
    setState(() {
      widget.mcqQuestion['selectedAnswers'] = value;
    });
  }

  bool get isSubmitted => widget.mcqQuestion['isSubmitted'] ?? false;
  set isSubmitted(bool value) {
    setState(() {
      widget.mcqQuestion['isSubmitted'] = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.mcqQuestion;
    final isSingleAnswer = question['is_single_answer'] ?? false;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['title'] ?? "Question Title Missing",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List<Widget>.generate(
              question['options']?.length ?? 0,
              (optionIndex) {
                final option = question['options'][optionIndex];
                final isSelected = selectedAnswers.contains(optionIndex);

                return ListTile(
                  leading: isSingleAnswer
                      ? Radio<int>(
                          value: optionIndex,
                          groupValue: selectedAnswers.isNotEmpty
                              ? selectedAnswers[0]
                              : -1,
                          onChanged: isSubmitted
                              ? null
                              : (value) {
                                  if (value != null) {
                                    selectedAnswers = [value];
                                  }
                                },
                        )
                      : Checkbox(
                          value: isSelected,
                          onChanged: isSubmitted
                              ? null
                              : (value) {
                                  if (value == true) {
                                    selectedAnswers = [
                                      ...selectedAnswers,
                                      optionIndex
                                    ];
                                  } else {
                                    selectedAnswers = selectedAnswers
                                        .where((item) => item != optionIndex)
                                        .toList();
                                  }
                                },
                        ),
                  title: Text(option ?? "Option Missing"),
                );
              },
            ),
            const SizedBox(height: 16),
            if (!isSubmitted)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isSubmitted = true;
                  });
                  // Submit the answer
                  submitAssessmentMcqAnswer();
                },
                child: const Text('Submit'),
              ),
            if (isSubmitted)
              const Text(
                "Answer submitted!",
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> submitAssessmentMcqAnswer() async {
    final question = widget.mcqQuestion;

    final data = {
      'round_id': question['round_id'],
      'question_id': question['id'],
      'submitted_options': selectedAnswers,
    };

    try {
      await ApiService.postData(
        '/assessment-mcq-question-submit',
        data,
        context,
      );
      print(
          "[DEBUG] MCQ Answer submitted successfully for Question ID: ${question['id']}");
    } catch (error) {
      print(
          "[ERROR] Failed to submit MCQ Answer for Question ID: ${question['id']}: $error");
    }
  }
}

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

//   // void loadInitialState() {
//   //   final question = widget.mcqQuestion;

//   //   // Add debugging log
//   //   print("[DEBUG] Loading question: $question");

//   //   // Handle missing fields with default values
//   //   selectedAnswers = question['submitted_options'] != null
//   //       ? List<int>.from(question['submitted_options'])
//   //       : [];
//   //   isSubmitted = question['is_attempted'] ?? false;
//   // }

//   void loadInitialState() {
//     final question = widget.mcqQuestion;

//     // Debug: Log the complete question object
//     print("[DEBUG] Full MCQ Question Data: $question");

//     // Check for required fields
//     if (question['title'] == null) {
//       print("[ERROR] Question title is missing");
//     }

//     if (question['options'] == null || question['options'].isEmpty) {
//       print("[ERROR] Question options are missing or empty");
//     }

//     selectedAnswers = question['submitted_options'] != null
//         ? List<int>.from(question['submitted_options'])
//         : [];
//     isSubmitted = question['is_attempted'] ?? false;

//     print("[DEBUG] Initial selectedAnswers: $selectedAnswers");
//     print("[DEBUG] Is question submitted: $isSubmitted");
//   }

//   // Future<void> submitAssessmentMcqAnswer() async {
//   //   final question = widget.mcqQuestion;

//   //   // Ensure required fields are present
//   //   if (question['round_id'] == null || question['id'] == null) {
//   //     print("[ERROR] Missing round_id or question_id");
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text("Error: Missing question data")),
//   //     );
//   //     return;
//   //   }

//   //   final data = {
//   //     'round_id': question['round_id'],
//   //     'question_id': question['id'],
//   //     'submitted_options': selectedAnswers,
//   //   };

//   //   try {
//   //     final response = await ApiService.postData(
//   //       '/assessment-mcq-question-submit',
//   //       data,
//   //       context,
//   //     );

//   //     setState(() {
//   //       isSubmitted = true;
//   //       question['is_attempted'] = true; // Mark question as attempted
//   //     });

//   //     print("[DEBUG] MCQ Answer submitted successfully");
//   //   } catch (error) {
//   //     print("[DEBUG] Error submitting MCQ Answer: $error");
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text("Error: Failed to submit answer")),
//   //     );
//   //   }
//   // }



// Future<void> submitAssessmentMcqAnswer() async {
//   final question = widget.mcqQuestion;

//   // Debug: Log data being submitted
//   print("[DEBUG] Submitting MCQ Answer for Question ID: ${question['id']}");
//   print("[DEBUG] Selected Answers: $selectedAnswers");

//   // Check for required fields
//   if (question['round_id'] == null || question['id'] == null) {
//     print("[ERROR] Missing round_id or question_id for submission");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: Missing question data")),
//     );
//     return;
//   }

//   final data = {
//     'round_id': question['round_id'],
//     'question_id': question['id'],
//     'submitted_options': selectedAnswers,
//   };

//   try {
//     final response = await ApiService.postData(
//       '/assessment-mcq-question-submit',
//       data,
//       context,
//     );

//     setState(() {
//       isSubmitted = true;
//       question['is_attempted'] = true;
//     });

//     print("[DEBUG] MCQ Answer submitted successfully for Question ID: ${question['id']}");
//   } catch (error) {
//     print("[ERROR] Failed to submit MCQ Answer for Question ID: ${question['id']}: $error");
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text("Error: Failed to submit answer")),
//     );
//   }
// }

//   @override
//   Widget build(BuildContext context) {
//     final question = widget.mcqQuestion;
//     print("[DEBUG] Building MCQ Widget for Question ID: ${question['id']}");
//     print("[DEBUG] Current selectedAnswers: $selectedAnswers");
//     print("[DEBUG] Is question already submitted: $isSubmitted");

//     // Add a fallback if 'options' is missing
//     final options = question['options'] ?? [];
//     if (options.isEmpty) {
//       print("[ERROR] No options available for question ID: ${question['id']}");
//       return Center(
//         child: Text("No options available for this question"),
//       );
//     }
//     final isSingleAnswer = question['is_single_answer'] ?? false;

//     if (options.isEmpty) {
//       return Center(
//         child: Text("No options available for this question"),
//       );
//     }

//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               question['title'] ?? "Question Title Missing",
//               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             ...List<Widget>.generate(
//               options.length,
//               (optionIndex) {
//                 final option = options[optionIndex];
//                 final isSelected = selectedAnswers.contains(optionIndex);

//                 return ListTile(
//                   leading: isSingleAnswer
//                       ? Radio<int>(
//                           value: optionIndex,
//                           groupValue: selectedAnswers.isNotEmpty
//                               ? selectedAnswers[0]
//                               : -1,
//                           onChanged: isSubmitted
//                               ? null
//                               : (value) {
//                                   setState(() {
//                                     selectedAnswers = [value!];
//                                   });
//                                 },
//                         )
//                       : Checkbox(
//                           value: isSelected,
//                           onChanged: isSubmitted
//                               ? null
//                               : (value) {
//                                   setState(() {
//                                     if (value == true) {
//                                       selectedAnswers.add(optionIndex);
//                                     } else {
//                                       selectedAnswers.remove(optionIndex);
//                                     }
//                                   });
//                                 },
//                         ),
//                   title: Text(option ?? "Option Missing"),
//                 );
//               },
//             ),
//             const SizedBox(height: 16),
//             if (!isSubmitted)
//               ElevatedButton(
//                 onPressed: submitAssessmentMcqAnswer,
//                 child: const Text('Submit'),
//               ),
//             if (isSubmitted)
//               Text(
//                 "Answer submitted!",
//                 style:
//                     TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
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


// //   Future<void> submitAssessmentMcqAnswer() async {
// //     final question = widget.mcqQuestion;

// //     final data = {
// //       'round_id': question['round_id'],
// //       'question_id': question['id'],
// //       'submitted_options': selectedAnswers,
// //     };

// //     try {
// //       final response = await ApiService.postData(
// //         '/assessment-mcq-question-submit', // Updated endpoint URL
// //         data,
// //         context,
// //       );

// //       setState(() {
// //         isSubmitted = true;
// //         question['is_attempted'] = true; // Mark question as attempted
// //       });

// //       print("[DEBUG] MCQ Answer submitted successfully");
// //     } catch (error) {
// //       print("[DEBUG] Error submitting MCQ Answer: $error");
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final question = widget.mcqQuestion;
// //     final isSingleAnswer = question['is_single_answer'] ?? false;

// //     return Card(
// //       margin: const EdgeInsets.all(8.0),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16.0),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               question['title'],
// //               style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
// //             ),
// //             const SizedBox(height: 8),
// //             ...List<Widget>.generate(
// //               question['options'].length,
// //               (optionIndex) {
// //                 final option = question['options'][optionIndex];
// //                 final isSelected = selectedAnswers.contains(optionIndex);

// //                 return ListTile(
// //                   leading: isSingleAnswer
// //                       ? Radio<int>(
// //                           value: optionIndex,
// //                           groupValue: selectedAnswers.isNotEmpty
// //                               ? selectedAnswers[0]
// //                               : -1,
// //                           onChanged: isSubmitted
// //                               ? null
// //                               : (value) {
// //                                   setState(() {
// //                                     selectedAnswers = [value!];
// //                                   });
// //                                 },
// //                         )
// //                       : Checkbox(
// //                           value: isSelected,
// //                           onChanged: isSubmitted
// //                               ? null
// //                               : (value) {
// //                                   setState(() {
// //                                     if (value == true) {
// //                                       selectedAnswers.add(optionIndex);
// //                                     } else {
// //                                       selectedAnswers.remove(optionIndex);
// //                                     }
// //                                   });
// //                                 },
// //                         ),
// //                   title: Text(option),
// //                 );
// //               },
// //             ),
// //             const SizedBox(height: 16),
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
