import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:team_tracking/data/entity/activities.dart';
import 'package:team_tracking/data/entity/lat_lng_with_altitude.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/data/repo/activity_dao_repository.dart';

class MapScreenForActivityCubit extends Cubit<List<Users>> {
  MapScreenForActivityCubit() : super([]);

  final userCollection = FirebaseFirestore.instance.collection("users");
  final activityCollection = FirebaseFirestore.instance.collection("activities");


  Timer? _trackMeTimer;
  Timer? _showAllOnMapTimer;
  List<LatLng> allUserLocations = [];
  //List<Users> allUserList = [];
  LatLng? myLocation;

  Future<void> cancelTimers() async{
    print("Timerlar durduruldu");
    _showAllOnMapTimer?.cancel();
    _trackMeTimer?.cancel();
  }

  //Future<void> runTrackMe(mapController) async {
  //  cancelTimers();
  //  await _trackMe(mapController);
  //  setMapPositionForMe(mapController);
  //  _trackMeTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
  //    await _trackMe(mapController);
  //  });
  //}

  Future<void> _runShowAllOnMap(mapController,memberIds) async {
    cancelTimers();
    await _showAllOnMap( mapController,memberIds);
    setMapPositionForAll(mapController);
    _showAllOnMapTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _showAllOnMap( mapController, memberIds);
    });
  }



  //TODO:Track Me Method (Shows only me on map)
  Future<void> _trackMe(MapController controller) async {

    //Son konumu al
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    LatLng myLastPosition = LatLng(position.latitude, position.longitude);
    myLocation = myLastPosition;

    // Mevcut kullanıcıyı al
    Users? currentUser = UsersManager().currentUser;

    //databasedeki konumu değil anlık konumu aldığımız için manuel user oluşturduk !!!
    if (currentUser != null) {
      List<Users> userList = [];
      Users u = Users(
        id: currentUser.id,
        name: currentUser.name,
        email: currentUser.email,
        photoUrl: currentUser.photoUrl ,
        lastLocation: myLastPosition, // !!!! geo locatordan gelen anlık konum
      );
      userList.add(u);
      emit([u]);
      for (int i=0; i < userList.length; i++) {
        print("trackMe çalışıyor for  ${userList[i].email}");
        print(userList[i].name);
        print("${position.latitude}");
        print("${position.longitude}");
      }
    }else {
      print("Kullanıcı giriş yapmamış.");
      // Kullanıcı giriş yapmamışsa gerekli işlemleri burada yapabilirsiniz.
    }
  }

  //TODO: Get activity member IDs method -----------
  Future<List<LatLngWithAltitude>> getActivityMembersAndShowMap(MapController mapController, Activities activity) async {
    try {
      DocumentSnapshot<
          Map<String, dynamic>> activityDocument = await activityCollection.doc(
          activity.id).get();
      Map<String, dynamic>? activityData = activityDocument.data();
      if (activityData != null) {
        List<dynamic> memberIdList = activityData["memberIds"];
        _runShowAllOnMap(mapController, memberIdList);
        // Extract GPX points and add them to gpxPoints
        if (activityData["gpxFilePath"] != null) {
          List<LatLngWithAltitude> gpxTrack = await ActivityDaoRepository.shared.extractGpxPointsFromFile(activityData["gpxFilePath"]);
          return gpxTrack;
        }
      }
    } catch (e) {
      print("Firestore veri çekme hatası-3: $e");
    }
    return [];
  }

  //TODO: Show all activity members method -----------
  Future<void> _showAllOnMap(MapController mapController, List<dynamic> memberIds) async {

    List<LatLng> userLocations = [];
    List<Users> userList = [];
    DateTime now = DateTime.now();

    // Kullanıcının konum izinlerini kontrol et
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Konum izni yoksa, izin iste
      await _requestLocationPermission();
      return;
    }

    for(var memberIs in memberIds){
      try {
        DocumentSnapshot<Map<String, dynamic>> userDocument = await userCollection.doc(memberIs).get();
        Map<String, dynamic>? userData = userDocument.data();
        if(userData != null){
          if (userData["lastLocation"] is Map<String, dynamic>) {
            DateTime lastLocationUpdatedAt = (userData["lastLocationUpdatedAt"] as Timestamp).toDate();
            Users u = Users.fromMap(userDocument.id, userData);
            // Son konumu belirli bir süre içinde güncellenmiş olanları al
            if(now.difference(lastLocationUpdatedAt).inMinutes <= 5) {
              userList.add(u);
              if (u.lastLocation?.latitude != null && u.lastLocation?.longitude != null) {
                userLocations.add(LatLng(u.lastLocation!.latitude, u.lastLocation!.longitude));
                print("${u.name} son konumu Firestore'dan alındı: ${u.lastLocation!.latitude} , ${u.lastLocation!.longitude}");
              }
            } else {
              print("${u.name} son konumu güncel değil: $lastLocationUpdatedAt");
            }
          }
        }
      }catch (e) {
        print("Firestore veri çekme hatası-1: $e");
      }
    }
    allUserLocations = userLocations;
    emit(userList);
    print("****** emited users ******");
    for( var u in userList){
      print("${u.name} -${u.lastLocation!.longitude} - ${u.lastLocation!.longitude} ");
    }
  }

  //TODO:Update Map position for all users
  Future<void> setMapPositionForAll(mapController) async {
    // harita konumunu güncelle
    LatLngBounds bounds = calculateBoundingBox(allUserLocations);
    mapController.fitBounds(
        bounds, options: const FitBoundsOptions(padding: EdgeInsets.all(30.0)));
  }

  Future<void> setMapPositionForMe(mapController) async {
    // harita konumunu güncelle
      mapController.move(myLocation, 17.0);
  }

  // TODO: SET MAP POSITION METHOD
  LatLngBounds calculateBoundingBox(List<LatLng> points) {
    double minLat = double.infinity;
    double minLng = double.infinity;
    double maxLat = -double.infinity;
    double maxLng = -double.infinity;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      LatLng(minLat, minLng),
      LatLng(maxLat, maxLng),
    );
  }

  //Get gpx point list from gpx file
  Future<List<LatLngWithAltitude>> extractGpxPointsFromFile (String gpxFilePath) async {
    return ActivityDaoRepository.shared.extractGpxPointsFromFile(gpxFilePath);
  }

  //Konum izni isteme metodu
  Future<void> _requestLocationPermission() async {
    // Konum izni iste
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied) {
      // Kullanıcı izni reddetti
      // Burada kullanıcıya bir bildirim veya açıklama gösterilebilir
      print('Konum izni reddedildi.');
    }
  }

}