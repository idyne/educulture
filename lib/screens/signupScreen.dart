import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../User.dart';
import '../loaders/color_loader_4.dart';

User user = new User();

class SignUpScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SignUpState();
  }
}

class _SignUpState extends State<SignUpScreen> {
  final Color primaryColor = Colors.deepOrange;
  final Color backgroundColor = Colors.black12;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String firstName, lastName, emailAddress, password, passwordCheck;

  signUp() async {
    setState(() {
      _isLoading = true;
    });
    final form = _formKey.currentState;
    Map<String, dynamic> result;
    if (form.validate()) {
      form.save();
      result = await user.signUp(firstName, lastName, emailAddress, password);
    }
    setState(() {
      _isLoading = false;
    });
    if (result['success']) {
      Navigator.of(context).pop();
    }
    if (result['error']) {
      Toast.show(result['errorMessage'], context,
           duration: 3);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints:
                  BoxConstraints(minHeight: viewportConstraints.maxHeight),
              child: Container(
                decoration: BoxDecoration(
                  color: this.backgroundColor,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      new ClipPath(
                        clipper: MyClipper(),
                        child: Container(
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                              image:
                                  new ExactAssetImage('assets/images/logo.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                          alignment: Alignment.center,
                          padding: EdgeInsets.only(top: 150.0, bottom: 75.0),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "EduCulture",
                                style: TextStyle(
                                    fontSize: 50.0,
                                    fontWeight: FontWeight.bold,
                                    color: this.primaryColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Text(
                          "First Name",
                          style: TextStyle(color: Colors.grey, fontSize: 16.0),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Row(
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              child: Icon(
                                Icons.lock_open,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              height: 30.0,
                              width: 1.0,
                              color: Colors.grey.withOpacity(0.5),
                              margin: const EdgeInsets.only(
                                  left: 00.0, right: 10.0),
                            ),
                            new Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your first name',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your first name';
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => firstName = val),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Text(
                          "Last Name",
                          style: TextStyle(color: Colors.grey, fontSize: 16.0),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Row(
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              child: Icon(
                                Icons.lock_open,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              height: 30.0,
                              width: 1.0,
                              color: Colors.grey.withOpacity(0.5),
                              margin: const EdgeInsets.only(
                                  left: 00.0, right: 10.0),
                            ),
                            new Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your last name',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your last name';
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => lastName = val),
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Text(
                          "Email",
                          style: TextStyle(color: Colors.grey, fontSize: 16.0),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Row(
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              child: Icon(
                                Icons.person_outline,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              height: 30.0,
                              width: 1.0,
                              color: Colors.grey.withOpacity(0.5),
                              margin: const EdgeInsets.only(
                                  left: 00.0, right: 10.0),
                            ),
                            new Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your email',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter your email address';
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => emailAddress = val),
                                keyboardType: TextInputType.emailAddress,
                              ),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Text(
                          "Password",
                          style: TextStyle(color: Colors.grey, fontSize: 16.0),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Row(
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              child: Icon(
                                Icons.lock_open,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              height: 30.0,
                              width: 1.0,
                              color: Colors.grey.withOpacity(0.5),
                              margin: const EdgeInsets.only(
                                  left: 00.0, right: 10.0),
                            ),
                            new Expanded(
                              child: TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your password',
                                  hintStyle: TextStyle(color: Colors.grey),
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
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 40.0),
                        child: Text(
                          "Password Check",
                          style: TextStyle(color: Colors.grey, fontSize: 16.0),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        margin: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        child: Row(
                          children: <Widget>[
                            new Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              child: Icon(
                                Icons.lock_open,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              height: 30.0,
                              width: 1.0,
                              color: Colors.grey.withOpacity(0.5),
                              margin: const EdgeInsets.only(
                                  left: 00.0, right: 10.0),
                            ),
                            new Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Enter your password again',
                                  hintStyle: TextStyle(color: Colors.grey),
                                ),
                                validator: (value) {
                                  if (value != _passwordController.text) {
                                    return 'Passwords do not match';
                                  }
                                },
                                onSaved: (val) =>
                                    setState(() => passwordCheck = val),
                                obscureText: true,
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: new Row(
                          children: <Widget>[
                            new Expanded(
                              child: FlatButton(
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(30.0)),
                                splashColor: this.primaryColor,
                                color: this.primaryColor,
                                child: new Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: !_isLoading
                                      ? <Widget>[
                                          new Padding(
                                            padding: const EdgeInsets.only(
                                                left: 20.0),
                                            child: Text(
                                              "SIGN UP",
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                          new Expanded(
                                            child: Container(),
                                          ),
                                          new Transform.translate(
                                            offset: Offset(15.0, 0.0),
                                            child: new Container(
                                              padding:
                                                  const EdgeInsets.all(5.0),
                                              child: FlatButton(
                                                shape:
                                                    new RoundedRectangleBorder(
                                                        borderRadius:
                                                            new BorderRadius
                                                                    .circular(
                                                                28.0)),
                                                splashColor: Colors.white,
                                                color: Colors.white,
                                                child: Icon(
                                                  Icons.arrow_forward,
                                                  color: this.primaryColor,
                                                ),
                                                onPressed: () => {},
                                              ),
                                            ),
                                          )
                                        ]
                                      : <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(24.0),
                                            child: Row(
                                              children: <Widget>[
                                                ColorLoader4(
                                                  dotOneColor: Colors.white,
                                                  dotTwoColor: Colors.black,
                                                  dotThreeColor: Colors.grey,
                                                )
                                              ],
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                            ),
                                          )
                                        ],
                                ),
                                onPressed: () {
                                  if (!_isLoading) signUp();
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = new Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height * 0.85);
    p.arcToPoint(
      Offset(0.0, size.height * 0.85),
      radius: const Radius.elliptical(50.0, 10.0),
      rotation: 0.0,
    );
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}
