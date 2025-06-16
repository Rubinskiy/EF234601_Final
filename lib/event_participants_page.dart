import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/event_model.dart';

class EventParticipantsPage extends StatelessWidget {
  final EventModel event;

  const EventParticipantsPage({super.key, required this.event});

  Future<String?> getUsernameFromUID(String uid) async {
    final user = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return user.data()?['name'];
  }

  Future<String?> getPhotoUrlFromUID(String uid) async {
    final user = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return user.data()?['pfp_url'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Participants'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('registrations')
            .where('eventId', isEqualTo: event.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No participants yet',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final registrations = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: registrations.length,
            itemBuilder: (context, index) {
              final registration = registrations[index].data() as Map<String, dynamic>;
              final userId = registration['userId'] as String;
              final additionalInfo = registration['additionalInfo'] as String?;
              final registeredAt = DateTime.parse(registration['registeredAt'] as String);

              return FutureBuilder<String?>(
                future: getUsernameFromUID(userId),
                builder: (context, usernameSnapshot) {
                  return FutureBuilder<String?>(
                    future: getPhotoUrlFromUID(userId),
                    builder: (context, photoSnapshot) {
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: photoSnapshot.data != null
                                ? NetworkImage(photoSnapshot.data!)
                                : null,
                            child: photoSnapshot.data == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(
                            usernameSnapshot.data ?? 'Unknown User',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (additionalInfo?.isNotEmpty ?? false)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    additionalInfo!,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  'Registered on ${registeredAt.toString().split('.')[0]}',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 