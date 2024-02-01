import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/activities.dart';
import 'package:team_tracking/ui/cubits/edit_activity_screen_cubit.dart';
import 'package:team_tracking/utils/constants.dart';

class EditActivityScreen extends StatefulWidget {

  final Activities activity;
  const EditActivityScreen({super.key, required this.activity});

  @override
  State<EditActivityScreen> createState() => _EditActivityScreenState();
}

class _EditActivityScreenState extends State<EditActivityScreen> {

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    context.read<EditActivityScreenCubit>().resetImage();
    _nameController.text = widget.activity.name;
    _cityController.text = widget.activity.city;
    _countryController.text = widget.activity.country;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityScreenCubit, File?>(
      builder: (context, activityImageFile) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Edit Activity"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                      onTap: () async {
                        setState(() {isLoading = true;});
                        await context.read<EditActivityScreenCubit>().pickImage();
                        setState(() {isLoading = false;});
                      } ,
                      child: activityImageFile == null ?
                      widget.activity.photoUrl == "" ?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: kSecondaryColor2, // İkonun rengini belirleyin
                          size: 150, // İkonun boyutunu belirleyin
                        ),
                      ):
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: NetworkImage(widget.activity.photoUrl!),
                          fit: BoxFit.cover,
                          width: 150,
                          height: 150,
                        ),
                      )
                          : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: FileImage(activityImageFile),
                          fit: BoxFit.cover,
                          height: 150,
                          width: 150,
                        )
                      )
                  ),
                  if(isLoading) CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: " Activity Name*"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _cityController,
                    decoration: const InputDecoration(labelText: "City*"),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _countryController,
                    decoration: const InputDecoration(labelText: "Country*"),
                  ),
                  const SizedBox(height: 30),
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kSecondaryColor2,
                              foregroundColor: Colors.white),
                          onPressed: (){
                            context.read<EditActivityScreenCubit>().editActivity(
                              context: context,
                              activityId: widget.activity.id,
                              name: _nameController.text.trim(),
                              city: _cityController.text.trim(),
                              country: _countryController.text.trim(),
                              activityImage: activityImageFile,
                              photoUrl: widget.activity.photoUrl
                            );
                          },
                          child: const Text("Save Activity",style: TextStyle(fontSize: 20),)),
                      const SizedBox(height: 30,),
                      ElevatedButton(
                         //style: ElevatedButton.styleFrom(
                         //    backgroundColor: kSecondaryColor2,
                         //    foregroundColor: Colors.white),
                          onPressed: (){
                            context.read<EditActivityScreenCubit>().deleteActivity(
                              context: context,
                              activityId: widget.activity.id,
                              photoUrl: widget.activity.photoUrl!,
                            );
                          },
                          child: const Text("Delete Activity",style: TextStyle(fontSize: 20, color: Colors.red),)),
                    ],
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class EditActivityScreenState {
  final File? activityImageFile;
  final bool isLoading;
  final String? error;

  EditActivityScreenState({
    required this.activityImageFile,
    required this.isLoading,
    required this.error,
  });

  factory EditActivityScreenState.init() {
    return EditActivityScreenState(
      activityImageFile: null,
      isLoading: false,
      error: null,
    );
  }

  factory EditActivityScreenState.loading() {
    return EditActivityScreenState(
      activityImageFile: null,
      isLoading: true,
      error: null,
    );
  }

  factory EditActivityScreenState.success(File? activityImageFile) {
    return EditActivityScreenState(
      activityImageFile: activityImageFile,
      isLoading: false,
      error: null,
    );
  }

  factory EditActivityScreenState.failure(String error) {
    return EditActivityScreenState(
      activityImageFile: null,
      isLoading: false,
      error: error,
    );
  }
}