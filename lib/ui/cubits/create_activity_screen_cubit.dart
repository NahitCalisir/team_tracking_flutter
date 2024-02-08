import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_tracking/data/repo/activity_dao_repository.dart';
import 'package:team_tracking/utils/helper_functions.dart';

class CreateActivityScreenCubit extends Cubit<File?> {
  CreateActivityScreenCubit(): super(null);

  Future<void> saveActivity(
      {
        required BuildContext context,
        required String name,
        required String city,
        required String country,
        required File? activityImage,
        required Timestamp timeStart,
        required Timestamp timeEnd,
        required String routeUrl,
      }) async {
    ActivityDaoRepository.shared.createActivity(
      context: context,
      name: name,
      city: city,
      country: country,
      activityImage: activityImage,
      timeStart: timeStart,
      timeEnd: timeEnd,
      routeUrl: routeUrl,
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

  // Dosya seçme işlemi
  Future<FilePickerResult?> pickRouteFile() async {
    return ActivityDaoRepository.shared.pickRouteFile();
  }

  Future<String?> uploadPickerResultToFirestore(FilePickerResult pickerResult) async {
    return ActivityDaoRepository.shared.uploadPickerResultToFirestore(pickerResult);
  }

}