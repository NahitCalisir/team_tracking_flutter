import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:geocoding/geocoding.dart';
//import '../../../../utils/myInput.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:flutter_map/plugin_api.dart';
//import 'package:http/http.dart' as http;
//import 'dart:convert';

class MyMarkerLayerWithPinIcon extends StatelessWidget {
  final LatLng markerPoint;

  const MyMarkerLayerWithPinIcon({required this.markerPoint, super.key});

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: markerPoint,
          rotate: true, // Yön
          child: Container(
            child: const Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  bottom: 10, // İkinci dairenin yüksekliği
                  child: Icon(Icons.location_pin, color: Colors.red, size: 30),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}





