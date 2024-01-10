import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:team_tracking/ui/cubits/map_screen_cubit.dart';
import 'myInput.dart';
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

  final TextEditingController start = TextEditingController();
  final TextEditingController end = TextEditingController();
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
                    zoom: 17,
                  ),
                  nonRotatedChildren: const [
                    SimpleAttributionWidget(
                      source: Text('OpenStreetMap contributors'),
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
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      myInput(controller: start, hint: "Enter Starting PostCode"),
                      SizedBox(height: 15),
                      myInput(controller: end, hint: "Enter Ending PostCode"),
                      SizedBox(height: 15),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                        onPressed: () async {
                          // Rotayı oluştur
                          await context.read<MapScreenCubit>().createRoute(start, end, _mapController);
                        },
                        child: Text("Route", style: TextStyle(color: Colors.white)),
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


