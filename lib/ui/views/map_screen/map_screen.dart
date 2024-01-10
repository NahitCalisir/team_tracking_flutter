import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:team_tracking/ui/cubits/map_screen_cubit.dart';
import 'package:team_tracking/utils/map_markers/my_marker_layer_with_circles.dart';
import 'package:team_tracking/utils/map_markers/my_marker_layer_with_image.dart';
import 'package:team_tracking/utils/map_markers/my_marker_layer_with_pin_icon.dart';
import '../../../utils/myInput.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MapScreenCubit(),
      child: MapScreenContent(),
    );
  }
}

class MapScreenContent extends StatelessWidget {

  final TextEditingController start = TextEditingController(text: "34740 bostancı");
  final TextEditingController end = TextEditingController(text: "34870 kartal");
  MapController _mapController = MapController();


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapScreenCubit, List<LatLng>>(
      builder: (context, routpoints) {
        return Scaffold(
          backgroundColor: Colors.grey.shade300,
          body: SafeArea(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: routpoints.isNotEmpty ? routpoints[0] : LatLng(0, 0),
                    //zoom: 17,
                    maxZoom: 18,
            ),
                  nonRotatedChildren: const [
                    SimpleAttributionWidget(
                      source: Text('OpenStreetMap '),
                    ),
                  ],
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.nahitcalisir.team_tracking',
                    ),
                    PolylineLayer(
                      polylineCulling: false,
                      polylines: [
                        Polyline(points: routpoints, color: Colors.blue, strokeWidth: 6),
                      ],
                    ),
                    //My Custom Marker Layers
                    MyMarkerLayerWithImage(markerPoint: routpoints.first,imageUrl: "http://nahitcalisir.online/images/nahit.jpg",),
                    MyMarkerLayerWithCircles(markerPoint: routpoints.last),
                    MyMarkerLayerWithPinIcon(markerPoint: routpoints.last),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      myInput(controller: start, hint: "Enter Starting PostCode"),
                      const SizedBox(height: 15),
                      myInput(controller: end, hint: "Enter Ending PostCode"),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                        onPressed: () async {
                          // Rotayı oluştur
                          await context.read<MapScreenCubit>().createRoute(start, end, _mapController);
                        },
                        child: const Text("Route", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


