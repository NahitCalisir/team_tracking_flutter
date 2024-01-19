import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/groups.dart';
import 'package:team_tracking/data/entity/user_manager.dart';
import 'package:team_tracking/ui/cubits/groups_screen_cubit.dart';
import 'package:team_tracking/ui/views/groups_screen/create_group_screen.dart';
import 'package:team_tracking/ui/views/groups_screen/group_members_screen.dart';
import 'package:team_tracking/utils/constants.dart';

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
          builder: (context,groupList){
            if(groupList.isNotEmpty){
              return ListView.builder(
                  itemCount: groupList.length,
                  itemBuilder: (context, indeks){
                    var group = groupList[indeks];
                    return InkWell(
                      onTap: () {
                        checkGroupMembershipAndNavigate(context, group);
                      },
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
                                  width: 50,
                                  height: 50,
                                ) ,
                              )
                              : Icon(Icons.groups, size:  50, color: kSecondaryColor2,),
                            ),
                            SizedBox(width: 8),
                            Column(crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(group.name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                                Text("${group.city} - ${group.country}"),
                                Text("Admin: ${group.owner} (${group.memberIds.length})"),
                              ],
                            ),
                          ],
                        ),
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
        backgroundColor: kSecondaryColor2,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const CircleBorder( //OR: BeveledRectangleBorder etc.,
          //side: BorderSide(color: Colors.blue, width: 2.0, style: BorderStyle.solid)
        ),
        //mini: true,
      ),
    );
  }
}

void checkGroupMembershipAndNavigate(BuildContext context, Groups selectedGroup) {
  // Grup üyeliğini kontrol et
  bool isMember = selectedGroup.memberIds.contains(UsersManager().currentUser!.id);

  if (isMember) {
    // Kullanıcı grup üyesiyse UsersScreen'e git
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupMembersScreen(group: selectedGroup),
      ),
    );
  } else {
    // Kullanıcı grup üyesi değilse uyarı göster
    showMembershipAlert(context);
  }
}

void showMembershipAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Warning"),
        content: Text("You are not a member of this group. Send a request to join."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              sendJoinRequest();
              Navigator.of(context).pop();
            },
            child: Text("Send Request"),
          ),
        ],
      );
    },
  );
}

void sendJoinRequest() {
  // TODO: Grup üyeliği için istek gönderme işlemleri
  // İstek gönderme işlemlerini buraya ekleyin
  print("istek gönderme başlatıldı");
}
