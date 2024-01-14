import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart';

class SettingsScreenCubit extends Cubit<Users> {
  SettingsScreenCubit(): super(Users(id: "", name: "", email: ""));

  Future<void> signOut(BuildContext context) async {
    TeamTrackingDaoRepository.shared.signOut(context);
  }

  Future<Users?> getCurrentUserInfo() async {
    Users? curentUser = await  TeamTrackingDaoRepository.shared.getCurrentUserInfo();
    if(curentUser != null){
      emit(curentUser);
    }
  }

}

