import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../User.dart';
import 'package:uuid/uuid.dart';
import './commentWidget.dart';

var uuid = new Uuid();

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({Key key, @required this.postID}) : super(key: key);
  final String postID;
  @override
  State<StatefulWidget> createState() {
    return _CommentsScreenState();
  }
}

class _CommentsScreenState extends State<CommentsScreen> {
  final User user = new User();
  final TextEditingController _commentController = new TextEditingController();
  bool _isAnon = false;
  void _onChanged1(bool value) => setState(() => _isAnon = value);
  bool _isPosting = false;

  Future<void> shareComment() async {
    increaseCommentsCount().whenComplete(() async {
      try {
        String _commentID = uuid.v1();
        await Firestore.instance.runTransaction(
            (transaction) => _shareComment(transaction, _commentID));
      } catch (e) {
        print(e);
      }
    });
  }

  _shareComment(Transaction transaction, String _commentID) async {
    String ownerID = await user.getCurrentUserID();
    var ownerInfo = await user.getUserInfo(ownerID);
    await transaction
        .set(Firestore.instance.collection("Comments").document(_commentID), {
      'post': widget.postID,
      'comment': _commentController.text,
      'ownerID': ownerID,
      'ownerFullName': "${ownerInfo['firstName']} ${ownerInfo['lastName']}",
      'likes': [],
      'date': FieldValue.serverTimestamp(),
      'isAnonymous': _isAnon ? true : false,
    }).whenComplete(() {
      FocusScope.of(context).requestFocus(new FocusNode());
      _commentController.clear();
      setState(() {
        _isPosting = false;
      });
    });
  }

  Future<void> increaseCommentsCount() async {
    try {
      DocumentSnapshot postInfo =
          await Firestore.instance.document('Posts/' + widget.postID).get();
      await Firestore.instance
          .document('Posts/' + widget.postID)
          .updateData({'commentsCount': postInfo.data['commentsCount'] + 1});
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: FlatButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back),
        ),
        title: Text('Comments'),
      ),
      body: StreamBuilder(
        stream: Firestore.instance
            .collection('Comments')
            .where('post', isEqualTo: widget.postID)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? Column(
                  children: <Widget>[
                    _buildList(context, snapshot.data.documents),
                    Divider(),
                    ListTile(
                      title: new TextFormField(
                        controller: _commentController,
                        decoration: new InputDecoration(
                            labelText: 'Write a comment...'),
                      ),
                      trailing: Column(
                        children: <Widget>[
                          SizedBox(
                            width: 100,
                            child: Row(
                              children: <Widget>[
                                Icon(FontAwesomeIcons.userSecret),
                                Switch(value: _isAnon, onChanged: _onChanged1)
                              ],
                            ),
                          ),
                          FlatButton(
                            onPressed: () {
                              if (!_isPosting) {
                                setState(() {
                                  _isPosting = true;
                                });
                                shareComment();
                              }
                            },
                            child: new Text("Post"),
                          )
                        ],
                      ),
                    )
                  ],
                )
              : CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _buildList(BuildContext context, comments) {
    return Expanded(
      child: ListView.builder(
        reverse: true,
        physics: BouncingScrollPhysics(),
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Comment(
              comment: comments[index],
              postID: widget.postID);
        },
        itemCount: comments.length,
      ),
    );
  }
}
