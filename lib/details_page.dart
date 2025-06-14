import 'package:flutter/material.dart';
import 'models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailsPage extends StatelessWidget {
  final EventModel event;

  const DetailsPage({super.key, required this.event});

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
    final imageUrl = event.toMap()['imageUrl'] ?? '';
    // Split date and time if possible
    String date = event.date;
    String time = event.time;
    if (event.date.contains('|')) {
      final parts = event.date.split('|');
      date = parts[0].trim();
      time = parts.length > 1 ? parts[1].trim() : '';
    }
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        children: [
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: Image.network(
                imageUrl,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, size: 80, color: Colors.grey),
                ),
              ),
            )
          else
            Container(
              height: 200,
              color: Colors.grey[200],
              child: const Icon(Icons.image, size: 80, color: Colors.grey),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 18, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Created By', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(width: 8),
                    FutureBuilder<String?>(
                      future: getPhotoUrlFromUID(event.createdBy),
                      builder: (context, snapshot) {
                        return snapshot.data != null ? CircleAvatar(
                          backgroundImage: NetworkImage(snapshot.data ?? ''),
                          radius: 10,
                        ) : const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(width: 8),
                    FutureBuilder<String?>(
                      future: getUsernameFromUID(event.createdBy),
                      builder: (context, snapshot) {
                        return Text(snapshot.data ?? 'Unknown User', style: const TextStyle(fontSize: 14, color: Colors.blueGrey));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Date', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 18)),
                        Text(date, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Time', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 18)),
                        Text(time.isNotEmpty ? time : '-', style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Location', style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 18)),
                        Text(event.location.length > 30 ? '${event.location.substring(0, 30)}...' : event.location, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // card for organizers
                const Text('Main Organizer', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(event.organizers),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Register for this event', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
