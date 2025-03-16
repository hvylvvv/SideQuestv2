import 'package:flutter/material.dart';

class LeaderBoardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Leaderboard")),
      body: Center(
        child: Text("Leaderboard Screen", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}