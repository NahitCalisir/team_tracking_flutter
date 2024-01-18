import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/ui/cubits/groups_screen_cubit.dart';
import 'package:team_tracking/ui/views/groups_screen/create_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {

  bool aramaYapiliyormu = false;

  @override
  void initState() {
    super.initState();
    context.read<GroupsScreenCubit>().getAllGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //app bar düzenlemesini mainde birkereye mahsus yaptık
        title: aramaYapiliyormu ?
        TextField(
          style: TextStyle(color: Colors.black87),
          cursorColor: Colors.white,
          decoration: InputDecoration(hintText: "Search",),
          onChanged: (arananKelime){
            context.read<GroupsScreenCubit>().filtrele(arananKelime);
          },
        ):
        Text("Groups"),
        actions: [
          aramaYapiliyormu ?
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = false;
            });
            context.read<GroupsScreenCubit>().getAllGroups(); // veri tabanından çektiğimizde gerekli
          }, icon:Icon(Icons.clear)):
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = true;
            });
          }, icon:Icon(Icons.search)),
        ],
      ),
      body: BlocBuilder<GroupsScreenCubit,List<Groups>>(
          builder: (context,userList){
            if(userList.isNotEmpty){
              return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, indeks){
                    var user = userList[indeks];
                    return Card(
                      child: Row(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Icon(Icons.groups,size: 50,color: Colors.orange,),
                          ),
                          SizedBox(width: 8),
                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              Text("${user.city} - ${user.country}"),
                              Text("Admin: ${user.owner} (${user.memberIds.length})"),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            } return const Center();
          }),
      //FLOATING ACTION BUTTON *********************************
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateGroupScreen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.black87,
        foregroundColor: Colors.orangeAccent,
        elevation: 0,
        shape: const CircleBorder( //OR: BeveledRectangleBorder etc.,
          //side: BorderSide(color: Colors.blue, width: 2.0, style: BorderStyle.solid)
        ),
        //mini: true,
      ),
    );
  }
}
