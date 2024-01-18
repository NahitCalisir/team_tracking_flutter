import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:team_tracking/ui/cubits/map_screen_cubit.dart';
import '../../../../utils/myInput.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyMarkerLayerWithCircles extends StatelessWidget {
  final LatLng markerPoint;

  const MyMarkerLayerWithCircles({required this.markerPoint, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  MarkerLayer(
      markers: [
        //Üç halkalı canlı konum default marker
        Marker(height: 50,width: 50,
          point: markerPoint,
          rotate: true,
          child: CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blue.withOpacity(0.4),
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 6,
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }
}





