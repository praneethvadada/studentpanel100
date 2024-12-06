import 'package:flutter/material.dart';
import 'package:studentpanel100/screens/login_page.dart';
import 'package:studentpanel100/utils/shared_prefs.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  Future<void> _logout(BuildContext context) async {
    // Remove the stored token
    await SharedPrefs.removeToken();
    // Navigate to the login page and clear the navigation stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
        title: Text('Profile'),
      ),
      body: Center(
        child: Text(
          'Welcome to Profile!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
    //   appBar: AppBar(
    //     title: const Text('Home Page'),
    //     actions: [
    //       IconButton(
    //         icon: const Icon(Icons.logout),
    //         onPressed: () => _logout(context),
    //       ),
    //     ],
    //   ),
    //   body: const Center(
    //     child: Text('Welcome to the Home Page!'),
    //   ),
    // );
  }
}

// import 'package:flutter/material.dart';

// class ProfilePage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Profile'),
//       ),
//       body: Center(
//         child: Text(
//           'Welcome to Profile!',
//           style: TextStyle(fontSize: 24),
//         ),
//       ),
//     );
//   }
// }
