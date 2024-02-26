import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/activities.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/data/repo/activity_dao_repository.dart'; // Import intl for date formatting

class ActivityMembersScreenCubit extends Cubit<List<Users>> {
  ActivityMembersScreenCubit():super(<Users>[]);

  final userCollection = FirebaseFirestore.instance.collection("users");
  final activitiesCollection = FirebaseFirestore.instance.collection("activities");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> getAllUsers() async {
    userCollection.snapshots().listen((event) {
      var userList = <Users>[];
      var documents = event.docs;
      for (var document in documents) {
        List<String> memberIds = List.from(document["memberIds"]);

        var user = Users.fromMap(document.id, document.data());
        userList.add(user);
      }
      emit(userList);
    });
  }

  Future<void> getActivityMembers(Activities activity) async {
    List<Users> activityMembers = [];
    DocumentSnapshot<Map<String, dynamic>> document = await activitiesCollection.doc(activity.id).get();
    Activities updatedActivity = Activities.fromMap(document.id, document.data()!);

    for (String memberId in updatedActivity.memberIds) {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await userCollection.doc(memberId).get();
      if (snapshot.exists) {
        Users user = Users.fromMap(snapshot.id, snapshot.data()!);
        activityMembers.add(user);
      }
    }
    emit(activityMembers);
  }
  Future<void> getMemberRequestList(Activities activity) async {
    List<Users> activityRequestMembers = [];
    DocumentSnapshot<Map<String, dynamic>> document = await activitiesCollection.doc(activity.id).get();
    Activities updatedActivity = Activities.fromMap(document.id, document.data()!);

    if(updatedActivity.joinRequests != null){
      for (String memberId in updatedActivity.joinRequests!) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
        await userCollection.doc(memberId).get();
        if (snapshot.exists) {
          Users user = Users.fromMap(snapshot.id, snapshot.data()!);
          activityRequestMembers.add(user);
        }
      }
    }
    print(activityRequestMembers.length);
    emit(activityRequestMembers);
  }


  Future<void> filteredMemberList(String searchText) async {
    userCollection.snapshots().listen((event) {
      var filteredMemberList = <Users>[];
      var documents = event.docs;
      for (var document in documents) {
        var user = Users.fromMap(document.id, document.data());
        if(user.name.toLowerCase().contains(searchText.toLowerCase())) {
          filteredMemberList.add(user);
        }
      }
      emit(filteredMemberList);
    });
  }

  // TODO:Notify activity owner about join request
  void notifyActivityOwner(String activityId, String userId) {
    // notification logic here
    // Firebase Cloud Messaging (FCM) or push notification
  }
 //TODO: accept join request
  Future<void> acceptJoinRequest(Activities activity, Users user) async {
   ActivityDaoRepository.shared.acceptJoinRequest(activity, user);
 }
 //TODO: reject join request
  Future<void> rejectJoinRequest(Activities activity, Users user) async {
   ActivityDaoRepository.shared.rejectJoinRequest(activity, user);
 }
  //TODO: remove from activity
  Future<void> removeFromActivity(Activities activity, Users user) async {
    ActivityDaoRepository.shared.removeFromActivity(activity, user);
  }



}
