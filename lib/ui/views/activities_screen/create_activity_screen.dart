import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
  DateTime timeStart = DateTime.now();
  DateTime timeEnd = DateTime.now();
  String? selectedRoutePath;
  String? selectedRouteName;
  String? routeDownloadUrl;
  double? routeDistance;
  double? routeElevation;
  FilePickerResult? filePickerResult;

  @override
  void initState() {
    context.read<CreateActivityScreenCubit>().resetImage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateActivityScreenCubit, File?>(
      builder: (context, activityImageFile) {
        return Stack(
          fit: StackFit.expand,
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
                title: const Text("Create Activity"),
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
                              await context.read<CreateActivityScreenCubit>().pickImage();
                              setState(() {isLoading = false;});
                            },
                            child: activityImageFile == null ?
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: const Icon(
                                Icons.add_a_photo,
                                color: Colors.grey, // İkonun rengini belirleyin
                                size: 100, // İkonun boyutunu belirleyin
                              ),
                            ) :
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
                            decoration:
                            InputDecoration(
                                  labelText: " Activity Name*",
                                  labelStyle: TextStyle(color: Colors.grey.shade700),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _cityController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              labelText: "City*",
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _countryController,
                            style: const TextStyle(color: Colors.white),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              labelText: "Country*",
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
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
                              decoration: InputDecoration(
                                labelText: 'Start Date and Time*',
                                suffixIconColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.grey.shade700),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    timeStart != null
                                        ? DateFormat('MM/dd/yyyy - HH:mm').format(timeStart)
                                        : 'Select Start Date and Time',
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
                          // Bitiş tarihini ve saati seçmek için
                          InkWell(
                            onTap: () async {
                              Timestamp? selectedTimestamp =
                              await _selectDateTime(context, timeEnd ?? DateTime.now());

                              DateTime selectedDateTime = selectedTimestamp.toDate(); // Convert to DateTime
                              setState(() {
                                timeEnd = selectedDateTime;
                              });
                                                    },
                            child: InputDecorator(
                              decoration: InputDecoration(
                                labelText: 'End Date and Time*',
                                suffixIconColor: Colors.white,
                                labelStyle: TextStyle(color: Colors.grey.shade700),
                                focusedBorder: const UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.white),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    timeEnd != null
                                        ? DateFormat('MM/dd/yyyy - HH:mm').format(timeEnd)
                                        : 'Select End Date and Time',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8.0),
                                    child: Icon(Icons.calendar_today, color:  Colors.white,),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: TextEditingController(text: selectedRouteName),
                            readOnly: true, //veri girişini engeller
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: "Route (GPX File)",
                              suffixIconColor: Colors.white,
                              labelStyle: TextStyle(color: Colors.grey.shade700),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                              suffixIcon: IconButton(
                                  onPressed: () async {
                                    setState(() {isLoading = true;});
                                    FilePickerResult? result  = await context.read<CreateActivityScreenCubit>().pickRouteFile();
                                    if(result != null) {
                                      selectedRoutePath = result.files.single.path;
                                      String fileName = selectedRoutePath!.split('/').last;
                                      //routeDownloadUrl = await context.read<CreateActivityScreenCubit>().uploadPickerResultToFirestore(result);
                                      setState(() {
                                        selectedRouteName = fileName;
                                        isLoading = false;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.upload_file)),
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 10,
                              backgroundColor: Colors.grey.shade800,
                              foregroundColor: Colors.white,
                              shadowColor: Colors.grey
                            ),
                            onPressed: () async {
                             //if(filePickerResult != null) {
                             //  routeDownloadUrl = await context.read<CreateActivityScreenCubit>().uploadPickerResultToFirestore(filePickerResult!);
                             //}
                              setState(() {isLoading = true;});
                              await context.read<CreateActivityScreenCubit>().saveActivity(
                                context: context,
                                name: _nameController.text.trim(),
                                city: _cityController.text.trim(),
                                country: _countryController.text.trim(),
                                activityImage: activityImageFile,
                                timeStart: Timestamp.fromDate(timeStart),
                                timeEnd: Timestamp.fromDate(timeEnd),
                                routeUrl: routeDownloadUrl ?? "",
                                routeName: selectedRouteName ?? "",
                              );
                              setState(() {isLoading = false;});
                            },
                            child: const Text("Create Activity",
                                style: TextStyle(fontSize: 20)),
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

  Future<Timestamp> _selectDateTime(
      BuildContext context,
      DateTime initialDateTime
      ) async {
    DateTime selectedDateTime = await showDatePicker(
      context: context,
      initialDate: initialDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    ) ?? DateTime.now();

    TimeOfDay selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedDateTime),
    ) ?? TimeOfDay.fromDateTime(DateTime.now());

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
}




