import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/accounts_screen_cubit.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  bool aramaYapiliyormu = false;

  @override
  void initState() {
    super.initState();
    context.read<AccountsScreenCubit>().getAllUsers();
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
            context.read<AccountsScreenCubit>().filtrele(arananKelime);
          },
        ):
        Text("Users"),
        actions: [
          aramaYapiliyormu ?
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = false;
            });
            context.read<AccountsScreenCubit>().getAllUsers(); // veri tabanından çektiğimizde gerekli
          }, icon:Icon(Icons.clear)):
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = true;
            });
          }, icon:Icon(Icons.search)),
        ],
      ),
      body: BlocBuilder<AccountsScreenCubit,List<Users>>(
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
                            child: Icon(Icons.account_circle,size: 50,color: Colors.orange,),
                          ),
                          SizedBox(width: 8),
                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                              Text(user.email),
                            ],
                          ),
                        ],
                      ),
                    );
                  });
            } return const Center();
          }),
    );
  }
}
