import 'package:flutter/material.dart';
import 'package:studentpanel100/screens/coding%20question%20detail/coding_question_display.dart';
import 'package:studentpanel100/services/api_service.dart';

class CodingPracticePage extends StatefulWidget {
  @override
  _CodingPracticePageState createState() => _CodingPracticePageState();
}

class _CodingPracticePageState extends State<CodingPracticePage> {
  List<dynamic> _codingDomains = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCodingDomains();
  }

  // Fetch coding domains from the API
  Future<void> fetchCodingDomains() async {
    try {
      print("Initiating API request to fetch Coding domains...");

      final data = await ApiService.fetchData('/coding-domains', context);

      if (data != null && data.containsKey('domains')) {
        setState(() {
          _codingDomains = data['domains'];
          _isLoading = false;
        });
        print("Coding Domains successfully loaded: $_codingDomains");
      } else {
        setState(() {
          _errorMessage =
              'Unexpected response structure: missing "domains" key';
          _isLoading = false;
        });
        print("Error: Unexpected response structure.");
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'An error occurred: $error';
        _isLoading = false;
      });
      print("Error during domain fetch: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coding Practice'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _codingDomains.length,
                  itemBuilder: (context, index) {
                    final domain = _codingDomains[index];
                    return ListTile(
                      title:
                          Text(domain['name'], style: TextStyle(fontSize: 18)),
                      trailing: Icon(Icons.arrow_forward),
                      onTap: () {
                        // Navigate to DomainPage with the selected domain
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CodingDomainPage(domain: domain),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class CodingDomainPage extends StatelessWidget {
  final Map<String, dynamic> domain;

  const CodingDomainPage({Key? key, required this.domain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> subdomains = domain['children'] ?? [];

    // If there are no children, navigate to the questions page directly
    if (subdomains.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CodingQuestionPage(domainId: domain['id']),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(domain['name']),
      ),
      body: subdomains.isNotEmpty
          ? ListView.builder(
              itemCount: subdomains.length,
              itemBuilder: (context, index) {
                final subdomain = subdomains[index];
                return ListTile(
                  title:
                      Text(subdomain['name'], style: TextStyle(fontSize: 18)),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CodingDomainPage(domain: subdomain),
                      ),
                    );
                  },
                );
              },
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}

// class CodingQuestionPage extends StatefulWidget {
//   final int domainId;

//   const CodingQuestionPage({Key? key, required this.domainId})
//       : super(key: key);

//   @override
//   _CodingQuestionPageState createState() => _CodingQuestionPageState();
// }

// class _CodingQuestionPageState extends State<CodingQuestionPage> {
//   List<dynamic> _questions = [];
//   bool _isLoading = true;
//   String _errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchQuestions();
//   }

//   // Fetch coding questions by domain ID
//   // Future<void> fetchQuestions() async {
//   //   try {
//   //     final endpoint = '/coding-questions/domain/${widget.domainId}';
//   //     print("Fetching data from endpoint: $endpoint");

//   //     final data = await ApiService.fetchData(endpoint, context);

//   //     if (data != null && data.containsKey('codingQuestions')) {
//   //       setState(() {
//   //         _questions = data['codingQuestions'];
//   //         _isLoading = false;
//   //       });
//   //     } else {
//   //       setState(() {
//   //         _errorMessage = 'Unexpected response structure';
//   //         _isLoading = false;
//   //       });
//   //     }
//   //   } catch (error) {
//   //     setState(() {
//   //       _errorMessage = 'An error occurred: $error';
//   //       _isLoading = false;
//   //     });
//   //   }
//   // }
//   Future<void> fetchQuestions() async {
//     try {
//       final endpoint = '/coding-questions/domain/${widget.domainId}';
//       print("Fetching data from endpoint: $endpoint");

//       final data = await ApiService.fetchData(endpoint, context);

//       if (data != null && data.containsKey('codingQuestions')) {
//         setState(() {
//           _isLoading = false;

//           if (data['codingQuestions'].isEmpty) {
//             // Handle case where there are zero questions
//             _errorMessage =
//                 'There are no approved practice coding questions in this domain.';
//             _questions = []; // Ensure _questions is empty
//           } else {
//             // Handle case where questions are found
//             _questions = data['codingQuestions'];
//           }
//         });
//       } else {
//         setState(() {
//           _errorMessage = 'Unexpected response structure';
//           _isLoading = false;
//         });
//       }
//     } catch (error) {
//       setState(() {
//         _errorMessage = 'An error occurred: $error';
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Coding Questions'),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : _errorMessage.isNotEmpty
//               ? Center(child: Text(_errorMessage))
//               : ListView.builder(
//                   itemCount: _questions.length,
//                   itemBuilder: (context, index) {
//                     final question = _questions[index];
//                     return Card(
//                       margin: EdgeInsets.all(8.0),
//                       child: Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               question['title'],
//                               style: TextStyle(
//                                   fontSize: 18, fontWeight: FontWeight.bold),
//                             ),
//                             SizedBox(height: 10),
//                             Text(
//                               question['description'],
//                               style: TextStyle(fontSize: 16),
//                             ),
//                             SizedBox(height: 10),
//                             Text("Input Format: ${question['input_format']}"),
//                             Text("Output Format: ${question['output_format']}"),
//                             SizedBox(height: 10),
//                             Text(
//                               "Test Cases:",
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             ...List<Widget>.generate(
//                               question['test_cases'].length,
//                               (index) {
//                                 final testCase = question['test_cases'][index];
//                                 return Padding(
//                                   padding: const EdgeInsets.only(top: 8.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       Text("- Input: ${testCase['input']}"),
//                                       Text("  Output: ${testCase['output']}"),
//                                       if (testCase['is_public'])
//                                         Text(
//                                             "  Explanation: ${testCase['explanation'] ?? ''}"),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                             SizedBox(height: 10),
//                             Text("Constraints: ${question['constraints']}"),
//                             Text("Difficulty: ${question['difficulty']}"),
//                             SizedBox(height: 10),
//                             Text(
//                               "Allowed Languages:",
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.bold),
//                             ),
//                             ...List<Widget>.generate(
//                               question['allowed_languages'].length,
//                               (index) => Padding(
//                                 padding: const EdgeInsets.only(top: 4.0),
//                                 child: Text(
//                                     "- ${question['allowed_languages'][index]}"),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

class CodingQuestionPage extends StatefulWidget {
  final int domainId;

  const CodingQuestionPage({Key? key, required this.domainId})
      : super(key: key);

  @override
  _CodingQuestionPageState createState() => _CodingQuestionPageState();
}

class _CodingQuestionPageState extends State<CodingQuestionPage> {
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
      final endpoint = '/coding-questions/domain/${widget.domainId}';
      final data = await ApiService.fetchData(endpoint, context);

      if (data != null && data.containsKey('codingQuestions')) {
        setState(() {
          _isLoading = false;
          _questions = data['codingQuestions'];
        });
      } else {
        setState(() {
          _errorMessage = 'Unexpected response structure';
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
        title: Text('Coding Questions'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    final question = _questions[index];
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          question['title'],
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Difficulty: ${question['difficulty']}"),
                        trailing: Icon(Icons.arrow_forward),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CodingQuestionDetailPage(
                                question: question,
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
