import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart';

class GroupsScreenCubit extends Cubit<List<Groups>> {
  GroupsScreenCubit():super(<Groups>[]);

  final groupCollection = FirebaseFirestore.instance.collection("groups");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> getAllGroups() async {
    groupCollection.snapshots().listen((event) {
      var groupList = <Groups>[];
      var documents = event.docs;
      for (var document in documents) {
        List<String> memberIds = List.from(document["memberIds"]);

        var group = Groups.fromMap(document.id, document.data());
        groupList.add(group);
      }
      emit(groupList);
    });
  }

  Future<void> getMyGroups(Users currentUser) async {
    groupCollection.snapshots().listen((event) {
      var myGroupList = <Groups>[];
      var documents = event.docs;
      for (var document in documents) {
        List<String> memberIds = List.from(document["memberIds"]);
        if(memberIds.contains(currentUser.id)) {
          var group = Groups.fromMap(document.id, document.data());
          myGroupList.add(group);
        }
      }
      emit(myGroupList);
    });
  }

  Future<void> filteredGroupList(Users currentUser,String searchText, int tabIndex) async {
    groupCollection.snapshots().listen((event) {
      var myGroupList = <Groups>[];
      var documents = event.docs;
      if(tabIndex == 1) {
        for (var document in documents) {
          var group = Groups.fromMap(document.id, document.data());
          if(group.name.toLowerCase().contains(searchText.toLowerCase())) {
            myGroupList.add(group);
          }
        }
      }
      if(tabIndex == 0) {
        for (var document in documents) {
          List<String> memberIds = List.from(document["memberIds"]);
          if(memberIds.contains(currentUser.id)) {
            var group = Groups.fromMap(document.id, document.data());
            if(group.name.toLowerCase().contains(searchText.toLowerCase())) {
              myGroupList.add(group);
            }
          }
        }
      }
      emit(myGroupList);
    });
  }

  void checkGroupMembershipAndNavigate(BuildContext context, Groups selectedGroup) {
    // Grup üyeliğini kontrol et
    TeamTrackingDaoRepository.shared.checkGroupMembershipAndNavigate(context, selectedGroup);
  }
  void sendRequestToJoinGroup(BuildContext context, String groupId) {
    TeamTrackingDaoRepository.shared.sendRequestToJoinGroup(context, groupId);
  }
  //TODO: remove from group
  Future<void> removeFromGroup(Groups group, Users user) async {
    TeamTrackingDaoRepository.shared.removeFromGroup(group, user);
  }
  //TODO: Cancel request to join group
  Future<void> cancelRequest(Groups group, Users user) async {
    TeamTrackingDaoRepository.shared.cancelRequest(group, user);
  }

}