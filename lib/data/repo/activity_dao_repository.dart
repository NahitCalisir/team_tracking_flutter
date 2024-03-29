import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:team_tracking/data/entity/activities.dart';
import 'package:team_tracking/data/entity/lat_lng_with_altitude.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/ui/views/activities_screen/activity_members_screen.dart';
import 'package:team_tracking/utils/constants.dart';
import 'package:team_tracking/data/repo/helper_functions.dart';
import 'package:xml/xml.dart';

import '../entity/users.dart';

class ActivityDaoRepository {

  static ActivityDaoRepository shared = ActivityDaoRepository();

  final userCollection = FirebaseFirestore.instance.collection("users");
  final activityCollection = FirebaseFirestore.instance.collection("activities");


  //TODO Register Activity in to firestore
  Future<void> registerActivity(
      {
        required String name,
        required String city,
        required String country,
        required String owner,
        required List<String> memberIds,
        required Timestamp timeStart,
        required Timestamp timeEnd,
        String? photoUrl,
        List<String>? joinRequests,
        String? routeUrl,
        String? routeName,
        double? routeDistance,
        double? routeElevation,
      }) async {
    var newActivity = {
      "name": name,
      "city": city,
      "country": country,
      "owner": owner,
      "memberIds": memberIds,
      "photoUrl": photoUrl,
      "joinRequests": joinRequests,
      "timeStart" : timeStart ,
      "timeEnd" : timeEnd,
      "routeUrl" :routeUrl,
      "routeName" :routeName,
      "routeDistance" :routeDistance,
      "routeElevation" :routeElevation,
    };
    await activityCollection.doc().set(newActivity);
  }

  //TODO Update Activity in the firestore
  Future<void> updateActivity(
      {
        required String activityId,
        required String name,
        required String city,
        required String country,
        String? photoUrl,
        required Timestamp timeStart,
        required Timestamp timeEnd,
        String? routeUrl,
        String? routeName,
        double? routeDistance,
        double? routeElevation,
      }) async {
    var updatedData = {
      "name": name,
      "city": city,
      "country": country,
      "photoUrl": photoUrl,
      "timeStart" : timeStart ,
      "timeEnd" : timeEnd,
      "routeUrl" :routeUrl,
      "routeName" :routeName,
      "routeDistance" :routeDistance,
      "routeElevation" :routeElevation,
    };
    await activityCollection.doc(activityId).update(updatedData);
  }


  Future<void> createActivity({
    required BuildContext context,
    required String name,
    required String city,
    required String country,
    required File? activityImage,
    required Timestamp timeStart,
    required Timestamp timeEnd,
    FilePickerResult? routeGpxFile,
    String? routeUrl,
    String? routeName,
  }) async {
    if (name.isNotEmpty && city.isNotEmpty && country.isNotEmpty && timeStart.toString().isNotEmpty && timeEnd.toString().isNotEmpty) {
      if(timeEnd.toDate().isAfter(timeStart.toDate())) {
        //Upload activity image
        String imageUrl = "";
        if (activityImage != null) {
          imageUrl = await uploadActivityImage(activityImage);
        }
        if (routeGpxFile != null) {
          deleteActivityGpxFile(routeUrl ?? "");
          routeUrl = await uploadPickerResultToStorage(routeGpxFile);
        }
        //Register activity to firestore
        String owner = UsersManager().currentUser!.id;
        List<String> memberIds = [UsersManager().currentUser!.id];
        List<String> joinRequests = [];
        //Update activity in firestore
        double routeDistance = 0.0;
        double routeElevation = 0.0;
        if(routeUrl != "") {
          List<LatLngWithAltitude> gpxPoints = await extractGpxPointsFromFile(routeUrl!);
          routeDistance = calculateRouteDistance(gpxPoints);
          routeElevation = calculateRouteElevation(gpxPoints);
        }
        registerActivity(
          name: name,
          city: city,
          country: country,
          owner:  owner,
          memberIds: memberIds,
          photoUrl: imageUrl,
          joinRequests: joinRequests,
          timeStart : timeStart ,
          timeEnd : timeEnd,
          routeUrl : routeUrl,
          routeName : routeName,
          routeDistance :routeDistance,
          routeElevation :routeElevation,
        );
        Navigator.pop(context);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor2,
              title: const Text("Warning",style: TextStyle(color: Colors.white),),
              content: const Text("End time must be after start time.",style: TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK",style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kSecondaryColor,
            title: const Text("Warning",style: TextStyle(color: Colors.white),),
            content: const Text("Please fill in all fields!",style: TextStyle(color: Colors.white),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK",style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> editActivity({
    required BuildContext context,
    required String activityId,
    required String name,
    required String city,
    required String country,
    File? activityImage,
    String? photoUrl,
    required Timestamp timeStart,
    required Timestamp timeEnd,
    FilePickerResult? routeGpxFile,
    String? routeUrl,
    String? routeName,
  }) async {
    if (name.isNotEmpty && city.isNotEmpty && country.isNotEmpty && timeStart.toString().isNotEmpty && timeEnd.toString().isNotEmpty) {
      if(timeEnd.toDate().isAfter(timeStart.toDate())) {
        //Upload activity image
        String imageUrl = photoUrl ?? "";
        if (activityImage != null) {
          deleteActivityImage(photoUrl ?? "");
          imageUrl = await uploadActivityImage(activityImage);
        }
        if (routeGpxFile != null) {
          deleteActivityGpxFile(routeUrl ?? "");
          routeUrl = await uploadPickerResultToStorage(routeGpxFile);
        }
        //Update activity in firestore
        double routeDistance = 0.0;
        double routeElevation = 0.0;
        if(routeUrl != "") {
          List<LatLngWithAltitude> gpxPoints = await extractGpxPointsFromFile(routeUrl!);
          routeDistance = calculateRouteDistance(gpxPoints);
          routeElevation = calculateRouteElevation(gpxPoints);
        }
        updateActivity(
          activityId: activityId,
          name: name,
          city: city,
          country: country,
          photoUrl: imageUrl,
          timeStart : timeStart ,
          timeEnd : timeEnd,
          routeUrl : routeUrl,
          routeName : routeName,
          routeDistance :routeDistance,
          routeElevation :routeElevation,
        );
        Navigator.pop(context);
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor,
              title: const Text("Warning",style: TextStyle(color: Colors.white),),
              content: const Text("End time must be after start time.",style: TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK",style: TextStyle(color: Colors.white),),
                ),
              ],
            );
          },
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kSecondaryColor,
            title: const Text("Warning",style: TextStyle(color: Colors.white),),
            content: const Text("Please fill in all fields!",style: TextStyle(color: Colors.white),),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK",style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        },
      );
    }
  }


  Future<void> deleteActivity({
    required BuildContext context,
    required String activityId,
    required String photoUrl,
    required String routeUrl,
  }) async {
    // Delay the execution of the dialog to allow the saveActivity method to complete
    await Future.delayed(Duration.zero, () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kSecondaryColor,
            title: const Text("Warning",style: TextStyle(color: kSecondaryColor2),),
            content: const Text("Are you sure you want to delete this activity?",style: TextStyle(color: Colors.white),),
            actions: [
              TextButton(
                onPressed: () {
                  deleteActivityFromFirestore(activityId: activityId, photoUrl: photoUrl, routeUrl: routeUrl);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                child: const Text("Delete",style: TextStyle(color: Colors.red),),
              ),
            ],
          );
        },
      );
    });
  }

  //TODO Delete Activity from the firestore
  Future<void> deleteActivityFromFirestore({
    required String activityId,
    required String photoUrl,
    required String routeUrl,
  }) async {
    try {
      await activityCollection.doc(activityId).delete();
      print("Activity deleted successfully!");
      await deleteActivityImage(photoUrl);
      await deleteActivityGpxFile(routeUrl);
    } catch (error) {
      print("Error deleting activity: $error");
      // Hata durumunda gerekli işlemleri yapabilirsiniz.
    }
  }


  //TODO: Upload Activity image to firebase storage
  Future<String> uploadActivityImage(File imageFile) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      String? userName = FirebaseAuth.instance.currentUser?.displayName ?? "";
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String fileName = 'activity_images/${userId}_${userName}_${timestamp}.jpg';

      // Upload the resized image to Firebase Storage
      File resizedImageFile = await HelperFunctions.resizeImage(imageFile, 200, 200);
      await FirebaseStorage.instance.ref(fileName).putFile(resizedImageFile);

      // Get the download URL of the uploaded image
      String imageUrl = await FirebaseStorage.instance.ref(fileName).getDownloadURL();

      return imageUrl;
    } catch (e) {
      print("Error uploading image: $e");
      return "";
    }
  }


  Future<void> deleteActivityImage(String imageUrl) async {
    try {
      Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    } catch (e) {
      print("Error deleting image: $e");
    }
  }
  Future<void> deleteActivityGpxFile(String routeUrl) async {
    try {
      Reference storageRef = FirebaseStorage.instance.refFromURL(routeUrl);
      await storageRef.delete();
    } catch (e) {
      print("Error deleting gpx file: $e");
    }
  }


  void checkActivityMembershipAndNavigate(BuildContext context, Activities selectedActivity) {
    // Grup üyeliğini kontrol et
    bool isMember = selectedActivity.memberIds.contains(UsersManager().currentUser!.id);

    if (isMember) {
      // Kullanıcı grup üyesiyse UsersScreen'e git
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ActivityMembersScreen(activity: selectedActivity),
        ),
      );
    } else {
      // Kullanıcı grup üyesi değilse uyarı göster
      showMembershipAlert(context,selectedActivity.id);
    }
  }

  void showMembershipAlert(BuildContext context, String activityId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: kSecondaryColor,
          title: const Text("Warning",style: TextStyle(color: kSecondaryColor2),),
          content: const Text("You are not a member of this activity. Send a request to join.",style: TextStyle(color: Colors.white),),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel",style: TextStyle(color: kSecondaryColor2),),
            ),
            TextButton(
              onPressed: () {
                sendRequestToJoinActivity(context, activityId);
                Navigator.of(context).pop();
              },
              child: const Text("Send Request",style: TextStyle(color: kSecondaryColor2),),
            ),
          ],
        );
      },
    );
  }

  // TODO: Altivite üyeliği için istek gönderme işlemleri
  void sendRequestToJoinActivity(BuildContext context, String activityId) async {
    print("istek gönderme başlatıldı");
    String userId = UsersManager().currentUser!.id;
    await activityCollection.doc(activityId).update(
        {"joinRequests": FieldValue.arrayUnion([userId])},
    );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Request sent successfully.",style: TextStyle(color: kSecondaryColor),),
          backgroundColor: kSecondaryColor2,
          duration: Durations.extralong4
      ),);
    notifyActivityOwner(activityId, userId);
  }
  // TODO:Notify activity owner about join request
  void notifyActivityOwner(String activityId, String userId) {
    // notification logic here
    // Firebase Cloud Messaging (FCM) or push notification
  }
  //TODO: accept join request
  Future<void> acceptJoinRequest(Activities activity, Users user) async {
    await activityCollection.doc(activity.id).update({
      "memberIds": FieldValue.arrayUnion([user.id]),
      "joinRequests": FieldValue.arrayRemove([user.id]),
    });
  }
  //TODO: reject join request
  Future<void> rejectJoinRequest(Activities activity, Users user) async {
    await activityCollection.doc(activity.id).update({
      "joinRequests": FieldValue.arrayRemove([user.id]),
    });
  }
  //TODO: remove from activity
  Future<void> removeFromActivity(Activities activity, Users user) async {
    await activityCollection.doc(activity.id).update({
      "memberIds": FieldValue.arrayRemove([user.id]),
    });
  }
  //TODO: Cancel request to join activity
  Future<void> cancelRequest(Activities activity, Users user) async {
    await activityCollection.doc(activity.id).update({
      "joinRequests": FieldValue.arrayRemove([user.id]),
    });
  }



  // Dosya seçme işlemi
  Future<FilePickerResult?> pickRouteFile() async {
    // Dosya seçiciyi kullanarak dosya seçme işlemi
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      //allowedExtensions: ["gpx"],
    );
    if (result != null) {
      //String? path = result.files.single.path;
      //File file = File(path!);
      return result;
    } else {
      return null;
    }
  }

  Future<String?> uploadPickerResultToStorage(FilePickerResult pickerResult) async {
    String path = pickerResult.files.single.path ?? "";
    String name = path.split('/').last;
    File file = File(path);
    FirebaseStorage storage = FirebaseStorage.instance;
    try {
      String fileName = "${name}_${DateTime.now().millisecondsSinceEpoch}.gpx";
      await storage.ref("route_files/$fileName").putFile(file);
      String uploadedFileUrl = await storage.ref("route_files/$fileName").getDownloadURL();
      return uploadedFileUrl;
    } catch(e) {
      print("File upload error : Dosya Yükleme hatası");
      return null;
    }
  }

  //Get gpx point list from gpx file
  Future<List<LatLngWithAltitude>> extractGpxPointsFromFile(String gpxUrl) async {
    final FirebaseStorage storage = FirebaseStorage.instance;
    final Reference ref = storage.refFromURL(gpxUrl);

    try {
      final Uint8List? data = await ref.getData();
      if (data != null) {
        final ByteData byteData = ByteData.sublistView(data);
        final String gpxContent = String.fromCharCodes(byteData.buffer.asUint8List());
        return _extractGpxPoints(gpxContent);
      } else {
        print("Error: Empty data received");
        return [];
      }
    } catch (e) {
      print("Error downloading or extracting GPX: $e");
      return [];
    }
  }

  List<LatLngWithAltitude> _extractGpxPoints(String gpxContent) {
    final XmlDocument xmlDocument = XmlDocument.parse(gpxContent);

    final List<LatLngWithAltitude> gpxPoints = [];

    try {
      final List<XmlElement> trackPoints = xmlDocument
          .findAllElements('trkpt')
          .toList();

      for (final trackPoint in trackPoints) {
        final double lat = double.parse(trackPoint.getAttribute('lat') ?? '0');
        final double lon = double.parse(trackPoint.getAttribute('lon') ?? '0');
        final double altitude = double.parse(trackPoint.findElements('ele').first.text);
        gpxPoints.add(LatLngWithAltitude(lat, lon, altitude));
      }
    } catch (e) {
      print("Error extracting GPX points: $e");
    }
    return gpxPoints;
  }

  //CALCULATE ROUTE DISTANCE
  double calculateRouteDistance(List<LatLngWithAltitude> gpxPoints) {
    double totalDistance = 0;
    if (gpxPoints.length < 2) {
      // En az iki nokta olmalıdır
      return 0.0;
    }

    for (int i = 1; i < gpxPoints.length; i++) {
      // İki ardışık nokta arasındaki mesafeyi hesapla
      double distance = _calculateDistance(gpxPoints[i - 1], gpxPoints[i]);
      totalDistance += distance;
    }
    return totalDistance/1000;
  }

  double _calculateDistance(LatLngWithAltitude point1, LatLngWithAltitude point2) {
    const int earthRadius = 6371000; // Dünya yarıçapı metre cinsinden
    double lat1Rad = _degreesToRadians(point1.latitude);
    double lat2Rad = _degreesToRadians(point2.latitude);
    double latDeltaRad = _degreesToRadians(point2.latitude - point1.latitude);
    double lonDeltaRad = _degreesToRadians(point2.longitude - point1.longitude);

    double a = sin(latDeltaRad / 2) * sin(latDeltaRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(lonDeltaRad / 2) * sin(lonDeltaRad / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;
    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }

  //CALCULATE ROUTE ELEVATION
  double calculateRouteElevation(List<LatLngWithAltitude> gpxPoints) {
    double totalElevation = 0;
    if (gpxPoints.length < 2) {
      // En az iki nokta olmalıdır
      return 0.0;
    }

    for (int i = 1; i < gpxPoints.length; i++) {
      // İki ardışık nokta arasındaki elevasyon farkını hesapla
      double elevationChange = gpxPoints[i].altitude - gpxPoints[i - 1].altitude;
      if (elevationChange > 0) {
        totalElevation += elevationChange;
      }
    }
    return totalElevation;
  }

}

