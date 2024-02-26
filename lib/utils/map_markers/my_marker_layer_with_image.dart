import 'package:flutter/material.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:geocoding/geocoding.dart';
//import '../../../../utils/myInput.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:flutter_map/plugin_api.dart';

class MyMarkerLayerWithImage extends StatelessWidget {
  final LatLng markerPoint;
  final String imageUrl;

  const MyMarkerLayerWithImage({required this.markerPoint,required this.imageUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return MarkerLayer(
      markers: [
        Marker(
          point: markerPoint,
          rotate: true,
          height: 155,
          width: 86,
          child: Container(
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Icon(Icons.location_pin, size: 84, color: Colors.red.shade900,),
                Positioned(
                  top: 10,
                  left: 20,
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(
                        imageUrl,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}





