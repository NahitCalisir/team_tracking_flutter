import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:intl/intl.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart'; // Import intl for date formatting

class GroupMembersScreenCubit extends Cubit<List<Users>> {
  GroupMembersScreenCubit():super(<Users>[]);

  final userCollection = FirebaseFirestore.instance.collection("users");
  final groupsCollection = FirebaseFirestore.instance.collection("groups");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> getAllUsers() async {
    //Firebase kullanırken repo içersinde veriyi çekip retun edemiyoruz.
    // direk cubit içeriside yapıyoruz.
    //bu metod veri tabanını sürekli dinliyor ve veri tabanında bir değişiklik olduğu an emit ediyor.
    userCollection.snapshots().listen((event) {
      var userList = <Users>[];
      var documents = event.docs;
      for (var document in documents) {
        var user = Users(
          id: document.id,
          name: document["name"] as String,
          email: document["email"] as String,);
        userList.add(user);
      }
      emit(userList);
    });
  }

  Future<void> getGroupMembers(Groups group) async {
    List<Users> groupMembers = [];
    DocumentSnapshot<Map<String, dynamic>> document = await groupsCollection.doc(group.id).get();
    Groups updatedGroup = Groups.fromMap(document.id, document.data()!);

    for (String memberId in updatedGroup.memberIds) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await userCollection.doc(memberId).get();
      if (snapshot.exists) {
        Users user = Users.fromMap(snapshot.id, snapshot.data()!);
        groupMembers.add(user);
      }
    }
    emit(groupMembers);
  }
  Future<void> getMemberRequestList(Groups group) async {
    List<Users> groupRequestMembers = [];
    DocumentSnapshot<Map<String, dynamic>> document = await groupsCollection.doc(group.id).get();
    Groups updatedGroup = Groups.fromMap(document.id, document.data()!);

    if(updatedGroup.joinRequests != null){
      for (String memberId in updatedGroup.joinRequests!) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await userCollection.doc(memberId).get();
        if (snapshot.exists) {
          Users user = Users.fromMap(snapshot.id, snapshot.data()!);
          groupRequestMembers.add(user);
        }
      }
    }
    print(groupRequestMembers.length);
    emit(groupRequestMembers);
  }

  Future<void> filtrele(String aramaTerimi) async {
    userCollection.snapshots().listen((event) {
      var userList = <Users>[];

      var documents = event.docs;
      for (var document in documents) {
        var user = Users(
            id: document.id as String,
            name: document["name"] as String,
            email: document["email"] as String,
            photoUrl: document["photoURl"] as String ?? "");
        if(user.name.toLowerCase().contains(aramaTerimi.toLowerCase())){
          userList.add(user);
        }
      }
      emit(userList);
    });
  }

  // TODO:Notify group owner about join request
  void notifyGroupOwner(String groupId, String userId) {
    // notification logic here
    // Firebase Cloud Messaging (FCM) or push notification
  }
 //TODO: accept join request
  Future<void> acceptJoinRequest(Groups group, Users user) async {
   TeamTrackingDaoRepository.shared.acceptJoinRequest(group, user);
 }
 //TODO: reject join request
  Future<void> rejectJoinRequest(Groups group, Users user) async {
   TeamTrackingDaoRepository.shared.rejectJoinRequest(group, user);
 }
  //TODO: remove from group
  Future<void> removeFromGroup(Groups group, Users user) async {
    TeamTrackingDaoRepository.shared.removeFromGroup(group, user);
  }



}
