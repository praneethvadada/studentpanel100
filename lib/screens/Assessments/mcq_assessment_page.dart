import 'package:flutter/material.dart';
import 'package:studentpanel100/services/api_service.dart';

class MCQQuestionWidget extends StatefulWidget {
  final Map<String, dynamic> mcqQuestion;

  const MCQQuestionWidget({Key? key, required this.mcqQuestion})
      : super(key: key);

  @override
  _MCQQuestionWidgetState createState() => _MCQQuestionWidgetState();
}

class _MCQQuestionWidgetState extends State<MCQQuestionWidget> {
  List<int> selectedAnswers = [];
  bool isSubmitted = false;

  @override
  void initState() {
    super.initState();
    loadInitialState();
  }

  void loadInitialState() {
    final question = widget.mcqQuestion;
    selectedAnswers = question['submitted_options'] != null
        ? List<int>.from(question['submitted_options'])
        : [];
    isSubmitted = question['is_attempted'] ?? false;
  }

  // Future<void> submitAssessmentMcqAnswer() async {
  //   final question = widget.mcqQuestion;
  //   final correctAnswers = question['correct_answers'] ?? [];
  //   bool isAnswerCorrect = false;
  //   int points = 0;

  //   // Map difficulty levels to points
  //   final difficultyMapping = {
  //     'Level1': 100,
  //     'Level2': 200,
  //     'Level3': 300,
  //     'Level4': 400,
  //     'Level5': 500,
  //   };
  //   points = difficultyMapping[question['difficulty']] ?? 100;

  //   // Check if the answer is correct
  //   if (question['is_single_answer'] == true) {
  //     // Single answer
  //     isAnswerCorrect = selectedAnswers.isNotEmpty &&
  //         correctAnswers.contains(question['options'][selectedAnswers[0]]);
  //   } else {
  //     // Multiple answers
  //     isAnswerCorrect = selectedAnswers.length == correctAnswers.length &&
  //         selectedAnswers.every(
  //             (index) => correctAnswers.contains(question['options'][index]));
  //   }

  //   // Assign points only if the answer is correct
  //   if (!isAnswerCorrect) {
  //     points = 0;
  //   }

  //   // Get student_id from the API or JWT
  //   final studentId = await ApiService.getStudentIdFromToken();

  //   final data = {
  //     'student_id': studentId, // Ensure student_id is included
  //     'round_id': question['round_id'],
  //     'question_id': question['id'],
  //     'submitted_options': selectedAnswers,
  //     'points': points,
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
  //       question['points'] = points;
  //     });
  //     print("[DEBUG] MCQ Answer submitted successfully: $response");
  //   } catch (error) {
  //     print("[DEBUG] Error submitting MCQ Answer: $error");
  //   }
  // }

  // Future<void> submitAssessmentMcqAnswer() async {
  //   final question = widget.mcqQuestion;

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

  //     final responseBody = response['data'];
  //     final int points = responseBody['score'];

  //     setState(() {
  //       isSubmitted = true;
  //       question['is_attempted'] = true;
  //       question['points'] = points;
  //     });

  //     print("[DEBUG] MCQ Answer submitted successfully with score: $points");
  //   } catch (error) {
  //     print("[DEBUG] Error submitting MCQ Answer: $error");
  //   }
  // }

  Future<void> submitAssessmentMcqAnswer() async {
    final question = widget.mcqQuestion;

    final data = {
      'round_id': question['round_id'],
      'question_id': question['id'],
      'submitted_options': selectedAnswers,
    };

    try {
      final response = await ApiService.postData(
        '/assessment-mcq-question-submit', // Updated endpoint URL
        data,
        context,
      );

      setState(() {
        isSubmitted = true;
        question['is_attempted'] = true; // Mark question as attempted
      });

      print("[DEBUG] MCQ Answer submitted successfully");
    } catch (error) {
      print("[DEBUG] Error submitting MCQ Answer: $error");
    }
  }

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
              question['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...List<Widget>.generate(
              question['options'].length,
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
                                  setState(() {
                                    selectedAnswers = [value!];
                                  });
                                },
                        )
                      : Checkbox(
                          value: isSelected,
                          onChanged: isSubmitted
                              ? null
                              : (value) {
                                  setState(() {
                                    if (value == true) {
                                      selectedAnswers.add(optionIndex);
                                    } else {
                                      selectedAnswers.remove(optionIndex);
                                    }
                                  });
                                },
                        ),
                  title: Text(option),
                );
              },
            ),
            const SizedBox(height: 16),
            if (!isSubmitted)
              ElevatedButton(
                onPressed: submitAssessmentMcqAnswer,
                child: const Text('Submit'),
              ),
          ],
        ),
      ),
    );
  }
}
