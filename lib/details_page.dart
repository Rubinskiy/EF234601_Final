import 'package:flutter/material.dart';
import 'models/event_model.dart';

class DetailsPage extends StatelessWidget {
  final EventModel event;

  const DetailsPage({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.toMap()['imageUrl'] ?? '';
    // Split date and time if possible
    String date = event.date;
    String time = '';
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
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Date', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(date, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Time', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 4),
                          Text(time.isNotEmpty ? time : '-', style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Location', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(event.location, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 16)),
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
