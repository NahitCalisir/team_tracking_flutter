import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/activities.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/activity_members_screen_cubit.dart';
import 'package:team_tracking/ui/views/map_screen/map_screen_for_activity.dart';
import 'package:team_tracking/utils/constants.dart';

class ActivityMembersScreen extends StatefulWidget {
  final Activities activity;

  const ActivityMembersScreen({super.key, required this.activity});
  @override
  _ActivityMembersScreenState createState() => _ActivityMembersScreenState();
}


class _ActivityMembersScreenState extends State<ActivityMembersScreen>
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
    context.read<ActivityMembersScreenCubit>().getActivityMembers(widget.activity);
    super.initState();
  }

  // Tab değişikliklerini dinleyen metod
  void _onTabChanged() {
    // Seçili tab'ın index'ini kontrol edin ve buna göre metodları çağırın
    if (_tabController.index == 0) {
      context.read<ActivityMembersScreenCubit>().getActivityMembers(widget.activity);
    } else if (_tabController.index == 1) {
      context.read<ActivityMembersScreenCubit>().getMemberRequestList(widget.activity);
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
    return DefaultTabController(
      length: 2, // İki sekme
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/background_image4.jpg',
            fit: BoxFit.cover,
          ),
          Scaffold(backgroundColor: Colors.transparent,
            appBar: AppBar(backgroundColor: Colors.transparent,foregroundColor: Colors.white,
              title: Text(widget.activity.name),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight), // AppBar'ın yüksekliği
                child: Stack(
                  children: [
                    TabBar(
                      labelColor: Colors.white,
                      indicatorColor: Colors.white,
                      dividerColor: Colors.grey.shade800,
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Activity Members'),
                        Tab(text: 'Membership Requests'),
                      ],
                    ),
                    if(widget.activity.joinRequests!.isNotEmpty)
                    Positioned(
                      top: 2,
                      right: 2,
                      child: CircleAvatar(
                        radius: 9,
                        backgroundColor: Colors.red,
                        child: Text(
                          widget.activity.joinRequests!.length.toString(),
                          style: const TextStyle(color: Colors.white,fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                IconButton(
                    onPressed: (){
                      if(widget.activity.timeEnd.toDate().isAfter(DateTime.now())) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context)=>MapScreenForActivity(activity: widget.activity)))
                            .then((value) => context.read<ActivityMembersScreenCubit>().getActivityMembers(widget.activity));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Activity completed."),backgroundColor: Colors.red,)
                        );
                      }
                    },
                    icon: const Icon(Icons.map_outlined,size: 30,)),
              ],
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                ActivityMembersList(activity: widget.activity,tabController: _tabController,),
                ActivityMembersList(activity: widget.activity,tabController: _tabController,),
                //MembershipRequestsList(activity: widget.activity),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActivityMembersList extends StatelessWidget {
  final Activities activity;

  TabController tabController;

  ActivityMembersList({super.key, required this.activity,required this.tabController});

  bool aramaYapiliyormu = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityMembersScreenCubit,List<Users>>(
      builder: (context,userList){
        DateTime now = DateTime.now();
        if(userList.isNotEmpty){
          return ListView.builder(
            itemCount: userList.length,
            itemBuilder: (context, indeks){
              var user = userList[indeks];
              Users? currentUser = UsersManager().currentUser;
              bool isOwner = activity.owner == currentUser?.id;
              bool isMember = activity.memberIds.contains(currentUser?.id);
              bool isWaitingMember = activity.joinRequests!.contains(currentUser?.id);
              DateTime lastLocationUpdatedAt = (user.lastLocationUpdatedAt as Timestamp).toDate();
              return Padding(
                padding: const EdgeInsets.only(top: 8.0,left: 8,right: 8),
                child: SizedBox(
                  height: 100,
                  child: Card(
                    color: Colors.grey.shade900.withOpacity(0.4),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: user.photoUrl.isEmpty ?
                          const Icon(Icons.account_circle, size: 50, color: Colors.grey,):
                          ClipOval(
                            child: Image(
                              image: NetworkImage(user.photoUrl),
                              width: 50,
                              height: 50,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(user.name,style: const TextStyle(color: Colors.white ,fontSize: 17,fontWeight: FontWeight.bold),),
                                const SizedBox(width: 8,),
                                Icon(Icons.circle,size: 15,color: (now.difference(lastLocationUpdatedAt).inMinutes <= 5) ?  Colors.greenAccent:  Colors.redAccent ),
                              ],
                            ),
                            Text(user.email, style: TextStyle(color: Colors.grey),),
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
                            handleMenuSelection(context, result, activity, isOwner, isMember,user);
                          },
                          color: Colors.black,
                          iconColor: Colors.white,
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                            if (tabController.index == 0) const PopupMenuItem<String>(
                              value: 'remove',
                              child: Text('Remove',style: TextStyle(color: Colors.white),),
                            ),
                            if (tabController.index == 1) const PopupMenuItem<String>(
                              value: 'accept',
                              child: Text('Accept',style: TextStyle(color: Colors.white)),
                            ),
                            if (tabController.index == 1) const PopupMenuItem<String>(
                              value: 'reject',
                              child: Text('Reject',style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
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
    Activities activity,
    bool isOwner,
    bool isMember,
    Users user
    ) async {
  switch (result)  {
    case 'remove':
      print(!isOwner);
      if(activity.owner.contains(user.id)) { //eğer çıkarılmak istenen admin ise
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: kSecondaryColor,
              title: const Text("Warning",style: TextStyle(color: kSecondaryColor2),),
              content: const Text("You cannot leave the activity because you are the administrator. If you wish, you can delete the activity entirely.",style: TextStyle(color: Colors.white),),
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
              content: Text("Are you sure you want to remove ${user.name}  from the activity?",style: const TextStyle(color: Colors.white),),
              actions: [
                TextButton(
                  onPressed: () async {Navigator.of(context).pop();},
                  child: const Text("Cancel",style: TextStyle(color: kSecondaryColor2),),
                ),
                TextButton(
                  onPressed: () async {
                    await context.read<ActivityMembersScreenCubit>().removeFromActivity(activity, user);
                    await context.read<ActivityMembersScreenCubit>().getActivityMembers(activity);
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
    case 'accept':
      await context.read<ActivityMembersScreenCubit>().acceptJoinRequest(activity, user);
      await context.read<ActivityMembersScreenCubit>().getMemberRequestList(activity);
      break;
    case 'reject':
      await context.read<ActivityMembersScreenCubit>().rejectJoinRequest(activity, user);
      await context.read<ActivityMembersScreenCubit>().getMemberRequestList(activity);

      break;
  }
}

/*
class MembershipRequestsList extends StatelessWidget {
  final Activities activity;

  MembershipRequestsList({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    // ActivityMembersScreenCubit ile grup üyelerini getir
    context.read<ActivityMembersScreenCubit>().getMemberRequestList(activity);
    return BlocBuilder<ActivityMembersScreenCubit,List<Users>>(
        builder: (context,userList){
          DateTime now = DateTime.now();
          if(userList.isNotEmpty){
            return ListView.builder(
                itemCount: userList.length,
                itemBuilder: (context, indeks){
                  var user = userList[indeks];
                  Users? currentUser = UsersManager().currentUser;
                  bool isOwner = activity.owner == currentUser?.id;
                  bool isMember = activity.memberIds.contains(currentUser?.id);
                  bool isWaitingMember = activity.joinRequests!.contains(currentUser?.id);
                  DateTime lastLocationUpdatedAt = (user.lastLocationUpdatedAt as Timestamp).toDate();
                  return Card(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: user.photoUrl.isEmpty ?
                          const Icon(Icons.account_circle, size: 50, color: kSecondaryColor2,):
                          ClipOval(
                            child: Image(
                              image: NetworkImage(user.photoUrl),
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
                            handleMenuSelectionForRequests(context, result, activity, isOwner, isMember,user);
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
                  );
                });
          } return const Center();
        });
  }
}
*/



/*
void handleMenuSelectionForRequests(
    BuildContext context,
    String result,
    Activities activity,
    bool isOwner,
    bool isMember,
    Users user
    ) async {
  switch (result)  {
    case 'accept':
    await context.read<ActivityMembersScreenCubit>().acceptJoinRequest(activity, user);
    await context.read<ActivityMembersScreenCubit>().getMemberRequestList(activity);
      break;
    case 'reject':
      await context.read<ActivityMembersScreenCubit>().rejectJoinRequest(activity, user);
      await context.read<ActivityMembersScreenCubit>().getMemberRequestList(activity);

      break;
  }
}
*/

