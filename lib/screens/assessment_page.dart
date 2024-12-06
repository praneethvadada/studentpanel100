import 'dart:html' as html;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:studentpanel100/services/api_service.dart';

class AssessmentPage extends StatelessWidget {
  const AssessmentPage({Key? key}) : super(key: key);

  Future<List<dynamic>> _fetchAssessments() async {
    return await ApiService().fetchStudentAssessments();
  }

  String _formatDateTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString).toLocal();
      return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _fetchAssessments(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.data == null || snapshot.data!.isEmpty) {
          return const Center(child: Text('No assessments found.'));
        } else {
          final assessments = snapshot.data!;
          return ListView.builder(
            itemCount: assessments.length,
            itemBuilder: (context, index) {
              final assessment = assessments[index];
              return ListTile(
                title: Text(assessment['title']),
                subtitle: Text(
                  '${assessment['description']}\n'
                  'Start: ${_formatDateTime(assessment['start_window'])}\n'
                  'End: ${_formatDateTime(assessment['end_window'])}\n'
                  'Duration: ${assessment['duration_minutes']} minutes',
                  style: const TextStyle(fontSize: 12),
                ),
                isThreeLine: true,
                onTap: () {
                  // Navigate to the ExamScreen and pass the assessment details
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamScreen(
                        assessmentId: assessment['id'],
                        assessmentTitle: assessment['title'],
                        assessmentDurationMinutes:
                            assessment['duration_minutes'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}

abstract class FullScreenEnforcedPage extends StatefulWidget {
  const FullScreenEnforcedPage({Key? key}) : super(key: key);
}

abstract class FullScreenEnforcedPageState<T extends FullScreenEnforcedPage>
    extends State<T> {
  Timer? _fullscreenCheckTimer;
  Timer? _visibilityCheckTimer;
  int fullscreenExitCount = 0;
  int tabSwitchCount = 0;
  bool isFullScreen = true; // Tracks full-screen state
  bool isExamMode = true; // Tracks whether exam content is displayed

  @override
  void initState() {
    super.initState();
    _enterFullScreenMode();
    _startFullScreenCheck();
    _monitorTabSwitches();
  }

  void _enterFullScreenMode() {
    html.document.documentElement?.requestFullscreen();
  }

  void _startFullScreenCheck() {
    _fullscreenCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentlyInFullScreen = html.document.fullscreenElement != null;

      if (currentlyInFullScreen != isFullScreen) {
        setState(() {
          isFullScreen = currentlyInFullScreen;
        });

        if (!currentlyInFullScreen) {
          fullscreenExitCount++;
          if (fullscreenExitCount >= 4) {
            _terminateExam(
                'Exam terminated due to multiple exits from full-screen mode.');
            timer.cancel();
          } else {
            _blankScreen();
            _showSnackbar(
                'You exited full-screen mode. Warning: ${4 - fullscreenExitCount} warnings left.');
          }
        }
      }
    });
  }

  void _monitorTabSwitches() {
    html.document.onVisibilityChange.listen((event) {
      final isHidden = html.document.hidden;

      if (isHidden == true) {
        tabSwitchCount++;
        if (tabSwitchCount >= 3) {
          _terminateExam(
              'Exam terminated due to multiple tab or window switches.');
        } else {
          _showSnackbar(
              'You switched tabs/windows. Warning: ${3 - tabSwitchCount} warnings left.');
        }
      }
    });
  }

  void _blankScreen() {
    setState(() {
      isExamMode = false;
    });
  }

  void _restoreExamContent() {
    if (fullscreenExitCount < 4) {
      setState(() {
        isExamMode = true;
      });
      _showSnackbar('You are back in full-screen mode. Exam content restored.');
    } else {
      _terminateExam(
          'Exam terminated due to multiple exits from full-screen mode.');
    }
  }

  void _terminateExam(String message) {
    _fullscreenCheckTimer?.cancel();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TerminationPage(message: message),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _fullscreenCheckTimer?.cancel();
    super.dispose();
  }
}

class ExamScreen extends FullScreenEnforcedPage {
  final int assessmentId;
  final String assessmentTitle;
  final int assessmentDurationMinutes;

  const ExamScreen({
    Key? key,
    required this.assessmentId,
    required this.assessmentTitle,
    required this.assessmentDurationMinutes,
  }) : super(key: key);

  @override
  _ExamScreenState createState() => _ExamScreenState();
}

class _ExamScreenState extends FullScreenEnforcedPageState<ExamScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assessmentTitle),
      ),
      body: Center(
        child: isExamMode
            ? RoundsScreen(
                assessmentId: widget.assessmentId,
                assessmentTitle: widget.assessmentTitle,
                assessmentDurationMinutes: widget.assessmentDurationMinutes,
              )
            : _buildBlankScreen(),
      ),
    );
  }

  Widget _buildBlankScreen() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Screen Blank - Please return to full-screen mode',
          style: TextStyle(fontSize: 18, color: Colors.red),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (fullscreenExitCount < 4) {
              _enterFullScreenMode();
              _restoreExamContent();
            } else {
              _terminateExam(
                  'Exam terminated due to multiple exits from full-screen mode.');
            }
          },
          child: const Text('Return to Full-Screen'),
        ),
      ],
    );
  }
}

class QuestionsScreen extends FullScreenEnforcedPage {
  final List<dynamic> questions;

  const QuestionsScreen({Key? key, required this.questions}) : super(key: key);

  @override
  _QuestionsScreenState createState() => _QuestionsScreenState();
}

class _QuestionsScreenState
    extends FullScreenEnforcedPageState<QuestionsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions'),
      ),
      body: isExamMode
          ? ListView.builder(
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                final question = widget.questions[index];
                if (question['codingQuestion'] != null) {
                  return ListTile(
                    title:
                        Text('Coding: ${question['codingQuestion']['title']}'),
                    subtitle: Text(question['codingQuestion']['description']),
                  );
                } else if (question['mcqQuestion'] != null) {
                  return ListTile(
                    title: Text('MCQ: ${question['mcqQuestion']['title']}'),
                    subtitle: Text(
                        'Options: ${question['mcqQuestion']['options'].join(', ')}'),
                  );
                } else {
                  return const ListTile(
                    title: Text('Unknown Question Type'),
                  );
                }
              },
            )
          : _buildBlankScreen(),
    );
  }

  Widget _buildBlankScreen() {
    return Center(
      child: Column(
        children: [
          const Text(
            'Screen Blank - Please return to full-screen mode',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (fullscreenExitCount < 4) {
                _enterFullScreenMode();
                _restoreExamContent();
              } else {
                _terminateExam(
                    'Exam terminated due to multiple exits from full-screen mode.');
              }
            },
            child: const Text('Return to Full-Screen'),
          ),
        ],
      ),
    );
  }
}

// import 'dart:html' as html;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:studentpanel100/services/api_service.dart';
// import 'dart:async';

// class AssessmentPage extends StatelessWidget {
//   const AssessmentPage({Key? key}) : super(key: key);

//   Future<List<dynamic>> _fetchAssessments() async {
//     return await ApiService().fetchStudentAssessments();
//   }

//   String _formatDateTime(String dateTimeString) {
//     try {
//       final dateTime =
//           DateTime.parse(dateTimeString).toLocal(); // Convert UTC to local
//       return DateFormat('dd-MM-yyyy hh:mm a')
//           .format(dateTime); // Format for display
//     } catch (e) {
//       return dateTimeString; // Fallback if parsing fails
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<dynamic>>(
//       future: _fetchAssessments(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//           return Center(child: Text('No assessments found.'));
//         } else {
//           final assessments = snapshot.data!;
//           return ListView.builder(
//             itemCount: assessments.length,
//             itemBuilder: (context, index) {
//               final assessment = assessments[index];
//               return ListTile(
//                 title: Text(assessment['title']),
//                 subtitle: Text(
//                   '${assessment['description']}\n'
//                   'Start: ${_formatDateTime(assessment['start_window'])}\n'
//                   'End: ${_formatDateTime(assessment['end_window'])}\n'
//                   'Duration: ${assessment['duration_minutes']} minutes',
//                   style: TextStyle(fontSize: 12),
//                 ),
//                 isThreeLine: true,
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ExamScreen(
//                         assessmentTitle: assessment['title'],
//                         assessmentDurationMinutes:
//                             assessment['duration_minutes'],
//                         assessmentId: assessment['id'],
//                       ),
//                     ),
//                   ).then((_) {
//                     // Reset the UI mode back after exiting full screen if needed.
//                     SystemChrome.setEnabledSystemUIMode(
//                         SystemUiMode.edgeToEdge);
//                   });
//                 },
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }

class RoundsScreen extends StatefulWidget {
  final int assessmentId;
  final String assessmentTitle;
  final int assessmentDurationMinutes;

  const RoundsScreen({
    Key? key,
    required this.assessmentId,
    required this.assessmentTitle,
    required this.assessmentDurationMinutes,
  }) : super(key: key);

  @override
  _RoundsScreenState createState() => _RoundsScreenState();
}

class _RoundsScreenState extends State<RoundsScreen> {
  late Timer _timer;
  Duration _remainingTime = Duration.zero;
  bool _isTimeUp = false;

  @override
  void initState() {
    super.initState();
    // Initialize the timer with the assessment duration
    _remainingTime = Duration(minutes: widget.assessmentDurationMinutes);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds <= 0) {
        setState(() {
          _isTimeUp = true;
          timer.cancel();
        });
      } else {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      }
    });
  }

  Future<List<dynamic>> _fetchRounds() async {
    return await ApiService().fetchRoundsByAssessmentId(widget.assessmentId);
  }

  // Future<void> _fetchAndOpenQuestions(dynamic roundId) async {
  //   try {
  //     // Convert roundId to an integer if it's a string
  //     if (roundId is String) {
  //       roundId = int.parse(roundId); // Convert string to integer
  //     }

  //     // Fetch questions from the API
  //     final questions = await ApiService().fetchQuestionsByRoundId(roundId);

  //     if (questions != null && questions.isNotEmpty) {
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => QuestionsScreen(questions: questions),
  //         ),
  //       );
  //     } else {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("No questions found for this round")),
  //       );
  //     }
  //   } catch (error) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Failed to load questions: $error")),
  //     );
  //   }
  // }
Future<void> _fetchAndOpenQuestions(dynamic roundId) async {
  try {
    // Ensure roundId is an integer
    if (roundId is String) {
      roundId = int.parse(roundId); // Convert string to integer if necessary
    }

    // Fetch questions from the API using the roundId
    final questions = await ApiService().fetchQuestionsByRoundId(roundId);

    if (questions != null && questions.isNotEmpty) {
      // Navigate to the QuestionsScreen if questions are found
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuestionsScreen(questions: questions),
        ),
      );
    } else {
      // Show a snackbar message if no questions are found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No questions found for this round.")),
      );
    }
  } catch (error) {
    // Handle any exceptions during API call or parsing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to load questions: $error")),
    );
  }
}

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          if (!_isTimeUp)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Time Remaining: ${_formatDuration(_remainingTime)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          if (_isTimeUp)
            const Center(
              child: Text(
                'Time is up!',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
            ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _fetchRounds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No rounds found.'));
                } else {
                  final rounds = snapshot.data!;
                  return ListView.builder(
                    itemCount: rounds.length,
                    itemBuilder: (context, index) {
                      final round = rounds[index];
                      return ListTile(
                        title: Text('Round ${round['round_order']}'),
                        subtitle: Text(round['round_type']),
                        onTap: () {
                          _fetchAndOpenQuestions(round['id']);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${duration.inHours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class TerminationPage extends StatelessWidget {
  final String message;

  const TerminationPage({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("TerminationPage: Displaying termination message.");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Terminated'),
      ),
      body: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
}

// class ExamScreen extends StatefulWidget {
//   final int assessmentId;
//   final String assessmentTitle;
//   final int assessmentDurationMinutes;

//   const ExamScreen({
//     Key? key,
//     required this.assessmentId,
//     required this.assessmentTitle,
//     required this.assessmentDurationMinutes,
//   }) : super(key: key);

//   @override
//   _ExamScreenState createState() => _ExamScreenState();
// }

// class _ExamScreenState extends State<ExamScreen> {
//   Timer? _fullscreenCheckTimer;
//   int fullscreenExitCount = 0;
//   int tabSwitchCount = 0; // Count of tab/window switches
//   bool isExamMode = true; // Tracks whether the exam is active or blank screen
//   bool isFullScreen = true; // Tracks the current full-screen state

//   @override
//   void initState() {
//     super.initState();
//     _enterFullScreenMode();
//     _startFullscreenCheck();
//     _monitorTabSwitches();
//   }

//   void _enterFullScreenMode() {
//     html.document.documentElement?.requestFullscreen();
//   }

//   void _startFullscreenCheck() {
//     _fullscreenCheckTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       final currentlyInFullScreen = html.document.fullscreenElement != null;

//       if (currentlyInFullScreen != isFullScreen) {
//         setState(() {
//           isFullScreen = currentlyInFullScreen;
//         });

//         if (!currentlyInFullScreen) {
//           fullscreenExitCount++;
//           if (fullscreenExitCount >= 4) {
//             _terminateExam(
//                 'Exam terminated due to multiple exits from full-screen mode.');
//             timer.cancel();
//           } else {
//             _blankScreen();
//             _showSnackbar(
//                 'You exited full-screen mode. Warning: ${4 - fullscreenExitCount} warnings left.');
//           }
//         }
//       }
//     });
//   }

//   void _monitorTabSwitches() {
//     html.document.onVisibilityChange.listen((event) {
//       final isHidden = html.document.hidden;

//       if (isHidden == true) {
//         tabSwitchCount++;
//         if (tabSwitchCount >= 3) {
//           _terminateExam(
//               'Exam terminated due to multiple tab or window switches.');
//         } else {
//           _showSnackbar(
//               'You switched tabs/windows. Warning: ${3 - tabSwitchCount} warnings left.');
//         }
//       }
//     });
//   }

//   void _blankScreen() {
//     setState(() {
//       isExamMode = false; // Switch to blank screen
//     });
//   }

//   void _restoreExamContent() {
//     if (fullscreenExitCount < 4) {
//       setState(() {
//         isExamMode = true; // Restore exam content
//       });
//       _showSnackbar('You are back in full-screen mode. Exam content restored.');
//     }
//   }

//   void _terminateExam(String message) {
//     _fullscreenCheckTimer?.cancel();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//           builder: (context) => TerminationPage(message: message)),
//     );
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 2),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _fullscreenCheckTimer?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.assessmentTitle),
//       ),
//       body: Center(
//         child: isExamMode
//             ? RoundsScreen(
//                 assessmentId: widget.assessmentId,
//                 assessmentTitle: widget.assessmentTitle,
//                 assessmentDurationMinutes: widget.assessmentDurationMinutes,
//               )
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Screen Blank - Please return to full-screen mode',
//                     style: TextStyle(fontSize: 18, color: Colors.red),
//                     textAlign: TextAlign.center,
//                   ),
                  // const SizedBox(height: 20),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     if (fullscreenExitCount < 4) {
                  //       _enterFullScreenMode();
                  //       _restoreExamContent();
                  //     } else {
                  //       _terminateExam(
                  //           'Exam terminated due to multiple exits from full-screen mode.');
                  //     }
                  //   },
                  //   child: const Text('Return to Full-Screen'),
                  // ),
//                 ],
//               ),
//       ),
//     );
//   }
// }



// class ExamBasePage extends StatefulWidget {
//   final Widget child;

//   const ExamBasePage({Key? key, required this.child}) : super(key: key);

//   @override
//   _ExamBasePageState createState() => _ExamBasePageState();
// }

// class _ExamBasePageState extends State<ExamBasePage> {
//   int fullscreenExitCount = 0;
//   int tabSwitchCount = 0;
//   bool isExamMode = true;

//   @override
//   void initState() {
//     super.initState();
//     _enforceFullScreen();
//     _monitorFullScreen();
//     _monitorTabSwitch();
//   }

//   void _enforceFullScreen() {
//     html.document.documentElement?.requestFullscreen();
//   }

//   void _monitorFullScreen() {
//     html.document.onFullscreenChange.listen((event) {
//       if (html.document.fullscreenElement == null) {
//         fullscreenExitCount++;
//         if (fullscreenExitCount >= 4) {
//           _terminateExam('Exam terminated due to multiple full-screen exits.');
//         } else {
//           setState(() {
//             isExamMode = false;
//           });
//           _showSnackbar(
//             'Exited full-screen mode. Warning: ${4 - fullscreenExitCount} left.',
//           );
//         }
//       } else {
//         setState(() {
//           isExamMode = true;
//         });
//       }
//     });
//   }

//   void _monitorTabSwitch() {
//     html.document.onVisibilityChange.listen((event) {
//       if (html.document.hidden) {
//         tabSwitchCount++;
//         if (tabSwitchCount >= 3) {
//           _terminateExam('Exam terminated due to multiple tab/window switches.');
//         } else {
//           _showSnackbar(
//             'Switched tabs/windows. Warning: ${3 - tabSwitchCount} left.',
//           );
//         }
//       }
//     });
//   }

//   void _terminateExam(String message) {
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TerminationPage(message: message),
//       ),
//     );
//   }

//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message), duration: Duration(seconds: 2)),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!isExamMode) {
//       return Scaffold(
//         body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Text(
//                 'Please return to full-screen mode.',
//                 style: TextStyle(fontSize: 18, color: Colors.red),
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   _enforceFullScreen();
//                 },
//                 child: Text('Return to Full-Screen'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return widget.child;
//   }
// }
