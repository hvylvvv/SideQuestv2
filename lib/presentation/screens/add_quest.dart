import 'package:flutter/material.dart';

class AddQuestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Quests")),
      body: Center(
        child: Text("Add Quests Screen", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}