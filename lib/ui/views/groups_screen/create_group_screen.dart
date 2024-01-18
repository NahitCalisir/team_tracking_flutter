import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {

  File? _groupImage;
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  String? photoUrl;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if(image != null) {
      setState(() {
        _groupImage = File(image.path);
      });
    }
  }

  Future<void> _saveGroup() async {
    final name = _nameController.text.trim();
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();

    if(name.isEmpty || city.isEmpty || country.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Warning"),
            content: Text("Please fill in all fields"),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
      return;
    } else {

      // TODO: Upload group image
      if (_groupImage != null) {
        String imageUrl = await TeamTrackingDaoRepository.shared.uploadGroupImage(_groupImage!);
        if (imageUrl.isNotEmpty) {
          // If the image upload is successful, set the imageUrl to the group
          photoUrl = imageUrl;
        }
      }

      // TODO: Register group to firestore
      String owner = UsersManager().currentUser!.name;
      List<String> memberIds = [UsersManager().currentUser!.id];
      TeamTrackingDaoRepository.shared.registerGroup(
          name: _nameController.text.trim(),
          city: _cityController.text.trim(),
          country: _countryController.text.trim(),
          owner:  owner,
          memberIds: memberIds,
          photoUrl: photoUrl
      );

      // After the group is saved, navigate back to the GroupsScreen
      Navigator.pop(context);
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Group"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _groupImage == null
                    ? const CircleAvatar(
                        backgroundColor: Colors.orangeAccent, // CircleAvatar'ın arka plan rengini ayarlayın
                        radius: 100, // Dilediğiniz bir yarıçap değerini belirleyin
                        child: Icon(
                          Icons.add_a_photo,
                          color: Colors.white, // İkonun rengini belirleyin
                          size: 100, // İkonun boyutunu belirleyin
                        ),
                      )
                    : CircleAvatar(
                      backgroundColor: Colors.deepOrangeAccent,
                      radius: 100,
                      child: CircleAvatar(
                          backgroundColor: Colors.blue, // CircleAvatar'ın arka plan rengini ayarlayın
                          radius: 98, // Dilediğiniz bir yarıçap değerini belirleyin
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(98),
                              child: Image(image: FileImage(_groupImage!))
                          )
                        ),
                    )
              ),
              SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: " Group Name*"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(labelText: "City*"),
              ),
              SizedBox(height: 8),
              TextField(
                controller: _countryController,
                decoration: InputDecoration(labelText: "Country*"),
              ),
             SizedBox(height: 16),
             ElevatedButton(
                 onPressed: (){
                   _saveGroup();
                 },
                 child: Text("Create Group"))
            ],
          ),
        ),
      ),
    );
  }
}
