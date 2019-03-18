import 'package:flutter/material.dart';
import '../User.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  final User user = new User();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        child: ListView(
          children: <Widget>[
            Text('Home'),
            RaisedButton(
              child: Text("Sign Out"),
              onPressed: () {
                user.signOut();
              },
            )
          ],
        ),
      ),
    );
  }
}
