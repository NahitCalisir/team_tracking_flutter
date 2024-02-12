
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
            backgroundColor: const Color(0xff14012c),//Color(0xff131230),
            appBar: AppBar(
              title: const Text("Team Tracking",style: TextStyle(color: Colors.white),),
              backgroundColor: const Color(0xff14012c),
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
                                        color: const Color(0xff14012c).withOpacity(0.7),
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
                                        color: const Color(0xff14012c).withOpacity(0.7),
                                        child: Text(
                                          menu.title,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
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
        title: "Group Tracking",
        image: "assets/images/team.jpg",
        sayfa: const GroupsScreen(),
        detailText: "You can create any group, such as your business team or family members, and track their live locations whenever you want.");
    var menu1 = MenuItems(
        title: "Activity Tracking",
        image: "assets/images/activity.jpg",
        sayfa: const ActivitiesScreen(),
        detailText: 'You can create group activities for a certain period of time and track live location of participants.');
    menuItemList.add(menu1);
    menuItemList.add(menu2);
    return menuItemList;
  }
}

/*
        return Scaffold(backgroundColor: Color(0xff14012c),//Color(0xff131230),
            appBar: AppBar(
              title: const Text("Team Track",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
              backgroundColor: Color(0xff14012c),
              actions: [
                IconButton(
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context)=>SettingsScreen()));
                    },
                    icon: Icon(Icons.account_circle,color: Colors.white),
                ),
              ],
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
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 16,right: 16,top: 16),
                            child: Container(
                              height: 370,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomRight: Radius.circular(40),
                                  bottomLeft: Radius.circular(2),
                                  topLeft: Radius.circular(2),
                                  topRight: Radius.circular(2),
                                ),
                                gradient:  LinearGradient(
                                  colors: [
                                    //Colors.pink,
                                    //Colors.purple,
                                    Colors.deepPurple,
                                    //Color(0xffb14fd6),
                                    //Color(0xff275d9d),
                                    Color(0xff1c023a),
                                    Color(0xff1c023a),
                                    Colors.primaries[Random().nextInt(Colors.primaries.length)],
                                    //Color(0xff131230),
                                    //Colors.deepPurple,
                                    //Colors.purple,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3), // Gölge rengi ve opaklığı
                                    spreadRadius: 2, // Yayılma yarıçapı
                                    blurRadius: 5, // Bulanıklık yarıçapı
                                    offset: const Offset(3, 3), // Gölge konumu (x, y)
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(5),
                                      child: Text(menu.title,style: const TextStyle(color:Colors.white,fontSize: 22,),),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16.0),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.3),
                                          ),
                                          child: Image.asset(
                                            menu.image,
                                            fit: BoxFit.cover,
                                            height: 260,
                                            width: MediaQuery.of(context).size.width * 0.88,
                                          ),
                                        ),
                                      ),
                                    ),
                                    //Image.asset(menu.image,height: 260,width: screenWidth*0.88,),
                                    Text(menu.detailText, style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                  );
                } else {
                  return const Center();
                }
              },
            )
        )
 */