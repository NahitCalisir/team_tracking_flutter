import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/ui/views/bottom_navigation_bar.dart';
import 'package:team_tracking/ui/views/login_screen/login_screen.dart';
import 'package:image/image.dart' as img;

import '../entity/users.dart';

class TeamTrackingDaoRepository {

  static TeamTrackingDaoRepository shared = TeamTrackingDaoRepository();

  //Dikkat: firestore kullanırken arayüzde veri güncelleme yapan metodları
  // (kisileriYukle ve kisiAra gibi) repoda yapıp return edemiyoruz.
  // Direk anasayfa_cubit içerisinde bu metodları yazıyoruz.



  final userCollection = FirebaseFirestore.instance.collection("users");
  final groupCollection = FirebaseFirestore.instance.collection("groups");
  final firebaseAuth = FirebaseAuth.instance;

  //TODO: Sign up with email and password
  Future<void> signUp(BuildContext context, {required String name, required String email, required String password}) async {
    try {
      final UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await handleUserSignIn(context, userCredential);
      await _registerUser(
        uid: userCredential.user!.uid,
        name: userCredential.user!.displayName ?? "",
        email: userCredential.user!.email ?? "",
        photoUrl: userCredential.user!.photoURL ?? "",
      );
    } on FirebaseAuthException catch (e) {
      handleAuthException(context, e);
    } catch (e) {
      // Diğer hatalar
    }
  }

  //TODO: Sign in with email and password
  Future<void> signIn(BuildContext context, {required String email, required String password}) async {
    try {
      final UserCredential userCredential = await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      await handleUserSignIn(context, userCredential);
    } on FirebaseAuthException catch (e) {
      handleAuthException(context, e);
    } catch (e) {
      // Diğer hatalar
    }
  }

  //TODO: Handle Mettods for sig in and sign up
  Future<void> handleUserSignIn(BuildContext context, UserCredential userCredential) async {
    if (userCredential.user != null) {
      Map<String, dynamic>? userData = await getUserData();
      if (userData != null) {
        Users curentUser = await Users.fromMap(userCredential.user!.uid, userData);
        await UsersManager().setUser(curentUser);
      }
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => BottomNavigationBarPage(),));
    }
  }
  void handleAuthException(BuildContext context, FirebaseAuthException e) {
    Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
  }


  //TODO: Sign In with Google account
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
      if (userCredential.user != null) {
        Map<String, dynamic>? userData = await getUserData();
        if(userData != null){
          Users curentUser = await Users.fromMap(userCredential.user!.uid, userData);
          await UsersManager().setUser(curentUser);
        }
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => BottomNavigationBarPage(),));
      }
    }
    return userCredential.user;
  }

  //TODO: Sign Out Method
  Future<void> signOut(BuildContext context) async {
    final navigator = Navigator.of(context);
    try {
      await firebaseAuth.signOut();
      navigator.push(MaterialPageRoute(builder: (context) => const LoginScreen()));
    } on FirebaseAuthException catch(e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }

  //TODO: Get User Data
  Future<Map<String, dynamic>?> getUserData() async {
    final _auth = await FirebaseAuth.instance;
    final currentUser = await _auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection("users").doc(currentUser.uid).get();
      if (snapshot.exists) {
        String id = snapshot.id;
        Map<String, dynamic>? userData = snapshot.data();
        return userData;
      } else {
        // Kullanıcı bulundu, ancak veri bulunamadı.
        return null;
      }
    } else {
      // Kullanıcı bulunamadı.
      return null;
    }
  }


  //TODO Register user to firestore
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
      "groups": {""},
    };
    await userCollection.doc(uid).set(newUser);
  }

  //TODO Register Group to the firestore
  Future<void> registerGroup(
      {
        required String name,
        required String city,
        required String country,
        required String owner,
        required List<String> memberIds,
        String? photoUrl
      }) async {
    var newGroup = {
      "name": name,
      "city": city,
      "country": country,
      "owner": owner,
      "memberIds": memberIds,
      "photoUrl": photoUrl,
    };
    await groupCollection.doc().set(newGroup);
  }

  Future<void> saveGroup(BuildContext context, String name, String city, String country, File? _groupImage) async {

    if(name.isEmpty || city.isEmpty || country.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text("Please fill in all fields"),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    } else {

      // TODO: Upload group image
      if (_groupImage != null) {
        String imageUrl = await TeamTrackingDaoRepository.shared.uploadGroupImage(_groupImage!);
        if (imageUrl.isNotEmpty) {
          // If the image upload is successful, set the imageUrl to the group
          //photoUrl = imageUrl;
        }
        // TODO: Register group to firestore
        String owner = UsersManager().currentUser!.name;
        List<String> memberIds = [UsersManager().currentUser!.id];
        TeamTrackingDaoRepository.shared.registerGroup(
          name: name,
          city: city,
          country: country,
          owner:  owner,
          memberIds: memberIds,
          photoUrl: imageUrl,
        );
        // After the group is saved, navigate back to the GroupsScreen
        Navigator.pop(context);
      }
    }

  }


  //TODO: Upload Group image to firebase storage
  Future<String> uploadGroupImage(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'group_images/$userId/$timestamp.jpeg';

      // Upload the resized image to Firebase Storage
      //File resizedImageFile = await resizeImage(imageFile, 200, 200);
      await FirebaseStorage.instance.ref(fileName).putFile(imageFile);

      // Get the download URL of the uploaded image
      String imageUrl = await FirebaseStorage.instance.ref(fileName).getDownloadURL();

      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }

  //TODO: Upload User profile image to firebase storage
 //Future<String> uploadUserImage(File imageFile) async {
 //  try {
 //    String userId = FirebaseAuth.instance.currentUser!.uid;
 //    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
 //    String fileName = 'user_images/$userId/$timestamp.jpeg';

 //    // Upload the resized image to Firebase Storage
 //    //File resizedImageFile = await resizeImage(imageFile, 200, 200);
 //    await FirebaseStorage.instance.ref(fileName).putFile(imageFile);

 //    // Get the download URL of the uploaded image
 //    String imageUrl = await FirebaseStorage.instance.ref(fileName).getDownloadURL();

 //    return imageUrl;
 //  } catch (e) {
 //    print("Error uploading image: $e");
 //    return "";
 //  }
 //}


  //Future<File> resizeImage(File imageFile, double width, double height) async {
  //  // Dosyayı oku ve image paketini kullanarak image nesnesine dönüştür
  //  List<int> imageBytes = await imageFile.readAsBytes();
  //  img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;
//
  //  // Belirli genişlik ve yüksekliğe boyutlandır
  //  img.Image resizedImage = img.copyResize(image, width: width.toInt(), height: height.toInt());
//
  //  // Boyutlandırılmış resmi bir File nesnesine dönüştür
  //  File resultFile = await File(imageFile.path)
  //    ..writeAsBytesSync(Uint8List.fromList(img.encodePng(resizedImage)!));
//
  //  return resultFile;
  //}




}

