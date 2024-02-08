import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/ui/cubits/create_group_screen_cubit.dart';
import 'package:team_tracking/utils/constants.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    context.read<CreateGroupScreenCubit>().resetImage();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateGroupScreenCubit, File?>(
      builder: (context, groupImageFile) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Create Group"),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                          onTap: () async {
                            setState(() {isLoading = true;});
                            await context.read<CreateGroupScreenCubit>().pickImage();
                            setState(() {isLoading = false;});
                          } ,
                          child: groupImageFile == null
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
                                      image: FileImage(groupImageFile),
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
                        decoration: const InputDecoration(labelText: " Group Name*"),
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
                            context.read<CreateGroupScreenCubit>().saveGroup(
                              context: context,
                              name: _nameController.text.trim(),
                              city: _cityController.text.trim(),
                              country: _countryController.text.trim(),
                              groupImage: groupImageFile,
                            );
                          },
                          child: const Text("Create Group",style: TextStyle(fontSize: 20),))
                    ],
                  ),
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}
