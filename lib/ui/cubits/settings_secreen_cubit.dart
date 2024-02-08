import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_tracking/data/repo/user_dao_repository.dart';
import 'package:team_tracking/utils/helper_functions.dart';

class SettingsScreenCubit extends Cubit<File?> {
  SettingsScreenCubit(): super(null);

  Future<void> signOut(BuildContext context) async {
    UserDaoRepository.shared.signOut(context);
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
    UserDaoRepository.shared.editUser(
      context: context,
      userId: userId,
      name: name,
      phone: phone,
      userImage: userImage,
      photoUrl: photoUrl,
    );
  }

  Future<void> pickImage() async {
    File? userImageFile;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null) {
      userImageFile = File(image.path);
      File resizedImage = await HelperFunctions.resizeImage(userImageFile, 300, 300);
      emit(resizedImage);
    }
  }
  Future<void> resetImage() async {
    emit(null);
  }

}

