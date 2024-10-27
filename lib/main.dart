import 'package:flutter/material.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';
import 'utils/shared_prefs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Panel',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder<String?>(
        future: SharedPrefs.getToken(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
            // If token is present, navigate to HomePage, otherwise LoginPage
            if (snapshot.data != null && snapshot.data!.isNotEmpty) {
              return HomePage();
            } else {
              return LoginPage();
            }
          }
        },
      ),
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

// import 'package:flutter/material.dart';
// import 'screens/login_page.dart';
// import 'screens/home_page.dart';
// import 'utils/shared_prefs.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Student Panel',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: FutureBuilder<String?>(
//         future: SharedPrefs.getToken(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return CircularProgressIndicator();
//           } else {
//             if (snapshot.data != null) {
//               return HomePage();
//             } else {
//               return LoginPage();
//             }
//           }
//         },
//       ),
//       routes: {
//         '/login': (context) => LoginPage(),
//         '/home': (context) => HomePage(),
//       },
//     );
//   }
// }
