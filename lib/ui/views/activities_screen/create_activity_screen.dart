import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/ui/cubits/create_activity_screen_cubit.dart';
import 'package:team_tracking/utils/constants.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  State<CreateActivityScreen> createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    context.read<CreateActivityScreenCubit>().resetImage();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateActivityScreenCubit, File?>(
      builder: (context, activityImageFile) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Create Activity"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GestureDetector(
                      onTap: (){
                        setState(() {isLoading = true;});
                        context.read<CreateActivityScreenCubit>().pickImage();
                        setState(() {isLoading = false;});
                      } ,
                      child: activityImageFile == null
                          ? const CircleAvatar(
                        backgroundColor: kSecondaryColor2, // CircleAvatar'ın arka plan rengini ayarlayın
                        radius: 100, // Dilediğiniz bir yarıçap değerini belirleyin
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.white, // İkonun rengini belirleyin
                          size: 100, // İkonun boyutunu belirleyin
                        ),
                      )
                          : CircleAvatar(
                        backgroundColor: kSecondaryColor2,
                        radius: 100,
                        child: ClipOval(
                                child: Image(
                                  image: FileImage(activityImageFile),
                                  fit: BoxFit.cover,
                                  height: 198,
                                  width: 198,
                                )
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
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: kSecondaryColor2,
                          foregroundColor: Colors.white),
                      onPressed: (){
                        context.read<CreateActivityScreenCubit>().saveActivity(
                          context: context,
                          name: _nameController.text.trim(),
                          city: _cityController.text.trim(),
                          country: _countryController.text.trim(),
                          activityImage: activityImageFile,
                        );
                      },
                      child: const Text("Create Activity",style: TextStyle(fontSize: 20),))
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
