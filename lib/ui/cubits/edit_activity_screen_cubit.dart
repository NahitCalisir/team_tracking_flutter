import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_tracking/data/repo/activity_dao_repository.dart';
import 'package:team_tracking/utils/helper_functions.dart';

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
        required String routeUrl,
        required String routeName,
      }) async {
    ActivityDaoRepository.shared.editActivity(
      context: context,
      activityId: activityId,
      name: name,
      city: city,
      country: country,
      activityImage: activityImage,
      photoUrl: photoUrl,
      timeStart: timeStart,
      timeEnd: timeEnd,
      routeUrl: routeUrl,
      routeName: routeName,
    );
  }

  Future<void> pickImage() async {
    File? activityImageFile;
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null) {
      activityImageFile = File(image.path);
      File resizedImage = await HelperFunctions.resizeImage(activityImageFile, 300, 300);
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
        required String routeUrl,
      }) async {
    ActivityDaoRepository.shared.deleteActivity(
      context: context,
      activityId: activityId,
      photoUrl: photoUrl,
      routeUrl: routeUrl,
    );
  }

  // Dosya seçme işlemi
  Future<FilePickerResult?> pickRouteFile() async {
    return ActivityDaoRepository.shared.pickRouteFile();
  }

  Future<String?> uploadPickerResultToFirestore(FilePickerResult pickerResult) async {
    return ActivityDaoRepository.shared.uploadPickerResultToFirestore(pickerResult);
  }

}

