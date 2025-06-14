import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'services/cloudinary_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = true;
  Map<String, dynamic> _userProfile = {};
  File? _pickedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          _userProfile = doc.data()!;
          _nameController.text = _userProfile['name'] ?? '';
          _bioController.text = _userProfile['bio'] ?? '';
        }
      }
    } catch (e) {
      _showSnackBar('Failed to load profile: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final updates = {
          'name': _nameController.text.trim(),
          'bio': _bioController.text.trim(),
        };
        // Use set with merge:true to update or create fields
        await _firestore.collection('users').doc(user.uid).set(updates, SetOptions(merge: true));
        _showSnackBar('Profile updated successfully!');
        if (mounted) {
          // Pop the page and return `true` to signal an update occurred
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      _showSnackBar('Failed to update profile: $e');
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
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
    return await CloudinaryService.uploadImageToCloudinary(imageFile);
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _updateProfile,
              tooltip: 'Save Changes',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.orange,
                  backgroundImage: _userProfile['pfp_url'] != null && _userProfile['pfp_url'].isNotEmpty
                      ? NetworkImage(_userProfile['pfp_url'])
                      : null,
                  child: _userProfile['pfp_url'] == null || _userProfile['pfp_url'].isEmpty
                      ? const Icon(Icons.person, size: 72, color: Colors.white)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _isUploadingImage ? null : _pickProfileImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: _isUploadingImage
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Bio',
              hintText: 'Tell us a little about yourself...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.info_outline),
            ),
            maxLines: 4,
          ),
        ],
      ),
    );
  }
}