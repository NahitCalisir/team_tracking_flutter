import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/map_screen_cubit.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:team_tracking/utils/constants.dart';

class MapScreen extends StatefulWidget {
  final Groups group;
  const MapScreen({Key? key, required this.group}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final TextEditingController start = TextEditingController(text: "34740 bostancı");
  final TextEditingController end = TextEditingController(text: "34870 kartal");
  final MapController _mapController = MapController();
  final ValueNotifier<bool> _isSatelliteView = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    context.read<MapScreenCubit>().getGroupMembersAndShowMap(_mapController, widget.group);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        context.read<MapScreenCubit>().cancelTimers();
      },
      child: BlocBuilder<MapScreenCubit, List<Users>>(
        builder: (context, userList) {
          return Scaffold(
            backgroundColor: Colors.grey.shade300,
            body: SafeArea(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: userList.isNotEmpty ? LatLng(userList[0].lastLocation!.latitude, userList[0].lastLocation!.longitude) : const LatLng(0, 0),
                      //zoom: 17,
                      maxZoom: 18,
                    ),
                    children: [
                      const SimpleAttributionWidget(
                        source: Text('OpenStreetMap '),
                      ),
                      TileLayer(
                        urlTemplate: _isSatelliteView.value
                            ? 'https://{s}.google.com/vt/lyrs=s,h&x={x}&y={y}&z={z}'
                            : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: ['mt0', 'mt1', 'mt2', 'mt3'],
                      ),
                      MarkerLayer(
                        markers: userList.map((user) {
                          return Marker(
                            point: LatLng(user.lastLocation!.latitude, user.lastLocation!.longitude),
                            rotate: true,
                            height: 250,
                            width: 86,
                            child: Container(
                              child: Column(
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      ProgressBar(
                                        value: user.lastSpeed! / 50,
                                        width: 75,
                                        height: 20,
                                        backgroundColor: Colors.deepPurpleAccent,
                                        gradient: const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [Colors.yellowAccent, Colors.red],
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.speed, color: Colors.red,),
                                          SizedBox(width: 8),
                                          Text(
                                            "${user.lastSpeed!.toStringAsFixed(1)}",
                                            style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 80,
                                    height: 27,
                                    child: Card(
                                      color: Colors.deepPurpleAccent,
                                      child: Text(
                                        "${user.name}",
                                        style: const TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      const Icon(Icons.location_pin, size: 84, color: Colors.deepPurpleAccent,),
                                      Positioned(
                                        top: 10,
                                        left: 20,
                                        child: CircleAvatar(
                                          radius: 22,
                                          backgroundColor: Colors.white,
                                          child: user.photoUrl!.isNotEmpty
                                              ? CircleAvatar(
                                            radius: 20,
                                            backgroundImage: NetworkImage(user.photoUrl!),
                                          )
                                              : const Icon(Icons.account_circle, color: Colors.orangeAccent, size: 42,),
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
                    padding: const EdgeInsets.only(left: 8),
                    child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            //backgroundColor: kSecondaryColor2,
                          ),
                          onPressed: () async {
                            context.read<MapScreenCubit>().getGroupMembersAndShowMap(_mapController, widget.group);
                          },
                          child: const Text("Show All"),
                        ),
                  ),
                  Positioned(bottom: 8,right: 8,
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isSatelliteView,
                      builder: (context, isSatelliteView, _) {
                        return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            //backgroundColor: kSecondaryColor2,
                          ),
                          onPressed: () {
                            _isSatelliteView.value = !_isSatelliteView.value;
                            // Harita görünümünü değiştirmek için uydu görünümü butonuna tıklandığında yapılacak işlemler
                          },
                          child: Text(isSatelliteView ? "Switch to Map View" : "Switch to Satellite View", ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                height: 38,
                width: 38,
                child: FloatingActionButton(
                  //backgroundColor: kSecondaryColor2,
                  //foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.close),
                  onPressed: () {
                    context.read<MapScreenCubit>().cancelTimers();
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
