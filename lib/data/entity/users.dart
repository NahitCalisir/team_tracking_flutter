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
  DateTime? lastLocationUpdatedAt;
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
          ? LatLng(
        data['lastLocation']['latitude'],
        data['lastLocation']['longitude'],
      )
          : null,
      lastLocationUpdatedAt: data["lastLocationUpdatedAt"] != null
          ? (data["lastLocationUpdatedAt"] as Timestamp).toDate()
          : null,
      lastSpeed: (data['lastSpeed'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'phone': phone,
      'lastLocation': {
        'latitude': lastLocation?.latitude,
        'longitude': lastLocation?.longitude,
      },
      'lastLocationUpdatedAt': lastLocationUpdatedAt != null
          ? Timestamp.fromDate(lastLocationUpdatedAt!)
          : null,
      'lastSpeed': lastSpeed,
    };
  }

  String formattedLastLocationUpdatedAt() {
    if (lastLocationUpdatedAt != null) {
      return DateFormat('dd.MM.yyyy - HH:mm:ss').format(lastLocationUpdatedAt!);
    } else {
      return '';
    }
  }
}

