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
    return SafeArea(
      child: Container(
        width: MediaQuery.of(context).size.width,
        color: Color(0xC4FF5722),
        child: Column(
          children: <Widget>[
            Text('Home', style: TextStyle(fontSize: 30, color: Colors.white),),
          ],
        ),
      ),
    );
  }
}
