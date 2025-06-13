import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onLogout;
  const ProfilePage({super.key, required this.onLogout});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  Map<String, dynamic> _userProfile = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (mounted && doc.exists) {
          setState(() => _userProfile = doc.data() ?? {});
        }
      }
    } catch (e) {
      if(mounted) _showSnackBar('Failed to load profile: $e');
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToEditProfile() async {
    // Navigate to the edit page and wait for a result
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfilePage()),
    );


    if (result == true) {
      _loadUserProfile();
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  String _getDisplayValue(String field, String fallback) {
    return _userProfile[field]?.toString().isNotEmpty == true
        ? _userProfile[field].toString()
        : fallback;
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Profile Header
            Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.orange,
                  backgroundImage: _userProfile['photoURL'] != null && _userProfile['photoURL'].toString().isNotEmpty
                      ? NetworkImage(_userProfile['photoURL'])
                      : null,
                  child: _userProfile['photoURL'] == null || _userProfile['photoURL'].toString().isEmpty
                      ? const Icon(Icons.person, size: 64, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _getDisplayValue('displayName', user?.displayName ?? 'Anonymous'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'No email',
                  style: const TextStyle(color: Colors.blueGrey),
                ),
                if (_userProfile['bio'] != null && _userProfile['bio'].toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                    child: Text(
                      _userProfile['bio'],
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // Edit Profile Button
            Center(
              child: ElevatedButton.icon(
                onPressed: _navigateToEditProfile,
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Preferences Section
            const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Email Notifications'),
                    subtitle: const Text('Receive updates via email'),
                    value: _userProfile['emailNotifications'] ?? true,
                    onChanged: (value) {
                      // This logic can stay here or be moved to a dedicated settings page
                    },
                  ),
                  // ... other preference items
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Events Section
            const Text('My Events', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),

            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.event, color: Colors.blue),
                    title: const Text('Registered Events'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showSnackBar('Events feature coming soon!'),
                  ),
                  // ... other event items
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Logout Section
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                onTap: () => _showLogoutDialog(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              widget.onLogout();
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}