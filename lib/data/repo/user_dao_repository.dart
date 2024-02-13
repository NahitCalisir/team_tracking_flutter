import 'dart:async';
import 'dart:developer';
import 'dart:ffi';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:latlong2/latlong.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/ui/views/homepage/homepage.dart';
import 'package:team_tracking/main.dart';
import 'package:team_tracking/utils/constants.dart';
import 'package:team_tracking/data/repo/helper_functions.dart';
import '../entity/users.dart';

class UserDaoRepository {

  static UserDaoRepository shared = UserDaoRepository();

  final userCollection = FirebaseFirestore.instance.collection("users");
  final groupCollection = FirebaseFirestore.instance.collection("groups");
  final firebaseAuth = FirebaseAuth.instance;
  double _lastSpeed = 0;

  //TODO: Sign up with email and password
  Future<void> signUp(BuildContext context, {required String name, required String email, required String password}) async {
    try {
      final UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      LatLng position = await getLocation();
      await _registerUser(
        uid: userCredential.user!.uid,
        name: name ?? "unnamed",
        email: email,
        photoUrl: "",
        position: LatLng(position.latitude, position.longitude),
      );
      await handleUserSignIn(context, userCredential);
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
      if(userCredential.user != null){
        await updateUserLocation(userId: userCredential.user!.uid);
      }
    } on FirebaseAuthException catch (e) {
      handleAuthException(context, e);
    } catch (e) {
      print(e);
    }
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        // Kullanıcı işlemi iptal etti.
        return null;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        // Yeni kaydedilen kullanıcı
        log("New user signed in with Google: ${userCredential.user?.displayName}");

        // Yeni kullanıcıya dair işlemleri burada yapabilirsiniz.
        LatLng position = await getLocation();
        await _registerUser(
          uid: userCredential.user!.uid,
          name: userCredential.user!.displayName ?? "unnamed",
          email: userCredential.user!.email ?? "noEmail",
          photoUrl: "",
          position: LatLng(position.latitude, position.longitude),
        );
      } else {
        // Zaten kayıtlı olan kullanıcı
        log("Existing user signed in with Google: ${userCredential.user?.displayName}");
      }

      // Kullanıcı girişini handle et
      await handleUserSignIn(context, userCredential);

      return userCredential.user;
    } catch (e) {
      // Hata durumunda handle et
      print("Error signing in with Google: $e");
      //handleAuthException(context, e);
      return null;
    }
  }

  //TODO: Handle Mettods for sig in and sign up
  Future<void> handleUserSignIn(BuildContext context, UserCredential userCredential) async {
    if (userCredential.user != null) {
      Map<String, dynamic>? userData = await getUserData();
      if (userData != null) {
        Users curentUser = Users.fromMap(userCredential.user!.uid, userData);
        await UsersManager().setUser(curentUser);
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Homepage(),));
      }
    } else {
      print(" kullanıcı bilgisi alnımadı ve set edilemedi");
    }
  }
  void handleAuthException(BuildContext context, FirebaseAuthException e) {
    Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
  }

  //TODO: Sign Out Method
  Future<void> signOut(BuildContext context) async {
    try {
      _updateMyLocationTimer?.cancel();//konum göndermeyi durdur
      await firebaseAuth.signOut();
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyApp()));
    } on FirebaseAuthException catch(e) {
      Fluttertoast.showToast(msg: e.message!, toastLength: Toast.LENGTH_LONG);
    }
  }

  //Forgot password method
  Future<void> forgotPassword(BuildContext context, {required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast
        (msg: "Şifre sıfırlama e-postası gönderildi. Lütfen e-postanızı kontrol edin.",
        toastLength: Toast.LENGTH_LONG,
      );
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Şifre sıfırlama e-postası gönderilemedi. Lütfen tekrar deneyin.",
        toastLength:  Toast.LENGTH_LONG,
      );
      print("Error sending password reset email: $e");
    }
  }


  //TODO: Get User Data
  Future<Map<String, dynamic>?> getUserData() async {
    final auth = FirebaseAuth.instance;
    final currentUser = auth.currentUser;
    if (currentUser != null) {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection("users").doc(currentUser.uid).get();
      if (snapshot.exists) {
        String id = snapshot.id;
        Map<String, dynamic>? userData = snapshot.data();
        print("Current User data firebaseden çekildi");
        return userData;
      } else {
        // Kullanıcı bulundu, ancak veri bulunamadı.
        print("Kullanıcı bulundu, ancak veri bulunamadı.");
        return null;
      }
    } else {
      // Kullanıcı bulunamadı.
      print("Kullanıcı bulunamadı.");
      return null;
    }
  }


  //TODO Register user to firestore
  Future<void> _registerUser({required String uid, required String name, required String email, required String photoUrl, required LatLng position}) async {
    DateTime now = DateTime.now();
    var newUser = {
      "name": name,
      "email": email,
      "photoUrl": photoUrl,
      "phone": "",
      "lastLocation": {
        "latitude": position.latitude,
        "longitude": position.longitude,
      },
      "lastLocationUpdatedAt": now,
      "lastSpeed": 0.1,
    };
    await userCollection.doc(uid).set(newUser);
  }


  //TODO Update User location in to firestore
  Future<void> updateUserLocation({required String userId}) async {
    LatLng position = await getLocation();
    var updatedData = {
      "lastLocation": {
        "latitude" : position.latitude,
        "longitude": position.longitude
      },
      "lastLocationUpdatedAt": DateTime.now()
    };
    await userCollection.doc(userId).update(updatedData);
    print("location updated: ${position.latitude} , ${position.longitude}");
  }

  Future<LatLng> getLocation() async{
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    LatLng firstPositon = LatLng(position.latitude, position.longitude);
    print(position); //here you will get your Latitude and Longitude
    return firstPositon;
  }


  //TODO Update User in the firestore
  Future<void> updateUser(
      {
        required String userId,
        required String name,
        required String phone,
        String? photoUrl
      }) async {
    var updatedData = {
      "name": name,
      "phone": phone,
      "photoUrl": photoUrl,
    };
    await userCollection.doc(userId).update(updatedData);
  }


  //TODO: update current user last location into firebase with timer when app is open
  Timer? _updateMyLocationTimer;
  Future<void> runUpdateMyLocation() async {
    _updateMyLocationTimer?.cancel();
    await _updateMyLocation();

    int? locationUpdateDurationSecond; // Default value
    try {
      final appSettingsSnapshot = await FirebaseFirestore.instance.collection('appSettings').get();
      if (appSettingsSnapshot.docs.isNotEmpty) {
        final doc = appSettingsSnapshot.docs.first;
        final duration = doc["locationUpdateDurationSecond"]?.toString();
        if (duration != null) {
          locationUpdateDurationSecond = int.tryParse(duration) ?? locationUpdateDurationSecond;
        }
      }
    } catch (e) {
      print("Error fetching app settings: $e");
    }
    _updateMyLocationTimer = Timer.periodic(Duration(seconds: locationUpdateDurationSecond ?? 60), (timer) async {
      await _updateMyLocation();
    });
  }

  //TODO: Update my location and speed, send to firestore method
  Future<void> _updateMyLocation() async {
    Users? currentUser = UsersManager().currentUser; // Mevcut kullanıcıyı al
    // Kullanıcının konum izinlerini kontrol et
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Konum izni yoksa, izin iste
      await _requestLocationPermission();
      return;
    }
    Position myLastPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    if (currentUser != null) {
      DateTime now = DateTime.now();

      // Hızı hesapla (m/s cinsinden)
      double speed = myLastPosition.speed ?? 0;
      double speedInKmPerHour = myLastPosition.speed != null ? myLastPosition.speed * 3.6 : 0;

      // Hız 0 ise ve önceki hız da 0 ise konum güncellemesini yapma
      if (speed == 0 && _lastSpeed == 0) {
        return;
      }

      // Firestore'da kullanıcının son konumunu güncelle
      await FirebaseFirestore.instance.collection('users').doc(currentUser.id).update({
        "lastLocation": {
          "latitude": myLastPosition.latitude,
          "longitude": myLastPosition.longitude,
        },
        "lastSpeed": speedInKmPerHour, // Hızı güncelle
        "lastLocationUpdatedAt": now, // Son güncelleme tarihi
      });

      // Hızı güncelle
      _lastSpeed = speed;

      print("${currentUser.name} son konumu Firestore'a gönderildi, Hız: $speedInKmPerHour m/s");
    } else {
      print("Konum güncellenemedi, çünkü kullanıcı bulunamadı");
    }
  }

  //Konum izni isteme metodu
  Future<void> _requestLocationPermission() async {
    // Konum izni iste
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      // Kullanıcı izni reddetti
      // Burada kullanıcıya bir bildirim veya açıklama gösterilebilir
      print('Konum izni reddedildi.');
    }
  }

  Future<void> editUser({
    required BuildContext context,
    required String userId,
    required String name,
    required String phone,
    File? userImage,
    String? photoUrl,
  }) async {
    if (name.isEmpty){
      // Delay the execution of the dialog to allow the saveUser method to complete
      await Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor,
              title: const Text("Warning",style: TextStyle(color: Colors.white),),
              content: const Text("Please fill in all fields!",style: TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK",style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      });
    } else {
      //Upload user image
      String imageUrl = photoUrl ?? "";
      if (userImage != null) {
        deleteUserImage(photoUrl ?? "");
        imageUrl = await uploadUserImage(userImage);
      }
      //Update user in firestore
      List<String> memberIds = [UsersManager().currentUser!.id];
      updateUser(
        userId: userId,
        name: name,
        phone: phone,
        photoUrl: imageUrl,
      );
      //get updated user data
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection("users").doc(userId).get();
      if (snapshot.exists) {
        String id = snapshot.id;
        Map<String, dynamic>? userData = snapshot.data();
        Users updatedUser = Users.fromMap(id, userData!);
        await UsersManager().setUser(updatedUser);
        print("Current User set edildi");
      } else {
        print("Kullanıcıya ait  veri bulunamadı.");
      }
      // After the user is saved, navigate back to the GroupMemberScreen
      Navigator.pop(context);
    }
  }

  Future<void> deleteUserImage(String imageUrl) async {
    try {
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }

  //TODO: Upload User profile image to firebase storage
  Future<String> uploadUserImage(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String? userName = FirebaseAuth.instance.currentUser?.displayName ?? "";
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'user_images/${userId}_$userName/$timestamp.jpeg';

      // Upload the resized image to Firebase Storage
      File resizedImageFile = await HelperFunctions.resizeImage(imageFile, 200, 200);
      await FirebaseStorage.instance.ref(fileName).putFile(resizedImageFile);

      // Get the download URL of the uploaded image
      String imageUrl = await FirebaseStorage.instance.ref(fileName).getDownloadURL();

      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }



}

