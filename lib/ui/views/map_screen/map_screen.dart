import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:team_tracking/data/entity/users.dart';
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
    context.read<MapScreenCubit>().trackMe(_mapController);
    return BlocBuilder<MapScreenCubit, List<Users>>(
      builder: (context, userList) {
        return Scaffold(
          backgroundColor: Colors.grey.shade300,
          body: SafeArea(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: userList.isNotEmpty ? LatLng(userList[0].lastLocation!.latitude, userList[0].lastLocation!.longitude) : LatLng(0, 0),
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
                    MarkerLayer(
                      markers: userList.map((user){
                        return Marker(
                          point: LatLng(user.lastLocation!.latitude, user.lastLocation!.longitude),
                          rotate: true,
                          height: 200,
                          width: 86,
                          builder: (_) => Container(
                            child: Column(
                              children: [
                                Container(
                                  child: Text("${user.name}",style: TextStyle(color: Colors.white, backgroundColor: Colors.red),),
                                  width: 86,
                                ),
                                Stack(
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
                                              "${user.photoUrl}",
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.black87),
                        onPressed: () async {
                          // Rotayı oluştur
                          //await context.read<MapScreenCubit>().createRoute(start, end, _mapController);

                          //await context.read<MapScreenCubit>().trackMe(_mapController);
                          await context.read<MapScreenCubit>().startLocationUpdates(_mapController);
                        },
                        child: const Text("Show All", style: TextStyle(color: Colors.white)),
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




