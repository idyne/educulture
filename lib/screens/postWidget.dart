import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:after_layout/after_layout.dart';
import '../User.dart';
import './postScreen.dart';
import './profileScreen.dart';

final User user = new User();

class Post extends StatefulWidget {
  const Post({Key key, @required this.post, @required this.isInList})
      : super(key: key);
  final DocumentSnapshot post;
  final bool isInList;
  @override
  _PostState createState() => _PostState();
}

class _PostState extends State<Post> with AfterLayoutMixin<Post> {
  Future _getCurrentUser;
  double _postOpacity = 0;
  bool isDeleting = false;
  bool subScribeRadio = false;
  String dropdownValue = 'One';

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
                  future: user.getUserInfo(widget.post.data['likes'][index]),
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
              itemCount: widget.post.data['likes'].length,
            ),
          ),
        );
      },
    );
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
              child:
                  new Text("Yes", style: TextStyle(color: Colors.deepOrange)),
              onPressed: () {
                deletePost();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void deletePost() async {
    if (!widget.isInList) Navigator.pop(context);
    if (!isDeleting) {
      setState(() {
        isDeleting = true;
      });
      try {
        /*await Firestore.instance
            .collection('Comments')
            .where('post', isEqualTo: widget.post.documentID)
            .getDocuments()
            .then((comments) {
          for (var document in comments.documents) {
            document.reference.delete();
          }
        });*/
        await Firestore.instance.runTransaction((transaction) async {
          await transaction.delete(
              Firestore.instance.document('Posts/' + widget.post.documentID));
        });
      } catch (e) {
        print(e);
      }
      print('alcatraz');
    }
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

  Widget footer(BuildContext context) {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              FutureBuilder(
                future: user.getCurrentUserID(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return snapshot.hasData
                      ? Container(
                          margin: EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.transparent, width: 1),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50))),
                          padding: EdgeInsets.only(right: 10),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              IconButton(
                                color: Colors.deepOrange,
                                highlightColor: Colors.deepOrange,
                                icon:
                                    widget.post['likes'].contains(snapshot.data)
                                        ? Icon(
                                            FontAwesomeIcons.poo,
                                            size: 20,
                                          )
                                        : Icon(
                                            FontAwesomeIcons.poop,
                                            color: Color(0xC4FF5722),
                                            size: 20,
                                          ),
                                onPressed: () async {
                                  if (widget.post['likes']
                                      .contains(snapshot.data)) {
                                    Firestore.instance
                                        .document(
                                            'Posts/' + widget.post.documentID)
                                        .updateData({
                                      'likes': FieldValue.arrayRemove(
                                          [await user.getCurrentUserID()])
                                    });
                                  } else {
                                    Firestore.instance
                                        .document(
                                            'Posts/' + widget.post.documentID)
                                        .updateData({
                                      'likes': FieldValue.arrayUnion(
                                          [await user.getCurrentUserID()])
                                    });
                                  }
                                },
                                splashColor: Colors.transparent,
                              ),
                              InkWell(
                                child: Text(
                                    widget.post['likes'].length.toString() +
                                        ' likes'),
                                onTap: _showLikesList,
                              )
                            ],
                          ),
                        )
                      : new CircularProgressIndicator();

                  ///load until snapshot.hasData resolves to true
                },
              ),
              widget.isInList
                  ? Container(
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.transparent, width: 1),
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      padding: EdgeInsets.only(right: 10, top: 15),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(bottom: 14),
                            child: Icon(
                              FontAwesomeIcons.toiletPaper,
                              color: Colors.deepOrange,
                              size: 20,
                            ),
                          ),
                          Text(widget.post['commentsCount'].toString() +
                              ' comments')
                        ],
                      ),
                    )
                  : Container(),
              FutureBuilder(
                future: _getCurrentUser,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  return (widget.post['ownerID'] == snapshot.data)
                      ? Column(
                          children: <Widget>[
                            IconButton(
                                color: Colors.red,
                                highlightColor: Colors.deepOrange,
                                icon: Icon(
                                  FontAwesomeIcons.toilet,
                                  size: 20,
                                ),
                                onPressed: _showDeletionDialog),
                            Text('Delete')
                          ],
                        )
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
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    _compareDate(widget.post['date']),
                    style: TextStyle(fontSize: 14),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    child: !widget.post['isAnonymous']
                        ? InkWell(
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            child: Text(
                              widget.post['ownerFullName'],
                              style: TextStyle(
                                  fontSize: 14, fontFamily: 'Poppins-Black'),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileScreen(
                                            uid: widget.post['ownerID'],
                                          )));
                            },
                          )
                        : Text('-Anonymous',
                            style: TextStyle(
                                fontSize: 14, fontFamily: 'Poppins-Black')),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        widget.isInList
            ? Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostScreen(
                          post: widget.post,
                        )))
            : print('not inList');
      },
      child: AnimatedOpacity(
        opacity: _postOpacity,
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3),
          margin: EdgeInsets.only(bottom: 5),
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
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              child: Text(
                                widget.post['title'],
                                style: TextStyle(
                                    fontSize: 25, fontFamily: 'Poppins-Black'),
                              ),
                            ),
                            PopupMenuButton(
                              onSelected: (value) async {
                                String userID = await user.getCurrentUserID();
                                if (value == 'subscribe') {
                                  if (!widget.post.data['subscribers']
                                      .contains(userID)) {
                                    Firestore.instance
                                        .document(
                                            'Posts/' + widget.post.documentID)
                                        .updateData({
                                      "subscribers":
                                          FieldValue.arrayUnion([userID])
                                    });
                                  } else {
                                    print('AA');
                                    Firestore.instance
                                        .document(
                                            'Posts/' + widget.post.documentID)
                                        .updateData({
                                      "subscribers":
                                          FieldValue.arrayRemove([userID])
                                    });
                                  }
                                }
                              },
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    value: 'subscribe',
                                    child: FutureBuilder(
                                      future: user.getCurrentUserID(),
                                      builder: (context, userID) {
                                        return userID.connectionState ==
                                                ConnectionState.done
                                            ? Text(widget
                                                    .post.data['subscribers']
                                                    .contains(userID.data)
                                                ? 'Unsubscribe'
                                                : 'Subscribe')
                                            : Container();
                                      },
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'report',
                                    child: Text('Report'),
                                  )
                                ];
                              },
                            ),
                          ],
                        ),
                        Text(widget.post['content'],
                            style: TextStyle(fontSize: 20)),
                        footer(context)
                      ],
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
