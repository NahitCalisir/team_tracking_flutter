import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart';

class SettingsScreenCubit extends Cubit<Users> {
  SettingsScreenCubit(): super(Users(id: "", name: "", email: ""));

  Future<void> signOut(BuildContext context) async {
    TeamTrackingDaoRepository.shared.signOut(context);
  }

  Future<Users?> getCurrentUserInfo() async {
    Users? curentUser = await  UsersManager().currentUser;
    if(curentUser != null){
      emit(curentUser);
    }
  }

}

