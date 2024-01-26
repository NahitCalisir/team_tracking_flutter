import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/group_members_screen_cubit.dart';
import 'package:team_tracking/ui/views/map_screen/map_screen.dart';
import 'package:team_tracking/utils/constants.dart';

class GroupMembersScreen extends StatefulWidget {
  final Groups group;

  const GroupMembersScreen({super.key, required this.group});

  @override
  _GroupMembersScreenState createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen>  {


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // İki sekme
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.group.name),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Group Members'),
              Tab(text: 'Membership Requests'),
            ],
          ),
          actions: [
            IconButton(
                onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MapScreen(group: widget.group)))
                      .then((value) => context.read<GroupMembersScreenCubit>().getGroupMembers(widget.group));
                },
                icon: const Icon(Icons.map)),
          ],
        ),
        body: TabBarView(
          children: [
            GroupMembersList(group: widget.group),
            MembershipRequestsList(group: widget.group),
          ],
        ),
      ),
    );
  }
}

class GroupMembersList extends StatelessWidget {
  final Groups group;

  GroupMembersList({super.key, required this.group});

  bool aramaYapiliyormu = false;


  @override
  Widget build(BuildContext context) {
    // GroupMembersScreenCubit ile grup üyelerini getir
    context.read<GroupMembersScreenCubit>().getGroupMembers(group);
    return BlocBuilder<GroupMembersScreenCubit,List<Users>>(
          builder: (context,userList){
            DateTime now = DateTime.now();
            if(userList.isNotEmpty){
              return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, indeks){
                    var user = userList[indeks];
                    Users? currentUser = UsersManager().currentUser;
                    bool isOwner = group.owner == currentUser?.id;
                    bool isMember = group.memberIds.contains(currentUser?.id);
                    bool isWaitingMember = group.joinRequests!.contains(currentUser?.id);
                    DateTime lastLocationUpdatedAt = (user.lastLocationUpdatedAt as Timestamp).toDate();
                    return InkWell(
                      onTap: (){
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context){
                              return Container(
                                height: 200,
                                color: Colors.amber,
                                child: const Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [

                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: Card(
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                Row(
                                  children: [
                                    Text(user.name,style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                                    const SizedBox(width: 8,),
                                    Icon(Icons.circle,size: 17,color: (now.difference(lastLocationUpdatedAt).inMinutes <= 5) ?  Colors.greenAccent:  Colors.redAccent ),
                                  ],
                                ),
                                Text(user.email),
                                Text(
                                  "Last Update: ${user.formattedLastLocationUpdatedAt()}",
                                  style: TextStyle(
                                      color: (now.difference(lastLocationUpdatedAt).inMinutes <= 5) ?  Colors.green:  Colors.red ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            if (isOwner) PopupMenuButton<String>(
                              onSelected: (String result) {
                                handleMenuSelectionForMembers(context, result, group, isOwner, isMember,user);
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: 'remove',
                                  child: Text('Remove'),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  });
            } return const Center();
          });

  }
}

class MembershipRequestsList extends StatelessWidget {
  final Groups group;

  MembershipRequestsList({super.key, required this.group});

  bool aramaYapiliyormu = false;


  @override
  Widget build(BuildContext context) {
    // GroupMembersScreenCubit ile grup üyelerini getir
    context.read<GroupMembersScreenCubit>().getMemberRequestList(group);
    return BlocBuilder<GroupMembersScreenCubit,List<Users>>(
        builder: (context,userList){
          DateTime now = DateTime.now();
          if(userList.isNotEmpty){
            return ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, indeks){
                  var user = userList[indeks];
                  Users? currentUser = UsersManager().currentUser;
                  bool isOwner = group.owner == currentUser?.id;
                  bool isMember = group.memberIds.contains(currentUser?.id);
                  bool isWaitingMember = group.joinRequests!.contains(currentUser?.id);
                  DateTime lastLocationUpdatedAt = (user.lastLocationUpdatedAt as Timestamp).toDate();
                  return InkWell(
                    onTap: (){
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context){
                          return Container(
                            height: 200,
                            color: Colors.amber,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [

                                ],
                              ),
                            ),
                          );
                        });
                      },
                    child: Card(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
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
                              Row(
                                children: [
                                  Text(user.name,style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                                  const SizedBox(width: 8,),
                                  Icon(Icons.circle,size: 17,color: (now.difference(lastLocationUpdatedAt).inMinutes <= 5) ?  Colors.greenAccent:  Colors.redAccent ),
                                ],
                              ),
                              Text(user.email),
                              Text(
                                "Last Update: ${user.formattedLastLocationUpdatedAt()}",
                                style: TextStyle(
                                    color: (now.difference(lastLocationUpdatedAt).inMinutes <= 5) ?  Colors.green:  Colors.red ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (isOwner) PopupMenuButton<String>(
                            onSelected: (String result) {
                              handleMenuSelectionForRequests(context, result, group, isOwner, isMember,user);
                            },
                            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'accept',
                                child: Text('Accept'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'reject',
                                child: Text('Reject'),
                              ),
                            ],
                          )

                        ],
                      ),
                    ),
                  );
                });
          } return const Center();
        });
  }
}

void handleMenuSelectionForMembers(
    BuildContext context,
    String result,
    Groups group,
    bool isOwner,
    bool isMember,
    Users user
    ) async {
  switch (result)  {
    case 'remove':
      print(!isOwner);
      if(group.owner.contains(user.id)) { //eğer çıkarılmak istenen admin ise
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor,
              title: const Text("Warning",style: TextStyle(color: kSecondaryColor2),),
              content: const Text("You cannot leave the group because you are the administrator. If you wish, you can delete the group entirely.",style: TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () {Navigator.of(context).pop();},
                  child: const Text("OK",style: TextStyle(color: kSecondaryColor2),),
                ),
              ],
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor,
              title: const Text("Warning",style: TextStyle(color: kSecondaryColor2),),
              content: Text("Are you sure you want to remove ${user.name}  from the group?",style: const TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () async {Navigator.of(context).pop();},
                  child: const Text("Cancel",style: TextStyle(color: kSecondaryColor2),),
                ),
                TextButton(
                  onPressed: () async {
                    await context.read<GroupMembersScreenCubit>().removeFromGroup(group, user);
                    await context.read<GroupMembersScreenCubit>().getGroupMembers(group);
                    Navigator.of(context).pop();
                    },
                  child: const Text("Remove",style: TextStyle(color: Colors.red),),
                ),
              ],
            );
          },
        );
      }
      break;
  }
}

void handleMenuSelectionForRequests(
    BuildContext context,
    String result,
    Groups group,
    bool isOwner,
    bool isMember,
    Users user
    ) async {
  switch (result)  {
    case 'accept':
    await context.read<GroupMembersScreenCubit>().acceptJoinRequest(group, user);
    await context.read<GroupMembersScreenCubit>().getMemberRequestList(group);
      break;
    case 'reject':
      await context.read<GroupMembersScreenCubit>().rejectJoinRequest(group, user);
      await context.read<GroupMembersScreenCubit>().getMemberRequestList(group);

      break;
  }
}


