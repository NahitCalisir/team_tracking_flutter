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
  Users? currentUser = UsersManager().currentUser;

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
          style: const TextStyle(color: Colors.black87),
          cursorColor: Colors.white,
          decoration: const InputDecoration(hintText: "Search",),
          onChanged: (arananKelime){
            context.read<GroupsScreenCubit>().filtrele(arananKelime);
          },
        ):
        const Text("Groups"),
        actions: [
          aramaYapiliyormu ?
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = false;
            });
            context.read<GroupsScreenCubit>().getAllGroups();
          }, icon:const Icon(Icons.clear)):
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = true;
            });
          }, icon:const Icon(Icons.search)),
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
                    child: SizedBox(
                      height: 80, // İstenilen sınırlı yüksekliği buradan ayarlayabilirsiniz
                      child: Card(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                  : const Icon(Icons.groups, size: 60, color: kSecondaryColor2),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    group.name,
                                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
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
                                        child: Text("  Request sent  ",style: TextStyle(color: Colors.white,fontSize: 12),)),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              onSelected: (String result) {
                                handleMenuSelection(context, result, group, isOwner, isMember, currentUser!);
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                if (isMember)
                                  const PopupMenuItem<String>(
                                    value: 'groupDetails',
                                    child: Text('Group Details'),
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
                                if (isWaitingMember)
                                  const PopupMenuItem<String>(
                                    value: 'cancelRequest',
                                    child: Text('Cancel Request'),
                                  ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
                } return const Center();
              }),
      //FLOATING ACTION BUTTON *********************************
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CreateGroupScreen()));
        },
        backgroundColor: kSecondaryColor2,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder( //OR: BeveledRectangleBorder etc.,
          //side: BorderSide(color: Colors.blue, width: 2.0, style: BorderStyle.solid)
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void handleMenuSelection(
      BuildContext context,
      String result,
      Groups group,
      bool isOwner,
      bool isMember,
      Users currentUser,
      ) {
    switch (result) {
      case 'groupDetails':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => GroupMembersScreen(group: group)));
        break;
      case 'editGroup':
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => EditGroupScreen(group: group)));
        break;
      case 'leaveGroup':
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor,
              title: const Text("Warning",style: TextStyle(color: kSecondaryColor2),),
              content: Text("Are you sure you want to leave  from ${group.name}?",style: const TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () async {Navigator.of(context).pop();},
                  child: const Text("Cancel",style: TextStyle(color: kSecondaryColor2),),
                ),
                TextButton(
                  onPressed: () async {
                    context.read<GroupsScreenCubit>().removeFromGroup(group, currentUser);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Leave",style: TextStyle(color: Colors.red),),
                ),
              ],
            );
          },
        );
        break;
      case 'joinGroup':
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor,
              title: const Text("Warning",style: TextStyle(color: kSecondaryColor2),),
              content: Text("Send a request to join ${group.name}?",style: const TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () async {Navigator.of(context).pop();},
                  child: const Text("Cancel",style: TextStyle(color: kSecondaryColor2),),
                ),
                TextButton(
                  onPressed: () async {
                    context.read<GroupsScreenCubit>().sendRequestToJoinGroup(context,group.id);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Send Request",style: TextStyle(color: kSecondaryColor2),),
                ),
              ],
            );
          },
        );
        break;
      case 'cancelRequest':
        context.read<GroupsScreenCubit>().cancelRequest(group, currentUser);
        break;
    }
  }

}


