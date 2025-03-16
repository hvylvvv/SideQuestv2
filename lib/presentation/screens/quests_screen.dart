import 'package:flutter/material.dart';

class QuestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quests")),
      body: Center(
        child: Text("Quests Screen", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}