import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/event_model.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  final _eventBox = Hive.box<EventModel>('events');

  void _showEventDialog({EventModel? event}) {
    final nameController = TextEditingController(text: event?.name);
    final descController = TextEditingController(text: event?.description);
    final dateTimeController = TextEditingController(text: event?.dateTime);
    final locationController = TextEditingController(text: event?.location);
    final organizerController = TextEditingController(text: event?.organizers);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event == null ? "Create Event" : "Edit Event"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Event Name")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
              TextField(controller: dateTimeController, decoration: const InputDecoration(labelText: "Date & Time")),
              TextField(controller: locationController, decoration: const InputDecoration(labelText: "Location")),
              TextField(controller: organizerController, decoration: const InputDecoration(labelText: "Organizers")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) return;

              final newEvent = EventModel(
                name: nameController.text,
                description: descController.text,
                dateTime: dateTimeController.text,
                location: locationController.text,
                organizers: organizerController.text,
                createdBy: userId,
              );

              if (event == null) {
                _eventBox.add(newEvent);
              } else {
                event
                  ..name = newEvent.name
                  ..description = newEvent.description
                  ..dateTime = newEvent.dateTime
                  ..location = newEvent.location
                  ..organizers = newEvent.organizers
                  ..save();
              }

              Navigator.pop(context);
            },
            child: Text(event == null ? "Create" : "Update"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event"),
        content: Text("Are you sure you want to delete ${event.name}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              event.delete();
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Events")),
      body: ValueListenableBuilder(
        valueListenable: _eventBox.listenable(),
        builder: (context, Box<EventModel> box, _) {
          final myEvents = box.values.where((e) => e.createdBy == userId).toList();

          if (myEvents.isEmpty) {
            return const Center(child: Text("You haven't created any events."));
          }

          return ListView.builder(
            itemCount: myEvents.length,
            itemBuilder: (context, index) {
              final event = myEvents[index];
              return ListTile(
                title: Text(event.name),
                subtitle: Text("${event.dateTime} | ${event.location}"),
                onTap: () => _showEventDialog(event: event),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(event),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
