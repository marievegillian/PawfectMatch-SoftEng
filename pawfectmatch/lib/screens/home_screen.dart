import 'package:flutter/material.dart';
import 'package:pawfectmatch/screens/screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int myIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            myIndex = index;
          });
        },
        currentIndex: myIndex,
        type: BottomNavigationBarType.fixed,
        items: const [          
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'), // Map icon added
          BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
          // BottomNavigationBarItem(icon: Icon(Icons.telegram), label: 'DOG REG TEST'),
        ],
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (myIndex) {
      case 0:
        return const MatchingScreen();
      case 1:
        return const ChatListScreen(); 
      case 2:
        return MapScreen(); // Add MapScreen
      case 3:
        return const UserProfileScreen(); 
      // case 5:
      //   // return const DogRegistrationScreen(); 
      default:
        return Container(); 
    }
  }
}
