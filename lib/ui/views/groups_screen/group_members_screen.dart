import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/group_members_screen_cubit.dart';
import 'package:team_tracking/ui/views/map_screen/map_screen.dart';
import 'package:team_tracking/utils/constants.dart';

class GroupMembersScreen extends StatefulWidget {
  const GroupMembersScreen({super.key, required this.group});

  final Groups group;

  @override
  State<GroupMembersScreen> createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> {

  bool aramaYapiliyormu = false;

  @override
  Widget build(BuildContext context) {
    context.read<GroupMembersScreenCubit>().getGroupMembers(widget.group);
    return Scaffold(
      appBar: AppBar(
        //app bar düzenlemesini mainde birkereye mahsus yaptık
        title: aramaYapiliyormu ?
        TextField(
          style: TextStyle(color: Colors.black87),
          cursorColor: Colors.white,
          decoration: InputDecoration(hintText: "Search",),
          onChanged: (arananKelime){
            context.read<GroupMembersScreenCubit>().filtrele(arananKelime);
          },
        ):
        Text(widget.group.name),
        actions: [
          aramaYapiliyormu ?
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = false;
            });
            context.read<GroupMembersScreenCubit>().getGroupMembers(widget.group); // veri tabanından çektiğimizde gerekli
          }, icon:Icon(Icons.clear)):
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = true;
            });
          }, icon:Icon(Icons.search)),
        ],
      ),
      body: BlocBuilder<GroupMembersScreenCubit,List<Users>>(
          builder: (context,userList){
            if(userList.isNotEmpty){
              return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, indeks){
                    var user = userList[indeks];
                    return Card(
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: user.photoUrl!.isEmpty ?
                                const Icon(Icons.account_circle, size: 50, color: kSecondaryColor2,):
                            ClipOval(
                              child: Image(
                                image: NetworkImage(user.photoUrl!),
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              Text(user.email),
                              Text("Last Update:${user.formattedLastLocationUpdatedAt()}"),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            } return const Center();
      }),
      floatingActionButton: FloatingActionButton.extended(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)) ,
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => MapScreen()));
        },
        icon: const Icon(Icons.map_outlined),
        label: const Text("Show on map"),
        backgroundColor: kSecondaryColor2,
        foregroundColor: Colors.white,
      ),


    );
  }
}
