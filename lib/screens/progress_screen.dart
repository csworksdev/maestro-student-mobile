import 'package:flutter/material.dart';
import 'package:maestro_client_mobile/screens/progress_list_screen.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return const ProgressListScreen();
  }

}