import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Center(child: Text("Coming Soon...", style: TextStyle(fontSize: 24, fontStyle: FontStyle.italic))),
        ),
      ],
    );
  }
}
