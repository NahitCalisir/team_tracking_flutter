import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/map_screen_cubit.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';
import 'package:team_tracking/utils/constants.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  BlocProvider(create: (context) => MapScreenCubit(),
    child: MapScreenContent());
  }
}
class MapScreenContent extends StatefulWidget {

  @override
  State<MapScreenContent> createState() => _MapScreenContentState();
}

class _MapScreenContentState extends State<MapScreenContent> with AutomaticKeepAliveClientMixin {
  final TextEditingController start = TextEditingController(text: "34740 bostancı");
  final TextEditingController end = TextEditingController(text: "34870 kartal");
  final MapController _mapController = MapController();
  late MapScreenCubit _mapScreenCubit; // Cubit'i saklamak için bir değişken

  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mapScreenCubit = context.read<MapScreenCubit>();
    context.read<MapScreenCubit>().runUpdateMyLocation();
    context.read<MapScreenCubit>().runTrackMe(_mapController);
    //context.read<MapScreenCubit>().runShowAllOnMap(_mapController);
  }

  @override
  void dispose() {
    print("Dispose method called");
    if (_mapScreenCubit.state != null) {
      _mapScreenCubit.cancelTimers();
      _mapScreenCubit.close();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                    initialCenter: userList.isNotEmpty ? LatLng(userList[0].lastLocation!.latitude, userList[0].lastLocation!.longitude) : LatLng(0, 0),
                    //zoom: 17,
                    maxZoom: 18,
                  ),
                  children: [
                    SimpleAttributionWidget(
                      source: Text('OpenStreetMap '),
                    ),
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
                          child: Container(
                            child: Column(
                              children: [
                                SizedBox( width:70,height: 27,
                                  child: Card(
                                    color: Colors.deepPurpleAccent,
                                    child: Text("${user.name}",style: TextStyle(color: Colors.white),textAlign:TextAlign.center),
                                  ),
                                ),
                                Stack(
                                  alignment: Alignment.topCenter,
                                  children: [
                                    Icon(Icons.location_pin, size: 84, color: Colors.deepPurpleAccent,),
                                    Positioned(
                                      top: 10,
                                      left: 20,
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: Colors.white,
                                        child: user.photoUrl!.isNotEmpty ?
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundImage:  NetworkImage( user.photoUrl!),
                                        ): Icon(Icons.account_circle,color: Colors.orangeAccent,size: 42,),
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
                  child: Column(
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                        backgroundColor: kSecondaryColor2),
                        onPressed: () async {
                          context.read<MapScreenCubit>().runShowAllOnMap(_mapController);
                        },
                        child: const Text("Show All", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: SizedBox(height: 38,width: 38,
              child: FloatingActionButton(
                  backgroundColor: kSecondaryColor2,
                  foregroundColor: Colors.white,
                  shape: CircleBorder(),
                  child: Icon(Icons.close),
                  onPressed: (){
                    context.read<MapScreenCubit>().cancelTimers();
                    Navigator.of(context).pop();
              }
                      ),
            ),
          ),
        );
      },
    );
  }
}




