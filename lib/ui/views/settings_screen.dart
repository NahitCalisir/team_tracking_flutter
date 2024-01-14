import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/settings_secreen_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final Users currentUser;

  @override
  Widget build(BuildContext context) {
    context.read<SettingsScreenCubit>().getCurrentUserInfo();
    return BlocBuilder<SettingsScreenCubit, Users>(
      builder: (context, currentUser){
        return Scaffold(
          body: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ListTile(
                      title: Text(currentUser.name),
                      subtitle: Text(currentUser.email),
                      leading: CircleAvatar(child: Image.network(currentUser.photoUrl ?? "http://nahitcalisir.online/images/person2.png"),)
                  ),
                  ElevatedButton(
                      onPressed: (){
                        context.read<SettingsScreenCubit>().signOut(context);
                      },
                      child: Text("Sign Out"))
                ],
              )
          ),
        );
      },
    );
  }
}

