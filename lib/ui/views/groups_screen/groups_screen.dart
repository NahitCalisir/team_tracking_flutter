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

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  bool aramaYapiliyormu = false;
  late TabController _tabController;
  Users? currentUser = UsersManager().currentUser;


  @override
  void initState() {
    // TabController'ı doğrudan oluşturma
    _tabController = TabController(length: 2, vsync: this);
    // Tab değişikliklerini dinlemek için listener ekledik
    _tabController.addListener(_onTabChanged);
    // İlk başta varsayılan olarak 0. index seçili olacak şekilde metodu çağırın
    context.read<GroupsScreenCubit>().getMyGroups(currentUser!);
    super.initState();
  }

  // Tab değişikliklerini dinleyen metod
  void _onTabChanged() {
    // Seçili tab'ın index'ini kontrol edin ve buna göre metodları çağırın
    if (_tabController.index == 0) {
      context.read<GroupsScreenCubit>().getMyGroups(currentUser!);
    } else if (_tabController.index == 1) {
      context.read<GroupsScreenCubit>().getAllGroups();
    }
    setState(() {
      //Close search when tab changes
      aramaYapiliyormu = false;
    });
  }

  @override
  void dispose() {
    //Stop Listener
    _tabController.removeListener(_onTabChanged);
    //Dispose TabController
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: aramaYapiliyormu
            ? TextField(
                style: const TextStyle(color: Colors.black87),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: "Search",
                ),
                onChanged: (searchText) {
                  context.read<GroupsScreenCubit>().filteredGroupList(
                      currentUser!, searchText, _tabController.index);
                },
              )
            : const Text("Groups"),
        actions: [
          aramaYapiliyormu
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      aramaYapiliyormu = false;
                    });
                    context.read<GroupsScreenCubit>().getAllGroups();
                  },
                  icon: const Icon(Icons.clear),
                )
              : IconButton(
                  onPressed: () {
                    setState(() {
                      aramaYapiliyormu = true;
                    });
                  },
                  icon: const Icon(Icons.search),
                ),
          IconButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const CreateGroupScreen()));
            },
            icon: const Icon(Icons.group_add),
            color: kSecondaryColor2,
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "My Groups"),
            Tab(text: "All Groups"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GroupList(),
          GroupList(),
        ],
      ),
    );
  }
}

class GroupList extends StatelessWidget {
  bool aramaYapiliyormu = false;
  Users? currentUser = UsersManager().currentUser;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupsScreenCubit, List<Groups>>(
        builder: (context, groupList) {
      if (groupList.isNotEmpty) {
        return ListView.builder(
          itemCount: groupList.length,
          itemBuilder: (context, index) {
            var group = groupList[index];
            Users? currentUser = UsersManager().currentUser;
            bool isOwner = group.owner == currentUser?.id;
            bool isMember = group.memberIds.contains(currentUser?.id);
            bool isWaitingMember =
                group.joinRequests!.contains(currentUser?.id);
            return InkWell(
              onTap: () {
                context
                    .read<GroupsScreenCubit>()
                    .checkGroupMembershipAndNavigate(context, group);
              },
              child: SizedBox(
                height: 80,
                // İstenilen sınırlı yüksekliği buradan ayarlayabilirsiniz
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
                            : const Icon(Icons.groups,
                                size: 60, color: kSecondaryColor2),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              group.name,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "${group.city} - ${group.country}",
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (isMember && !isOwner)
                              Card(
                                  color: Colors.green.shade100,
                                  child: const Text(
                                    "  Member  ",
                                    style: TextStyle(fontSize: 12),
                                  )),
                            if (isOwner)
                              Card(
                                  color: Colors.red.shade100,
                                  child: const Text(
                                    "  Admin  ",
                                    style: TextStyle(fontSize: 12),
                                  )),
                            if (isWaitingMember)
                              Card(
                                  color: Colors.amber.shade100,
                                  child: const Text(
                                    "  Request sent  ",
                                    style: TextStyle(fontSize: 12),
                                  )),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String result) {
                          handleMenuSelection(context, result, group, isOwner,
                              isMember, currentUser!);
                        },
                        itemBuilder: (BuildContext context) =>
                            <PopupMenuEntry<String>>[
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
                          if (!isOwner && !isMember && !isWaitingMember)
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
      }
      return const Center();
    });
  }
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
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => GroupMembersScreen(group: group)));
      break;
    case 'editGroup':
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EditGroupScreen(group: group)));
      break;
    case 'leaveGroup':
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: kSecondaryColor,
            title: const Text(
              "Warning",
              style: TextStyle(color: kSecondaryColor2),
            ),
            content: Text(
              "Are you sure you want to leave  from ${group.name}?",
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: kSecondaryColor2),
                ),
              ),
              TextButton(
                onPressed: () async {
                  context
                      .read<GroupsScreenCubit>()
                      .removeFromGroup(group, currentUser);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Leave",
                  style: TextStyle(color: Colors.red),
                ),
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
            title: const Text(
              "Warning",
              style: TextStyle(color: kSecondaryColor2),
            ),
            content: Text(
              "Send a request to join ${group.name}?",
              style: const TextStyle(color: Colors.white),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: kSecondaryColor2),
                ),
              ),
              TextButton(
                onPressed: () async {
                  context
                      .read<GroupsScreenCubit>()
                      .sendRequestToJoinGroup(context, group.id);
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "Send Request",
                  style: TextStyle(color: kSecondaryColor2),
                ),
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
