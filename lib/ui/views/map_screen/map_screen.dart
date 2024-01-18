import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/map_screen_cubit.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
//import 'package:flutter_map/plugin_api.dart';
import 'package:provider/provider.dart';

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


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _mapScreenCubit = BlocProvider.of<MapScreenCubit>(context);
    context.read<MapScreenCubit>().updateMyLocation();
    context.read<MapScreenCubit>().runTrackMe(_mapController);
  }

  @override
  void dispose() {
    print("Dispose method called");
    _mapScreenCubit.cancelTimers(); // _mapScreenCubit'i kullanarak cancelTimer'ı çağır
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
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundImage: NetworkImage(
                                            user.photoUrl!.isNotEmpty ? user.photoUrl! : "http://nahitcalisir.online/images/person2.png",
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
        );
      },
    );
  }
}




