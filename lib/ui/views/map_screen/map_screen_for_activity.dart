import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:team_tracking/data/entity/activities.dart';
import 'package:team_tracking/data/entity/lat_lng_with_altitude.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/services/google_ads.dart';
import 'package:team_tracking/ui/cubits/map_screen_for_activity_cubit.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:team_tracking/utils/constants.dart';

class MapScreenForActivity extends StatefulWidget {
  final Activities activity;
  const MapScreenForActivity({Key? key, required this.activity}) : super(key: key);

  @override
  State<MapScreenForActivity> createState() => _MapScreenForActivityState();
}

class _MapScreenForActivityState extends State<MapScreenForActivity> {
  final TextEditingController start = TextEditingController(text: "34740 bostancı");
  final TextEditingController end = TextEditingController(text: "34870 kartal");
  final MapController _mapController = MapController();
  final ValueNotifier<bool> _isSatelliteView = ValueNotifier<bool>(false);

  List<LatLngWithAltitude> gpxPoints = [];
  GoogleAds _googleAds = GoogleAds();


  @override
  void initState()  {
    if(widget.activity.routeUrl!.isNotEmpty  || widget.activity.routeUrl != "" ) {
      getGpxPoint();
    }
    _googleAds.loadBannerAd();
    super.initState();
  }

  Future<void> getGpxPoint() async {
    if(widget.activity.routeUrl!.isNotEmpty || widget.activity.routeUrl != null || widget.activity.routeUrl != "" ) {
      gpxPoints = await context.read<MapScreenForActivityCubit>().extractGpxPointsFromFile(widget.activity.routeUrl!);
    }
  }


  @override
  Widget build(BuildContext context) {
    context.read<MapScreenForActivityCubit>().getActivityMembersAndShowMap(_mapController, widget.activity);
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        context.read<MapScreenForActivityCubit>().cancelTimers();
      },
      child: BlocBuilder<MapScreenForActivityCubit, List<Users>>(
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
                      PolylineLayer(
                        polylineCulling: false,
                        polylines: [
                          Polyline(
                              points: gpxPoints.map((point) => LatLng(point.latitude, point.longitude)).toList(),
                              color: Colors.blue,
                              strokeWidth: 6),
                        ],
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
                                          const Icon(Icons.speed, color: Colors.white,),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${user.lastSpeed!.toStringAsFixed(1)}",
                                            style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
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
                  Column(
                    children: [
                      if (_googleAds.bannerAd != null)
                        SizedBox(
                          width: _googleAds.bannerAd!.size.width.toDouble(),
                          height: _googleAds.bannerAd!.size.height.toDouble(),
                          child: AdWidget(ad: _googleAds.bannerAd!),
                        ),
                      Row(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              color: Colors.black.withOpacity(0.6),
                              child: Text(
                                " Distance  : ${widget.activity.routeDistance?.toStringAsFixed(1).toString() ?? ""} km \n"
                                " Elevation : ${widget.activity.routeElevation?.toStringAsFixed(0).toString() ?? ""} m ",
                                style: TextStyle(color: Colors.greenAccent),
                              ),
                            ),
                          ),
                          Spacer(),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                  elevation: 10,
                                ),
                                onPressed: () async {
                                  context.read<MapScreenForActivityCubit>().cancelTimers();
                                  Navigator.of(context).pop();
                                 },
                                child: const Icon(Icons.close),
                              ),
                              ValueListenableBuilder<bool>(
                                valueListenable: _isSatelliteView,
                                builder: (context, isSatelliteView, _) {
                                  return ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: CircleBorder(),
                                      backgroundColor: Colors.white.withOpacity(0.7),
                                      elevation: 10,
                                    ),
                                    onPressed: () {
                                      _isSatelliteView.value = !_isSatelliteView.value;
                                    },
                                    //child: Text(isSatelliteView ? "Map View" : "Satellite View", ),
                                    child: Icon( isSatelliteView ? Icons.map_outlined : Icons.satellite_alt, ),
                                  );
                                },
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: CircleBorder(),
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                  elevation: 10,
                                ),
                                onPressed: () async {
                                  context.read<MapScreenForActivityCubit>().getActivityMembersAndShowMap(_mapController, widget.activity);
                                },
                                child: const Icon(Icons.my_location_sharp),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            //floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
            //floatingActionButton: Padding(
            //  padding: const EdgeInsets.only(top: 4),
            //  child: SizedBox(
            //    height: 38,
            //    width: 38,
            //    child: FloatingActionButton(
            //      backgroundColor: Colors.white.withOpacity(0.7),
            //      //foregroundColor: Colors.red,
            //      shape: const CircleBorder(),
            //      child: const Icon(Icons.close),
            //      onPressed: () {
            //        context.read<MapScreenForActivityCubit>().cancelTimers();
            //        Navigator.of(context).pop();
            //      },
            //    ),
            //  ),
            //),
          );
        },
      ),
    );
  }
}

