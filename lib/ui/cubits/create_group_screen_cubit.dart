import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart';

class CreateGroupScreenCubit extends Cubit<File?> {
  CreateGroupScreenCubit(): super(null);

  Future<void> saveGroup(
      {
        required BuildContext context,
        required String name,
        required String city,
        required String country,
        required File? groupImage
      }) async {
    TeamTrackingDaoRepository.shared.saveGroup(
      context: context,
      name: name,
      city: city,
      country: country,
      groupImage: groupImage,
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