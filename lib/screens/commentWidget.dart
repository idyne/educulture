import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:after_layout/after_layout.dart';
import '../User.dart';

final User user = new User();

class Comment extends StatefulWidget {
  const Comment({Key key, @required this.comment, @required this.postID})
      : super(key: key);
  final DocumentSnapshot comment;
  final String postID;
  @override
  State<StatefulWidget> createState() {
    return _CommentState();
  }
}

class _CommentState extends State<Comment> with AfterLayoutMixin {
  Future _getCurrentUser;
  bool _isDeleted;
  double _commentOpacity = 0;

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    changePostOpacity();
  }

  void changePostOpacity() {
    if (_commentOpacity == 1) {
      setState(() {
        _commentOpacity = 0;
      });
    } else {
      setState(() {
        _commentOpacity = 1;
      });
    }
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

  Future<void> decreaseCommentsCount() async {
    try {
      DocumentSnapshot postInfo =
          await Firestore.instance.document('Posts/' + widget.postID).get();
      await Firestore.instance
          .document('Posts/' + widget.postID)
          .updateData({'commentsCount': postInfo.data['commentsCount'] - 1});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    _getCurrentUser = user.getCurrentUserID();
    _isDeleted = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      curve: Curves.ease,
      opacity: _commentOpacity,
      duration: Duration(milliseconds: 1000),
      child: Container(
        child: Flex(
          direction: Axis.vertical,
          children: <Widget>[
            Card(
              elevation: 10,
              child: Container(
                margin: EdgeInsets.only(top: 10),
                padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                            margin: EdgeInsets.only(bottom: 5),
                            width: 70.0,
                            height: 70.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                image: new ExactAssetImage(
                                    'assets/images/logo.png'),
                                fit: BoxFit.cover,
                              ),
                            )),
                        Text(
                          !widget.comment['isAnonymous']
                              ? widget.comment['ownerFullName']
                              : 'Anonymous',
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    ),
                    Text(
                      widget.comment['comment'],
                      style: TextStyle(
                          fontSize: 20, letterSpacing: 0.2, wordSpacing: 2),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FutureBuilder(
                              future: user.getCurrentUserID(),
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                return snapshot.hasData
                                    ? FlatButton(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(4.0))),
                                        highlightColor: Colors.deepOrange,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Icon(widget.comment['likes']
                                                    .contains(snapshot.data)
                                                ? FontAwesomeIcons.solidThumbsUp
                                                : FontAwesomeIcons.thumbsUp),
                                            Text(widget.comment['likes'].length
                                                .toString())
                                          ],
                                        ),
                                        onPressed: () async {
                                          if (widget.comment['likes']
                                              .contains(snapshot.data)) {
                                            Firestore.instance
                                                .document('Comments/' +
                                                    widget.comment.documentID)
                                                .updateData({
                                              'likes': FieldValue.arrayRemove([
                                                await user.getCurrentUserID()
                                              ])
                                            });
                                          } else {
                                            Firestore.instance
                                                .document('Comments/' +
                                                    widget.comment.documentID)
                                                .updateData({
                                              'likes': FieldValue.arrayUnion([
                                                await user.getCurrentUserID()
                                              ])
                                            });
                                          }
                                        },
                                      )
                                    : new CircularProgressIndicator();
                              },
                            ),
                            FutureBuilder(
                              future: _getCurrentUser,
                              builder: (BuildContext context,
                                  AsyncSnapshot snapshot) {
                                return widget.comment['ownerID'] ==
                                        snapshot.data
                                    ? FlatButton(
                                        child: Icon(FontAwesomeIcons.trash),
                                        onPressed: () {
                                          if (!_isDeleted) {
                                            setState(() {
                                              _isDeleted = true;
                                            });
                                            decreaseCommentsCount()
                                                .whenComplete(() async {
                                              await Firestore.instance
                                                  .document('Comments/' +
                                                      widget.comment.documentID)
                                                  .delete();
                                            });
                                          }
                                        },
                                      )
                                    : Text('');
                              },
                            )
                          ],
                        ),
                        Text(
                          _compareDate(widget.comment['date']),
                          style: TextStyle(fontSize: 15),
                        )
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = new Path();
    p.lineTo(0, 70);
    p.lineTo(size.width / 2 - 65, 70);
    p.lineTo(size.width / 2 - 55, 0);
    p.lineTo(size.width / 2 + 55, 0);
    p.lineTo(size.width / 2 + 65, 70);
    p.lineTo(size.width, 70);
    p.lineTo(size.width, size.height);
    p.lineTo(0, size.height);
    p.lineTo(0, 70);

    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
