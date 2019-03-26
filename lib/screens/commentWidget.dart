import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:after_layout/after_layout.dart';
import './profileScreen.dart';
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

  void _showLikesList() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            height: 300,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return FutureBuilder(
                  future: user.getUserInfo(widget.comment.data['likes'][index]),
                  builder: (context, snapshot) {
                    return snapshot.connectionState == ConnectionState.done
                        ? Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(4),
                              highlightColor: Colors.deepOrange,
                              splashColor: Colors.deepOrange,
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ProfileScreen(
                                              uid: snapshot.data['uid'],
                                            )));
                              },
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    margin: EdgeInsets.only(right: 10),
                                    width: 30,
                                    height: 30,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.grey,
                                      backgroundImage:
                                          CachedNetworkImageProvider(snapshot
                                              .data['profilePictureURL']),
                                      radius: 50.0,
                                    ),
                                  ),
                                  Text(
                                      '${snapshot.data['firstName']} ${snapshot.data['lastName']}')
                                ],
                              ),
                            ))
                        : Container();
                  },
                );
              },
              itemCount: widget.comment.data['likes'].length,
            ),
          ),
        );
      },
    );
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

  void deleteComment() {
    if (!_isDeleted) {
      setState(() {
        _isDeleted = true;
      });
      decreaseCommentsCount().whenComplete(() async {
        await Firestore.instance
            .document('Comments/' + widget.comment.documentID)
            .delete();
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

  void _showDeletionDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Delete"),
          content: new Text("Are you sure?"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("No", style: TextStyle(color: Colors.deepOrange)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "Yes",
                style: TextStyle(color: Colors.deepOrange),
              ),
              onPressed: () {
                deleteComment();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
        padding: EdgeInsets.fromLTRB(10, 0, 10, 5),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      widget.comment['comment'],
                      style: TextStyle(fontSize: 20),
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
                                    ? Container(
                                        margin: EdgeInsets.only(right: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: <Widget>[
                                            IconButton(
                                              color: Colors.deepOrange,
                                              highlightColor: Colors.deepOrange,
                                              icon: widget.comment['likes']
                                                      .contains(snapshot.data)
                                                  ? Icon(
                                                      FontAwesomeIcons.poo,
                                                    )
                                                  : Icon(
                                                      FontAwesomeIcons.poop,
                                                      color: Color(0xC4FF5722),
                                                    ),
                                              onPressed: () async {
                                                if (widget.comment['likes']
                                                    .contains(snapshot.data)) {
                                                  Firestore.instance
                                                      .document('Comments/' +
                                                          widget.comment
                                                              .documentID)
                                                      .updateData({
                                                    'likes':
                                                        FieldValue.arrayRemove([
                                                      await user
                                                          .getCurrentUserID()
                                                    ])
                                                  });
                                                } else {
                                                  Firestore.instance
                                                      .document('Comments/' +
                                                          widget.comment
                                                              .documentID)
                                                      .updateData({
                                                    'likes':
                                                        FieldValue.arrayUnion([
                                                      await user
                                                          .getCurrentUserID()
                                                    ])
                                                  });
                                                }
                                              },
                                            ),
                                            InkWell(
                                              child: Text(
                                                widget.comment['likes'].length
                                                        .toString() +
                                                    ' likes',
                                              ),
                                              onTap: _showLikesList,
                                            )
                                          ],
                                        ),
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
                                    ? Column(
                                        children: <Widget>[
                                          IconButton(
                                            color: Colors.red,
                                            icon: Icon(FontAwesomeIcons.toilet),
                                            onPressed: () {
                                              _showDeletionDialog();
                                            },
                                          ),
                                          Text('Delete',
                                              style: TextStyle(fontSize: 14))
                                        ],
                                      )
                                    : Container();
                              },
                            )
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              _compareDate(widget.comment['date']),
                              style: TextStyle(fontSize: 14),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 8),
                              child: !widget.comment['isAnonymous']
                                  ? InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      child: Text(
                                        widget.comment['ownerFullName'],
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: 'Poppins-Black'),
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfileScreen(
                                                      uid: widget
                                                          .comment['ownerID'],
                                                    )));
                                      },
                                    )
                                  : Text('-Anonymous',
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: 'Poppins-Black')),
                            )
                          ],
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
