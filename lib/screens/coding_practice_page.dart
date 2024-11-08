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
          print("Fetched Questions: $_questions");

          // Check if the list of questions is empty and set a message if so
          if (_questions.isEmpty) {
            _errorMessage = 'No coding questions found for this domain.';
          }
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
