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

  // Fetch MCQ domains from the API
  Future<void> fetchMcqDomains() async {
    try {
      print("Initiating API request to fetch MCQ domains...");

      // Fetch the data using the ApiService
      final data = await ApiService.fetchData('/mcq-domains', context);

      // Check if the expected data structure is present
      if (data != null && data.containsKey('domains')) {
        setState(() {
          _mcqDomains = data['domains'];
          _isLoading = false;
        });
        print("MCQ Domains successfully loaded: $_mcqDomains");
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
                        // Navigate to DomainPage with the selected domain
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

// Page to display subdomains or questions if it's a leaf node
class DomainPage extends StatelessWidget {
  final Map<String, dynamic> domain;

  const DomainPage({Key? key, required this.domain}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<dynamic> subdomains = domain['children'] ?? [];

    // If there are no children, navigate to the questions page directly
    if (subdomains.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => McqQuestionPage(domainId: domain['id']),
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
                        builder: (context) => DomainPage(domain: subdomain),
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

// Page to display questions for a specific domain
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

  // Fetch questions by domain ID
  Future<void> fetchQuestions() async {
    try {
      final endpoint = '/mcq-questions/domain/${widget.domainId}';
      print("Fetching data from endpoint: $endpoint");

      final data = await ApiService.fetchData(endpoint, context);

      if (data != null && data.containsKey('mcqQuestions')) {
        setState(() {
          _questions = data['mcqQuestions'];
          _isLoading = false;
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
                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              question['title'],
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            ...List<Widget>.generate(
                              question['options'].length,
                              (optionIndex) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                    "- ${question['options'][optionIndex]}"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
