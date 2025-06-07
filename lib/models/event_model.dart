class EventModel {
  final String id;
  final String name;
  final String description;
  final String dateTime;
  final String location;
  final String organizers;
  final String createdBy;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.organizers,
    required this.createdBy,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      name: map['name'],
      description: map['description'],
      dateTime: map['dateTime'],
      location: map['location'],
      organizers: map['organizers'],
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'dateTime': dateTime,
      'location': location,
      'organizers': organizers,
      'createdBy': createdBy,
    };
  }
}
