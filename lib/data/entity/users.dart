import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class Users {
  String id;
  String name;
  String email;
  String photoUrl;
  String? phone;
  LatLng? lastLocation;
  Timestamp? lastLocationUpdatedAt;
  double? lastSpeed;

  Users({
    required this.id,
    required this.name,
    required this.email,
    required this.photoUrl,
    this.phone,
    this.lastLocation,
    this.lastLocationUpdatedAt,
    this.lastSpeed,
  });

  factory Users.fromMap(String id, Map<String, dynamic> data) {
    return Users(
      id: id,
      name: data['name'],
      email: data['email'],
      photoUrl: data['photoUrl'],
      phone: data['phone'],
      lastLocation: data['lastLocation'] != null
          ? LatLng(data['lastLocation']['latitude'], data['lastLocation']['longitude'])
          : null,
      lastLocationUpdatedAt: data['lastLocationUpdatedAt'],
      lastSpeed: data['lastSpeed']?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'lastLocation': lastLocation != null
          ? {'latitude': lastLocation!.latitude, 'longitude': lastLocation!.longitude}
          : null,
      'lastLocationUpdatedAt': lastLocationUpdatedAt,
      'lastSpeed': lastSpeed,
    };
  }

  // Custom method to format timestamp
  String formattedLastLocationUpdatedAt() {
    if (lastLocationUpdatedAt != null) {
      DateTime dateTime = lastLocationUpdatedAt!.toDate();
      return DateFormat('dd.MM.yyyy - HH:mm:ss').format(dateTime);
    } else {
      return 'No timestamp available';
    }
  }
}
