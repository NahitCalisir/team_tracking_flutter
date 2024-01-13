import 'dart:collection';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_tracking/ui/views/bottom_navigation_bar.dart';

class TeamTrackingDaoRepository {

  static TeamTrackingDaoRepository shared = TeamTrackingDaoRepository();

  //Dikkat: firestore kullanırken arayüzde veri güncelleme yapan metodları
  // (kisileriYukle ve kisiAra gibi) repoda yapıp return edemiyoruz.
  // Direk anasayfa_cubit içerisinde bu metodları yazıyoruz.

  final userCollection = FirebaseFirestore.instance.collection("users");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> signUp(BuildContext context, {required String name, required String email, required String password}) async {
    try {
      final UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        await _registerUser(uid: userCredential.user!.uid, name: name, email: email, photoUrl: "",);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => BottomNavigationBarPage(),));
      }
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }

  Future<void> _registerUser({required String uid, required String name, required String email, required String photoUrl}) async {
    var newUser = {
      "name": name,
      "email": email,
      "photoUrl": photoUrl,
      "city": "",
      "lastLocation": {
        "latitude": 0.0,
        "longitude": 0.0,
      },
      "groups": {},
    };
    await userCollection.doc(uid).set(newUser);
  }

  Future<void> signIn(BuildContext context, {required String email, required String password}) async {
    final navigator = Navigator.of(context);
    try {
      final UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (userCredential.user != null) {
        navigator.push(MaterialPageRoute(builder: (context) => BottomNavigationBarPage(),));
      }
    } on FirebaseAuthException catch(e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }



  Future<User?> signInWithGoogle(BuildContext context,) async {
    // Oturum açma sürecini başlat
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    // Süreç içerisinden bilgileri al
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    // Kullanıcı nesnesi oluştur
    final credential = GoogleAuthProvider.credential(accessToken: gAuth.accessToken, idToken: gAuth.idToken);

    // Kullanıcı girişini sağla
    final UserCredential userCredential = await firebaseAuth.signInWithCredential(credential);
    log(userCredential.user!.email.toString());

    if (userCredential.user != null) {
      await _registerUser(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? "",
        email: userCredential.user!.email ?? "",
        photoUrl: userCredential.user!.photoURL ?? "",
      );
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => BottomNavigationBarPage()));
    }
    return userCredential.user;
  }

}

