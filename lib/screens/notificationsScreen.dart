import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import './notificationWidget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key key, @required this.userID}) : super(key: key);
  final String userID;
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection('Notifications')
              .where('ownerID', isEqualTo: widget.userID)
              .orderBy('date', descending: true)
              .snapshots(),
          builder: (context, snapshots) {
            return snapshots.connectionState == ConnectionState.active
                ? ListView.builder(
                    itemCount: snapshots.data.documents.length,
                    itemBuilder: (context, index) {
                      return NotificationWidget(
                          notification: snapshots.data.documents[index]);
                    },
                  )
                : Container();
          },
        ),
      ),
    );
  }
}
