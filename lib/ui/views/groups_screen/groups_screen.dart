import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/ui/cubits/groups_screen_cubit.dart';
import 'package:team_tracking/ui/views/groups_screen/create_group_screen.dart';
import 'package:team_tracking/ui/views/groups_screen/edit_group_screen.dart';
import 'package:team_tracking/ui/views/groups_screen/group_members_screen.dart';
import 'package:team_tracking/utils/constants.dart';

import '../../../data/entity/users.dart';

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
            context.read<GroupsScreenCubit>().getAllGroups();
          }, icon:Icon(Icons.clear)):
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = true;
            });
          }, icon:Icon(Icons.search)),
        ],
      ),
      body: BlocBuilder<GroupsScreenCubit,List<Groups>>(
          builder: (context,groupList){
            if(groupList.isNotEmpty){
              return ListView.builder(
                itemCount: groupList.length,
                itemBuilder: (context, index) {
                  var group = groupList[index];
                  Users? currentUser = UsersManager().currentUser;
                  bool isOwner = group.owner == currentUser?.id;
                  bool isMember = group.memberIds.contains(currentUser?.id);
                  bool isWaitingMember = group.joinRequests!.contains(currentUser?.id);
                  return InkWell(
                    onTap: (){
                      context.read<GroupsScreenCubit>().checkGroupMembershipAndNavigate(context, group);
                    },
                    child: Container(
                      height: 80, // İstenilen sınırlı yüksekliği buradan ayarlayabilirsiniz
                      child: Card(
                        child: Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: group.photoUrl!.isNotEmpty
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image(
                                  image: NetworkImage(group.photoUrl!),
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                ),
                              )
                                  : Icon(Icons.groups, size: 60, color: kSecondaryColor2),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.name,
                                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    "${group.city} - ${group.country}",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (isMember && !isOwner)
                                    const Card(color: kSecondaryColor2,
                                        child: Text("  Member  ",style: TextStyle(color: Colors.white,fontSize: 12),)),
                                  if (isOwner)
                                    const Card(color: kSecondaryColor2,
                                        child: Text("  Admin  ",style: TextStyle(color: Colors.white,fontSize: 12),)),
                                  if (isWaitingMember)
                                    const Card(color: kSecondaryColor2,
                                        child: Text("  Request sent  ",style: TextStyle(color: Colors.white,fontSize: 12),)),                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (String result) {
                                handleMenuSelection(context, result, group, isOwner, isMember);
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                if (isMember)
                                  const PopupMenuItem<String>(
                                    value: 'watchGroup',
                                    child: Text('Watch Group'),
                                  ),
                                if (isOwner)
                                  const PopupMenuItem<String>(
                                    value: 'editGroup',
                                    child: Text('Edit Group'),
                                  ),
                                if (!isOwner && isMember)
                                  const PopupMenuItem<String>(
                                    value: 'leaveGroup',
                                    child: Text('Leave Group'),
                                  ),
                                if (!isOwner && !isMember)
                                  const PopupMenuItem<String>(
                                    value: 'joinGroup',
                                    child: Text('Join Group'),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );;
              ;
                } return const Center();
              }),
      //FLOATING ACTION BUTTON *********************************
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateGroupScreen()));
        },
        child: Icon(Icons.add),
        backgroundColor: kSecondaryColor2,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder( //OR: BeveledRectangleBorder etc.,
          //side: BorderSide(color: Colors.blue, width: 2.0, style: BorderStyle.solid)
        ),
      ),
    );
  }

  void handleMenuSelection(
      BuildContext context,
      String result,
      Groups group,
      bool isOwner,
      bool isMember,
      ) {
    switch (result) {
      case 'watchGroup':
      // Handle "Watch Group"
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => GroupMembersScreen(group: group)));
        break;
      case 'editGroup':
      // Handle "Edit Group"
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditGroupScreen(group: group)));

        break;
      case 'leaveGroup':
      // Handle "Leave Group"
        break;
      case 'joinGroup':
      // Handle "Join Group"
      context.read<GroupsScreenCubit>().sendRequestToJoinGroup(context,group.id);
        break;
    }
  }

}


