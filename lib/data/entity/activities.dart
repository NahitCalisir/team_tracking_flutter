import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum ActivityStatus {
  notStarted,
  continues,
  finished,
}

class Activities {
  String id;
  String name;
  String city;
  String country;
  String owner;
  List<String> memberIds;
  String? photoUrl;
  List<String>? joinRequests;
  Timestamp timeStart;
  Timestamp timeEnd;

  Activities({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.owner,
    required this.memberIds,
    this.photoUrl,
    this.joinRequests,
    required this.timeStart,
    required this.timeEnd,
  });

  factory Activities.fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) {
      throw ArgumentError("Map cannot be null");
    }

    List<String> memberIds = List.from(data["memberIds"] ?? []);
    List<String> joinRequests = List.from(data["joinRequests"] ?? []);

    return Activities(
      id: id,
      name: data["name"] ?? "",
      city: data["city"] ?? "",
      country: data["country"] ?? "",
      owner: data["owner"] ?? "",
      memberIds: memberIds,
      photoUrl: data["photoUrl"],
      joinRequests: joinRequests,
      timeStart: data["timeStart"] ?? Timestamp.now(),
      timeEnd: data["timeEnd"] ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "city": city,
      "country": country,
      "owner": owner,
      "memberIds": memberIds,
      "photoUrl": photoUrl,
      "joinRequests": joinRequests,
      "timeStart": timeStart,
      "timeEnd": timeEnd,
    };
  }

  ActivityStatus getActivityStatus() {
    DateTime now = DateTime.now();
    if (timeStart.toDate().isAfter(now)) {
      return ActivityStatus.notStarted;
    } else if (timeEnd.toDate().isBefore(now)) {
      return ActivityStatus.finished;
    } else {
      return ActivityStatus.continues;
    }
  }

  String formattedTimestamp(time) {
    DateTime dateTime = time!.toDate();
    return DateFormat('dd.MM.yyyy - HH:mm').format(dateTime);
  }
}

/*
Kullanış şekli

Activities myActivity = ...; // Aktivitenizi oluşturun veya alın

print("Aktivite Durumu: ${myActivity.getActivityStatus()}");
*/
