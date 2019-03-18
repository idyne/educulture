import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:after_layout/after_layout.dart';
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

class _MainScreenState extends State<MainScreen>
    with AfterLayoutMixin<MainScreen> {
  int _currentIndex = 0;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    updateDeviceToken();
  }

  Future<void> updateDeviceToken() async {
    String token = await _firebaseMessaging.getToken();
    QuerySnapshot snapshot = await Firestore.instance
        .collection("DeviceTokens")
        .where("uid", isEqualTo: await user.getCurrentUserID())
        .getDocuments();

    if (snapshot.documents.length != 0) {
      if (snapshot.documents[0].data["token"] != token) {
        await snapshot.documents[0].reference.updateData({"token": token});
      }
    } else {
      await Firestore.instance
          .collection("DeviceTokens")
          .add({"uid": await user.getCurrentUserID(), "token": token});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomePage(),
        ForumScreen(),
        ProfileScreen(
          uid: null,
        )
      ][_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 1
          ? FloatingActionButton(
              backgroundColor: Colors.deepOrange,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => NewPostScreen()));
              },
              tooltip: 'Increment',
              child: Icon(Icons.add),
              elevation: 2.0,
            )
          : null,
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
