import 'package:flutter/material.dart';

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

  Future<void> submitAnswer() async {
    final question = widget.mcqQuestion;
    final correctAnswers = question['correct_answers'] ?? [];
    bool isAnswerCorrect = false;

    // Check if the answer is correct
    if (question['is_single_answer'] == true) {
      isAnswerCorrect = selectedAnswers.isNotEmpty &&
          correctAnswers.contains(question['options'][selectedAnswers[0]]);
    } else {
      isAnswerCorrect = selectedAnswers.length == correctAnswers.length &&
          selectedAnswers.every(
              (index) => correctAnswers.contains(question['options'][index]));
    }

    setState(() {
      isSubmitted = true;
      question['is_attempted'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(isAnswerCorrect ? 'Correct Answer!' : 'Incorrect Answer.'),
        backgroundColor: isAnswerCorrect ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.mcqQuestion;
    final isSingleAnswer = question['is_single_answer'] ?? false;
    final correctAnswers = question['correct_answers'] ?? [];

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question Title
            Text(
              question['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Options
            ...List<Widget>.generate(
              question['options'].length,
              (optionIndex) {
                final option = question['options'][optionIndex];
                final isCorrect = correctAnswers.contains(option);
                final isSelected = selectedAnswers.contains(optionIndex);

                // Determine Background Color
                Color? backgroundColor;
                if (isSubmitted) {
                  if (isSelected && isCorrect) {
                    backgroundColor =
                        const Color(0Xffdaf3e8); // Correct Selection
                  } else if (isSelected && !isCorrect) {
                    backgroundColor =
                        const Color(0Xfffee5e7); // Incorrect Selection
                  } else if (isCorrect) {
                    backgroundColor = const Color(0Xffdaf3e8); // Correct Option
                  }
                }

                return Container(
                  color: backgroundColor,
                  child: ListTile(
                    leading: isSingleAnswer
                        ? Radio<int>(
                            value: optionIndex,
                            groupValue: selectedAnswers.isNotEmpty
                                ? selectedAnswers[0]
                                : -1,
                            onChanged: isSubmitted
                                ? null // Disable after submission
                                : (value) {
                                    setState(() {
                                      selectedAnswers = [value!];
                                    });
                                  },
                          )
                        : Checkbox(
                            value: selectedAnswers.contains(optionIndex),
                            onChanged: isSubmitted
                                ? null // Disable after submission
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
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Submit Button
            if (!isSubmitted)
              ElevatedButton(
                onPressed: submitAnswer,
                child: const Text('Submit'),
              ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:studentpanel100/services/api_service.dart';

// class MCQQuestionWidget extends StatelessWidget {
//   final Map<String, dynamic> mcqQuestion;

//   const MCQQuestionWidget({Key? key, required this.mcqQuestion})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: const EdgeInsets.all(8.0),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Question: ${mcqQuestion['title']}',
//                 style:
//                     const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             ...mcqQuestion['options'].map<Widget>((option) {
//               return ListTile(
//                 title: Text(option),
//                 leading: const Icon(Icons.radio_button_unchecked),
//               );
//             }).toList(),
//             const SizedBox(height: 8),
//             Text('Difficulty: ${mcqQuestion['difficulty']}'),
//           ],
//         ),
//       ),
//     );
//   }
// }

