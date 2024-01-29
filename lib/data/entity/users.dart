import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class Users {
  String id; // Doküman ID'sini tutacak alan
  String name;
  String email;
  String photoUrl;
  String? phone;
  LatLng? lastLocation;
  List<String>? groups;
  Timestamp? lastLocationUpdatedAt;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.phone,
    this.lastLocation,
    this.groups,
    this.lastLocationUpdatedAt
  });

  factory Users.fromMap(String id, Map<String, dynamic> data) {
    List<String> groups = List.from(data["groups"]);
    return Users(
      id: id,
      name: data['name'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      phone: data['phone'],
      lastLocation: LatLng(
        data['lastLocation']['latitude'],
        data['lastLocation']['longitude'],
      ),
      groups: groups ,
      lastLocationUpdatedAt: data["lastLocationUpdatedAt"],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl' : photoUrl,
      'phone' : phone,
      'lastLocation': {
        'latitude': lastLocation?.latitude,
        'longitude': lastLocation?.longitude,
      },
      'groups' :groups
    };
  }

  // Custom method to format timestamp
  String formattedLastLocationUpdatedAt() {
    if (lastLocationUpdatedAt != null) {
      DateTime dateTime = lastLocationUpdatedAt!.toDate();
      return DateFormat('dd.MM.yyyy - HH:mm:ss').format(dateTime);
    } else {
      return '';
    }
  }

}
