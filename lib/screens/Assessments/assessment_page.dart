// import 'dart:html' as html;
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:studentpanel100/screens/Assessments/coding_assessment_page.dart';
// import 'package:studentpanel100/screens/Assessments/mcq_assessment_page.dart';
// import 'package:studentpanel100/services/api_service.dart';

// class TimerAppBar extends StatefulWidget implements PreferredSizeWidget {
//   final Duration duration;

//   const TimerAppBar({
//     Key? key,
//     required this.duration,
//   }) : super(key: key);

//   @override
//   State<TimerAppBar> createState() => _TimerAppBarState();

//   @override
//   Size get preferredSize => const Size.fromHeight(kToolbarHeight);
// }

// class _TimerAppBarState extends State<TimerAppBar> {
//   late Duration _remainingTime;
//   late Stream<Duration> _timerStream;

//   @override
//   void initState() {
//     super.initState();
//     _remainingTime = widget.duration;
//     _timerStream = _createTimerStream();
//   }

//   Stream<Duration> _createTimerStream() async* {
//     while (_remainingTime.inSeconds > 0) {
//       await Future.delayed(const Duration(seconds: 1));
//       _remainingTime -= const Duration(seconds: 1);
//       yield _remainingTime;
//     }
//   }

//   String _formatDuration(Duration duration) {
//     final minutes = duration.inMinutes % 60;
//     final seconds = duration.inSeconds % 60;
//     return '${duration.inHours.toString().padLeft(2, '0')}:'
//         '${minutes.toString().padLeft(2, '0')}:'
//         '${seconds.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AppBar(
//       title: StreamBuilder<Duration>(
//         stream: _timerStream,
//         builder: (context, snapshot) {
//           final timeText = snapshot.hasData
//               ? _formatDuration(snapshot.data!)
//               : _formatDuration(widget.duration);
//           return Text('Time Remaining: $timeText');
//         },
//       ),
//     );
//   }
// }

// class AssessmentPage extends StatelessWidget {
//   const AssessmentPage({Key? key}) : super(key: key);

//   Future<List<dynamic>> _fetchAssessments() async {
//     return await ApiService().fetchStudentAssessments();
//   }

//   String _formatDateTime(String dateTimeString) {
//     try {
//       final dateTime = DateTime.parse(dateTimeString).toLocal();
//       return DateFormat('dd-MM-yyyy hh:mm a').format(dateTime);
//     } catch (e) {
//       return dateTimeString;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<dynamic>>(
//       future: _fetchAssessments(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(child: CircularProgressIndicator());
//         } else if (snapshot.hasError) {
//           return Center(child: Text('Error: ${snapshot.error}'));
//         } else if (snapshot.data == null || snapshot.data!.isEmpty) {
//           return const Center(child: Text('No assessments found.'));
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
//                   style: const TextStyle(fontSize: 12),
//                 ),
//                 isThreeLine: true,
//                 onTap: () {
//                   // Navigate to the ExamScreen and pass the assessment details
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => ExamScreen(
//                         assessmentId: assessment['id'],
//                         assessmentTitle: assessment['title'],
//                         assessmentDurationMinutes:
//                             assessment['duration_minutes'],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         }
//       },
//     );
//   }
// }

// abstract class FullScreenEnforcedPage extends StatefulWidget {
//   const FullScreenEnforcedPage({Key? key}) : super(key: key);
// }

// abstract class FullScreenEnforcedPageState<T extends FullScreenEnforcedPage>
//     extends State<T> {
//   Timer? _fullscreenCheckTimer;
//   Timer? _visibilityCheckTimer;
//   int fullscreenExitCount = 0;
//   int tabSwitchCount = 0;
//   bool isFullScreen = true; // Tracks full-screen state
//   bool isExamMode = true; // Tracks whether exam content is displayed

//   @override
//   void initState() {
//     super.initState();
//     _enterFullScreenMode();
//     _startFullScreenCheck();
//     _monitorTabSwitches();
//   }

//   void _enterFullScreenMode() {
//     html.document.documentElement?.requestFullscreen();
//   }

//   void _startFullScreenCheck() {
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
//       isExamMode = false;
//     });
//   }

//   void _restoreExamContent() {
//     if (fullscreenExitCount < 4) {
//       setState(() {
//         isExamMode = true;
//       });
//       _showSnackbar('You are back in full-screen mode. Exam content restored.');
//     } else {
//       _terminateExam(
//           'Exam terminated due to multiple exits from full-screen mode.');
//     }
//   }

//   void _terminateExam(String message) {
//     _fullscreenCheckTimer?.cancel();
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TerminationPage(message: message),
//       ),
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
// }

// class ExamScreen extends FullScreenEnforcedPage {
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

// class _ExamScreenState extends FullScreenEnforcedPageState<ExamScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: TimerAppBar(
//         duration: Duration(minutes: widget.assessmentDurationMinutes),
//       ),
//       body: Center(
//         child: isExamMode
//             ? RoundsScreen(
//                 assessmentId: widget.assessmentId,
//                 assessmentTitle: widget.assessmentTitle,
//                 assessmentDurationMinutes: widget.assessmentDurationMinutes,
//               )
//             : _buildBlankScreen(),
//       ),
//     );
//   }

//   Widget _buildBlankScreen() {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           'Screen Blank - Please return to full-screen mode',
//           style: TextStyle(fontSize: 18, color: Colors.red),
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 20),
//         ElevatedButton(
//           onPressed: () {
//             if (fullscreenExitCount < 4) {
//               _enterFullScreenMode();
//               _restoreExamContent();
//             } else {
//               _terminateExam(
//                   'Exam terminated due to multiple exits from full-screen mode.');
//             }
//           },
//           child: const Text('Return to Full-Screen'),
//         ),
//       ],
//     );
//   }
// }

// // class QuestionsScreen extends FullScreenEnforcedPage {
// //   final List<dynamic> questions;

// //   const QuestionsScreen({Key? key, required this.questions}) : super(key: key);

// //   @override
// //   _QuestionsScreenState createState() => _QuestionsScreenState();
// // }

// // class _QuestionsScreenState
// //     extends FullScreenEnforcedPageState<QuestionsScreen> {
// //   int _currentQuestionIndex = 0;

// //   void _navigateToQuestion(int index) {
// //     setState(() {
// //       _currentQuestionIndex = index;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final question = widget.questions[_currentQuestionIndex];

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: const Text('Assessment Questions'),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.fullscreen),
// //             onPressed: _enterFullScreenMode,
// //           ),
// //         ],
// //       ),
// //       body: isExamMode
// //           ? Row(
// //               children: [
// //                 // Side Navigation
// //                 SizedBox(
// //                   width: 80,
// //                   child: SideNavigation(
// //                     questions: widget.questions,
// //                     onQuestionSelected: _navigateToQuestion,
// //                   ),
// //                 ),
// //                 // Question Content
// //                 Expanded(
// //                   child: question['codingQuestion'] != null
// //                       ? CodingQuestionWidget(
// //                           codingQuestion: question['codingQuestion'],
// //                         )
// //                       : MCQQuestionWidget(
// //                           mcqQuestion: question['mcqQuestion'],
// //                         ),
// //                 ),
// //               ],
// //             )
// //           : _buildBlankScreen(),
// //     );
// //   }

// //   Widget _buildBlankScreen() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           const Text(
// //             'Screen Blank - Please return to full-screen mode',
// //             style: TextStyle(fontSize: 18, color: Colors.red),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 20),
// //           ElevatedButton(
// //             onPressed: () {
// //               if (fullscreenExitCount < 4) {
// //                 _enterFullScreenMode();
// //                 _restoreExamContent();
// //               } else {
// //                 _terminateExam(
// //                     'Exam terminated due to multiple exits from full-screen mode.');
// //               }
// //             },
// //             child: const Text('Return to Full-Screen'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class QuestionsScreen extends FullScreenEnforcedPage {
// //   final List<dynamic> questions;
// //   final Stream<Duration> timerStream; // Add timerStream

// //   const QuestionsScreen({
// //     Key? key,
// //     required this.questions,
// //     required this.timerStream,
// //   }) : super(key: key);

// //   @override
// //   _QuestionsScreenState createState() => _QuestionsScreenState();
// // }

// // class _QuestionsScreenState
// //     extends FullScreenEnforcedPageState<QuestionsScreen> {
// //   int _currentQuestionIndex = 0;

// //   void _navigateToQuestion(int index) {
// //     setState(() {
// //       _currentQuestionIndex = index;
// //     });
// //   }

// //   String _formatDuration(Duration duration) {
// //     final minutes = duration.inMinutes % 60;
// //     final seconds = duration.inSeconds % 60;
// //     return '${duration.inHours.toString().padLeft(2, '0')}:' +
// //         '${minutes.toString().padLeft(2, '0')}:' +
// //         '${seconds.toString().padLeft(2, '0')}';
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final question = widget.questions[_currentQuestionIndex];

// //     return Scaffold(
// //       appBar: AppBar(
// //         title: StreamBuilder<Duration>(
// //           stream: widget.timerStream,
// //           builder: (context, snapshot) {
// //             final timeText = snapshot.hasData
// //                 ? _formatDuration(snapshot.data!)
// //                 : 'Loading Timer...';
// //             return Text('Time Remaining: $timeText');
// //           },
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: const Icon(Icons.fullscreen),
// //             onPressed: _enterFullScreenMode,
// //           ),
// //         ],
// //       ),
// //       body: isExamMode
// //           ? Row(
// //               children: [
// //                 // Side Navigation
// //                 SizedBox(
// //                   width: 80,
// //                   child: SideNavigation(
// //                     questions: widget.questions,
// //                     onQuestionSelected: _navigateToQuestion,
// //                   ),
// //                 ),
// //                 // Question Content
// //                 Expanded(
// //                   child: question['codingQuestion'] != null
// //                       ? CodingQuestionWidget(
// //                           codingQuestion: question['codingQuestion'],
// //                         )
// //                       : MCQQuestionWidget(
// //                           mcqQuestion: question['mcqQuestion'],
// //                         ),
// //                 ),
// //               ],
// //             )
// //           : _buildBlankScreen(),
// //     );
// //   }

// //   Widget _buildBlankScreen() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           const Text(
// //             'Screen Blank - Please return to full-screen mode',
// //             style: TextStyle(fontSize: 18, color: Colors.red),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 20),
// //           ElevatedButton(
// //             onPressed: () {
// //               if (fullscreenExitCount < 4) {
// //                 _enterFullScreenMode();
// //                 _restoreExamContent();
// //               } else {
// //                 _terminateExam(
// //                     'Exam terminated due to multiple exits from full-screen mode.');
// //               }
// //             },
// //             child: const Text('Return to Full-Screen'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // class QuestionsScreen extends FullScreenEnforcedPage {
// //   final List<dynamic> questions;
// //   final Stream<Duration> timerStream;

// //   const QuestionsScreen({
// //     Key? key,
// //     required this.questions,
// //     required this.timerStream,
// //   }) : super(key: key);

// //   @override
// //   _QuestionsScreenState createState() => _QuestionsScreenState();
// // }

// // class _QuestionsScreenState
// //     extends FullScreenEnforcedPageState<QuestionsScreen> {
// //   int _currentQuestionIndex = 0;

// //   void _navigateToQuestion(int index) {
// //     setState(() {
// //       _currentQuestionIndex = index;
// //     });
// //   }

// //   String _formatDuration(Duration duration) {
// //     final minutes = duration.inMinutes % 60;
// //     final seconds = duration.inSeconds % 60;
// //     return '${duration.inHours.toString().padLeft(2, '0')}:' +
// //         '${minutes.toString().padLeft(2, '0')}:' +
// //         '${seconds.toString().padLeft(2, '0')}';
// //   }

// //   // @override
// //   // Widget build(BuildContext context) {
// //   //   final question = widget.questions[_currentQuestionIndex];

// //   //   return Scaffold(
// //   //     appBar: AppBar(
// //   //       automaticallyImplyLeading: true, // Enables default back button
// //   //       title: StreamBuilder<Duration>(
// //   //         stream: widget.timerStream,
// //   //         builder: (context, snapshot) {
// //   //           if (snapshot.hasData && snapshot.data!.inSeconds > 0) {
// //   //             return Text(
// //   //               'Time Remaining: ${_formatDuration(snapshot.data!)}',
// //   //               style: const TextStyle(fontSize: 16),
// //   //             );
// //   //           } else if (snapshot.hasData && snapshot.data!.inSeconds == 0) {
// //   //             return const Text(
// //   //               'Time is up!',
// //   //               style: TextStyle(fontSize: 16, color: Colors.red),
// //   //             );
// //   //           } else {
// //   //             return const Text('Loading Timer...');
// //   //           }
// //   //         },
// //   //       ),
// //   //       leading: IconButton(
// //   //         icon: const Icon(Icons.arrow_back),
// //   //         onPressed: () {
// //   //           Navigator.pop(context); // Explicit back navigation
// //   //         },
// //   //       ),
// //   //     ),
// //   //     body: isExamMode
// //   //         ? Row(
// //   //             children: [
// //   //               // Side Navigation
// //   //               SizedBox(
// //   //                 width: 80,
// //   //                 child: SideNavigation(
// //   //                   questions: widget.questions,
// //   //                   onQuestionSelected: _navigateToQuestion,
// //   //                 ),
// //   //               ),
// //   //               // Question Content
// //   //               Expanded(
// //   //                 child: question['codingQuestion'] != null
// //   //                     ? CodingQuestionWidget(
// //   //                         codingQuestion: question['codingQuestion'],
// //   //                       )
// //   //                     : MCQQuestionWidget(
// //   //                         mcqQuestion: question['mcqQuestion'],
// //   //                       ),
// //   //               ),
// //   //             ],
// //   //           )
// //   //         : _buildBlankScreen(),
// //   //   );
// //   // }

// //   @override
// //   Widget build(BuildContext context) {
// //     final question = widget.questions[_currentQuestionIndex];

// //     return Scaffold(
// //       appBar: AppBar(
// //         automaticallyImplyLeading: true, // Back button
// //         title: StreamBuilder<Duration>(
// //           stream: widget.timerStream,
// //           builder: (context, snapshot) {
// //             if (snapshot.hasData && snapshot.data!.inSeconds > 0) {
// //               return Text(
// //                 'Time Remaining: ${_formatDuration(snapshot.data!)}',
// //                 style: const TextStyle(fontSize: 16),
// //               );
// //             } else if (snapshot.hasData && snapshot.data!.inSeconds == 0) {
// //               return const Text(
// //                 'Time is up!',
// //                 style: TextStyle(fontSize: 16, color: Colors.red),
// //               );
// //             } else {
// //               return const Text('Loading Timer...');
// //             }
// //           },
// //         ),
// //         centerTitle: true, // Align the title to the center
// //       ),
// //       body: isExamMode
// //           ? Row(
// //               children: [
// //                 // Side Navigation
// //                 SizedBox(
// //                   width: 80,
// //                   child: SideNavigation(
// //                     questions: widget.questions,
// //                     onQuestionSelected: _navigateToQuestion,
// //                   ),
// //                 ),
// //                 // Question Content
// //                 Expanded(
// //                   child: question['codingQuestion'] != null
// //                       ? CodingQuestionWidget(
// //                           codingQuestion: question['codingQuestion'],
// //                         )
// //                       : MCQQuestionWidget(
// //                           mcqQuestion: question['mcqQuestion'],
// //                         ),
// //                 ),
// //               ],
// //             )
// //           : _buildBlankScreen(),
// //     );
// //   }

// //   Widget _buildBlankScreen() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           const Text(
// //             'Screen Blank - Please return to full-screen mode',
// //             style: TextStyle(fontSize: 18, color: Colors.red),
// //             textAlign: TextAlign.center,
// //           ),
// //           const SizedBox(height: 20),
// //           ElevatedButton(
// //             onPressed: () {
// //               if (fullscreenExitCount < 4) {
// //                 _enterFullScreenMode();
// //                 _restoreExamContent();
// //               } else {
// //                 _terminateExam(
// //                     'Exam terminated due to multiple exits from full-screen mode.');
// //               }
// //             },
// //             child: const Text('Return to Full-Screen'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class QuestionsScreen extends FullScreenEnforcedPage {
//   final List<dynamic> questions;
//   final Stream<Duration> timerStream;

//   const QuestionsScreen({
//     Key? key,
//     required this.questions,
//     required this.timerStream,
//   }) : super(key: key);

//   @override
//   _QuestionsScreenState createState() => _QuestionsScreenState();
// }

// class _QuestionsScreenState
//     extends FullScreenEnforcedPageState<QuestionsScreen> {
//   int _currentQuestionIndex = 0;

//   void _navigateToQuestion(int index) {
//     setState(() {
//       _currentQuestionIndex = index;
//     });
//   }

//   String _formatDuration(Duration duration) {
//     final minutes = duration.inMinutes % 60;
//     final seconds = duration.inSeconds % 60;
//     return '${duration.inHours.toString().padLeft(2, '0')}:' +
//         '${minutes.toString().padLeft(2, '0')}:' +
//         '${seconds.toString().padLeft(2, '0')}';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final question = widget.questions[_currentQuestionIndex];

//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: true, // Ensures back button is present
//         title: StreamBuilder<Duration>(
//           stream: widget.timerStream,
//           builder: (context, snapshot) {
//             if (snapshot.hasData && snapshot.data!.inSeconds > 0) {
//               return Text(
//                 'Time Remaining: ${_formatDuration(snapshot.data!)}',
//                 style: const TextStyle(fontSize: 16),
//               );
//             } else if (snapshot.hasData && snapshot.data!.inSeconds == 0) {
//               return const Text(
//                 'Time is up!',
//                 style: TextStyle(fontSize: 16, color: Colors.red),
//               );
//             } else {
//               return const Text('Loading Timer...');
//             }
//           },
//         ),
//         centerTitle: true, // Align the title in the center
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context); // Navigate back to the previous screen
//           },
//         ),
//       ),
//       body: isExamMode
//           ? Row(
//               children: [
//                 // Side Navigation
//                 SizedBox(
//                   width: 80,
//                   child: SideNavigation(
//                     questions: widget.questions,
//                     onQuestionSelected: _navigateToQuestion,
//                   ),
//                 ),
//                 // Question Content
//                 Expanded(
//                   child: question['codingQuestion'] != null
//                       ? CodingQuestionWidget(
//                           codingQuestion: question['codingQuestion'],
//                         )
//                       : MCQQuestionWidget(
//                           mcqQuestion: question['mcqQuestion'],
//                         ),
//                 ),
//               ],
//             )
//           : _buildBlankScreen(),
//     );
//   }

//   Widget _buildBlankScreen() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Text(
//             'Screen Blank - Please return to full-screen mode',
//             style: TextStyle(fontSize: 18, color: Colors.red),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               if (fullscreenExitCount < 4) {
//                 _enterFullScreenMode();
//                 _restoreExamContent();
//               } else {
//                 _terminateExam(
//                     'Exam terminated due to multiple exits from full-screen mode.');
//               }
//             },
//             child: const Text('Return to Full-Screen'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class RoundsScreen extends StatefulWidget {
//   final int assessmentId;
//   final String assessmentTitle;
//   final int assessmentDurationMinutes;

//   const RoundsScreen({
//     Key? key,
//     required this.assessmentId,
//     required this.assessmentTitle,
//     required this.assessmentDurationMinutes,
//   }) : super(key: key);

//   @override
//   _RoundsScreenState createState() => _RoundsScreenState();
// }

// // class _RoundsScreenState extends State<RoundsScreen> {
// //   late Stream<Duration> _timerStream;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _timerStream = _createTimerStream();
// //   }

// //   Stream<Duration> _createTimerStream() async* {
// //     Duration remainingTime =
// //         Duration(minutes: widget.assessmentDurationMinutes);

// //     while (remainingTime.inSeconds > 0) {
// //       await Future.delayed(const Duration(seconds: 1));
// //       remainingTime -= const Duration(seconds: 1);
// //       yield remainingTime;
// //     }

// //     yield Duration.zero; // Emit zero when time is up.
// //   }

// //   Future<List<dynamic>> _fetchRounds() async {
// //     return await ApiService().fetchRoundsByAssessmentId(widget.assessmentId);
// //   }

// //   Future<void> _fetchAndOpenQuestions(dynamic roundId) async {
// //     try {
// //       if (roundId is String) {
// //         roundId = int.parse(roundId); // Ensure roundId is an integer
// //       }

// //       final questions = await ApiService().fetchQuestionsByRoundId(roundId);

// //       if (questions != null && questions.isNotEmpty) {
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => QuestionsScreen(questions: questions),
// //           ),
// //         );
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("No questions found for this round.")),
// //         );
// //       }
// //     } catch (error) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Failed to load questions: $error")),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Column(
// //         children: [
// //           Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: StreamBuilder<Duration>(
// //               stream: _timerStream,
// //               builder: (context, snapshot) {
// //                 if (snapshot.hasData && snapshot.data!.inSeconds > 0) {
// //                   return Text(
// //                     'Time Remaining: ${_formatDuration(snapshot.data!)}',
// //                     style: const TextStyle(
// //                         fontSize: 18, fontWeight: FontWeight.bold),
// //                   );
// //                 } else {
// //                   return const Text(
// //                     'Time is up!',
// //                     style: TextStyle(
// //                         fontSize: 20,
// //                         fontWeight: FontWeight.bold,
// //                         color: Colors.red),
// //                   );
// //                 }
// //               },
// //             ),
// //           ),
// //           Expanded(
// //             child: FutureBuilder<List<dynamic>>(
// //               future: _fetchRounds(),
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 } else if (snapshot.hasError) {
// //                   return Center(child: Text('Error: ${snapshot.error}'));
// //                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //                   return const Center(child: Text('No rounds found.'));
// //                 } else {
// //                   final rounds = snapshot.data!;
// //                   return ListView.builder(
// //                     itemCount: rounds.length,
// //                     itemBuilder: (context, index) {
// //                       final round = rounds[index];
// //                       return ListTile(
// //                         title: Text('Round ${round['round_order']}'),
// //                         subtitle: Text(round['round_type']),
// //                         onTap: () {
// //                           _fetchAndOpenQuestions(round['id']);
// //                         },
// //                       );
// //                     },
// //                   );
// //                 }
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   String _formatDuration(Duration duration) {
// //     final minutes = duration.inMinutes % 60;
// //     final seconds = duration.inSeconds % 60;
// //     return '${duration.inHours.toString().padLeft(2, '0')}:'
// //         '${minutes.toString().padLeft(2, '0')}:'
// //         '${seconds.toString().padLeft(2, '0')}';
// //   }
// // }

// // class _RoundsScreenState extends State<RoundsScreen> {
// //   @override
// //   void initState() {
// //     super.initState();
// //   }

// //   Future<List<dynamic>> _fetchRounds() async {
// //     return await ApiService().fetchRoundsByAssessmentId(widget.assessmentId);
// //   }

// //   Future<void> _fetchAndOpenQuestions(dynamic roundId) async {
// //     try {
// //       if (roundId is String) {
// //         roundId = int.parse(roundId); // Ensure roundId is an integer
// //       }

// //       final questions = await ApiService().fetchQuestionsByRoundId(roundId);

// //       if (questions != null && questions.isNotEmpty) {
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (context) => QuestionsScreen(questions: questions),
// //           ),
// //         );
// //       } else {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(content: Text("No questions found for this round.")),
// //         );
// //       }
// //     } catch (error) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text("Failed to load questions: $error")),
// //       );
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Column(
// //         children: [
// //           Expanded(
// //             child: FutureBuilder<List<dynamic>>(
// //               future: _fetchRounds(),
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting) {
// //                   return const Center(child: CircularProgressIndicator());
// //                 } else if (snapshot.hasError) {
// //                   return Center(child: Text('Error: ${snapshot.error}'));
// //                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
// //                   return const Center(child: Text('No rounds found.'));
// //                 } else {
// //                   final rounds = snapshot.data!;
// //                   return ListView.builder(
// //                     itemCount: rounds.length,
// //                     itemBuilder: (context, index) {
// //                       final round = rounds[index];
// //                       return ListTile(
// //                         title: Text('Round ${round['round_order']}'),
// //                         subtitle: Text(round['round_type']),
// //                         onTap: () {
// //                           _fetchAndOpenQuestions(round['id']);
// //                         },
// //                       );
// //                     },
// //                   );
// //                 }
// //               },
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// class _RoundsScreenState extends State<RoundsScreen> {
//   late Stream<Duration> _timerStream;

//   @override
//   void initState() {
//     super.initState();
//     _timerStream = _createTimerStream();
//   }

//   Stream<Duration> _createTimerStream() async* {
//     Duration remainingTime =
//         Duration(minutes: widget.assessmentDurationMinutes);

//     while (remainingTime.inSeconds > 0) {
//       await Future.delayed(const Duration(seconds: 1));
//       remainingTime -= const Duration(seconds: 1);
//       yield remainingTime;
//     }

//     yield Duration.zero; // Emit zero when time is up.
//   }

//   Future<List<dynamic>> _fetchRounds() async {
//     return await ApiService().fetchRoundsByAssessmentId(widget.assessmentId);
//   }

//   Future<void> _fetchAndOpenQuestions(dynamic roundId) async {
//     try {
//       if (roundId is String) {
//         roundId = int.parse(roundId); // Ensure roundId is an integer
//       }

//       final questions = await ApiService().fetchQuestionsByRoundId(roundId);

//       if (questions != null && questions.isNotEmpty) {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => QuestionsScreen(
//               questions: questions,
//               timerStream: _timerStream,
//             ),
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("No questions found for this round.")),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed to load questions: $error")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: StreamBuilder<Duration>(
//               stream: _timerStream,
//               builder: (context, snapshot) {
//                 if (snapshot.hasData && snapshot.data!.inSeconds > 0) {
//                   return Text(
//                     'Time Remaining: ${_formatDuration(snapshot.data!)}',
//                     style: const TextStyle(
//                         fontSize: 18, fontWeight: FontWeight.bold),
//                   );
//                 } else {
//                   return const Text(
//                     'Time is up!',
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.red),
//                   );
//                 }
//               },
//             ),
//           ),
//           Expanded(
//             child: FutureBuilder<List<dynamic>>(
//               future: _fetchRounds(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (snapshot.hasError) {
//                   return Center(child: Text('Error: ${snapshot.error}'));
//                 } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                   return const Center(child: Text('No rounds found.'));
//                 } else {
//                   final rounds = snapshot.data!;
//                   return ListView.builder(
//                     itemCount: rounds.length,
//                     itemBuilder: (context, index) {
//                       final round = rounds[index];
//                       return ListTile(
//                         title: Text('Round ${round['round_order']}'),
//                         subtitle: Text(round['round_type']),
//                         onTap: () {
//                           _fetchAndOpenQuestions(round['id']);
//                         },
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDuration(Duration duration) {
//     final minutes = duration.inMinutes % 60;
//     final seconds = duration.inSeconds % 60;
//     return '${duration.inHours.toString().padLeft(2, '0')}:' +
//         '${minutes.toString().padLeft(2, '0')}:' +
//         '${seconds.toString().padLeft(2, '0')}';
//   }
// }

// class TerminationPage extends StatelessWidget {
//   final String message;

//   const TerminationPage({Key? key, required this.message}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     print("TerminationPage: Displaying termination message.");
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Exam Terminated'),
//       ),
//       body: Center(
//         child: Text(
//           message,
//           textAlign: TextAlign.center,
//           style: const TextStyle(fontSize: 18, color: Colors.red),
//         ),
//       ),
//     );
//   }
// }

// class SideNavigation extends StatelessWidget {
//   final List<dynamic> questions;
//   final Function(int) onQuestionSelected;

//   const SideNavigation(
//       {Key? key, required this.questions, required this.onQuestionSelected})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: questions.length,
//       itemBuilder: (context, index) {
//         return GestureDetector(
//           onTap: () => onQuestionSelected(index),
//           child: Container(
//             margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//             padding: const EdgeInsets.all(8.0),
//             decoration: BoxDecoration(
//               border: Border.all(color: Colors.grey),
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: Center(
//               child: Text(
//                 'Q${index + 1}',
//                 style: const TextStyle(fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
