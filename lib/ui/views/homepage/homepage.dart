
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/services/google_ads.dart';
import 'package:team_tracking/ui/cubits/homepage_cubit.dart';
import 'package:team_tracking/ui/views/activities_screen/activities_screen.dart';
import 'package:team_tracking/ui/views/groups_screen/groups_screen.dart';
import 'package:team_tracking/ui/views/homepage/menu_items.dart';
import 'package:team_tracking/ui/views/settings_screen.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  final Users? currentUser = UsersManager().currentUser;
  final GoogleAds _googleAds = GoogleAds();

  @override
  void initState() {
    context.read<HomepageCubit>().checkAndUpdateVersion(context);
    _googleAds.loadInterstitialAd();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    var screenInfo = MediaQuery.of(context);
    final double screenHeight = screenInfo.size.height;
    final double screenWidth = screenInfo.size.width;

    context.read<HomepageCubit>().runUpdateMyLocation();

    return BlocBuilder<HomepageCubit,void>(
      builder: (BuildContext context, void state) {
        return Scaffold(
          backgroundColor: Colors.black,//Color(0xff14012c),
          appBar: AppBar(
            title: const Text("Tracker",style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.black, // Color(0xff14012c),
            actions: [
              GestureDetector(
                onTap: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>const SettingsScreen()));
                  },
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ClipOval(
                    child: Icon(Icons.account_circle,color: Colors.white,size: 40,),
                  ),
                ),
              )],
            ),
            body: FutureBuilder<List<MenuItems>>(
              future: loadMenuItems(),
              builder: (context,snapshot){
                if(snapshot.hasData){
                  var menuItemList = snapshot.data;
                  return ListView.builder(
                      itemCount: menuItemList!.length,
                      itemBuilder: (context,indeks){
                        var menu = menuItemList[indeks];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => menu.sayfa,
                              ),
                            );
                            GoogleAds().showInterstitialAd();
                          },
                          child: Padding(
                            padding:  const EdgeInsets.symmetric(horizontal: 8,vertical: 20),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    menu.image,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    left: 0,
                                    right: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        color: Colors.black.withOpacity(0.7),
                                        child: Text(
                                          menu.detailText,
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(24),
                                        color: Colors.black.withOpacity(0.7),
                                        child: Text(
                                          menu.title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ) ,
                        );
                      }
                  );
                } else {
                  return const Center();
                }
              },
            )
        );
      },
    );
  }

  Future<List<MenuItems>> loadMenuItems() async {
    var menuItemList = <MenuItems>[];
    var menu2 = MenuItems(
        title: "Group Tracker",
        image: "assets/images/team.jpg",
        sayfa: const GroupsScreen(),
        detailText: "You can create any group, such as your business team or family members and track their live locations whenever you want.");
    var menu1 = MenuItems(
        title: "Activity Tracker",
        image: "assets/images/activity.jpg",
        sayfa: const ActivitiesScreen(),
        detailText: 'You can create group activities, upload your route, and track live locations of participants during the activity.');
    menuItemList.add(menu1);
    menuItemList.add(menu2);
    return menuItemList;
  }
}

