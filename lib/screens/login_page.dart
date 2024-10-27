import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'home_page.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_textfield.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController =
      TextEditingController(text: "praneeth@gmail.com");
  final TextEditingController _passwordController =
      TextEditingController(text: "12345");
  bool isLoading = false;

  void _login() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Making the login request using ApiService
      final response = await ApiService.login(
        _emailController.text,
        _passwordController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'])),
      );

      // Navigate to Home Page after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } catch (e) {
      // Showing error message if login fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: ${e.toString()}')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Student Login')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomTextField(
              controller: _emailController,
              labelText: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.0),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 24.0),
            isLoading
                ? CircularProgressIndicator()
                : CustomButton(
                    text: 'Login',
                    onPressed: _login,
                  ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import '../services/api_service.dart';
// import 'home_page.dart';
// import '../widgets/custom_button.dart';
// import '../widgets/custom_textfield.dart';

// class LoginPage extends StatefulWidget {
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final TextEditingController _emailController =
//       TextEditingController(text: "praneeth@gmail.com");
//   final TextEditingController _passwordController =
//       TextEditingController(text: "12345");
//   bool isLoading = false;

//   void _login() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response = await ApiService.login(
//         _emailController.text,
//         _passwordController.text,
//       );

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(response['message'])),
//       );

//       // Navigate to Home Page after successful login
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => HomePage()),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Login failed: ${e.toString()}')),
//       );
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Student Login')),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CustomTextField(
//               controller: _emailController,
//               labelText: 'Email',
//               keyboardType: TextInputType.emailAddress,
//             ),
//             SizedBox(height: 16.0),
//             CustomTextField(
//               controller: _passwordController,
//               labelText: 'Password',
//               obscureText: true,
//             ),
//             SizedBox(height: 24.0),
//             isLoading
//                 ? CircularProgressIndicator()
//                 : CustomButton(
//                     text: 'Login',
//                     onPressed: _login,
//                   ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import '../services/api_service.dart';
// // import 'home_page.dart';
// // import '../widgets/custom_button.dart';
// // import '../widgets/custom_textfield.dart';

// // class LoginPage extends StatefulWidget {
// //   @override
// //   _LoginPageState createState() => _LoginPageState();
// // }

// // class _LoginPageState extends State<LoginPage> {
// //   final TextEditingController _emailController =
// //       TextEditingController(text: "praneeth@gmail.com");
// //   final TextEditingController _passwordController =
// //       TextEditingController(text: "12345");
// //   bool isLoading = false;

// //   void _login() async {
// //     setState(() {
// //       isLoading = true;
// //     });

// //     try {
// //       final response = await ApiService.login(
// //         _emailController.text,
// //         _passwordController.text,
// //       );
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text(response['message'])),
// //       );

// //       Navigator.pushReplacement(
// //         context,
// //         MaterialPageRoute(builder: (context) => HomePage()),
// //       );
// //     } catch (e) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Login failed: ${e.toString()}')),
// //       );
// //     } finally {
// //       setState(() {
// //         isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       appBar: AppBar(title: Text('Student Login')),
// //       body: Padding(
// //         padding: EdgeInsets.all(16.0),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             CustomTextField(
// //               controller: _emailController,
// //               labelText: 'Email',
// //               keyboardType: TextInputType.emailAddress,
// //             ),
// //             SizedBox(height: 16.0),
// //             CustomTextField(
// //               controller: _passwordController,
// //               labelText: 'Password',
// //               obscureText: true,
// //             ),
// //             SizedBox(height: 24.0),
// //             isLoading
// //                 ? CircularProgressIndicator()
// //                 : CustomButton(
// //                     text: 'Login',
// //                     onPressed: _login,
// //                   ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
