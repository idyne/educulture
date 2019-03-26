import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:after_layout/after_layout.dart';
import './homeScreen.dart';
import './notificationsScreen.dart';
import '../User.dart';
import './forumScreen.dart';
import './newPostScreen.dart';
import './profileScreen.dart';
import './postScreen.dart';

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
  bool isThereNewNotification = false;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    updateDeviceToken();
  }

  Future<DocumentSnapshot> getPost(String postID) async {
    DocumentSnapshot post =
        await Firestore.instance.document("Posts/" + postID).get();
    return post;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseCloudMessagingListeners();
  }

  void firebaseCloudMessagingListeners() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        if (_currentIndex != 1) {
          setState(() {
            isThereNewNotification = true;
          });
        }
        print('on message ${message['data']['postID']}');
      },
      onResume: (Map<String, dynamic> message) async {
        if (message['data']['postID'] != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return FutureBuilder(
              future: getPost(message['data']['postID']),
              builder: (context, snapshot) {
                return snapshot.connectionState == ConnectionState.done
                    ? PostScreen(
                        post: snapshot.data,
                      )
                    : Container();
              },
            );
          }));
        }
        print('on resume ${message['data']['postID']}');
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['data']['postID'] != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return FutureBuilder(
              future: getPost(message['data']['postID']),
              builder: (context, snapshot) {
                return snapshot.connectionState == ConnectionState.done
                    ? PostScreen(
                        post: snapshot.data,
                      )
                    : Container();
              },
            );
          }));
        }
        print('on launch ${message['data']['postID']}');
      },
    );
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
        //HomePage(),
        ForumScreen(),
        FutureBuilder(
          future: user.getCurrentUserID(),
          builder: (context, snapshot) {
            return snapshot.connectionState == ConnectionState.done
                ? NotificationScreen(
                    userID: snapshot.data,
                  )
                : Container();
          },
        ),
        ProfileScreen(
          uid: null,
        ),
      ][_currentIndex],
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _currentIndex == 0
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
          //BottomNavigationBarItem(icon: Icon(Icons.home), title: Container()),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.poop), title: Container(height: 8)),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.pooStorm),
              title: isThereNewNotification
                  ? Icon(
                      FontAwesomeIcons.solidCircle,
                      color: Colors.red,
                      size: 8,
                    )
                  : Container(
                      width: 8,
                    )),
          BottomNavigationBarItem(
              icon: Icon(FontAwesomeIcons.user),
              title: Container(
                height: 8,
              )),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (index == 1) {
        setState(() {
          isThereNewNotification = false;
        });
      }
    });
  }
}
