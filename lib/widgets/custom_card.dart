// import 'package:flutter/material.dart';

// class CustomCard extends StatefulWidget {
//   final String title;
//   final IconData icon;
//   final VoidCallback onTap;

//   const CustomCard({
//     required this.title,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   _CustomCardState createState() => _CustomCardState();
// }

// class _CustomCardState extends State<CustomCard> {
//   bool isHovered = false;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Container(
//         height: 50,
//         width: 150,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               widget.icon,
//               size: 40, // Reduced icon size
//               color: isHovered ? Colors.white : Colors.black,
//             ),
//             SizedBox(height: 8.0), // Reduced space between icon and text
//             Text(
//               widget.title,
//               style: TextStyle(
//                 fontSize: 16, // Reduced text size
//                 color: isHovered ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _onHover(bool hovering) {
//     setState(() {
//       isHovered = hovering;
//     });
//   }
// }

// // import 'package:flutter/material.dart';

// // class CustomCard extends StatefulWidget {
// //   final String title;
// //   final IconData icon;
// //   final VoidCallback onTap;

// //   const CustomCard(
// //       {required this.title, required this.icon, required this.onTap});

// //   @override
// //   _CustomCardState createState() => _CustomCardState();
// // }

// // class _CustomCardState extends State<CustomCard> {
// //   bool isHovered = false;

// //   @override
// //   Widget build(BuildContext context) {
// //     return MouseRegion(
// //       onEnter: (event) => _onHover(true),
// //       onExit: (event) => _onHover(false),
// //       child: GestureDetector(
// //         onTap: widget.onTap,
// //         child: AnimatedContainer(
// //           height: 50,
// //           width: 50,
// //           duration: Duration(milliseconds: 300),
// //           padding: EdgeInsets.all(16.0),
// //           decoration: BoxDecoration(
// //             color: isHovered ? Colors.blueAccent : Colors.white,
// //             borderRadius: BorderRadius.circular(12),
// //             boxShadow: [
// //               if (isHovered)
// //                 BoxShadow(
// //                   color: Colors.blueAccent.withOpacity(0.5),
// //                   spreadRadius: 4,
// //                   blurRadius: 10,
// //                   offset: Offset(0, 3),
// //                 ),
// //             ],
// //           ),
// //           child: Column(
// //             mainAxisAlignment: MainAxisAlignment.center,
// //             children: [
// //               Icon(widget.icon,
// //                   size: 50, color: isHovered ? Colors.white : Colors.black),
// //               SizedBox(height: 16.0),
// //               Text(
// //                 widget.title,
// //                 style: TextStyle(
// //                   fontSize: 18,
// //                   color: isHovered ? Colors.white : Colors.black,
// //                   fontWeight: FontWeight.bold,
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   void _onHover(bool hovering) {
// //     setState(() {
// //       isHovered = hovering;
// //     });
// //   }
// // }
