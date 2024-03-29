import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_tracking/data/repo/group_dao_repository.dart';
import 'package:team_tracking/data/repo/helper_functions.dart';

class EditGroupScreenCubit extends Cubit<File?> {
  EditGroupScreenCubit(): super(null);

  Future<void> editGroup(
      {
        required BuildContext context,
        required String groupId,
        required String name,
        required String city,
        required String country,
        File? groupImage,
        String? photoUrl,
      }) async {
    GroupDaoRepository.shared.editGroup(
      context: context,
      groupId: groupId,
      name: name,
      city: city,
      country: country,
      groupImage: groupImage,
      photoUrl: photoUrl,
    );
  }

  Future<void> pickImage() async {
    File? groupImageFile;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null) {
      groupImageFile = File(image.path);
      File resizedImage = await HelperFunctions.resizeImage(groupImageFile, 300, 300);
      emit(resizedImage);
    }
  }
  Future<void> resetImage() async {
    emit(null);
  }

  Future<void> deleteGroup(
      {
        required BuildContext context,
        required String groupId,
        required String photoUrl,
      }) async {
    GroupDaoRepository.shared.deleteGroup(
      context: context,
      groupId: groupId, photoUrl: photoUrl,
    );
  }

}

