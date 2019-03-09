import 'package:flutter/material.dart';
import '../User.dart';

class SignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignInState();
  }
}

class _SignInState extends State<SignIn> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  User _user = new User();
  String emailAddress, username, password;

  @override
  Widget build(BuildContext context) {
    return _signInForm(context);
  }

  Widget _signInForm(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sign In"),
      ),
      resizeToAvoidBottomPadding: false,
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
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter an email address';
                              }
                            },
                            onSaved: (val) =>
                                setState(() => emailAddress = val),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a password';
                              }
                            },
                            onSaved: (val) =>
                                setState(() => password = val),
                            obscureText: true,
                          ),
                          RaisedButton(
                            onPressed: () {
                              final form = _formKey.currentState;
                              if (form.validate()) {
                                form.save();
                                _user.signIn(emailAddress, password);
                              }
                            },
                            child: Text('Sign In'),
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
