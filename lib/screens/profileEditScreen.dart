import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterstudy/User.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toast/toast.dart';
import './diagonally_cut_colored_image.dart';
import 'package:image_crop/image_crop.dart';
import '../loaders/color_loader_2.dart';
import 'dart:io';

User user = new User();

class ProfileEditScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileEditScreenStateState();
  }
}

class _ProfileEditScreenStateState extends State<ProfileEditScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  static const BACKGROUND_IMAGE = 'assets/images/cats.jpeg';
  File sampleImage;
  final cropKey = GlobalKey<CropState>();
  File croppedFile;
  String aboutUser, department;
  bool _isSavingPicture = false, _isSavingForm = false;
  Future crop() async {
    try {
      final crop = cropKey.currentState;
      final sampledFile = await ImageCrop.sampleImage(
        file: sampleImage,
        preferredWidth: (1024 / crop.scale).round(),
        preferredHeight: (4096 / crop.scale).round(),
      );
      croppedFile = await ImageCrop.cropImage(
        file: sampledFile,
        area: crop.area,
      );
      setState(() {});
    } catch (e) {
      print(e.message);
    }
  }

  Future<String> _getProfilePicture(profilePictureID) async {
    try {
      final StorageReference firebaseStorageRef =
          FirebaseStorage.instance.ref().child(profilePictureID);
      String profilePictureURL = await firebaseStorageRef.getDownloadURL();
      return profilePictureURL;
    } catch (e) {
      print(e.message);
      return 'https://pbs.twimg.com/profile_images/1081248660111982593/AIzeZIts_400x400.jpg';
    }
  }

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

  Widget _buildCropImage() {
    return Container(
      color: Colors.black,
      width: 400,
      height: 400,
      padding: const EdgeInsets.all(20.0),
      child: Crop(
        key: cropKey,
        image: FileImage(sampleImage),
        aspectRatio: 1,
      ),
    );
  }

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildCropImage(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                sampleImage == null
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        child: Text('Save'),
                        onPressed: () async {
                          if (!_isSavingPicture) {
                            setState(() {
                              _isSavingPicture = true;
                            });
                            Toast.show("Updating...", context, duration: 5);
                            Navigator.pop(context);
                            await crop();
                            uploadPicture();
                            setState(() {
                              _isSavingPicture = false;
                              sampleImage = null;
                            });
                          }
                        },
                      ),
              ],
            )
          ],
        );
      },
    );
  }

  Widget _buildAvatar(String profilePictureURL) {
    return CircleAvatar(
      backgroundColor: Colors.grey,
      backgroundImage: CachedNetworkImageProvider(profilePictureURL),
      radius: 50.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
            child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: FutureBuilder(
                  future: user.getUserInfo(null),
                  builder: (context, snapshot) {
                    return snapshot.hasData
                        ? SafeArea(
                            child: Container(
                              color: Color(0x44FF5722),
                              child: Stack(
                                children: <Widget>[
                                  _buildDiagonalImageBackground(context),
                                  new Container(
                                    alignment: FractionalOffset.topCenter,
                                    margin: EdgeInsets.only(top: 45),
                                    child: new Column(
                                      children: <Widget>[
                                        _buildAvatar(snapshot.data[
                                                    'profilePictureURL'] !=
                                                null
                                            ? snapshot.data['profilePictureURL']
                                            : ''),
                                        RaisedButton(
                                          child: Text('Change Picture'),
                                          onPressed: () async {
                                            await getImage();
                                            _showDialog();
                                          },
                                        ),
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
                                          margin: EdgeInsets.only(top: 50),
                                          padding: EdgeInsets.all(10),
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              children: <Widget>[
                                                TextFormField(
                                                  initialValue: snapshot
                                                      .data['aboutUser'],
                                                  decoration: InputDecoration(
                                                    labelText: 'About You',
                                                  ),
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'There must be something about you';
                                                    }
                                                  },
                                                  onSaved: (val) => setState(
                                                      () => aboutUser = val),
                                                ),
                                                TextFormField(
                                                  initialValue: snapshot
                                                      .data['department'],
                                                  decoration: InputDecoration(
                                                    labelText: 'Department',
                                                  ),
                                                  validator: (value) {
                                                    if (value.isEmpty) {
                                                      return 'You must state your department';
                                                    }
                                                  },
                                                  onSaved: (val) => setState(
                                                      () => department = val),
                                                ),
                                                RaisedButton(
                                                  child: Text('Save'),
                                                  onPressed: () async {
                                                    if (!_isSavingForm) {
                                                      setState(() {
                                                        _isSavingForm = true;
                                                      });
                                                      final form =
                                                          _formKey.currentState;
                                                      if (form.validate()) {
                                                        form.save();
                                                      }
                                                      await user.updateUser(
                                                          aboutUser,
                                                          department);
                                                      setState(() {
                                                        _isSavingForm = false;
                                                      });
                                                      Toast.show(
                                                          "Profile saved",
                                                          context,
                                                          duration: 3);
                                                    }
                                                  },
                                                ),
                                                RaisedButton(
                                                  child: Text("Sign Out"),
                                                  onPressed: () {
                                                    user.signOut();
                                                  },
                                                )
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Positioned(
                                    top: 26.0,
                                    left: 4.0,
                                    child: new BackButton(color: Colors.white),
                                  ),
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
                )));
      }),
    );
  }

  void uploadPicture() async {
    var path = croppedFile.path.split('/');
    var profilePictureID = path[path.length - 1].substring(11);
    final StorageReference firebaseStorageRef =
        FirebaseStorage.instance.ref().child(profilePictureID);
    final StorageUploadTask uploadTask =
        firebaseStorageRef.putFile(croppedFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String profilePictureURL = await storageTaskSnapshot.ref.getDownloadURL();
    try {
      await Firestore.instance
          .collection('Users')
          .where('uid', isEqualTo: await user.getCurrentUserID())
          .getDocuments()
          .then((onValue) async {
        await onValue.documents[0].reference.updateData({
          'profilePictureID': profilePictureID,
          'profilePictureURL': profilePictureURL
        });
        print('updated');
        Toast.show("Profile picture updated", context, duration: 3);
      });
    } catch (e) {
      print(e.message);
    }
  }
}
