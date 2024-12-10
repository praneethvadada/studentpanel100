import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:studentpanel100/utils/shared_prefs.dart';

class AssessmentPage extends StatefulWidget {
  @override
  _AssessmentPageState createState() => _AssessmentPageState();
}

class _AssessmentPageState extends State<AssessmentPage> {
  List assessments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssessments();
  }

  Future<void> fetchAssessments() async {
    final token = await SharedPrefs.getToken(); // Fetch the JWT token
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/assessments/live'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          assessments = data['assessments'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load assessments');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching assessments: $e');
    }
  }

  // Future<void> startAssessment(int assessmentId) async {
  //   final token = await SharedPrefs.getToken();
  //   print('Attempting to start or resume assessment for ID: $assessmentId');

  //   try {
  //     // Step 1: Check for active session
  //     final sessionResponse = await http.get(
  //       Uri.parse(
  //           'http://localhost:3000/timer/exam/active?assessment_id=$assessmentId'),
  //       headers: {'Authorization': 'Bearer $token'},
  //     );

  //     if (sessionResponse.statusCode == 200) {
  //       // Handle active session
  //       final sessionData = json.decode(sessionResponse.body)['session'];
  //       final int sessionId = sessionData['id'];
  //       final DateTime endTime = DateTime.now()
  //           .add(Duration(seconds: sessionData['remaining_time']));
  //       print('Active session found: $sessionData');

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => RoundsPage(
  //             assessmentId: assessmentId,
  //             endTime: endTime,
  //             sessionId: sessionId,
  //           ),
  //         ),
  //       );
  //       return; // Exit if session is active
  //     } else {
  //       print('No active session found. Starting a new one.');
  //     }
  //   } catch (e) {
  //     print('Error checking active session: $e');
  //   }

  //   // Step 2: Start a new session if no active session
  //   try {
  //     final response = await http.post(
  //       Uri.parse('http://localhost:3000/timer/exam/start'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Authorization': 'Bearer $token',
  //       },
  //       body: jsonEncode({"assessment_id": assessmentId}),
  //     );

  //     if (response.statusCode == 201) {
  //       final data = json.decode(response.body);
  //       final int sessionId = data['session_id'];
  //       final DateTime endTime = DateTime.parse(data['end_time']);
  //       print('New session started successfully: $data');

  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => RoundsPage(
  //             assessmentId: assessmentId,
  //             endTime: endTime,
  //             sessionId: sessionId,
  //           ),
  //         ),
  //       );
  //     } else if (response.statusCode == 400) {
  //       // Check if a session already exists
  //       final data = json.decode(response.body);
  //       print('Session already exists: ${data['session']}');
  //     } else {
  //       throw Exception(
  //           'Failed to start assessment. Response: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error starting new session: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Error: Unable to start assessment')),
  //     );
  //   }
  // }

  Future<void> startAssessment(int assessmentId) async {
    final token = await SharedPrefs.getToken();
    print('Attempting to start or resume assessment for ID: $assessmentId');

    try {
      // Check for active session
      final sessionResponse = await http.get(
        Uri.parse(
            'http://localhost:3000/timer/exam/active?assessment_id=$assessmentId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (sessionResponse.statusCode == 200) {
        final sessionData = json.decode(sessionResponse.body)['session'];
        final int sessionId = sessionData['id'];
        final DateTime endTime = DateTime.now()
            .add(Duration(seconds: sessionData['remaining_time']));
        print('Active session found: $sessionData');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoundsPage(
              assessmentId: assessmentId,
              endTime: endTime,
              sessionId: sessionId,
            ),
          ),
        );
        return;
      } else {
        print('No active session found. Starting a new one.');
      }
    } catch (e) {
      print('Error checking active session: $e');
    }

    // Start a new session
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/timer/exam/start'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"assessment_id": assessmentId}),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final int sessionId = data['session_id'];
        final DateTime endTime = DateTime.parse(data['end_time']);
        print('New session started successfully: $data');

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RoundsPage(
              assessmentId: assessmentId,
              endTime: endTime,
              sessionId: sessionId,
            ),
          ),
        );
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body);
        if (errorData['message'] ==
            "This assessment has already been ended by you.") {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Assessment Ended'),
                content: Text(
                    'You have already ended this assessment and cannot restart it.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          throw Exception(
              'Failed to start assessment. Response: ${response.body}');
        }
      } else {
        throw Exception(
            'Failed to start assessment. Response: ${response.body}');
      }
    } catch (e) {
      print('Error starting new session: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to start assessment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Assessments')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: assessments.length,
              itemBuilder: (context, index) {
                final assessment = assessments[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(assessment['title']),
                    subtitle: Text(assessment['description']),
                    // trailing: ElevatedButton(
                    //   // onPressed: () => startAssessment(assessment['id']),
                    //   onPressed: assessment['status'] == 'ended'
                    //       ? null
                    //       : () => startAssessment(assessment['id']),

                    //   child: Text('Start Assessment'),
                    // ),
                    trailing: ElevatedButton(
                      onPressed: assessment['status'] == 'ended'
                          ? () {
                              // Show an alert dialog if the exam has already ended
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Exam Ended'),
                                    content: Text(
                                        'You have ended this exam. It cannot be restarted.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // Close the dialog
                                        },
                                        child: Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          : () => startAssessment(assessment[
                              'id']), // Otherwise, start the assessment
                      child: Text('Start Assessment'),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class RoundsPage extends StatefulWidget {
  final int assessmentId;
  final DateTime endTime;
  final int sessionId;

  RoundsPage(
      {required this.assessmentId,
      required this.endTime,
      required this.sessionId});

  @override
  _RoundsPageState createState() => _RoundsPageState();
}

class _RoundsPageState extends State<RoundsPage> {
  late Timer timer;
  late Duration remainingTime;
  List rounds = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('Initializing with endTime: ${widget.endTime}');
    remainingTime = widget.endTime.difference(DateTime.now());
    fetchRounds();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      if (!mounted)
        return; // Prevent unnecessary updates if the widget is disposed

      setState(() {
        remainingTime -= Duration(seconds: 1); // Decrease time by 1 second
      });

      if (remainingTime.inSeconds % 10 == 0) {
        // Sync remaining time with the backend every 10 seconds
        await syncRemainingTime();
      }

      if (remainingTime.inSeconds <= 0) {
        timer?.cancel();
        showTimeUpDialog();
      }
    });
  }

  Future<void> syncRemainingTime() async {
    final token = await SharedPrefs.getToken();
    try {
      await http.post(
        Uri.parse('http://localhost:3000/timer/exam/update-remaining'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "session_id": widget.sessionId, // Pass the session ID
          "remaining_time": remainingTime.inSeconds,
        }),
      );
    } catch (e) {
      print('Error syncing remaining time: $e');
    }
  }

  Future<void> fetchRounds() async {
    final token = await SharedPrefs.getToken();
    try {
      final response = await http.get(
        Uri.parse(
            'http://localhost:3000/assessments/${widget.assessmentId}/rounds'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          rounds = data['rounds'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load rounds');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching rounds: $e');
    }
  }

  void showTimeUpDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Time\'s up!'),
        content: Text('Your assessment time has ended.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    syncRemainingTime();
    super.dispose();
  }

  Future<void> endExam() async {
    final token = await SharedPrefs.getToken();
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/timer/exam/end'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"session_id": widget.sessionId}),
      );

      if (response.statusCode == 200) {
        print('Exam ended successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exam ended successfully')),
        );
        Navigator.of(context)
            .popUntil((route) => route.isFirst); // Return to the main screen
      } else {
        throw Exception('Failed to end exam. Response: ${response.body}');
      }
    } catch (e) {
      print('Error ending exam: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to end exam')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Rounds'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Time Left: ${remainingTime.inHours.toString().padLeft(2, '0')}:${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          ElevatedButton(
              onPressed: () => endExam(), // Call the end exam function
              child: Text('End Exam')),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: rounds.length,
              itemBuilder: (context, index) {
                final round = rounds[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(round['round_type']),
                    subtitle: Text('Order: ${round['round_order']}'),
                    trailing: ElevatedButton(
                      onPressed: () => navigateToQuestions(round['id']),
                      child: Text('Start Round'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void navigateToQuestions(int roundId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsPage(
          sessionId: widget.sessionId,
          roundId: roundId,
          endTime: widget.endTime,
        ),
      ),
    );
  }
}

class QuestionsPage extends StatefulWidget {
  final int roundId;
  final DateTime endTime;
  final int sessionId; // Define the sessionId parameter here

  QuestionsPage(
      {required this.roundId, required this.endTime, required this.sessionId});

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  List questions = [];
  bool isLoading = true;
  late Timer timer;
  late Duration remainingTime;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
    print('Initializing with endTime: ${widget.endTime}');
    remainingTime = widget.endTime.difference(DateTime.now());
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) async {
      if (!mounted)
        return; // Prevent unnecessary updates if the widget is disposed

      setState(() {
        remainingTime -= Duration(seconds: 1); // Decrease time by 1 second
      });

      if (remainingTime.inSeconds % 10 == 0) {
        // Sync remaining time with the backend every 10 seconds
        await syncRemainingTime();
      }

      if (remainingTime.inSeconds <= 0) {
        timer?.cancel();
        showTimeUpDialog();
      }
    });
  }

  Future<void> syncRemainingTime() async {
    final token = await SharedPrefs.getToken();
    try {
      await http.post(
        Uri.parse('http://localhost:3000/timer/exam/update-remaining'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "session_id": widget.sessionId, // Pass the session ID
          "remaining_time": remainingTime.inSeconds,
        }),
      );
    } catch (e) {
      print('Error syncing remaining time: $e');
    }
  }

  Future<void> fetchQuestions() async {
    try {
      final response = await http.get(Uri.parse(
          'http://localhost:3000/assessments/round/${widget.roundId}/questions'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          questions = data['questions'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load questions');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  void showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Time\'s up!'),
        content: Text('Your assessment time has ended.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget buildMCQQuestion(question) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(question['mcqQuestion']['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var option in question['mcqQuestion']['options'])
              Row(
                children: [
                  Radio(
                    value: option,
                    groupValue: question['selectedOption'],
                    onChanged: (value) {
                      setState(() {
                        question['selectedOption'] = value;
                      });
                    },
                  ),
                  Text(option),
                ],
              ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Handle MCQ submission
          },
          child: Text('Submit'),
        ),
      ),
    );
  }

  Widget buildCodingQuestion(question) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(question['codingQuestion']['title']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Description: ${question['codingQuestion']['description']}'),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Write your code here...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                question['code'] = value;
              },
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Handle Coding Question submission
          },
          child: Text('Submit'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    syncRemainingTime();
    super.dispose();
  }

  Future<void> endExam() async {
    final token = await SharedPrefs.getToken();
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/timer/exam/end'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({"session_id": widget.sessionId}),
      );

      if (response.statusCode == 200) {
        print('Exam ended successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exam ended successfully')),
        );
        Navigator.of(context)
            .popUntil((route) => route.isFirst); // Return to the main screen
      } else {
        throw Exception('Failed to end exam. Response: ${response.body}');
      }
    } catch (e) {
      print('Error ending exam: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to end exam')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions'),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Time Left: ${remainingTime.inHours.toString().padLeft(2, '0')}:${(remainingTime.inMinutes % 60).toString().padLeft(2, '0')}:${(remainingTime.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => endExam(), // Call the end exam function
            child: Text('End Exam'),
            style: ElevatedButton.styleFrom(),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                if (question['mcqQuestion'] != null) {
                  return buildMCQQuestion(question);
                } else if (question['codingQuestion'] != null) {
                  return buildCodingQuestion(question);
                } else {
                  return SizedBox();
                }
              },
            ),
    );
  }
}
