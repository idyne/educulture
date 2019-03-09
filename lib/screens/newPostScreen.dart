import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../User.dart';

class NewPostScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NewPostScreenState();
  }
}

class _NewPostScreenState extends State<NewPostScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User user = new User();
  String title, content;
  bool _isAnon = false;
  void _onChanged1(bool value) => setState(() => _isAnon = value);

  Future<void> sharePost(title, content) async {
    try {
      await Firestore.instance.runTransaction(
          (transaction) => _sharePost(transaction, title, content));
    } catch (e) {
      print(e);
      return null;
    }
  }

  _sharePost(Transaction transaction, String title, String content) async {
    Map<dynamic, dynamic> userInfo =
        await user.getUserInfo(await user.getCurrentUserID());
    await transaction.set(Firestore.instance.collection("Posts").document(), {
      'title': title,
      'content': content,
      'ownerID': userInfo['uid'],
      'ownerFullName': "${userInfo['firstName']} ${userInfo['lastName']}",
      'isAnonymous': _isAnon ? true : false,
      'date': FieldValue.serverTimestamp(),
      'comments': [],
      'likes': [],
      'commentsCount': 0
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NotificationListener<OverscrollIndicatorNotification>(
        onNotification: (overscroll) {
          overscroll.disallowGlow();
        },
        child: ListView(
          children: <Widget>[
            new Center(
              child: Builder(
                builder: (context) => Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          TextFormField(
                            maxLength: 30,
                            decoration: InputDecoration(
                              labelText: 'Title',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a title';
                              }
                            },
                            onSaved: (val) => setState(() => title = val),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          TextFormField(
                            maxLength: 250,
                            decoration: InputDecoration(
                              labelText: 'Content',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your post content';
                              }
                            },
                            onSaved: (val) => setState(() => content = val),
                          ),
                          Row(
                            children: <Widget>[
                              Icon(FontAwesomeIcons.userSecret),
                              Switch(value: _isAnon, onChanged: _onChanged1)
                            ],
                          ),
                          RaisedButton(
                            onPressed: () {
                              final form = _formKey.currentState;
                              if (form.validate()) {
                                form.save();
                                sharePost(title, content);
                              }
                            },
                            child: Text('Share Post'),
                          ),
                        ],
                      ),
                    ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
