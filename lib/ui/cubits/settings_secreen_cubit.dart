import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart';

class SettingsScreenCubit extends Cubit<File?> {
  SettingsScreenCubit(): super(null);

  Future<void> signOut(BuildContext context) async {
    TeamTrackingDaoRepository.shared.signOut(context);
  }

  Future<void> editUser(
      {
        required BuildContext context,
        required String userId,
        required String name,
        required String phone,
        File? userImage,
        String? photoUrl,
      }) async {
    TeamTrackingDaoRepository.shared.editUser(
      context: context,
      userId: userId,
      name: name,
      phone: phone,
      userImage: userImage,
      photoUrl: photoUrl,
    );
  }

  Future<void> pickImage() async {
    File? groupImageFile;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null) {
      groupImageFile = File(image.path);
      File resizedImage = await TeamTrackingDaoRepository.shared.resizeImage(groupImageFile, 300, 300);
      emit(resizedImage);
    }
  }
  Future<void> resetImage() async {
    emit(null);
  }

}

