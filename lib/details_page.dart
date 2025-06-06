import 'package:flutter/material.dart';
import 'models/event_model.dart';

class DetailsPage extends StatelessWidget {
  final EventModel event;

  const DetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.name)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Text("📍 Location: ${event.location}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("🕒 Date & Time: ${event.dateTime}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("📋 Description:\n${event.description}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text("🧑‍💼 Organizers: ${event.organizers}", style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
