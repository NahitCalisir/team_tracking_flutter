import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/settings_secreen_cubit.dart';
import 'package:team_tracking/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});


  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool isLoading = false;
  Users? currentUser =  UsersManager().currentUser;

  @override
  void initState() {
    context.read<SettingsScreenCubit>().resetImage();
    _nameController.text = currentUser?.name ?? "";
    _phoneController.text = currentUser?.phone ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsScreenCubit, File?>(
      builder: (context, userImageFile){
        return Stack(
          children: [
            // Background image
            Image.asset(
              'assets/images/background_image4.jpg',
              fit: BoxFit.cover,
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                title: const Text("Profile"),
              ),
                body: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        GestureDetector(
                            onTap: () async {
                              setState(() {isLoading = true;});
                              await context.read<SettingsScreenCubit>().pickImage();
                              setState(() {isLoading = false;});
                            } ,
                            child: userImageFile == null ?
                            currentUser?.photoUrl == "" ?
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: kSecondaryColor2, // İkonun rengini belirleyin
                                size: 150, // İkonun boyutunu belirleyin
                              ),
                            ):
                            ClipOval(
                              child: Image(
                                image: NetworkImage(currentUser?.photoUrl ?? ""),
                                fit: BoxFit.cover,
                                width: 150,
                                height: 150,
                              ),
                            )
                                : ClipOval(
                                child: Image(
                                  image: FileImage(userImageFile),
                                  fit: BoxFit.cover,
                                  height: 150,
                                  width: 150,
                                )
                            )
                        ),
                        const SizedBox(height: 16),
                        Text(currentUser!.email,style: TextStyle(color: Colors.grey),),
                        if(isLoading) const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _nameController,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: "Name*",
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _phoneController,
                          style: TextStyle(color: Colors.white),
                          cursorColor: Colors.white,
                          decoration: InputDecoration(
                            labelText: "Phone Number",
                            labelStyle: TextStyle(color: Colors.grey.shade700),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 50),
                        Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    elevation: 10,
                                    backgroundColor: Colors.grey.shade800,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.grey
                                ),
                                onPressed: () async {
                                  await context.read<SettingsScreenCubit>().editUser(
                                      context: context,
                                      userId: currentUser!.id,
                                      name: _nameController.text.trim(),
                                      phone: _phoneController.text.trim(),
                                      userImage: userImageFile,
                                      photoUrl: currentUser!.photoUrl,
                                  );
                                },
                                child: const Text("Save",style: TextStyle(fontSize: 20),)),
                            const SizedBox(height: 50),
                            ElevatedButton(
                                //style: ElevatedButton.styleFrom(backgroundColor: kSecondaryColor2,foregroundColor: Colors.white),
                                onPressed: () async {
                                  await context.read<SettingsScreenCubit>().signOut(context);
                                },
                                style: ElevatedButton.styleFrom(
                                    elevation: 10,
                                    backgroundColor: Colors.grey.shade800,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.grey
                                ),
                                child: const Text("Sign Out",style: TextStyle(fontSize: 20,color: Colors.red)))
                          ],
                        ),

                      ],
                    ),
                  ),
                )
            ),
          ],
        );
      },
    );
  }
}
