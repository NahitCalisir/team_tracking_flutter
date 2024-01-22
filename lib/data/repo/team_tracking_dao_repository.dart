import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/ui/views/bottom_navigation_bar.dart';
import 'package:team_tracking/ui/views/groups_screen/group_members_screen.dart';
import 'package:team_tracking/ui/views/groups_screen/groups_screen.dart';
import 'package:team_tracking/ui/views/login_screen/login_screen.dart';
import 'package:image/image.dart' as img;
import 'package:team_tracking/utils/constants.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
        name: name ?? "unnamed",
        email: email,
        photoUrl: "",
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

  //TODO Update Group in the firestore
  Future<void> updateGroup(
      {
        required String groupId,
        required String name,
        required String city,
        required String country,
        String? photoUrl
      }) async {
    var updatedData = {
      "name": name,
      "city": city,
      "country": country,
      "photoUrl": photoUrl,
    };
    await groupCollection.doc(groupId).update(updatedData);
  }

  //TODO Delete Group from the firestore
  Future<void> deleteGroupFromFirestore({
    required String groupId,
    required String photoUrl,
  }) async {
    try {
      await groupCollection.doc(groupId).delete();
      print("Group deleted successfully!");
      await deleteGroupImage(photoUrl);
    } catch (error) {
      print("Error deleting group: $error");
      // Hata durumunda gerekli işlemleri yapabilirsiniz.
    }
  }

  Future<void> deleteGroupImage(String imageUrl) async {
    try {
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }



  Future<void> createGroup({
    required BuildContext context,
    required String name,
    required String city,
    required String country,
    required File? groupImage,
  }) async {
    if (name.isEmpty || city.isEmpty || country.isEmpty) {
      // Delay the execution of the dialog to allow the saveGroup method to complete
      await Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor2,
              title: Text("Warning",style: TextStyle(color: Colors.white),),
              content: Text("Please fill in all fields!",style: TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop;
                  },
                  child: Text("OK",style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      });
    } else {
      //Upload group image
      String imageUrl = "";
      if (groupImage != null) {
        imageUrl = await uploadGroupImage(groupImage);
      }
      //Register group to firestore
      String owner = UsersManager().currentUser!.id;
      List<String> memberIds = [UsersManager().currentUser!.id];
      registerGroup(
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

  Future<void> editGroup({
    required BuildContext context,
    required String groupId,
    required String name,
    required String city,
    required String country,
    required File? groupImage,
  }) async {
    if (name.isEmpty || city.isEmpty || country.isEmpty) {
      // Delay the execution of the dialog to allow the saveGroup method to complete
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
                  child: Text("OK",style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      });
    } else {
      //Upload group image
      String imageUrl = "";
      if (groupImage != null) {
        imageUrl = await uploadGroupImage(groupImage);
      }
      //Update group in firestore
      String owner = UsersManager().currentUser!.id;
      List<String> memberIds = [UsersManager().currentUser!.id];
      updateGroup(
        groupId: groupId,
        name: name,
        city: city,
        country: country,
        photoUrl: imageUrl,
      );
      // After the group is saved, navigate back to the GroupsScreen
      Navigator.pop(context);
    }
  }

  Future<void> deleteGroup({
    required BuildContext context,
    required String groupId,
    required String photoUrl,
  }) async {
      // Delay the execution of the dialog to allow the saveGroup method to complete
      await Future.delayed(Duration.zero, () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor,
              title: const Text("Warning",style: TextStyle(color: Colors.white),),
              content: const Text("Are you sure you want to delete this group?",style: TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () {
                    deleteGroupFromFirestore(groupId: groupId, photoUrl: photoUrl);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: Text("Delete",style: TextStyle(color: Colors.red),),
                ),
              ],
            );
          },
        );
      });
    }


  //TODO: Upload Group image to firebase storage
  Future<String> uploadGroupImage(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'group_images/$userId/$timestamp.jpeg';

      // Upload the resized image to Firebase Storage
      File resizedImageFile = await resizeImage(imageFile, 200, 200);
      await FirebaseStorage.instance.ref(fileName).putFile(resizedImageFile);

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


  Future<File> resizeImage(File imageFile, double width, double height) async {
    // Dosyayı oku ve image paketini kullanarak image nesnesine dönüştür
    List<int> imageBytes = await imageFile.readAsBytes();
    img.Image image = img.decodeImage(Uint8List.fromList(imageBytes))!;

    // Belirli genişlik ve yüksekliğe boyutlandır
    img.Image resizedImage = img.copyResize(image, width: width.toInt(), height: height.toInt());

    // Boyutlandırılmış resmi bir File nesnesine dönüştür
    File resultFile = await File(imageFile.path)
      ..writeAsBytesSync(Uint8List.fromList(img.encodePng(resizedImage)!));

    return resultFile;
  }


  void checkGroupMembershipAndNavigate(BuildContext context, Groups selectedGroup) {
    // Grup üyeliğini kontrol et
    bool isMember = selectedGroup.memberIds.contains(UsersManager().currentUser!.id);

    if (isMember) {
      // Kullanıcı grup üyesiyse UsersScreen'e git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GroupMembersScreen(group: selectedGroup),
        ),
      );
    } else {
      // Kullanıcı grup üyesi değilse uyarı göster
      showMembershipAlert(context);
    }
  }

  void showMembershipAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kSecondaryColor,
          title: Text("Warning",style: TextStyle(color: kSecondaryColor2),),
          content: Text("You are not a member of this group. Send a request to join.",style: TextStyle(color: Colors.white),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel",style: TextStyle(color: kSecondaryColor2),),
            ),
            TextButton(
              onPressed: () {
                sendRequestToJoinGroup();
              },
              child: Text("Send Request",style: TextStyle(color: kSecondaryColor2),),
            ),
          ],
        );
      },
    );
  }
  void sendRequestToJoinGroup() {
    // TODO: Grup üyeliği için istek gönderme işlemleri
    // İstek gönderme işlemleri buraya eklenecek
    print("istek gönderme başlatıldı");
  }


}

