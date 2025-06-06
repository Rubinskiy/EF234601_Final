import 'package:hive/hive.dart';

part 'event_model.g.dart';

@HiveType(typeId: 0)
class EventModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  String dateTime;

  @HiveField(3)
  String location;

  @HiveField(4)
  String organizers;

  @HiveField(5)
  String createdBy;

  EventModel({
    required this.name,
    required this.description,
    required this.dateTime,
    required this.location,
    required this.organizers,
    required this.createdBy,
  });
}
