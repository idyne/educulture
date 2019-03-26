import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../loaders/color_loader_2.dart';
import 'package:uuid/uuid.dart';
import './postWidget.dart';
import './commentWidget.dart';
import '../User.dart';

var uuid = new Uuid();

class PostScreen extends StatefulWidget {
  const PostScreen({Key key, @required this.post}) : super(key: key);
  final DocumentSnapshot post;
  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final User user = new User();
  final TextEditingController _commentController = new TextEditingController();
  bool _isAnon = false;
  void _onChanged1(bool value) => setState(() => _isAnon = value);
  bool _isPosting = false;
  Stream<void> getComments;

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
      'post': widget.post.documentID,
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
      DocumentSnapshot postInfo = await Firestore.instance
          .document('Posts/' + widget.post.documentID)
          .get();
      await Firestore.instance
          .document('Posts/' + widget.post.documentID)
          .updateData({'commentsCount': postInfo.data['commentsCount'] + 1});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getComments = Firestore.instance
                      .collection('Comments')
                      .where('post', isEqualTo: widget.post.documentID)
                      .orderBy('date', descending: true)
                      .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(resizeToAvoidBottomInset: true, resizeToAvoidBottomPadding: true, body: SafeArea(
      child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
            child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxHeight: viewportConstraints.maxHeight),
                child: StreamBuilder(
                  stream: getComments,
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    return snapshot.hasData
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Post(
                                post: widget.post,
                                isInList: false,
                              ),
                              _buildList(context, snapshot.data.documents),
                              Divider(),
                              ListTile(
                                dense: true,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 5),
                                title: new TextFormField(
                                  autocorrect: true,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  keyboardType: TextInputType.text,
                                  controller: _commentController,
                                  decoration: new InputDecoration(
                                    hintText: 'Write a comment...',
                                    icon: Icon(FontAwesomeIcons.comment),
                                    border: InputBorder.none,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Switch(
                                      inactiveThumbImage: AssetImage(
                                          'assets/images/anonymous_inactive.png'),
                                      activeThumbImage: AssetImage(
                                          'assets/images/anonymous_active.png'),
                                      value: _isAnon,
                                      onChanged: _onChanged1,
                                      activeColor: Colors.deepOrange,
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
                                      child: Text(
                                        'Share',
                                        style: TextStyle(
                                            fontFamily: 'Poppins-Medium'),
                                      ),
                                    )
                                  ],
                                ),
                              )
                            ],
                          )
                        : Align(
                            alignment: AlignmentDirectional.center,
                            child: ColorLoader2(
                              color1: Colors.purple,
                              color2: Colors.deepPurple,
                              color3: Colors.blue,
                            ),
                          );
                  },
                )));
      }),
    ));
  }

  Widget _buildList(BuildContext context, comments) {
    return Expanded(
        child: NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowGlow();
      },
      child: ListView.builder(
        reverse: true,
        itemBuilder: (BuildContext context, int index) {
          return Comment(
              comment: comments[index], postID: widget.post.documentID);
        },
        itemCount: comments.length,
      ),
    ));
  }
}
