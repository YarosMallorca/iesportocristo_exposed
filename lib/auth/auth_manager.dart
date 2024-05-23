import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthManager extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;
  bool? get isAuthenticated => user != null;
  String? get uid => user?.uid;
  String? get name => user?.displayName?.split(" ")[0];

  Future<User?> signInWithGoogle() async {
    final db = FirebaseFirestore.instance;

    final GoogleSignIn googleSignIn = GoogleSignIn();
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      final docSnapshot = await db.collection('users').doc(user!.uid).get();
      if (docSnapshot.exists) {
        db.collection('users').doc(user.uid).update({
          'name': user.displayName,
        });
      } else {
        db.collection('users').doc(user.uid).set({
          'name': user.displayName,
          'photoURL': user.photoURL,
        });
      }

      notifyListeners();
      return user;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<void> changeProfilePhoto(Uint8List imageBytes) async {
    final db = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    final ref = storage.ref().child('profile_photos').child("${user!.uid}.jpg");
    await ref.putData(imageBytes, SettableMetadata(contentType: 'image/jpeg'));

    final url = await ref.getDownloadURL();
    await db.collection('users').doc(user!.uid).update({'photoURL': url});
    _auth.currentUser!.updatePhotoURL(url);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    notifyListeners();
  }

  Future<String?> getName([bool hideSurname = true]) async {
    if (user == null) {
      throw FirebaseException(
          plugin: "AuthManager", message: "User is not authenticated.");
    }
    return user!.displayName![0] +
        (hideSurname ? "" : user!.displayName!.split(" ")[1]);
  }

  Future<void> setNickname(String nickname) async {
    final db = FirebaseFirestore.instance;
    if (user == null) {
      throw FirebaseException(
          plugin: "AuthManager", message: "User is not authenticated.");
    }
    db.collection('users').doc(user!.uid).update({'nickname': nickname});
    notifyListeners();
  }

  Future<String?> getNickname() async {
    final db = FirebaseFirestore.instance;
    if (user == null) {
      throw FirebaseException(
          plugin: "AuthManager", message: "User is not authenticated.");
    }
    final doc = await db.collection('users').doc(user!.uid).get();
    return doc.data()?['nickname'];
  }

  Future<bool> checkIfUserExists(String uid) async {
    final db = FirebaseFirestore.instance;
    final doc = await db.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> setUserDescription(String? description) async {
    final db = FirebaseFirestore.instance;
    if (user == null) {
      throw FirebaseException(
          plugin: "AuthManager", message: "User is not authenticated.");
    }
    db.collection('users').doc(user!.uid).update({'description': description});
    notifyListeners();
  }

  Future<String?> getUserDescription() async {
    final db = FirebaseFirestore.instance;
    if (user == null) {
      throw FirebaseException(
          plugin: "AuthManager", message: "User is not authenticated.");
    }
    final doc = await db.collection('users').doc(user!.uid).get();
    return doc.data()?['description'];
  }

  Future<void> deleteAccount() async {
    if (user == null) {
      throw FirebaseException(
          plugin: "AuthManager", message: "User is not authenticated.");
    }
    await user!.delete();
    notifyListeners();
  }
}
