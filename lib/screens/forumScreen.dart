import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../User.dart';
import './postWidget.dart';

class ForumScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ForumScreenState();
  }
}

class _ForumScreenState extends State<ForumScreen> {
  final User user = new User();

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: MediaQuery.of(context).padding,
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('Posts')
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return LinearProgressIndicator();
            }
            return _buildList(context, snapshot.data.documents);
          },
        ));
  }

  Widget _buildList(BuildContext context, snapshots) {
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
      },
      child: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Post(
            post: snapshots[index],
            isInList: true,
          );
        },
        itemCount: snapshots.length,
      ),
    );
  }
}
