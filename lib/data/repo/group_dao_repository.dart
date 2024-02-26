import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/ui/views/groups_screen/group_members_screen.dart';
import 'package:team_tracking/utils/constants.dart';
import 'package:team_tracking/data/repo/helper_functions.dart';
import '../entity/users.dart';

class GroupDaoRepository {

  static GroupDaoRepository shared = GroupDaoRepository();

  final userCollection = FirebaseFirestore.instance.collection("users");
  final groupCollection = FirebaseFirestore.instance.collection("groups");
  final firebaseAuth = FirebaseAuth.instance;


  //TODO Register Group to the firestore
  Future<void> registerGroup(
      {
        required String name,
        required String city,
        required String country,
        required String owner,
        required List<String> memberIds,
        String? photoUrl,
        List<String>? joinRequests,
      }) async {
    var newGroup = {
      "name": name,
      "city": city,
      "country": country,
      "owner": owner,
      "memberIds": memberIds,
      "photoUrl": photoUrl,
      "joinRequests": joinRequests,
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
              title: const Text("Warning",style: TextStyle(color: Colors.white),),
              content: const Text("Please fill in all fields!",style: TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop;
                  },
                  child: const Text("OK",style: TextStyle(color: Colors.white),),
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
      List<String> joinRequests = [];
      registerGroup(
        name: name,
        city: city,
        country: country,
        owner:  owner,
        memberIds: memberIds,
        photoUrl: imageUrl,
        joinRequests: joinRequests,
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
    File? groupImage,
    String? photoUrl,
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
                  child: const Text("OK",style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      });
    } else {
      //Upload group image
      String imageUrl = photoUrl ?? "";
      if (groupImage != null) {
        deleteGroupImage(photoUrl ?? "");
        imageUrl = await uploadGroupImage(groupImage);
      }
      //Update group in firestore
      String currentUser = UsersManager().currentUser!.id;
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
            title: const Text("Warning",style: TextStyle(color: kSecondaryColor2),),
            content: const Text("Are you sure you want to delete this group?",style: TextStyle(color: Colors.white),),
            actions: [
              TextButton(
                onPressed: () {
                  deleteGroupFromFirestore(groupId: groupId, photoUrl: photoUrl);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Delete",style: TextStyle(color: Colors.red),),
              ),
            ],
          );
        },
      );
    });
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


  //TODO: Upload Group image to firebase storage
  Future<String> uploadGroupImage(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String? userName = FirebaseAuth.instance.currentUser?.displayName ?? "";
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'group_images/${userId}_$userName/$timestamp.jpeg';

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



  Future<void> deleteGroupImage(String imageUrl) async {
    try {
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
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
      showMembershipAlert(context,selectedGroup.id);
    }
  }

  void showMembershipAlert(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kSecondaryColor,
          title: const Text("Warning",style: TextStyle(color: kSecondaryColor2),),
          content: const Text("You are not a member of this group. Send a request to join.",style: TextStyle(color: Colors.white),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel",style: TextStyle(color: kSecondaryColor2),),
            ),
            TextButton(
              onPressed: () {
                sendRequestToJoinGroup(context, groupId);
                Navigator.of(context).pop();
              },
              child: const Text("Send Request",style: TextStyle(color: kSecondaryColor2),),
            ),
          ],
        );
      },
    );
  }

  // TODO: Grup üyeliği için istek gönderme işlemleri
  void sendRequestToJoinGroup(BuildContext context, String groupId) async {
    print("istek gönderme başlatıldı");
    String userId = UsersManager().currentUser!.id;
    await groupCollection.doc(groupId).update(
        {"joinRequests": FieldValue.arrayUnion([userId])},
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Request sent successfully.",style: TextStyle(color: kSecondaryColor),),
          backgroundColor: kSecondaryColor2,
          duration: Durations.extralong4
      ),);
    notifyGroupOwner(groupId, userId);
  }
  // TODO:Notify group owner about join request
  void notifyGroupOwner(String groupId, String userId) {
    // notification logic here
    // Firebase Cloud Messaging (FCM) or push notification
  }
  //TODO: accept join request
  Future<void> acceptJoinRequest(Groups group, Users user) async {
    await groupCollection.doc(group.id).update({
      "memberIds": FieldValue.arrayUnion([user.id]),
      "joinRequests": FieldValue.arrayRemove([user.id]),
    });
  }
  //TODO: reject join request
  Future<void> rejectJoinRequest(Groups group, Users user) async {
    await groupCollection.doc(group.id).update({
      "joinRequests": FieldValue.arrayRemove([user.id]),
    });
  }
  //TODO: remove from group
  Future<void> removeFromGroup(Groups group, Users user) async {
    await groupCollection.doc(group.id).update({
      "memberIds": FieldValue.arrayRemove([user.id]),
    });
  }
  //TODO: Cancel request to join group
  Future<void> cancelRequest(Groups group, Users user) async {
    await groupCollection.doc(group.id).update({
      "joinRequests": FieldValue.arrayRemove([user.id]),
    });
  }



}

