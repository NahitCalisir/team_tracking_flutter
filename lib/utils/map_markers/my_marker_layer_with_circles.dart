import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:flutter_map/plugin_api.dart';

class MyMarkerLayerWithCircles extends StatelessWidget {
  final LatLng markerPoint;

  const MyMarkerLayerWithCircles({required this.markerPoint, super.key});

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





