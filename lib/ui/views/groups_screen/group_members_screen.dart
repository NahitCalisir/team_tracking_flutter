import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/data/repo/team_tracking_dao_repository.dart';
import 'package:team_tracking/ui/cubits/group_members_screen_cubit.dart';
import 'package:team_tracking/ui/cubits/groups_screen_cubit.dart';
import 'package:team_tracking/ui/views/map_screen/map_screen.dart';
import 'package:team_tracking/utils/constants.dart';

class GroupMembersScreen extends StatefulWidget {
  final Groups group;

  GroupMembersScreen({Key? key, required this.group}) : super(key: key);

  @override
  _GroupMembersScreenState createState() => _GroupMembersScreenState();
}

class _GroupMembersScreenState extends State<GroupMembersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    // Aktif sekme değiştiğinde burada state güncellemelerini tetikleyebilirsiniz.
    final currentTab = _tabController.index;
    if (currentTab == 0) {
      context.read<GroupMembersScreenCubit>().getGroupMembers(widget.group);
    } else if (currentTab == 1) {
      context.read<GroupMembersScreenCubit>().getMemberRequestList(widget.group);
    }
    // Her iki BlocBuilder'ı da güncelleyin
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // İki sekme
      child: Scaffold(
        appBar: AppBar(
          title: Text('Group Members'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Group Members'),
              Tab(text: 'Membership Requests'),
            ],
          ),
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

  GroupMembersList({required this.group});

  bool aramaYapiliyormu = false;
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // GroupMembersScreenCubit ile grup üyelerini getir
    context.read<GroupMembersScreenCubit>().getGroupMembers(group);
    return BlocBuilder<GroupMembersScreenCubit,List<Users>>(
          builder: (context,userList){
            if(userList.isNotEmpty){
              return ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, indeks){
                    var user = userList[indeks];
                    DateTime lastLocationUpdatedAt = (user.lastLocationUpdatedAt as Timestamp).toDate();
                    return InkWell(
                      onTap: (){
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context){
                              return Container(
                                height: 200,
                                color: Colors.amber,
                                child: Center(
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
                                Row(
                                  children: [
                                    Text(user.name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
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

  MembershipRequestsList({required this.group});

  bool aramaYapiliyormu = false;
  DateTime now = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // GroupMembersScreenCubit ile grup üyelerini getir
    context.read<GroupMembersScreenCubit>().getMemberRequestList(group);
    return BlocBuilder<GroupMembersScreenCubit,List<Users>>(
        builder: (context,userList){
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
                              child: Center(
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
                              Row(
                                children: [
                                  Text(user.name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
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
                          Spacer(),
                          if (isOwner) PopupMenuButton<String>(
                            onSelected: (String result) {
                              handleMenuSelection(context, result, group, isOwner, isMember,user);
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

void handleMenuSelection(
    BuildContext context,
    String result,
    Groups group,
    bool isOwner,
    bool isMember,
    Users user
    ) {
  switch (result) {
    case 'accept':
    context.read<GroupMembersScreenCubit>().acceptJoinRequest(group, user);
      break;
    case 'reject':
      context.read<GroupMembersScreenCubit>().rejectJoinRequest(group, user);

      break;
  }
}
