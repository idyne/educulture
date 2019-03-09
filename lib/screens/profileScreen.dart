import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterstudy/User.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

User user = new User();

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenStateState();
  }
}

class _ProfileScreenStateState extends State<ProfileScreen> {
  File sampleImage;

  Future getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      sampleImage = tempImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          sampleImage == null ? Text('Select an image') : enableUpload(),
          RaisedButton(
            child: Text('dada'),
            onPressed: getImage,
          )
        ],
      ),
    );
  }

  Widget enableUpload() {
    return Container(
      child: Column(
        children: <Widget>[
          Image.file(sampleImage, height: 300.0, width: 300.0),
          RaisedButton(
            elevation: 7.0,
            child: Text('Upload'),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: () async {
              final StorageReference firebaseStorageRef = FirebaseStorage
                  .instance
                  .ref()
                  .child(await user.getCurrentUserID());
              final StorageUploadTask task =
                  firebaseStorageRef.putFile(sampleImage);
            },
          )
        ],
      ),
    );
  }
}
