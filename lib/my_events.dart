import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/event_model.dart';
import 'services/firestore_service.dart';

class MyEventsPage extends StatefulWidget {
  const MyEventsPage({super.key});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> {
  final _firestoreService = FirestoreService();

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
            onPressed: () async {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId == null) return;

              final data = {
                'name': nameController.text,
                'description': descController.text,
                'dateTime': dateTimeController.text,
                'location': locationController.text,
                'organizers': organizerController.text,
                'createdBy': userId,
              };

              if (event == null) {
                await _firestoreService.addEvent(data);
              } else {
                await _firestoreService.updateEvent(event.id, data);
              }

              Navigator.pop(context);
            },
            child: Text(event == null ? "Create" : "Update"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Event"),
        content: const Text("Are you sure you want to delete this event?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              await _firestoreService.deleteEvent(id);
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

    if (userId == null) return const Center(child: Text("Not logged in"));

    return Scaffold(
      appBar: AppBar(title: const Text("My Events")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getUserEvents(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("No events created."));

          final events = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return EventModel.fromMap(data, doc.id);
          }).toList();

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text(event.name),
                subtitle: Text("${event.dateTime} | ${event.location}"),
                onTap: () => _showEventDialog(event: event),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _confirmDelete(event.id),
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
