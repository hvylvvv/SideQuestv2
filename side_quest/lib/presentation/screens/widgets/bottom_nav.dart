import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:side_quest/presentation/screens/add_quest.dart';
import '../../screens/home_screen.dart';
import '../../screens/leaderboard_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/quests_screen.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    LeaderBoardScreen(),
    QuestsScreen(),
    ProfileScreen(),
    AddQuestScreen()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // Show the selected screen
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svgs/home.svg',
              width: 30,
              color: _selectedIndex == 0 ? Colors.blueAccent : Colors.grey,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svgs/map.svg',
              width: 35,
              color: _selectedIndex == 1 ? Colors.blueAccent : Colors.grey,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/svgs/addQuest.png',
              width: 90,
              height: 70,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svgs/trophy.svg',
              width: 35,
              color: _selectedIndex == 2 ? Colors.blueAccent : Colors.grey,
            ),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/svgs/profile.svg',
              width: 35,
              color: _selectedIndex == 3 ? Colors.blueAccent : Colors.grey,
            ),
            label: "",
          ),
        ],
      ),
    );
  }
}

