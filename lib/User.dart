import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class User {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<Map> getUserInfo(String uid) async {
    var userInfo = await Firestore()
        .collection('Users')
        .where('uid',
            isEqualTo: uid != null ? uid : await this.getCurrentUserID())
        .getDocuments();
    return userInfo.documents.last.data;
  }

  Future<Map<String, dynamic>> signUp(String firstName, String lastName,
      String emailAddress, String password) async {
    try {
      print(emailAddress.split('@'));
      if (emailAddress.endsWith('.edu.tr')) {
        return {
          'success': false,
          'errorMessage': 'Your email domain must be educational',
          'error': true,
          'uid': null
        };
      }
    } catch (e) {
      print(e.message);
    }
    try {
      FirebaseUser user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailAddress, password: password);
      await Firestore.instance.runTransaction((transaction) =>
          _signUp(transaction, firstName, lastName, emailAddress, user.uid));
      await user.sendEmailVerification();
      return {
        'success': true,
        'errorMessage': null,
        'error': false,
        'uid': user.uid
      };
    } catch (e) {
      print(e.message);
      return {
        'success': false,
        'errorMessage': e.message,
        'error': true,
        'uid': null
      };
    }
  }

  _signUp(Transaction transaction, String firstName, String lastName,
      String emailAddress, String uid) async {
    await transaction.set(Firestore.instance.collection("Users").document(), {
      'firstName': firstName,
      'lastName': lastName,
      'emailAddress': emailAddress,
      'uid': uid,
      'signUpDate': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateUser(aboutUser, department) async {
    try {
      await Firestore.instance
          .collection('Users')
          .where('uid', isEqualTo: await this.getCurrentUserID())
          .getDocuments()
          .then((onValue) async {
        await onValue.documents[0].reference
            .updateData({'aboutUser': aboutUser, 'department': department});
        print('updated');
      });
    } catch (e) {
      print(e.message);
    }
  }

  Future<Map<String, dynamic>> signIn(emailAddress, password) async {
    try {
      FirebaseUser user = await _firebaseAuth.signInWithEmailAndPassword(
          email: emailAddress, password: password);

      return {
        'success': true,
        'errorMessage': null,
        'error': false,
        'uid': user.uid,
      };
    } catch (e) {
      print(e.message);
      String _errorMessage;
      switch (e.message) {
        case 'There is no user record corresponding to this identifier. The user may have been deleted.':
          _errorMessage = 'User not found';
          break;
        case 'The password is invalid or the user does not have a password.':
          _errorMessage = 'Invalid password';
          break;
        default:
          _errorMessage = e.message;
      }
      return {
        'success': false,
        'errorMessage': _errorMessage,
        'error': true,
        'uid': null,
      };
    }
  }

  Future<String> getCurrentUserID() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }
}
