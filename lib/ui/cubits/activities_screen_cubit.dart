import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/activities.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/data/repo/activity_tracking_dao_repository.dart';

class ActivitiesScreenCubit extends Cubit<List<Activities>> {
  ActivitiesScreenCubit():super(<Activities>[]);

  final activityCollection = FirebaseFirestore.instance.collection("activities");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> getAllActivities() async {
    activityCollection.snapshots().listen((event) {
      var activityList = <Activities>[];
      var documents = event.docs;
      for (var document in documents) {
        List<String> memberIds = List.from(document["memberIds"]);

        var activity = Activities.fromMap(document.id, document.data());
        activityList.add(activity);
      }
      emit(activityList);
    });
  }

  Future<void> getMyActivities(Users currentUser) async {
    activityCollection.snapshots().listen((event) {
      var myActivityList = <Activities>[];
      var documents = event.docs;
      for (var document in documents) {
        List<String> memberIds = List.from(document["memberIds"]);
        if(memberIds.contains(currentUser.id)) {
          var activity = Activities.fromMap(document.id, document.data());
          myActivityList.add(activity);
        }
      }
      emit(myActivityList);
    });
  }

  Future<void> filteredActivityList(Users currentUser,String searchText, int tabIndex) async {
    activityCollection.snapshots().listen((event) {
      var myActivityList = <Activities>[];
      var documents = event.docs;
      if(tabIndex == 1) {
        for (var document in documents) {
          var activity = Activities.fromMap(document.id, document.data());
          if(activity.name.toLowerCase().contains(searchText.toLowerCase())) {
            myActivityList.add(activity);
          }
        }
      }
      if(tabIndex == 0) {
        for (var document in documents) {
          List<String> memberIds = List.from(document["memberIds"]);
          if(memberIds.contains(currentUser.id)) {
            var activity = Activities.fromMap(document.id, document.data());
            if(activity.name.toLowerCase().contains(searchText.toLowerCase())) {
              myActivityList.add(activity);
            }
          }
        }
      }
      emit(myActivityList);
    });
  }

  void checkActivityMembershipAndNavigate(BuildContext context, Activities selectedActivity) {
    // Grup üyeliğini kontrol et
    ActivityTrackingDaoRepository.shared.checkActivityMembershipAndNavigate(context, selectedActivity);
  }
  void sendRequestToJoinActivity(BuildContext context, String activityId) {
    ActivityTrackingDaoRepository.shared.sendRequestToJoinActivity(context, activityId);
  }
  //TODO: remove from activity
  Future<void> removeFromActivity(Activities activity, Users user) async {
    ActivityTrackingDaoRepository.shared.removeFromActivity(activity, user);
  }
  //TODO: Cancel request to join activity
  Future<void> cancelRequest(Activities activity, Users user) async {
    ActivityTrackingDaoRepository.shared.cancelRequest(activity, user);
  }

}