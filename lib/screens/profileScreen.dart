import 'package:flutter/material.dart';
import 'package:flutterstudy/User.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'diagonally_cut_colored_image.dart';
import '../loaders/color_loader_2.dart';
import './profileEditScreen.dart';

User user = new User();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key key, @required this.uid}) : super(key: key);
  final uid;
  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenStateState();
  }
}

class _ProfileScreenStateState extends State<ProfileScreen> {
  static const BACKGROUND_IMAGE = 'assets/images/cats.jpeg';

  @override
  void initState() {
    super.initState();
  }

  Widget _buildDiagonalImageBackground(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return new DiagonallyCutColoredImage(
      new Image.asset(
        BACKGROUND_IMAGE,
        width: screenWidth,
        height: 280.0,
        fit: BoxFit.cover,
      ),
      color: const Color(0x88FF5722),
    );
  }

  Widget _buildAvatar(String profilePictureURL) {
    return CircleAvatar(
      backgroundColor: Colors.grey,
      backgroundImage: new CachedNetworkImageProvider(profilePictureURL != ''
          ? profilePictureURL
          : "https://pbs.twimg.com/profile_images/906153817821106177/mhzMfGtv.jpg"),
      radius: 50.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: user.getUserInfo(widget.uid),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? SafeArea(
                  child: Container(
                    color: Color(0x44FF5722),
                    child: Stack(
                      children: <Widget>[
                        _buildDiagonalImageBackground(context),
                        widget.uid == null
                            ? Align(
                                alignment: AlignmentDirectional.topEnd,
                                child: IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.cog,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ProfileEditScreen()));
                                  },
                                ),
                              )
                            : Container(),
                        new Container(
                          alignment: FractionalOffset.topCenter,
                          margin: EdgeInsets.only(top: 65),
                          child: new Column(
                            children: <Widget>[
                              _buildAvatar(
                                  snapshot.data['profilePictureURL'] != null
                                      ? snapshot.data['profilePictureURL']
                                      : ''),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                child: Text(
                                  "${snapshot.data['firstName']} ${snapshot.data['lastName']}",
                                  style: TextStyle(
                                      fontFamily: 'Poppins-Medium',
                                      fontSize: 20,
                                      color: Colors.white),
                                ),
                              ),
                              Container(
                                alignment: AlignmentDirectional.topStart,
                                margin: EdgeInsets.only(top: 90),
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(bottom: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          snapshot.data['aboutUser'] != null
                                              ? Text(
                                                  'About Me',
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      color: Colors.black),
                                                )
                                              : Container(),
                                          snapshot.data['aboutUser'] != null
                                              ? Padding(
                                                  padding:
                                                      EdgeInsets.only(left: 5),
                                                  child: Text(
                                                    snapshot.data['aboutUser'],
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.black),
                                                  ),
                                                )
                                              : Container()
                                        ],
                                      ),
                                    ),
                                    snapshot.data['department'] != null
                                        ? Text(
                                            'Department',
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black),
                                          )
                                        : Container(),
                                    snapshot.data['department'] != null
                                        ? Padding(
                                            padding: EdgeInsets.only(left: 5),
                                            child: Text(
                                              snapshot.data['department'],
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.black),
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                        widget.uid != null
                            ? Positioned(
                                top: 26.0,
                                left: 4.0,
                                child: new BackButton(color: Colors.white),
                              )
                            : Container(),
                      ],
                    ),
                  ),
                )
              : Container(
                  color: Colors.deepOrange,
                  child: Align(
                    alignment: AlignmentDirectional.center,
                    child: ColorLoader2(
                      color1: Colors.purple,
                      color2: Colors.deepPurple,
                      color3: Colors.blue,
                    ),
                  ),
                );
        },
      ),
    );
  }
}
