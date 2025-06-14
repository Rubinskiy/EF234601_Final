import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'edit_profile_page.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  File? _pickedImage;
  bool _isUploadingImage = false;

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

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _pickedImage = File(picked.path));
      await _uploadProfileImage();
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_pickedImage == null) return;
    setState(() => _isUploadingImage = true);
    try {
      final url = await _uploadImageToCloudinary(_pickedImage!);
      if (url != null) {
        final user = _auth.currentUser;
        if (user != null) {
          await _firestore.collection('users').doc(user.uid).update({'pfp_url': url});
          setState(() => _userProfile['pfp_url'] = url);
        }
      } else {
        _showSnackBar('Failed to upload image.');
      }
    } catch (e) {
      _showSnackBar('Image upload error: $e');
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    const cloudName = 'dqfyez52e';
    const uploadPreset = 'flutter_unsigned';
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      final data = json.decode(respStr);
      return data['secure_url'];
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          if (_isLoading || _isUploadingImage) // Show indicator for general loading or image upload
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white,),
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
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.orange,
                      backgroundImage: _userProfile['pfp_url'] != null && _userProfile['pfp_url'].toString().isNotEmpty
                          ? NetworkImage(_userProfile['pfp_url'])
                          : null,
                      child: _userProfile['pfp_url'] == null || _userProfile['pfp_url'].toString().isEmpty
                          ? const Icon(Icons.person, size: 64, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingImage ? null : _pickProfileImage,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: _isUploadingImage
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _getDisplayValue('name', user?.displayName ?? 'Anonymous'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDisplayValue('email', user?.email ?? 'No email'),
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
                if (_userProfile['createdAt'] != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Joined: ' + (_userProfile['createdAt'] is String
                          ? _userProfile['createdAt']
                          : (_userProfile['createdAt']?.toDate().toString().split(' ')[0] ?? '')),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                      _firestore.collection('users').doc(user?.uid).update({'emailNotifications': value});
                      setState(() => _userProfile['emailNotifications'] = value);
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

            const SizedBox(height: 8),

            // Logout Section
            Card(
              color: Colors.red.shade50,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Sign Out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                onTap: () => _showLogoutDialog(),
              ),
            ),

            const SizedBox(height: 8),

            // request to delete account
            Card(
              child: ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Account', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
                // *** CHANGED THIS LINE ***
                onTap: _showDeleteAccountDialog,
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


  // Shows the confirmation dialog before deleting the account.
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              _deleteAccount(); // Proceed with deletion
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }


  // Handles the logic for deleting the user account and data.
  Future<void> _deleteAccount() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _showSnackBar('No user is logged in.');
        return;
      }

      final userId = user.uid;





      // 1. Delete user document from Firestore
      await _firestore.collection('users').doc(userId).delete();
      print("User document deleted from Firestore.");

      // 2. Delete the user from Firebase Authentication
      // This is the final step and will sign the user out permanently.
      await user.delete();
      print("User deleted from Firebase Authentication.");

      // The onLogout callback will handle navigation back to the login screen
      if(mounted) widget.onLogout();

    } catch (e) {
      print("Error deleting account: $e");
      // This error often happens if the user hasn't signed in recently.
      _showSnackBar('Error deleting account. Please sign out and sign back in before trying again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}