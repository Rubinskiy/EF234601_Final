import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import 'models/event_model.dart';
import 'details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final response = await http.get(Uri.parse('https://wsmj.org/test/api'));
    if (response.statusCode == 200) {
      final List events = json.decode(response.body);
      return events.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load external events');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localBox = Hive.box<EventModel>('events');

    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Events')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("🌐 External Events", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: fetchEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No events found.'));
              }
              final events = snapshot.data!;
              return SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return SizedBox(
                      width: 260,
                      child: Card(
                        margin: const EdgeInsets.only(right: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.grey[200],
                                  ),
                                  child: event['imageUrl'] != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(event['imageUrl'], fit: BoxFit.cover),
                                  )
                                      : const Icon(Icons.event, size: 48, color: Colors.grey),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(event['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(event['date'] ?? '', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("📦 Local Events", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: localBox.listenable(),
              builder: (context, Box<EventModel> box, _) {
                if (box.values.isEmpty) {
                  return const Center(child: Text("No local events available."));
                }
                final allEvents = box.values.toList(); // ✅ tampilkan SEMUA event
                return ListView.builder(
                  itemCount: allEvents.length,
                  itemBuilder: (context, index) {
                    final event = allEvents[index];
                    return ListTile(
                      title: Text(event.name),
                      subtitle: Text("${event.dateTime} | ${event.location}"),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => DetailsPage(event: event)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
