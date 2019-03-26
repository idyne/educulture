import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:after_layout/after_layout.dart';
import './postScreen.dart';

class NotificationWidget extends StatefulWidget {
  const NotificationWidget({Key key, @required this.notification})
      : super(key: key);
  final DocumentSnapshot notification;
  @override
  _NotificationWidgetState createState() => _NotificationWidgetState();
}

class _NotificationWidgetState extends State<NotificationWidget>
    with AfterLayoutMixin {
  Future<DocumentSnapshot> getPost(String postID) async {
    DocumentSnapshot post =
        await Firestore.instance.document("Posts/" + postID).get();
    return post;
  }

  String _compareDate(date) {
    DateTime now = DateTime.now();
    if (now.difference(date).inSeconds < 60) {
      return now.difference(date).inSeconds.toString() + ' seconds ago';
    } else if (now.difference(date).inMinutes < 60) {
      return now.difference(date).inMinutes.toString() + ' minutes ago';
    } else if (now.difference(date).inHours < 24) {
      return now.difference(date).inHours.toString() + ' hours ago';
    } else if (now.difference(date).inDays < 30) {
      return now.difference(date).inDays.toString() + ' days ago';
    } else if (now.difference(date).inDays < 365) {
      return (365 ~/ now.difference(date).inDays).toString() + ' months ago';
    }
    return (now.difference(date).inDays ~/ 365).toString() + ' years ago';
  }

  DocumentSnapshot post;
  @override
  void afterFirstLayout(BuildContext context) async {
    // Calling the same function "after layout" to resolve the issue.
    post = await getPost(widget.notification['post']);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if (post != null) {
          DocumentReference reference = widget.notification.reference;
          await reference.updateData({'isSeen': true});
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return PostScreen(
              post: post,
            );
          }));
        }
      },
      child: Container(
        padding: EdgeInsets.all(5),
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(5),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      child: Column(
                        children: <Widget>[
                          widget.notification['isSeen'] == false
                              ? Icon(
                                  FontAwesomeIcons.solidCircle,
                                  size: 8,
                                  color: Colors.red,
                                )
                              : Container(),
                          Icon(
                            widget.notification['event'] == 'newPostLike'
                                ? FontAwesomeIcons.poop
                                : FontAwesomeIcons.toiletPaper,
                            color: Colors.deepOrange,
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      margin: EdgeInsets.only(right: 10),
                      child: Text(
                        widget.notification['content'],
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Text(_compareDate(widget.notification['date'])),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
