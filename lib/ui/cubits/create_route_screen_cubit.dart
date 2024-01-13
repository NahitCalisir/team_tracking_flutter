import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:team_tracking/data/entity/users.dart';

class CreateRouteScreenCubit extends Cubit<List<LatLng>> {
  CreateRouteScreenCubit() : super([LatLng(37.4219983, -122.084)]);





  Future<void> createRoute(TextEditingController start, TextEditingController end, MapController controller) async {
    List<Location> startLocations = await locationFromAddress(start.text);
    List<Location> endLocations = await locationFromAddress(end.text);

    var startLatitude = startLocations[0].latitude;
    var startLongitude = startLocations[0].longitude;
    var endLatitude = endLocations[0].latitude;
    var endLongitude = endLocations[0].longitude;

    var url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/$startLongitude,$startLatitude;$endLongitude,$endLatitude?steps=true&annotations=true&geometries=geojson&overview=full');

    var response = await http.get(url);
    List<LatLng> routePoints = [];

    var routes = jsonDecode(response.body)['routes'];
    if (routes != null && routes.isNotEmpty) {
      var ruter = routes[0]['geometry']['coordinates'];
      for (int i = 0; i < ruter.length; i++) {
        var reep = ruter[i].toString();
        reep = reep.replaceAll("[", "").replaceAll("]", "");
        var lat1 = reep.split(',');
        routePoints.add(LatLng(double.parse(lat1[1]), double.parse(lat1[0])));
      }
    }
    // Harita konumunu güncelle(Başlangıç konumuna odaklar)
    //if (routePoints.isNotEmpty && controller != null) {
    //  controller!.move(routePoints[0], 17.0);
    //}

    // Harita konumunu güncelle(rotanın bütününü gösterir)
    if (routePoints.isNotEmpty && controller != null) {
      LatLngBounds bounds = calculateBoundingBox(routePoints);
      controller.fitBounds(bounds, options: FitBoundsOptions(padding: EdgeInsets.all(30.0)));
    }
    emit(routePoints);
  }




}

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

