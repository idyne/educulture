import 'package:flutter/material.dart';
import './screens/signinScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screens/splashScreen.dart';
import './screens/mainScreen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Anonymous Chat',
      theme: ThemeData(
          fontFamily: 'Poppins-Light',
          primaryColor: Colors.deepOrange,
          scaffoldBackgroundColor: Colors.white),
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        body: _handleCurrentScreen(),
      ),
    );
  }

  Widget _handleCurrentScreen() {
    return new StreamBuilder<FirebaseUser>(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return new SplashScreen();
          } else {
            if (snapshot.hasData) {
              if (!snapshot.data.isEmailVerified) {
                return Container(
                  child: SignInScreen(
                    isLoggedInButNotVerified: true,
                  ),
                );
              }
              return MainScreen();
            }
            return Container(
              child: SignInScreen(
                isLoggedInButNotVerified: false,
              ),
            );
          }
        });
  }
}
