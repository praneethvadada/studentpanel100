import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/shared_prefs.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class ApiService {
  static const String baseUrl = "http://localhost:3000/students";

  // Method to handle token expiration and redirect to login page
  static Future<void> _handleExpiredToken(BuildContext context) async {
    await SharedPrefs.removeToken();
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
  }

  // Helper method to get headers with JWT token
  static Future<Map<String, String>> _getHeaders() async {
    final token = await SharedPrefs.getToken();
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // GET request with token in headers and context for token expiration handling
  static Future<Map<String, dynamic>> fetchData(
      String endpoint, BuildContext context) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    print("Requesting URL: $url");

    final response = await http.get(url, headers: headers);

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, handle logout and redirect to login
      await _handleExpiredToken(context);
      throw Exception('Token expired. Redirecting to login.');
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  // POST request with token in headers and context for token expiration handling
  static Future<Map<String, dynamic>> postData(
      String endpoint, Map<String, dynamic> data, BuildContext context) async {
    final url = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    print("Posting to URL: $url");
    print("Posting data: $data");

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(data),
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 401) {
      // Token expired, handle logout and redirect to login
      await _handleExpiredToken(context);
      throw Exception('Token expired. Redirecting to login.');
    } else {
      throw Exception('Failed to post data: ${response.statusCode}');
    }
  }

  static Future<int?> getStudentIdFromToken() async {
    final token = await SharedPrefs.getToken();
    if (token != null && !JwtDecoder.isExpired(token)) {
      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'];
    }
    return null;
  }

  // Define the login method for user authentication
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      print("Login response status: ${response.statusCode}");
      print("Login response body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save the token to SharedPreferences
        if (data.containsKey('token')) {
          await SharedPrefs.saveToken(data['token']);
        }

        return data;
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Error logging in: $error');
    }
  }

  Future<List<dynamic>> fetchStudentAssessments() async {
    final token = await SharedPrefs.getToken();

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://localhost:3000/assessments/live'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['assessments'];
      } else {
        print(response.body);
        throw Exception('Failed to fetch assessments');
      }
    } else {
      throw Exception('Token not found');
    }
  }

  Future<List<dynamic>> fetchRoundsByAssessmentId(int assessmentId) async {
    final token = await SharedPrefs.getToken();

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://localhost:3000/assessments/$assessmentId/rounds'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['rounds'];
      } else {
        print(response.body);
        throw Exception('Failed to fetch rounds');
      }
    } else {
      throw Exception('Token not found');
    }
  }

  Future<List<dynamic>> fetchQuestionsByRoundId(int roundId) async {
    final token = await SharedPrefs.getToken();

    if (token != null) {
      final response = await http.get(
        Uri.parse('http://localhost:3000/assessments/round/$roundId/questions'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body)['questions'];
      } else {
        print(response.body);
        throw Exception('Failed to fetch questions');
      }
    } else {
      throw Exception('Token not found');
    }
  }
}

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../utils/shared_prefs.dart';
// import 'package:flutter/material.dart';

// class ApiService {
//   static const String baseUrl = "http://localhost:3000/students";
// // Method to handle token expiration and redirect to login page
//   static Future<void> _handleExpiredToken(BuildContext context) async {
//     await SharedPrefs.removeToken();
//     Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
//   }

//   // Helper method to get headers with JWT token
//   static Future<Map<String, String>> _getHeaders() async {
//     final token = await SharedPrefs.getToken();
//     return {
//       "Content-Type": "application/json",
//       "Authorization": "Bearer $token",
//     };
//   }

//   // GET request with token in headers
//   static Future<Map<String, dynamic>> fetchData(String endpoint) async {
//     final url = Uri.parse('$baseUrl$endpoint');
//     final headers = await _getHeaders();

//     print("Requesting URL: $url");

//     final response = await http.get(url, headers: headers);

//     print("Response status: ${response.statusCode}");
//     print("Response body: ${response.body}");

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to load data: ${response.statusCode}');
//     }
//   }

//   // POST request with token in headers
//   static Future<Map<String, dynamic>> postData(
//       String endpoint, Map<String, dynamic> data) async {
//     final url = Uri.parse('$baseUrl$endpoint');
//     final headers = await _getHeaders();

//     print("Posting to URL: $url");
//     print("Posting data: $data");

//     final response = await http.post(
//       url,
//       headers: headers,
//       body: jsonEncode(data),
//     );

//     print("Response status: ${response.statusCode}");
//     print("Response body: ${response.body}");

//     if (response.statusCode == 200) {
//       return jsonDecode(response.body);
//     } else {
//       throw Exception('Failed to post data: ${response.statusCode}');
//     }
//   }

//   // Define the login method for user authentication
//   static Future<Map<String, dynamic>> login(
//       String email, String password) async {
//     final url = Uri.parse('$baseUrl/login');

//     try {
//       final response = await http.post(
//         url,
//         headers: {
//           "Content-Type": "application/json",
//         },
//         body: jsonEncode({
//           "email": email,
//           "password": password,
//         }),
//       );

//       print("Login response status: ${response.statusCode}");
//       print("Login response body: ${response.body}");

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         // Save the token to SharedPreferences
//         if (data.containsKey('token')) {
//           await SharedPrefs.saveToken(data['token']);
//         }

//         return data;
//       } else {
//         throw Exception('Failed to login: ${response.statusCode}');
//       }
//     } catch (error) {
//       throw Exception('Error logging in: $error');
//     }
//   }
// }

// // import 'dart:convert';
// // import 'package:http/http.dart' as http;
// // import '../utils/shared_prefs.dart';

// // class ApiService {
// //   static const String baseUrl = "http://localhost:3000/students";
// //   static Future<Map<String, String>> _getHeaders() async {
// //     final token =
// //         await SharedPrefs.getToken(); // Retrieve token from SharedPreferences
// //     return {
// //       "Content-Type": "application/json",
// //       "Authorization": "Bearer $token",
// //     };
// //   }

// //   // Fetch data with token in headers
// //   static Future<Map<String, dynamic>> fetchData(String endpoint) async {
// //     final url = Uri.parse('$baseUrl$endpoint');
// //     final headers = await _getHeaders(); // Fetch headers with token

// //     final response = await http.get(url, headers: headers);

// //     if (response.statusCode == 200) {
// //       return jsonDecode(response.body);
// //     } else {
// //       throw Exception('Failed to load data: ${response.statusCode}');
// //     }
// //   }

// //   // Define the login method
// //   static Future<Map<String, dynamic>> login(
// //       String email, String password) async {
// //     final url = Uri.parse(
// //         '$baseUrl/login'); // Ensure this is the correct URL for your login API

// //     try {
// //       final response = await http.post(
// //         url,
// //         headers: {
// //           "Content-Type": "application/json",
// //         },
// //         body: jsonEncode({
// //           "email": email,
// //           "password": password,
// //         }),
// //       );

// //       // Check for a successful response
// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);

// //         // Save the token to SharedPreferences
// //         if (data.containsKey('token')) {
// //           await SharedPrefs.saveToken(data['token']);
// //         }

// //         return data;
// //       } else {
// //         throw Exception('Failed to login: ${response.statusCode}');
// //       }
// //     } catch (error) {
// //       throw Exception('Error logging in: $error');
// //     }
// //   }

// //   // Helper function to get the token and return the headers with the JWT token
// //   // static Future<Map<String, String>> _getHeaders() async {
// //   //   final token = await SharedPrefs.getToken();
// //   //   return {
// //   //     "Content-Type": "application/json",
// //   //     "Authorization": "Bearer $token",
// //   //   };
// //   // }

// //   // static Future<Map<String, dynamic>> fetchData(String endpoint) async {
// //   //   final url = Uri.parse('$baseUrl/$endpoint');
// //   //   final headers = await _getHeaders(); // Attach the JWT token in headers

// //   //   final response = await http.get(url, headers: headers);

// //   //   print("Response status: ${response.statusCode}");
// //   //   print("Response body: ${response.body}");

// //   //   if (response.statusCode == 200) {
// //   //     return jsonDecode(response.body);
// //   //   } else {
// //   //     throw Exception('Failed to load data: ${response.statusCode}');
// //   //   }
// //   // }

// //   // Example: Post data with the Authorization Bearer token
// //   static Future<Map<String, dynamic>> postData(
// //       String endpoint, Map<String, dynamic> data) async {
// //     final url = Uri.parse('$baseUrl/$endpoint');
// //     final headers = await _getHeaders(); // Attach the JWT token in headers

// //     final response = await http.post(
// //       url,
// //       headers: headers,
// //       body: jsonEncode(data),
// //     );

// //     print("Response status: ${response.statusCode}");
// //     print("Response body: ${response.body}");

// //     if (response.statusCode == 200) {
// //       return jsonDecode(response.body);
// //     } else {
// //       throw Exception('Failed to post data: ${response.statusCode}');
// //     }
// //   }
// // }

// // // import 'dart:convert';
// // // import 'package:http/http.dart' as http;
// // // import '../utils/shared_prefs.dart';

// // // class ApiService {
// // //   // Example API base URL
// //   // static const String baseUrl = "http://localhost:3000";

// //   // // Helper function to get the token and return the headers with the JWT token
// //   // static Future<Map<String, String>> _getHeaders() async {
// //   //   final token = await SharedPrefs.getToken();
// //   //   return {
// //   //     "Content-Type": "application/json",
// //   //     "Authorization": "Bearer $token",
// //   //   };
// //   // }

// // //   // Example: Fetch data with the Authorization Bearer token
// //   // static Future<Map<String, dynamic>> fetchData(String endpoint) async {
// //   //   final url = Uri.parse('$baseUrl/$endpoint');
// //   //   final headers = await _getHeaders(); // Attach the JWT token in headers

// //   //   final response = await http.get(url, headers: headers);

// //   //   print("Response status: ${response.statusCode}");
// //   //   print("Response body: ${response.body}");

// //   //   if (response.statusCode == 200) {
// //   //     return jsonDecode(response.body);
// //   //   } else {
// //   //     throw Exception('Failed to load data: ${response.statusCode}');
// //   //   }
// //   // }

// //   // // Example: Post data with the Authorization Bearer token
// //   // static Future<Map<String, dynamic>> postData(
// //   //     String endpoint, Map<String, dynamic> data) async {
// //   //   final url = Uri.parse('$baseUrl/$endpoint');
// //   //   final headers = await _getHeaders(); // Attach the JWT token in headers

// //   //   final response = await http.post(
// //   //     url,
// //   //     headers: headers,
// //   //     body: jsonEncode(data),
// //   //   );

// //   //   print("Response status: ${response.statusCode}");
// //   //   print("Response body: ${response.body}");

// //   //   if (response.statusCode == 200) {
// //   //     return jsonDecode(response.body);
// //   //   } else {
// //   //     throw Exception('Failed to post data: ${response.statusCode}');
// //   //   }
// //   // }
// // // }

// // // // import 'dart:convert';
// // // // import 'package:http/http.dart' as http;
// // // // import '../utils/shared_prefs.dart';

// // // // class ApiService {
// // // //   static const String baseUrl = "http://localhost:3000/students";

// // // //   static Future<Map<String, dynamic>> login(
// // // //       String email, String password) async {
// // // //     final url = Uri.parse('$baseUrl/login');
// // // //     final response = await http.post(
// // // //       url,
// // // //       headers: {"Content-Type": "application/json"},
// // // //       body: jsonEncode({"email": email, "password": password}),
// // // //     );

// // // //     if (response.statusCode == 200) {
// // // //       final data = jsonDecode(response.body);
// // // //       await SharedPrefs.saveToken(
// // // //           data['token']); // Save token to SharedPreferences
// // // //       return data;
// // // //     } else {
// // // //       throw Exception('Failed to login');
// // // //     }
// // // //   }
// // // // }
