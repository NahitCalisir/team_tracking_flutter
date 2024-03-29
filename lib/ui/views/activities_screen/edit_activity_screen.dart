import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
  final _routeController = TextEditingController();
  bool isLoading = false;
  late DateTime timeStart;
  late DateTime timeEnd;
  String? selectedRoutePath;
  String? selectedRouteName;
  String? routeDownloadUrl;
  FilePickerResult? filePickerResult;

  @override
  void initState() {
    context.read<EditActivityScreenCubit>().resetImage();
    _nameController.text = widget.activity.name;
    _cityController.text = widget.activity.city;
    _countryController.text = widget.activity.country;
    timeStart = widget.activity.timeStart.toDate();
    timeEnd = widget.activity.timeEnd.toDate();
    _routeController.text = widget.activity.routeName ?? "";
    routeDownloadUrl = widget.activity.routeUrl ?? "";
    selectedRouteName = widget.activity.routeName ?? "";
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditActivityScreenCubit, File?>(
      builder: (context, activityImageFile) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.asset(
              'assets/images/background_image4.jpg',
              fit: BoxFit.cover,
            ),
            Scaffold(backgroundColor: Colors.transparent,
              appBar: AppBar(backgroundColor: Colors.transparent,foregroundColor: Colors.white,
                title: const Text("Edit Activity"),
              ),
              body: Stack(
                children: [
                  SingleChildScrollView(
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
                                  color: Colors.grey, // İkonun rengini belirleyin
                                  size: 100, // İkonun boyutunu belirleyin
                                ),
                              ):
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                  image: NetworkImage(widget.activity.photoUrl!),
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                              ):
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                image: FileImage(activityImageFile),
                                fit: BoxFit.cover,
                                height: 100,
                                width: 100,
                              )
                            )
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _nameController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              labelText: " Activity Name*",
                              labelStyle: TextStyle(color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cityController,
                            style: TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              labelText: "City*",
                              labelStyle: TextStyle(color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _countryController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              labelText: "Country*",
                              labelStyle: TextStyle(color: Colors.grey),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),),
                          ),
                          const SizedBox(height: 8),
                          // Başlangıç tarihini ve saati seçmek için
                          InkWell(
                            onTap: () async {
                              Timestamp? selectedTimestamp =
                              await _selectDateTime(context, timeStart);

                              DateTime selectedDateTime = selectedTimestamp.toDate(); // Convert to DateTime
                              setState(() {
                                timeStart = selectedDateTime;
                              });
                                                    },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Start Date and Time*',
                                labelStyle: TextStyle(color: Colors.grey),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    timeStart.toString().isNotEmpty
                                        ? DateFormat('dd/MM/yyyy - HH:mm').format(timeStart)
                                        : 'Select Start Date and Time',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.calendar_today, color: Colors.white,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Bitiş tarihini ve saati seçmek için
                          InkWell(
                            onTap: () async {
                              Timestamp? selectedTimestamp =
                              await _selectDateTime(context, timeEnd);

                              if (selectedTimestamp != null) {
                                DateTime selectedDateTime = selectedTimestamp.toDate(); // Convert to DateTime
                                setState(() {
                                  timeEnd = selectedDateTime;
                                });
                              }
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'End Date and Time*',
                                labelStyle: TextStyle(color: Colors.grey),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    timeEnd.toString().isNotEmpty
                                        ? DateFormat('dd/MM/yyyy - HH:mm').format(timeEnd)
                                        : 'Select End Date and Time',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.calendar_today,color: Colors.white,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _routeController,
                            style: const TextStyle(color: Colors.white),
                            readOnly: true, //veri girişini engeller
                            decoration: InputDecoration(
                              labelText: "Route (GPX File)",
                              suffixIconColor: Colors.white,
                              labelStyle: const TextStyle(color: Colors.grey),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              suffixIcon: IconButton(
                                  onPressed: () async {
                                    setState(() {isLoading = true;});
                                    filePickerResult  = await context.read<EditActivityScreenCubit>().pickRouteFile();
                                    if(filePickerResult != null) {
                                      selectedRoutePath = filePickerResult?.files.single.path;
                                      String fileName = selectedRoutePath!.split('/').last;
                                      setState(() {
                                        _routeController.text = fileName;
                                        selectedRouteName = fileName;
                                        isLoading = false;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.upload_file)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade800,
                                      shadowColor: Colors.grey,
                                      elevation: 10,
                                      foregroundColor: Colors.white),
                                  onPressed: () async {
                                    setState(() {isLoading = true;});
                                    await context.read<EditActivityScreenCubit>().editActivity(
                                      context: context,
                                      activityId: widget.activity.id,
                                      name: _nameController.text.trim(),
                                      city: _cityController.text.trim(),
                                      country: _countryController.text.trim(),
                                      activityImage: activityImageFile,
                                      photoUrl: widget.activity.photoUrl,
                                      timeStart: Timestamp.fromDate(timeStart),
                                      timeEnd: Timestamp.fromDate(timeEnd),
                                      routeUrl: widget.activity.routeUrl ?? "",
                                      routeName: selectedRouteName ?? "",
                                      routeGpxFile: filePickerResult,
                                    );
                                    setState(() {isLoading = false;});
                                  },
                                  child: const Text("Save Activity",style: TextStyle(fontSize: 20),)),
                              const SizedBox(height: 30,),
                              ElevatedButton(
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.grey.shade800,
                                   shadowColor: Colors.grey,
                                   elevation: 10
                                 //    backgroundColor: kSecondaryColor2,
                                 //    foregroundColor: Colors.white),
                                  ),
                                  onPressed: (){
                                    context.read<EditActivityScreenCubit>().deleteActivity(
                                      context: context,
                                      activityId: widget.activity.id,
                                      photoUrl: widget.activity.photoUrl!,
                                      routeUrl: widget.activity.routeUrl!,
                                    );
                                  },
                                  child: const Text("Delete Activity",style: TextStyle(fontSize: 20, color: Colors.red),)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if(isLoading) const CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

Future<Timestamp> _selectDateTime(
    BuildContext context,
    DateTime initialDateTime
    ) async {
  DateTime selectedDateTime = await showDatePicker(
    context: context,
    initialDate: initialDateTime,
    firstDate: initialDateTime,
    lastDate: DateTime(2101),
  ) ?? DateTime.now();

  TimeOfDay selectedTime = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(selectedDateTime),) ?? TimeOfDay.fromDateTime(DateTime.now());

  selectedDateTime = DateTime(
    selectedDateTime.year,
    selectedDateTime.month,
    selectedDateTime.day,
    selectedTime.hour,
    selectedTime.minute,
  );

  // Convert selectedDateTime to Timestamp
  Timestamp timestamp = Timestamp.fromDate(selectedDateTime);
  return timestamp;
}

