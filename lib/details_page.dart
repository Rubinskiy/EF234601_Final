import 'package:flutter/material.dart';
import 'models/event_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class DetailsPage extends StatefulWidget {
  final EventModel event;

  const DetailsPage({super.key, required this.event});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  bool _isLoading = false;
  bool _isRegistered = false;
  final _additionalInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  @override
  void dispose() {
    _additionalInfoController.dispose();
    super.dispose();
  }

  Future<void> _checkRegistrationStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('registrations')
          .doc('${user.uid}_${widget.event.id}')
          .get();

      if (mounted) {
        setState(() => _isRegistered = doc.exists);
      }
    } catch (e) {
      print('Error checking registration status: $e');
    }
  }

  Future<void> _showRegistrationDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Register for Event'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide any additional information for the event organizers:'),
            const SizedBox(height: 16),
            TextField(
              controller: _additionalInfoController,
              decoration: const InputDecoration(
                hintText: 'Additional information (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _registerForEvent();
            },
            child: const Text('Register'),
          ),
        ],
      ),
    );
  }

  Future<void> _registerForEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to register for events')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('registrations')
          .doc('${user.uid}_${widget.event.id}')
          .set({
        'userId': user.uid,
        'eventId': widget.event.id,
        'additionalInfo': _additionalInfoController.text.trim(),
        'registeredAt': DateTime.now().toIso8601String(),
      });

      if (mounted) {
        setState(() => _isRegistered = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully registered for the event!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering for event: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> getUsernameFromUID(String uid) async {
    final user = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return user.data()?['name'];
  }

  Future<String?> getPhotoUrlFromUID(String uid) async {
    final user = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return user.data()?['pfp_url'];
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$address&format=json&limit=1');
    final response = await http.get(url, headers: {'User-Agent': 'campus_event_tracker/1.0'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        return LatLng(lat, lon);
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.event.toMap()['imageUrl'] ?? '';
    String date = widget.event.date;
    String time = widget.event.time;
    if (widget.event.date.contains('|')) {
      final parts = widget.event.date.split('|');
      date = parts[0].trim();
      time = parts.length > 1 ? parts[1].trim() : '';
    }

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
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
                Text(widget.event.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(widget.event.description, style: const TextStyle(fontSize: 18, color: Colors.black87)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Created By', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(width: 8),
                    FutureBuilder<String?>(
                      future: getPhotoUrlFromUID(widget.event.createdBy),
                      builder: (context, snapshot) {
                        return snapshot.data != null
                            ? CircleAvatar(backgroundImage: NetworkImage(snapshot.data ?? ''), radius: 10)
                            : const SizedBox.shrink();
                      },
                    ),
                    const SizedBox(width: 8),
                    FutureBuilder<String?>(
                      future: getUsernameFromUID(widget.event.createdBy),
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
                        const Text('Date', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 18)),
                        Text(date, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Time', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 18)),
                        Text(time.isNotEmpty ? time : '-', style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Location', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500, fontSize: 18)),
                        Text(widget.event.location.length > 30 ? '${widget.event.location.substring(0, 30)}...' : widget.event.location, style: const TextStyle(fontSize: 18)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text('Map Location', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                FutureBuilder<LatLng?>(
                  future: getCoordinatesFromAddress(widget.event.location),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(
                        height: 200,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return SizedBox(
                        height: 200,
                        child: FlutterMap(
                          options: MapOptions(
                            center: snapshot.data!,
                            zoom: 15.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              subdomains: ['a', 'b', 'c'],
                              userAgentPackageName: 'com.example.final_project',
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: snapshot.data!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Text('Lokasi tidak ditemukan di peta.');
                    }
                  },
                ),
                const SizedBox(height: 24),
                const Text('Main Organizer', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(widget.event.organizers),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isRegistered || _isLoading ? null : _showRegistrationDialog,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isRegistered ? 'Already Registered' : 'Register for this event',
                            style: const TextStyle(fontSize: 16),
                          ),
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
