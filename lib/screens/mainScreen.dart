import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import './homeScreen.dart';
import '../User.dart';
import './forumScreen.dart';
import './newPostScreen.dart';
import './profileScreen.dart';

class MainScreen extends StatefulWidget {
  final User user = new User();
  @override
  State<StatefulWidget> createState() {
    return _MainScreenState();
  }
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [HomePage(), ForumScreen(), ProfileScreen()][_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 1? FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => NewPostScreen()));
        },
        tooltip: 'Increment',
        child: Icon(Icons.add),
        elevation: 2.0,
      ):null,
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), title: Text('Home')),
          BottomNavigationBarItem(
              icon: Icon(Icons.short_text), title: Text('Forum')),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.user), title: Text('Profile'))
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
