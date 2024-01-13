import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:team_tracking/data/entity/users.dart';

class MapScreenCubit extends Cubit<List<Users>> {
  MapScreenCubit() : super([]);

  Timer? _updateLocationsTimer;

  // Timer'ı başlatan metod
  Future<void> startLocationUpdates(MapController controller) async {
    bool isFirstRun = true;

    // Timer zaten çalışıyorsa durdur
    _updateLocationsTimer?.cancel();

    // Timer'ı her 3 saniyede bir çalıştır
    _updateLocationsTimer = Timer.periodic(Duration(seconds: 3), (timer) async {
      try {
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await FirebaseFirestore.instance.collection('users').get();

        List<LatLng> allUserLocations = [];
        List<Users> allUserList = [];

        for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot in querySnapshot.docs) {
          if (documentSnapshot.exists) {
            String id = documentSnapshot.id;
            Map<String, dynamic> userData = documentSnapshot.data();
            if (userData != null && userData.containsKey("lastLocation")) {
              Users u = Users.fromMap(id, userData);
              allUserList.add(u);
              if (u.lastLocation?.latitude != null &&
                  u.lastLocation?.longitude != null)
                allUserLocations.add(LatLng(u.lastLocation!.latitude,
                    u.lastLocation!.longitude));
            }
          }
        }

        // Sadece ilk çalıştırmada harita konumunu güncelle
        if (isFirstRun && allUserList.isNotEmpty && controller != null) {
          LatLngBounds bounds = calculateBoundingBox(allUserLocations);
          controller.fitBounds(
              bounds, options: FitBoundsOptions(padding: EdgeInsets.all(30.0)));
          isFirstRun = false;
        }

        // State'i güncelle (Tüm kullanıcı konumlarını göster)
        emit(allUserList);
      } catch (e) {
        print("Firestore veri çekme hatası: $e");
      }
    });
  }


  //Get Current Location of the user with timer
  Future<void> trackMe(MapController controller) async {
    // Mevcut kullanıcıyı al
    final FirebaseAuth _auth = FirebaseAuth.instance;
    User? currentUser = _auth.currentUser;

    // Timer zaten çalışıyorsa durdur
    _updateLocationsTimer?.cancel();

    //Her 3 sn de konumu al
    _updateLocationsTimer = Timer.periodic(Duration(seconds: 3), (Timer timer) async {
          //Son konumu al
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          final myLastPosition = LatLng(position.latitude, position.longitude);

          if (currentUser != null) {
            // Firestore'da kullanıcının son konumunu güncelle
            await FirebaseFirestore.instance.collection('users').doc(
                currentUser.uid).update({
              "lastLocation": {
                "latitude": myLastPosition.latitude,
                "longitude": myLastPosition.longitude,
              },
            });

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
                Users u = Users.fromMap(id, userData);
                allUserList.add(u);
                print(allUserList[0].email);
              }
              emit(allUserList);
              // Harita konumunu güncelle(Başlangıç konumuna odaklar)
              if (allUserList.isNotEmpty) {
                controller.move(myLastPosition, 17.0);
              }
            } else {
              print("Kullanıcı giriş yapmamış.");
              // Kullanıcı giriş yapmamışsa gerekli işlemleri burada yapabilirsiniz.
            }
          }
        }
      );
    }


    //Get Current Location of the user without timer
    Future<void> getMyLocation(MapController controller) async {
      LatLng myLastPosition = LatLng(0, 0);
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);


      myLastPosition = LatLng(position.latitude, position.longitude);

      // Mevcut kullanıcıyı al
      final FirebaseAuth _auth = FirebaseAuth.instance;
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        List<Users> cuser = [];

        // Firestore'dan kullanıcı verilerini çek
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(
            currentUser.uid).get();

        String id = documentSnapshot.id;
        Map<String, dynamic>? userData = documentSnapshot.data();
        if (userData != null && userData.containsKey("lastLocation")) {
          Users u = Users.fromMap(id, userData);
          cuser.add(u);
          print(cuser[0].lastLocation?.longitude);
          emit(cuser);
        }


        // Harita konumunu güncelle(Başlangıç konumuna odaklar)
        if (cuser.isNotEmpty) {
          controller.move(myLastPosition, 17.0);
        }
      }
    }

  //SET MAP POSITION METHOD
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