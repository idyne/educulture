import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:after_layout/after_layout.dart';
import '../User.dart';
import './commentsScreen.dart';

final User user = new User();

class Post extends StatefulWidget {
  const Post({Key key, @required this.post}) : super(key: key);
  final DocumentSnapshot post;
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> with AfterLayoutMixin<Post> {
  Future _getCurrentUser;
  double _postOpacity = 0;

  @override
  void initState() {
    _getCurrentUser = user.getCurrentUserID();

    super.initState();
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    changePostOpacity();
  }

  void changePostOpacity() {
    if (_postOpacity == 1) {
      setState(() {
        _postOpacity = 0;
      });
    } else {
      setState(() {
        _postOpacity = 1;
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

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _postOpacity,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
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
                                      'assets/images/avatar.png'),
                                  fit: BoxFit.cover,
                                ),
                              )),
                          Text(!widget.post['isAnonymous']
                              ? widget.post['ownerFullName']
                              : 'Anonymous'),
                        ],
                      ),
                      Text(
                        widget.post['title'],
                        style: TextStyle(fontSize: 25),
                      ),
                      Text(widget.post['content'],
                          style: TextStyle(fontSize: 20)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              FutureBuilder(
                                future: user.getCurrentUserID(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  return snapshot.hasData
                                      ? Container(
                                          margin: EdgeInsets.only(right: 10),
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.deepOrange,
                                                  width: 1),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(4))),
                                          padding: EdgeInsets.only(right: 10),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              IconButton(
                                                highlightColor:
                                                    Colors.deepOrange,
                                                icon: Icon(widget.post['likes']
                                                        .contains(snapshot.data)
                                                    ? FontAwesomeIcons
                                                        .solidThumbsUp
                                                    : FontAwesomeIcons
                                                        .thumbsUp),
                                                onPressed: () async {
                                                  setState(() {
                                                    _postOpacity = 0.5;
                                                  });
                                                  if (widget.post['likes']
                                                      .contains(
                                                          snapshot.data)) {
                                                    Firestore.instance
                                                        .document('Posts/' +
                                                            widget.post
                                                                .documentID)
                                                        .updateData({
                                                      'likes': FieldValue
                                                          .arrayRemove([
                                                        await user
                                                            .getCurrentUserID()
                                                      ])
                                                    });
                                                  } else {
                                                    Firestore.instance
                                                        .document('Posts/' +
                                                            widget.post
                                                                .documentID)
                                                        .updateData({
                                                      'likes': FieldValue
                                                          .arrayUnion([
                                                        await user
                                                            .getCurrentUserID()
                                                      ])
                                                    });
                                                  }
                                                },
                                              ),
                                              Text(widget.post['likes'].length
                                                  .toString())
                                            ],
                                          ),
                                        )
                                      : new CircularProgressIndicator();

                                  ///load until snapshot.hasData resolves to true
                                },
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.deepOrange, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                padding: EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    IconButton(
                                      highlightColor: Colors.deepOrange,
                                      icon: Icon(FontAwesomeIcons.comment),
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    CommentsScreen(
                                                      postID: widget
                                                          .post.documentID,
                                                    )));
                                      },
                                    ),
                                    Text(
                                        widget.post['commentsCount'].toString())
                                  ],
                                ),
                              ),
                              FutureBuilder(
                                future: _getCurrentUser,
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  return (widget.post['ownerID'] ==
                                          snapshot.data)
                                      ? IconButton(
                                          highlightColor: Colors.deepOrange,
                                          icon: Icon(
                                            Icons.delete_outline,
                                            size: 30,
                                          ),
                                          onPressed: () async {
                                            try {
                                              Firestore.instance
                                                  .collection('Comments')
                                                  .where('post',
                                                      isEqualTo: widget
                                                          .post.documentID)
                                                  .getDocuments()
                                                  .then((comments) {
                                                for (var document
                                                    in comments.documents) {
                                                  document.reference.delete();
                                                }
                                              });
                                              await Firestore.instance
                                                  .runTransaction(
                                                      (transaction) async {
                                                await transaction.delete(
                                                    Firestore.instance.document(
                                                        'Posts/' +
                                                            widget.post
                                                                .documentID));
                                              });
                                            } catch (e) {
                                              print(e);
                                            }
                                            print('alcatraz');
                                          })
                                      : Container();
                                },
                              )
                            ],
                          ),
                          AnimatedContainer(
                            duration: Duration(seconds: 1),
                            curve: Curves.ease,
                            child: Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(_compareDate(widget.post['date'])),
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
