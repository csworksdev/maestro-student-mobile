// import 'package:flutter/material.dart';
// // import 'package:provider/provider.dart';
// // import 'package:maestroswim_mobile_coach/providers/navigation_provider.dart';

// class FloatingProfileButton extends StatefulWidget {
//   @override
//   _FloatingProfileButtonState createState() => _FloatingProfileButtonState();
// }

// class _FloatingProfileButtonState extends State<FloatingProfileButton> {
//   double _scale = 1.0;

//   void _onTapDown(TapDownDetails details) {
//     setState(() {
//       _scale = 0.9;
//     });
//   }

//   void _onTapUp(TapUpDetails details) {
//     setState(() {
//       _scale = 1.0;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // final navProvider = Provider.of<NavigationProvider>(context);
//     double screenWidth = MediaQuery.of(context).size.width;
//     double buttonSize = 50.0; 

//     return Positioned(
//       left: (screenWidth - buttonSize) / 2,
//       bottom: 25, 
//       child: GestureDetector(
//         // onTap: () => navProvider.setIndex(0),
//         onTapDown: _onTapDown,
//         onTapUp: _onTapUp,
//         onTapCancel: () => setState(() => _scale = 1.0),
//         child: AnimatedContainer(
//           duration: Duration(milliseconds: 100),
//           transform: Matrix4.identity()..scale(_scale),
//           width: buttonSize,
//           height: buttonSize,
//           decoration: BoxDecoration(
//             shape: BoxShape.circle,
//             color: Colors.white,
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 6,
//                 spreadRadius: 2,
//               ),
//             ],
//           ),
//           child: CircleAvatar(
//             radius: buttonSize / 2,
//             backgroundImage: AssetImage('assets/images/profile2.png'),
//           ),
//         ),
//       ),
//     );
//   }
// }