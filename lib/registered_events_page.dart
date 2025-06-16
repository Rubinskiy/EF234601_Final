import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models/event_model.dart';
import 'details_page.dart';

class RegisteredEventsPage extends StatelessWidget {
  const RegisteredEventsPage({super.key});

  Future<EventModel?> getEventDetails(String eventId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('events').doc(eventId).get();
      if (doc.exists) {
        return EventModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      // error fetching event details
    }
    return null;
  }

  Future<void> _editAdditionalInfo(BuildContext context, String registrationId, String currentInfo) async {
    final controller = TextEditingController(text: currentInfo);
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Additional Information'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Additional information',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('registrations')
                    .doc(registrationId)
                    .update({'additionalInfo': controller.text.trim()});
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Information updated successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating information: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showCancelRegistrationDialog(BuildContext context, String registrationId) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Registration'),
        content: const Text('Are you sure you want to cancel your registration for this event?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No, Keep Registration'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance
                    .collection('registrations')
                    .doc(registrationId)
                    .delete();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Registration cancelled successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error cancelling registration: $e')),
                  );
                }
              }
            },
            child: const Text('Yes, Cancel Registration', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text("Not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registered Events'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('registrations')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t registered for any events yet',
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
              final eventId = registration['eventId'] as String;
              final additionalInfo = registration['additionalInfo'] as String?;
              final registeredAt = DateTime.parse(registration['registeredAt'] as String);

              return FutureBuilder<EventModel?>(
                future: getEventDetails(eventId),
                builder: (context, eventSnapshot) {
                  if (!eventSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final event = eventSnapshot.data!;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailsPage(event: event),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Event Image
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: event.imageUrl.isNotEmpty
                                      ? Image.network(
                                          event.imageUrl,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 80,
                                          height: 80,
                                          color: Colors.grey[300],
                                          child: const Icon(Icons.image, size: 32, color: Colors.white),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                // Event Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        event.name,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.description,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.grey),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              event.date,
                                              style: TextStyle(color: Colors.blue[700], fontSize: 12),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.blue[50],
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              event.time,
                                              style: TextStyle(color: Colors.blue[700], fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (additionalInfo?.isNotEmpty ?? false) ...[
                              const Divider(height: 24),
                              Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Your Additional Information:',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 16),
                                    onPressed: () => _editAdditionalInfo(
                                      context,
                                      registrations[index].id,
                                      additionalInfo ?? '',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Text(
                                  additionalInfo!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              'Registered on ${registeredAt.toString().split('.')[0]}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () => _showCancelRegistrationDialog(
                                    context,
                                    registrations[index].id,
                                  ),
                                  icon: const Icon(Icons.cancel_outlined, size: 18),
                                  label: const Text('Cancel Registration'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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