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
  DateTime timeStart;
  DateTime timeEnd;

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

  factory Activities.fromMap(String id, Map<String, dynamic> data) {
    List<String> memberIds = List.from(data["memberIds"]) ?? [];
    List<String> joinRequests = List.from(data["joinRequests"]) ?? [];

    // Değerleri doğru türde almak için DateTime.parse kullanıyoruz
    DateTime timeStart = DateTime.parse(data["timeStart"]);
    DateTime timeEnd = DateTime.parse(data["timeEnd"]);

    return Activities(
      id: id,
      name: data["name"],
      city: data["city"],
      country: data["country"],
      owner: data["owner"],
      memberIds: memberIds,
      photoUrl: data["photoUrl"],
      joinRequests: joinRequests,
      timeStart: timeStart,
      timeEnd: timeEnd,
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
      "timeStart": timeStart.toIso8601String(), // DateTime nesnelerini ISO 8601 formatına çeviriyoruz
      "timeEnd": timeEnd.toIso8601String(),
    };
  }

  ActivityStatus getActivityStatus() {
    DateTime now = DateTime.now();
    if (timeStart.isAfter(now)) {
      return ActivityStatus.notStarted;
    } else if (timeEnd.isBefore(now)) {
      return ActivityStatus.finished;
    } else {
      return ActivityStatus.continues;
    }
  }
}

/*
Kullanış şekli

Activities myActivity = ...; // Aktivitenizi oluşturun veya alın

ActivityStatus status = myActivity.getActivityStatus();

if (status == ActivityStatus.notStarted) {
  print("Aktivite başlamadı!");
} else if (status == ActivityStatus.ongoing) {
  print("Aktivite devam ediyor!");
} else if (status == ActivityStatus.finished) {
  print("Aktivite bitmiş!");
}
 */
