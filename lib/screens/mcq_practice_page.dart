import 'package:flutter/material.dart';
import 'package:studentpanel100/services/api_service.dart';

class McqPracticePage extends StatefulWidget {
  @override
  _McqPracticePageState createState() => _McqPracticePageState();
}

class _McqPracticePageState extends State<McqPracticePage> {
  List<dynamic> _mcqDomains = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchMcqDomains();
  }

  Future<void> fetchMcqDomains() async {
    try {
      final data = await ApiService.fetchData('/mcq-domains', context);
      if (data != null && data.containsKey('domains')) {
        setState(() {
          _mcqDomains = data['domains'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'Unexpected response structure: missing "domains" key';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MCQ Practice'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _mcqDomains.length,
                  itemBuilder: (context, index) {
                    final domain = _mcqDomains[index];
                    return ListTile(
                      title:
                          Text(domain['name'], style: TextStyle(fontSize: 18)),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DomainPage(domain: domain),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

// class DomainPage extends StatelessWidget {
//   final Map<String, dynamic> domain;

//   const DomainPage({Key? key, required this.domain}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final List<dynamic> subdomains = domain['children'] ?? [];

//     if (subdomains.isEmpty) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => McqQuestionPage(domainId: domain['id']),
//           ),
//         );
//       });
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(domain['name']),
//       ),
//       body: subdomains.isNotEmpty
//           ? ListView.builder(
//               itemCount: subdomains.length,
//               itemBuilder: (context, index) {
//                 final subdomain = subdomains[index];
//                 return ListTile(
//                   title:
//                       Text(subdomain['name'], style: TextStyle(fontSize: 18)),
//                   trailing: Icon(Icons.arrow_forward),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => DomainPage(domain: subdomain),
//                       ),
//                     );
//                   },
//                 );
//               },
//             )
//           : Center(child: CircularProgressIndicator()),
//     );
//   }
// }

class DomainPage extends StatefulWidget {
  final Map<String, dynamic> domain;

  const DomainPage({Key? key, required this.domain}) : super(key: key);

  @override
  _DomainPageState createState() => _DomainPageState();
}

class _DomainPageState extends State<DomainPage> {
  bool _isLoadingQuestions = false;
  String _errorMessage = '';
  List<dynamic> _questions = [];
  List<dynamic> _subdomains = [];

  @override
  void initState() {
    super.initState();
    _subdomains = widget.domain['children'] ?? [];
    if (_subdomains.isEmpty) {
      // If it's a leaf domain, fetch questions
      fetchQuestions();
    }
  }

  Future<void> fetchQuestions() async {
    setState(() {
      _isLoadingQuestions = true;
    });

    try {
      final endpoint = '/mcq-questions/domain/${widget.domain['id']}';
      final data = await ApiService.fetchData(endpoint, context);

      if (data != null && data.containsKey('mcqQuestions')) {
        setState(() {
          _questions = data['mcqQuestions'];
          _isLoadingQuestions = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Unexpected response structure';
          _isLoadingQuestions = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred: $error';
        _isLoadingQuestions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.domain['name']),
      ),
      body: _subdomains.isNotEmpty
          ? ListView.builder(
              itemCount: _subdomains.length,
              itemBuilder: (context, index) {
                final subdomain = _subdomains[index];
                return ListTile(
                  title: Text(
                    subdomain['name'],
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    '${subdomain['children']?.length ?? 0} subdomains',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DomainPage(domain: subdomain),
                      ),
                    );
                  },
                );
              },
            )
          : _isLoadingQuestions
              ? Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
                  ? Center(child: Text(_errorMessage))
                  : ListView.builder(
                      itemCount: _questions.length,
                      itemBuilder: (context, index) {
                        final question = _questions[index];
                        final bool isSubmitted =
                            question['is_attempted'] == true;
                        // final int points = question['points'] ?? 0;
                        // final int maxPoints = 500;

                        return Card(
                          color: Colors.white,
                          elevation: 0,
                          // margin: const EdgeInsets.symmetric(
                          //     vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(
                              question['title'],
                              style: TextStyle(
                                fontSize: 18,
                                color:
                                    isSubmitted ? Colors.black : Colors.black,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                isSubmitted
                                    ? const Row(
                                        children: [
                                          Text(
                                            "Status: Submitted",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          // const SizedBox(width: 8),
                                          // Expanded(
                                          //   child: LinearProgressIndicator(
                                          //     value: points / maxPoints,
                                          //     backgroundColor: Colors.grey[300],
                                          //     color: Colors.green,
                                          //   ),
                                          // ),
                                          // const SizedBox(width: 8),
                                          // Text(
                                          //   '${((points / maxPoints) * 100).toStringAsFixed(0)}%',
                                          //   style: TextStyle(
                                          //     fontSize: 14,
                                          //     color: Colors.green,
                                          //     fontWeight: FontWeight.bold,
                                          //   ),
                                          // ),
                                        ],
                                      )
                                    : const Text(
                                        "Status: Not Submitted",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => McqQuestionDetailPage(
                                    questions: _questions,
                                    currentIndex: index,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}

class McqQuestionPage extends StatefulWidget {
  final int domainId;

  const McqQuestionPage({Key? key, required this.domainId}) : super(key: key);

  @override
  _McqQuestionPageState createState() => _McqQuestionPageState();
}

class _McqQuestionPageState extends State<McqQuestionPage> {
  List<dynamic> _questions = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    try {
      final endpoint = '/mcq-questions/domain/${widget.domainId}';
      final data = await ApiService.fetchData(endpoint, context);

      if (data == null || !data.containsKey('mcqQuestions')) {
        throw Exception('Unexpected response structure');
      }

      setState(() {
        _questions = data['mcqQuestions'];
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred: $error';
        _isLoading = false;
      });
      print('Error fetching questions: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MCQ Questions'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    final bool isSubmitted = question['is_attempted'] == true;
                    final int points = question['points'] ?? 0;
                    final int maxPoints = 500; // Assuming max score is 500.

                    return Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(
                          question['title'],
                          style: TextStyle(
                            fontSize: 18,
                            color: isSubmitted ? Colors.green : Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            isSubmitted
                                ? Row(
                                    children: [
                                      Text(
                                        "Status: Submitted",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // const SizedBox(width: 8),
                                      // Expanded(
                                      //   child: LinearProgressIndicator(
                                      //     value: points / maxPoints,
                                      //     backgroundColor: Colors.grey[300],
                                      //     color: Colors.green,
                                      //   ),
                                      // ),
                                      const SizedBox(width: 8),
                                      // Text(
                                      //   '${((points / maxPoints) * 100).toStringAsFixed(0)}%',
                                      //   style: TextStyle(
                                      //     fontSize: 14,
                                      //     color: Colors.green,
                                      //     fontWeight: FontWeight.bold,
                                      //   ),
                                      // ),
                                    ],
                                  )
                                : const Text(
                                    "Status: Not Submitted",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => McqQuestionDetailPage(
                                questions: _questions,
                                currentIndex: index,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}

class McqQuestionDetailPage extends StatefulWidget {
  final List<dynamic> questions;
  final int currentIndex;

  const McqQuestionDetailPage({
    Key? key,
    required this.questions,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _McqQuestionDetailPageState createState() => _McqQuestionDetailPageState();
}

class _McqQuestionDetailPageState extends State<McqQuestionDetailPage> {
  late int currentIndex;
  List<int> selectedAnswers = [];
  bool isSubmitted = false;
  bool isMarked = false;
  bool isReported = false;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    loadQuestionState();
  }

  void loadQuestionState() {
    final question = widget.questions[currentIndex];
    selectedAnswers = question['submitted_options'] != null
        ? List<int>.from(question['submitted_options'])
        : [];
    isSubmitted = question['is_attempted'] ?? false;
  }

  Future<void> submitAnswer() async {
    final question = widget.questions[currentIndex];
    final correctAnswers = question['correct_answers'] ?? [];
    bool isAnswerCorrect = false;
    int points = 0;

    // Determine Points Based on Difficulty
    switch (question['difficulty']) {
      case 'Level1':
        points = 100;
        break;
      case 'Level2':
        points = 200;
        break;
      case 'Level3':
        points = 300;
        break;
      case 'Level4':
        points = 400;
        break;
      case 'Level5':
        points = 500;
        break;
      default:
        points = 100;
    }

    // Check if the Answer is Correct
    if (question['is_single_answer'] == true) {
      // Single Answer
      isAnswerCorrect = selectedAnswers.isNotEmpty &&
          correctAnswers.contains(question['options'][selectedAnswers[0]]);
    } else {
      // Multiple Answers
      isAnswerCorrect = selectedAnswers.length == correctAnswers.length &&
          selectedAnswers.every(
              (index) => correctAnswers.contains(question['options'][index]));
    }

    // Assign Points Only if the Answer is Correct
    if (!isAnswerCorrect) {
      points = 0;
    }

    final data = {
      'student_id': await ApiService.getStudentIdFromToken(),
      'domain_id': question['mcqdomain_id'],
      'question_id': question['id'],
      'submitted_options': selectedAnswers,
      'points': points,
    };

    try {
      await ApiService.postData('/submit-answer', data, context);
      setState(() {
        isSubmitted = true;
        question['is_attempted'] = true; // Update State
        question['points'] = points;
      });
    } catch (error) {
      print("Error submitting answer: $error");
    }
  }

  void navigateToNextQuestion() {
    if (currentIndex < widget.questions.length - 1) {
      setState(() {
        currentIndex++;
        loadQuestionState();
      });
    }
  }

  void navigateToPreviousQuestion() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        loadQuestionState();
      });
    }
  }

  void navigateToQuestion(int index) {
    setState(() {
      currentIndex = index;
      loadQuestionState();
    });
  }

  Future<void> toggleMarkQuestion() async {
    final question = widget.questions[currentIndex];
    final data = {
      // 'student_id': /* Add logic to get student_id from token */,
      "student_id": await ApiService.getStudentIdFromToken(),
      'domain_id': question['mcqdomain_id'],
      'question_id': question['id'],
      'marked': !isMarked,
    };

    try {
      await ApiService.postData('/mark-question', data, context);
      setState(() {
        isMarked = !isMarked;
        question['marked'] = isMarked ? 1 : 0;
      });
    } catch (error) {
      print("Error marking question: $error");
    }
  }

  Future<void> reportQuestion() async {
    TextEditingController reportController = TextEditingController();
    final question = widget.questions[currentIndex];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Report Question"),
          content: TextField(
            controller: reportController,
            decoration: InputDecoration(hintText: "Enter report reason"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final data = {
                  // 'student_id': /* Add logic to get student_id from token */,
                  "student_id": await ApiService.getStudentIdFromToken(),
                  'domain_id': question['mcqdomain_id'],
                  'question_id': question['id'],
                  'is_reported': true,
                  'reported_text': reportController.text,
                };

                try {
                  await ApiService.postData('/report-question', data, context);
                  setState(() {
                    isReported = true;
                    question['is_reported'] = 1;
                    question['reported_text'] = reportController.text;
                  });
                } catch (error) {
                  print("Error reporting question: $error");
                }
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentIndex];
    final isSingleAnswer = question['is_single_answer'] ?? false;
    final correctAnswers = question['correct_answers'] ?? [];
    final codeSnippets = question['code_snippets'] ?? '';
    final points = question['points'] ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1}'),
      ),
      body: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.05,
            height: MediaQuery.of(context).size.height * 0.95,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 250,
                width: 250,
                child: ListView.builder(
                  itemCount: widget.questions.length,
                  itemBuilder: (context, index) {
                    bool isQuestionSubmitted =
                        widget.questions[index]['is_attempted'] == true;
                    return ElevatedButton(
                      onPressed: () => navigateToQuestion(index),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(30.0),
                        ),
                        backgroundColor: index == currentIndex
                            ? const Color.fromARGB(255, 199, 105, 240)
                            : isQuestionSubmitted
                                ? const Color.fromARGB(255, 239, 221, 247)
                                : const Color.fromARGB(255, 253, 252, 252),
                        padding: const EdgeInsets.all(8.0),
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color:
                              isQuestionSubmitted ? Colors.black : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question Title
                  Text(
                    question['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Points Scored
                  if (isSubmitted)
                    Text(
                      'Points scored: $points',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.green,
                      ),
                    ),
                  const SizedBox(height: 10),

                  // Code Snippets
                  if (codeSnippets.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      color: Colors.grey[200],
                      child: Text(
                        codeSnippets,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),

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
                              Color(0Xffdaf3e8); // Correct Selection
                        } else if (isSelected && !isCorrect) {
                          backgroundColor =
                              Color(0Xfffee5e7); // Incorrect Selection
                        } else if (isCorrect) {
                          backgroundColor = Color(0Xffdaf3e8); // Correct Option
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
                                              selectedAnswers
                                                  .remove(optionIndex);
                                            }
                                          });
                                        },
                                ),
                          title: Text(option),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Submit Button
                  if (!isSubmitted)
                    ElevatedButton(
                      onPressed: () async {
                        await submitAnswer();
                      },
                      child: const Text('Submit'),
                    ),
                  const SizedBox(height: 10),

                  // Navigation Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: currentIndex > 0
                            ? () {
                                setState(() {
                                  currentIndex--;
                                  loadQuestionState();
                                });
                              }
                            : null,
                        child: const Text('Back'),
                      ),
                      ElevatedButton(
                        onPressed: currentIndex < widget.questions.length - 1
                            ? () {
                                setState(() {
                                  currentIndex++;
                                  loadQuestionState();
                                });
                              }
                            : null,
                        child: const Text('Next'),
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
