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
                          await context.read<CreateActivityScreenCubit>().pickImage();
                          setState(() {isLoading = false;});
                        },
                        child: activityImageFile == null
                            ? const CircleAvatar(
                                backgroundColor: kSecondaryColor2,
                                radius: 50,
                                child: Icon(
                                  Icons.add_a_photo,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              )
                            : CircleAvatar(
                                backgroundColor: kSecondaryColor2,
                                radius: 50,
                                child: ClipOval(
                                  child: Image(
                                    image: FileImage(activityImageFile),
                                    fit: BoxFit.cover,
                                    height: 100,
                                    width: 100,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _nameController,
                        decoration:
                            const InputDecoration(labelText: " Activity Name*"),
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
                      const SizedBox(height: 8),
                      // Başlangıç tarihini ve saati seçmek için
                      InkWell(
                        onTap: () async {
                          Timestamp? selectedTimestamp =
                          await _selectDateTime(context, timeStart);

                          if (selectedTimestamp != null) {
                            DateTime selectedDateTime = selectedTimestamp.toDate(); // Convert to DateTime
                            setState(() {
                              timeStart = selectedDateTime;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Start Date and Time*',
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                timeStart != null
                                    ? DateFormat('MM/dd/yyyy - HH:mm').format(timeStart)
                                    : 'Select Start Date and Time',
                              ),
                              const Icon(Icons.calendar_today),
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
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                timeEnd != null
                                    ? DateFormat('MM/dd/yyyy - HH:mm').format(timeEnd)
                                    : 'Select End Date and Time',
                              ),
                              const Icon(Icons.calendar_today),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: TextEditingController(text: selectedRouteName),
                        readOnly: true, //veri girişini engeller
                        decoration: InputDecoration(
                          labelText: "Route (GPX File)",
                          suffixIcon: IconButton(
                              onPressed: () async {
                                setState(() {isLoading = true;});
                                FilePickerResult? result  = await context.read<CreateActivityScreenCubit>().pickRouteFile();
                                if(result != null) {
                                  selectedRoutePath = result.files.single.path;
                                  String fileName = selectedRoutePath!.split('/').last;
                                  routeDownloadUrl = await context.read<CreateActivityScreenCubit>().uploadPickerResultToFirestore(result);
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
                          backgroundColor: kSecondaryColor2,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                            context.read<CreateActivityScreenCubit>().saveActivity(
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




