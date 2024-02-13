import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/activities.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/ui/cubits/activities_screen_cubit.dart';
import 'package:team_tracking/ui/views/activities_screen/create_activity_screen.dart';
import 'package:team_tracking/ui/views/activities_screen/edit_activity_screen.dart';
import 'package:team_tracking/ui/views/activities_screen/activity_members_screen.dart';
import 'package:team_tracking/utils/constants.dart';
import '../../../data/entity/users.dart';

class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});

  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}

class _ActivitiesScreenState extends State<ActivitiesScreen>
    with SingleTickerProviderStateMixin {
  bool isSearching = false;
  late TabController _tabController;
  Users? currentUser = UsersManager().currentUser;


  @override
  void initState() {
    // TabController'ı doğrudan oluşturma
    _tabController = TabController(length: 2, vsync: this);
    // Tab değişikliklerini dinlemek için listener ekledik
    _tabController.addListener(_onTabChanged);
    // İlk başta varsayılan olarak 0. index seçili olacak şekilde metodu çağırın
    context.read<ActivitiesScreenCubit>().getMyActivities(currentUser!);
    super.initState();
  }

  // Tab değişikliklerini dinleyen metod
  void _onTabChanged() {
    // Seçili tab'ın index'ini kontrol edin ve buna göre metodları çağırın
    if (_tabController.index == 0) {
      context.read<ActivitiesScreenCubit>().getMyActivities(currentUser!);
    } else if (_tabController.index == 1) {
      context.read<ActivitiesScreenCubit>().getAllActivities();
    }
    setState(() {
      //Close search when tab changes
      isSearching = false;
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
    return Stack(
      children: [
        // Background image
        Image.asset(
          'assets/images/background_image4.jpg',
          fit: BoxFit.cover,
        ),
        Scaffold(backgroundColor: Colors.transparent,
          appBar: AppBar(backgroundColor: Colors.transparent,foregroundColor: Colors.white,
            title: isSearching
                ? TextField(
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade800)
                      ),
                      suffixIconColor: Colors.red,
                      hintText: "Search",
                    ),
                    onChanged: (searchText) {
                      context.read<ActivitiesScreenCubit>().filteredActivityList(
                          currentUser!, searchText, _tabController.index);
                    },
                  )
                : const Text("Activities"),
            actions: [
              isSearching
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          isSearching = false;
                        });
                        context.read<ActivitiesScreenCubit>().getAllActivities();
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : IconButton(
                      onPressed: () {
                        setState(() {
                          isSearching = true;
                        });
                      },
                      icon: const Icon(Icons.search),
                    ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const CreateActivityScreen()));
                },
                icon: const Icon(Icons.add),
              )
            ],
            bottom: TabBar(
              labelColor: Colors.white,
              indicatorColor: Colors.white,
              dividerColor: Colors.grey.shade800,
              controller: _tabController,
              tabs: const [
                Tab(text: "My Activities"),
                Tab(text: "All Activities"),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              ActivityList(),
              ActivityList(),
            ],
          ),
        ),
      ],
    );
  }
}


class ActivityList extends StatelessWidget {
  bool isSearching = false;
  Users? currentUser = UsersManager().currentUser;

  ActivityList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivitiesScreenCubit, List<Activities>>(
      builder: (context, activityList) {
        if (activityList.isNotEmpty) {
          activityList.sort((a,b) => b.timeStart.compareTo(a.timeStart));
          return ListView.builder(
            itemCount: activityList.length,
            itemBuilder: (context, index) {
              var activity = activityList[index];
              Users? currentUser = UsersManager().currentUser;
              bool isOwner = activity.owner == currentUser?.id;
              bool isMember = activity.memberIds.contains(currentUser?.id);
              bool isWaitingMember =
                  activity.joinRequests!.contains(currentUser?.id);
              return InkWell(
                onTap: () {
                  context
                      .read<ActivitiesScreenCubit>()
                      .checkActivityMembershipAndNavigate(context, activity);
                },
                child: SizedBox(
                  height: 235,
                  // İstenilen sınırlı yüksekliği buradan ayarlayabilirsiniz
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8,right: 8,top: 8),
                    child: Card(color: Colors.grey.shade900.withOpacity(0.4),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: activity.photoUrl!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image(
                                      image: NetworkImage(activity.photoUrl!),
                                      fit: BoxFit.cover,
                                      width: 70,
                                      height: 70,
                                    ),
                                  )
                                : const Icon(Icons.run_circle_outlined,
                                    size: 70, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activity.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                        fontSize: 17,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  (activity.routeDistance != 0) ?
                                    Text("Distance    : ${activity.routeDistance?.toStringAsFixed(1)} km",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey)):
                                    const Text("Distance    : Route not selected",
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.grey)),
                                  (activity.routeElevation != 0) ?
                                    Text("Elevation   : ${activity.routeElevation?.toStringAsFixed(0)} m",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.grey)):
                                  const Text("Elevation   : Route not selected",
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.grey)),
                                  Row(
                                    children: [
                                      const Text("Status         : ",style: TextStyle(color: Colors.grey),),
                                      if(activity.getActivityStatus() == ActivityStatus.notStarted)
                                        const Text("Not Started",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.green,
                                            )),
                                      if(activity.getActivityStatus() == ActivityStatus.finished)
                                        const Text("Finished",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.red,
                                            )),
                                      if(activity.getActivityStatus() == ActivityStatus.continues)
                                        const Text("Continues",
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.yellow,
                                            )),
                                    ],
                                  ),
                                  Text("Start Time : ${activity.formattedTimestamp(activity.timeStart)}",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey)),
                                  Text("End   Time : ${activity.formattedTimestamp(activity.timeEnd)}",
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.grey)),
                                  Text("Location    : ${activity.city} - ${activity.country}",
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey),
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
                                        color: Colors.red.shade200,
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
                                  const Spacer(),
                                ],
                              ),
                            ),
                          ),
                          PopupMenuButton<String>(iconSize: 30,
                            iconColor: Colors.white,
                            color: Colors.black,
                            onSelected: (String result) {
                              handleMenuSelection(context, result, activity, isOwner,
                                  isMember, currentUser!);
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              if (isMember)
                                const PopupMenuItem<String>(
                                  value: 'activityDetails',
                                  child: Text('Activity Details',style: TextStyle(color: Colors.white),),
                                ),
                              if (isOwner)
                                const PopupMenuItem<String>(
                                  value: 'editActivity',
                                  child: Text('Edit Activity',style: TextStyle(color: Colors.white),),
                                ),
                              if (!isOwner && isMember)
                                const PopupMenuItem<String>(
                                  value: 'leaveActivity',
                                  child: Text('Leave Activity',style: TextStyle(color: Colors.white),),
                                ),
                              if (!isOwner && !isMember && !isWaitingMember)
                                const PopupMenuItem<String>(
                                  value: 'joinActivity',
                                  child: Text('Join Activity',style: TextStyle(color: Colors.white),),
                                ),
                              if (isWaitingMember)
                                const PopupMenuItem<String>(
                                  value: 'cancelRequest',
                                  child: Text('Cancel Request',style: TextStyle(color: Colors.white),),
                                ),
                            ],
                          )
                        ],
                      ),
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
  Activities activity,
  bool isOwner,
  bool isMember,
  Users currentUser,
) {
  switch (result) {
    case 'activityDetails':
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ActivityMembersScreen(activity: activity)));
      break;
    case 'editActivity':
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => EditActivityScreen(activity: activity)));
      break;
    case 'leaveActivity':
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
              "Are you sure you want to leave  from ${activity.name}?",
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
                      .read<ActivitiesScreenCubit>()
                      .removeFromActivity(activity, currentUser);
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
    case 'joinActivity':
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
              "Send a request to join ${activity.name}?",
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
                      .read<ActivitiesScreenCubit>()
                      .sendRequestToJoinActivity(context, activity.id);
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
      context.read<ActivitiesScreenCubit>().cancelRequest(activity, currentUser);
      break;
  }
}
