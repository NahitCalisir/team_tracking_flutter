class Groups {
  String id;
  String name;
  String city;
  String country;
  String owner;
  List<String> memberIds;
  String? photoUrl;

  Groups({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.owner,
    required this.memberIds,
    this.photoUrl,
  });

  factory Groups.fromMap(String id, Map<String, dynamic> data) {
    List<String> memberIds = List.from(data["memberIds"]) ?? [] ;
    return Groups(
      id: id,
      name: data["name"],
      city: data["city"],
      country: data["country"],
      owner: data["owner"],
      memberIds: memberIds,
      photoUrl: data["photoUrl"]
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "city": city,
      "country": country,
      "owner": owner,
      "memberIds": memberIds,
      "photoUrl" : photoUrl,
    };
  }
}

