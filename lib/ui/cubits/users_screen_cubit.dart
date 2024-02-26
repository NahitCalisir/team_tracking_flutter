import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:team_tracking/data/entity/users.dart';

class UsersScreenCubit extends Cubit<List<Users>> {
  UsersScreenCubit():super(<Users>[]);

  final userCollection = FirebaseFirestore.instance.collection("users");
  final firebaseAuth = FirebaseAuth.instance;

  Future<void> getAllUsers() async {
    //Firebase kullanırken repo içersinde veriyi çekip retun edemiyoruz.
    // direk cubit içeriside yapıyoruz.
    //bu metod veri tabanını sürekli dinliyor ve veri tabanında bir değişiklik olduğu an emit ediyor.
    userCollection.snapshots().listen((event) {
      var userList = <Users>[];
      var documents = event.docs;
      for (var document in documents) {
        var user = Users(
            id: document.id,
            name: document["name"] as String,
            email: document["email"] as String,
            photoUrl: document["photoUrl"] as String,);
        userList.add(user);
      }
      emit(userList);
    });
  }

  Future<void> filtrele(String aramaTerimi) async {
    userCollection.snapshots().listen((event) {
      var userList = <Users>[];

      var documents = event.docs;
      for (var document in documents) {
        var user = Users(
            id: document.id,
            name: document["name"] as String,
            email: document["email"] as String,
            photoUrl: document["photoURl"] as String ?? "");
        if(user.name.toLowerCase().contains(aramaTerimi.toLowerCase())){
          userList.add(user);
        }
      }
      emit(userList);
    });
  }

}
