import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/users_screen_cubit.dart';

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
    context.read<UsersScreenCubit>().getAllUsers();
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
            context.read<UsersScreenCubit>().filtrele(arananKelime);
          },
        ):
        const Text("Users"),
        actions: [
          aramaYapiliyormu ?
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = false;
            });
            context.read<UsersScreenCubit>().getAllUsers(); // veri tabanından çektiğimizde gerekli
          }, icon:const Icon(Icons.clear)):
          IconButton(onPressed: (){
            setState(() {
              aramaYapiliyormu = true;
            });
          }, icon:const Icon(Icons.search)),
        ],
      ),
      body: BlocBuilder<UsersScreenCubit,List<Users>>(
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
                          const SizedBox(width: 8),
                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.name,style: const TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
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
