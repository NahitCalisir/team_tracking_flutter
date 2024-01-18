import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:flutter_map/plugin_api.dart';
import 'package:team_tracking/data/entity/users.dart';

class MapScreenCubit extends Cubit<List<Users>> {
  MapScreenCubit() : super([]);

  Timer? _updateMyLocationTimer;
  Timer? _trackMeTimer;
  Timer? _showAllOnMapTimer;
  List<LatLng> allUserLocations = [];
  List<Users> allUserList = [];
  LatLng? myLocation;

  void cancelTimers(){
    print("Timer durduruldu");
    _showAllOnMapTimer?.cancel();
    _trackMeTimer?.cancel();
  }

  Future<void> runUpdateMyLocation() async {
    await updateMyLocation();
    _updateMyLocationTimer = Timer.periodic(Duration(seconds: 300), (timer) async {
      await updateMyLocation();
    });
  }

  Future<void> runTrackMe(mapController) async {
    cancelTimers();
    await trackMe(mapController);
    setMapPositionForMe(mapController);
    _trackMeTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
      await trackMe(mapController);
    });
  }

  Future<void> runShowAllOnMap(mapController) async {
    cancelTimers();
    await showAllOnMap( mapController);
    setMapPositionForAll(mapController);
    _showAllOnMapTimer = Timer.periodic(Duration(seconds: 5), (timer) async {
     await showAllOnMap( mapController);
    });
  }

  //TODO: Update my location, send to firestore method
  Future<void> updateMyLocation() async {
    // Timer zaten çalışıyorsa durdur
    _updateMyLocationTimer?.cancel();

    //Mevcut kullanıcıyı al
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? currentUser = _auth.currentUser;

    //Son konumu al
    Position myLastPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (currentUser != null) {
      // Firestore'da kullanıcının son konumunu güncelle
      await FirebaseFirestore.instance.collection('users').doc(
          currentUser.uid).update({
        "lastLocation": {
          "latitude": myLastPosition.latitude,
          "longitude": myLastPosition.longitude,
        },
      });
      print("${currentUser.displayName} son konumum firestora gönerildi");
    }
  }

  //TODO:Track Me Method (Shows only me on map)
  Future<void> trackMe(MapController controller) async {

    // Mevcut kullanıcıyı al
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? currentUser = _auth.currentUser;

    //Son konumu al
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final myLastPosition = LatLng(position.latitude, position.longitude);
    myLocation = myLastPosition;

    if (currentUser != null) {
      // Firestore'dan kullanıcı verilerini çek
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await FirebaseFirestore.instance.collection('users')
          .doc(currentUser.uid)
          .get();

      //Çekilen documandan Users modelinde kullanıcı oluştur
      List<Users> allUserList = [];
      List<LatLng> allUserLocations = [];
      if (documentSnapshot.exists) {
        String id = documentSnapshot.id;
        Map<String, dynamic>? userData = documentSnapshot.data();
        if (userData != null && userData.containsKey("lastLocation")) {
          Users u = Users(
            id: id,
            name: userData["name"],
            email: userData["email"],
            photoUrl: userData["photoUrl"] ,
            lastLocation: myLastPosition,
          );
          allUserList.add(u);
        }

        // Harita konumunu güncelle(Başlangıç konumuna odaklar)
        //if (allUserList.isNotEmpty) {
        //  controller.move(myLastPosition, 17.0);
        //}
        emit(allUserList);
        print("${currentUser.displayName} trackMe çalışıyor");
      } else {
        print("Kullanıcı giriş yapmamış.");
        // Kullanıcı giriş yapmamışsa gerekli işlemleri burada yapabilirsiniz.
      }
    }
  }


  //TODO: Show all group members method -----------
  Future<void> showAllOnMap(MapController mapController) async {
    bool isFirstRun = true;

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('users').get();

      List<LatLng> userLocations = [];
      List<Users> userList = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
        if (documentSnapshot.exists) {
          String id = documentSnapshot.id;
          Map<String, dynamic> userData = documentSnapshot.data();
          if (userData != null && userData.containsKey("lastLocation")) {
            Users u = Users.fromMap(id, userData);
            userList.add(u);
            if (u.lastLocation?.latitude != null && u.lastLocation?.longitude != null){
              userLocations.add(LatLng(u.lastLocation!.latitude, u.lastLocation!.longitude));
            }
            allUserList = userList;
            allUserLocations = userLocations;
            print(u.name);
          }
        }
      }
      // State'i güncelle (Tüm kullanıcı konumlarını göster)
      emit(userList);
    } catch (e) {
      print("Firestore veri çekme hatası: $e");
    }
  }

  //TODO:Update Map position for all users
  Future<void> setMapPositionForAll(mapController) async {
    // harita konumunu güncelle
    LatLngBounds bounds = calculateBoundingBox(allUserLocations);
    mapController.fitBounds(
        bounds, options: FitBoundsOptions(padding: EdgeInsets.all(30.0)));
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

}