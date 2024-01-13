import 'package:latlng/latlng.dart';

class Users {
  String id; // Doküman ID'sini tutacak alan
  String name;
  String email;
  String? photoUrl;
  String? phone;
  LatLng? lastLocation;

  Users({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.lastLocation,
    this.phone,
  });

  factory Users.fromMap(String id, Map<String, dynamic> data) {
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
    };
  }
}
