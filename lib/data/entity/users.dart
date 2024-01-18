import 'package:latlong2/latlong.dart';

class Users {
  String id; // Doküman ID'sini tutacak alan
  String name;
  String email;
  String? photoUrl;
  String? phone;
  LatLng? lastLocation;
  List<String>? groups;

  Users({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.phone,
    this.lastLocation,
    this.groups
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
}
