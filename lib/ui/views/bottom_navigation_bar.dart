import 'package:flutter/material.dart';
import 'package:team_tracking/ui/views/homepage.dart';
import 'package:team_tracking/ui/views/groups_screen/groups_screen.dart';
import 'package:team_tracking/ui/views/settings_screen.dart';
import 'package:team_tracking/utils/constants.dart';


class BottomNavigationBarPage extends StatefulWidget {
  const BottomNavigationBarPage({super.key});

  @override
  State<BottomNavigationBarPage> createState() => _BottomNavigationBarPageState();
}

class _BottomNavigationBarPageState extends State<BottomNavigationBarPage> {

  int secilenIndex = 0;

  final List<Widget> sayfalar = [
    const Homepage(),
    //const UsersScreen(),
    //const MapScreen(),
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
      body: sayfalar[secilenIndex],

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
            //buildBottomNavItem(Icons.person, "Users", 1),
            //buildBottomNavItem(Icons.map, "Map", 2),
            buildBottomNavItem(Icons.groups, "Groups", 1),
            buildBottomNavItem(Icons.settings, "Setting", 2),
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
              color: secilenIndex == index ? kSecondaryColor2 : Colors.white,
            ),
            Text(
              label,
              style: TextStyle(
                color: secilenIndex == index ? kSecondaryColor2 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
