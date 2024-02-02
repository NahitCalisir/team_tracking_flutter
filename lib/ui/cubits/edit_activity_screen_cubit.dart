import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_tracking/data/repo/activity_tracking_dao_repository.dart';

class EditActivityScreenCubit extends Cubit<File?> {
  EditActivityScreenCubit(): super(null);

  Future<void> editActivity(
      {
        required BuildContext context,
        required String activityId,
        required String name,
        required String city,
        required String country,
        File? activityImage,
        String? photoUrl,
        required Timestamp timeStart,
        required Timestamp timeEnd,
      }) async {
    ActivityTrackingDaoRepository.shared.editActivity(
      context: context,
      activityId: activityId,
      name: name,
      city: city,
      country: country,
      activityImage: activityImage,
      photoUrl: photoUrl,
      timeStart: timeStart,
      timeEnd: timeEnd,
    );
  }

  Future<void> pickImage() async {
    File? activityImageFile;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null) {
      activityImageFile = File(image.path);
      File resizedImage = await ActivityTrackingDaoRepository.shared.resizeImage(activityImageFile, 300, 300);
      emit(resizedImage);
    }
  }
  Future<void> resetImage() async {
    emit(null);
  }

  Future<void> deleteActivity(
      {
        required BuildContext context,
        required String activityId,
        required String photoUrl,
      }) async {
    ActivityTrackingDaoRepository.shared.deleteActivity(
      context: context,
      activityId: activityId, photoUrl: photoUrl,
    );
  }

}

