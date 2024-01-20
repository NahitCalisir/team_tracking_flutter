import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/users.dart';
import 'package:team_tracking/ui/cubits/settings_secreen_cubit.dart';
import 'package:team_tracking/utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {


  @override
  Widget build(BuildContext context) {
    context.read<SettingsScreenCubit>().getCurrentUserInfo();
    return BlocBuilder<SettingsScreenCubit, Users>(
      builder: (context, currentUser){
        return Scaffold(
          body: Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                            child: currentUser.photoUrl != null && currentUser.photoUrl!.isNotEmpty ?
                            ClipOval(
                              child: Image(
                                image: NetworkImage(currentUser.photoUrl!),
                                width: 100,
                                height: 100,
                              ),
                            ):
                            Icon(Icons.account_circle, size: 100, color: kSecondaryColor2),
                        ),
                        SizedBox(width: 8),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(currentUser.name,style: TextStyle(fontSize: 17,fontWeight: FontWeight.bold),),
                            Text(currentUser.email),
                          ],
                        ),
                      ],
                    ),
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

