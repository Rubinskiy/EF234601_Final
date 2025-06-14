class EventModel {
  final String id;
  final String name;
  final String description;
  final String date;
  final String time;
  final String imageUrl;
  final String location;
  final String organizers;
  final String createdBy;
  final String createdAt;

  EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.date,
    required this.time,
    this.imageUrl = '',
    required this.location,
    required this.organizers,
    required this.createdBy,
    required this.createdAt,
  });

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    return EventModel(
      id: id,
      name: map['name'],
      description: map['description'],
      date: map['date'],
      time: map['time'],
      imageUrl: map['imageUrl'] ?? '',
      location: map['location'],
      organizers: map['organizers'],
      createdBy: map['createdBy'],
      createdAt: map['createdAt'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'date': date,
      'time': time,
      'imageUrl': imageUrl,
      'location': location,
      'organizers': organizers,
      'createdBy': createdBy,
      'createdAt': createdAt,
    };
  }
}
