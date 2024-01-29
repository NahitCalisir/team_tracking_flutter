import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/ui/cubits/edit_group_screen_cubit.dart';
import 'package:team_tracking/utils/constants.dart';

class EditGroupScreen extends StatefulWidget {

  final Groups group;
  const EditGroupScreen({super.key, required this.group});

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {

  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  void initState() {
    context.read<EditGroupScreenCubit>().resetImage();
    _nameController.text = widget.group.name;
    _cityController.text = widget.group.city;
    _countryController.text = widget.group.country;
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditGroupScreenCubit, File?>(
      builder: (context, groupImageFile) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Edit Group"),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  GestureDetector(
                      onTap: (){
                        context.read<EditGroupScreenCubit>().pickImage();
                      } ,
                      child: groupImageFile == null ?
                      widget.group.photoUrl == "" ?
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const Icon(
                          Icons.add_a_photo,
                          color: kSecondaryColor2, // İkonun rengini belirleyin
                          size: 200, // İkonun boyutunu belirleyin
                        ),
                      ):
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: NetworkImage(widget.group.photoUrl!),
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        ),
                      )
                          : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                        child: Image(
                          image: FileImage(groupImageFile),
                          fit: BoxFit.cover,
                          height: 198,
                          width: 198,
                        )
                      )
                  ),
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
                  Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: kSecondaryColor2,
                              foregroundColor: Colors.white),
                          onPressed: (){
                            context.read<EditGroupScreenCubit>().editGroup(
                              context: context,
                              groupId: widget.group.id,
                              name: _nameController.text.trim(),
                              city: _cityController.text.trim(),
                              country: _countryController.text.trim(),
                              groupImage: groupImageFile,
                              photoUrl: widget.group.photoUrl
                            );
                          },
                          child: const Text("Save Group",style: TextStyle(fontSize: 20),)),
                      const SizedBox(height: 30,),
                      ElevatedButton(
                         //style: ElevatedButton.styleFrom(
                         //    backgroundColor: kSecondaryColor2,
                         //    foregroundColor: Colors.white),
                          onPressed: (){
                            context.read<EditGroupScreenCubit>().deleteGroup(
                              context: context,
                              groupId: widget.group.id,
                              photoUrl: widget.group.photoUrl!,
                            );
                          },
                          child: const Text("Delete Group",style: TextStyle(fontSize: 20, color: Colors.red),)),
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
