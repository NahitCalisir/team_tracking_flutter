import 'package:flutter/material.dart';
import 'package:team_tracking/ui/views/map_screen/map_screen.dart';
import 'package:team_tracking/ui/views/users_screen.dart';
import 'package:team_tracking/ui/views/homepage.dart';
import 'package:team_tracking/ui/views/groups_screen.dart';
import 'package:team_tracking/ui/views/settings.dart';

import 'map_screen/create_route_screen.dart';

class BottomNavigationBarPage extends StatefulWidget {
  const BottomNavigationBarPage({super.key});

  @override
  State<BottomNavigationBarPage> createState() => _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {

  int secilenIndex = 0;

  final List<Widget> sayfalar = [
    const Homepage(),
    const UsersScreen(),
    const MapScreen(),
    const GroupsScreen(),
    const SettingsScreen(),
  ];

  void sayfaDegistir(int index) {
    setState(() {
      secilenIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey.shade700,
      //appBar: AppBar(
      //  iconTheme: IconThemeData(color: Colors.white,),
      //  centerTitle: true,
      //  backgroundColor: Colors.black45,
      //  title: Text(
      //    "Floating Action Button",
      //    style: TextStyle(color: Colors.white),
      //  ),
      //  actions: [ ],
      //),
      body: sayfalar[secilenIndex],

      //FLOATING ACTION BUTTON *********************************
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      //floatingActionButton: FloatingActionButton(
      //  onPressed: () {},
      //  child: Icon(Icons.add),
      //  backgroundColor: Colors.black87,
      //  foregroundColor: Colors.yellow,
      //  elevation: 0,
      //  shape: const CircleBorder( //OR: BeveledRectangleBorder etc.,
      //    //side: BorderSide(color: Colors.blue, width: 2.0, style: BorderStyle.solid)
      //  ),
      //  //mini: true,
      //),

      //BOTTOM NAVIGATION BAR  *****************************************
      bottomNavigationBar: BottomAppBar(
        notchMargin: 5.0,
        shape: const CircularNotchedRectangle(),
        color: Colors.black87,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          mainAxisSize: MainAxisSize.max,
          children: [
            buildBottomNavItem(Icons.home, "Home", 0),
            buildBottomNavItem(Icons.person, "Users", 1),
            buildBottomNavItem(Icons.map, "Map", 2),
            buildBottomNavItem(Icons.groups, "Groups", 3),
            buildBottomNavItem(Icons.settings, "Setting", 4),
            //buildBottomNavItem(Icons.settings, "Setting", 3),
          ],
        ),
      ),
    );
  }

  Widget buildBottomNavItem(IconData icon, String label, int index) {
    return InkWell(
      onTap: () {
        sayfaDegistir(index);
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: secilenIndex == index ? Colors.orangeAccent : Colors.white,
            ),
            Text(
              label,
              style: TextStyle(
                color: secilenIndex == index ? Colors.orangeAccent : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
