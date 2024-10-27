import 'package:flutter/material.dart';

class AssessmentPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessments'),
      ),
      body: Center(
        child: Text(
          'Welcome to Assessments!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
