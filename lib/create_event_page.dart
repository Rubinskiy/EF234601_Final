import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'services/firestore_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'models/event_model.dart';
import 'services/cloudinary_service.dart';

class CreateEventPage extends StatefulWidget {
  final EventModel? event; // <-- Tambah ini

  const CreateEventPage({super.key, this.event});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _locationController = TextEditingController();
  final _organizerController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  File? _imageFile;
  bool _agreed = false;
  bool _isLoading = false;
  String? _error;
  bool _isUploadingImage = false;
  String _imageUrl = '';

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _nameController.text = widget.event!.name;
      _descController.text = widget.event!.description;
      _locationController.text = widget.event!.location;
      _organizerController.text = widget.event!.organizers;
      _selectedDate = DateTime.tryParse(widget.event!.date);
      _selectedTime = _parseTime(widget.event!.time);
      _imageUrl = widget.event!.imageUrl;
    }
  }

  TimeOfDay? _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) return null;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }


  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<String?> _uploadImageToCloudinary(File imageFile) async {
    return await CloudinaryService.uploadImageToCloudinary(imageFile);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || !_agreed || _selectedDate == null || _selectedTime == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) throw Exception('Not logged in');

      String imageUrl = _imageUrl;

// Upload image jika user memilih gambar baru
      if (_imageFile != null) {
        setState(() => _isUploadingImage = true);
        final uploadedUrl = await _uploadImageToCloudinary(_imageFile!);
        setState(() => _isUploadingImage = false);
        if (uploadedUrl != null) {
          imageUrl = uploadedUrl;
        } else {
          setState(() => _error = 'Failed to upload image.');
          imageUrl = _imageUrl; // fallback ke gambar lama kalau gagal upload
        }
      }


      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'date': _selectedDate!.toIso8601String().split('T')[0],
        'time': '${_selectedTime!.hour}:${_selectedTime!.minute}',
        'imageUrl': imageUrl.isNotEmpty ? imageUrl : "https://www.fristads.com/images/broken.jpg",
        'location': _locationController.text.trim(),
        'organizers': _organizerController.text.trim(),
        'createdBy': userId,
        'createdAt': DateTime.now().toIso8601String(),
      };

      if (widget.event == null) {
        // Create
        await FirestoreService().addEvent(data);
      } else {
        // Update
        await FirestoreService().updateEvent(widget.event!.id, data);
      }

      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.event == null ? 'Create Event' : 'Edit Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Date'),
                        child: Text(_selectedDate == null ? 'Select date' : _selectedDate!.toLocal().toString().split(' ')[0]),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      child: InputDecorator(
                        decoration: const InputDecoration(labelText: 'Time'),
                        child: Text(_selectedTime == null ? 'Select time' : _selectedTime!.format(context)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _organizerController,
                decoration: const InputDecoration(labelText: 'Main Organizer'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _imageFile != null
                      ? Image.file(_imageFile!, width: 80, height: 80, fit: BoxFit.cover)
                      : imageUrlPreview(),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _isUploadingImage ? null : _pickImage,
                    icon: const Icon(Icons.upload),
                    label: _isUploadingImage ? const Text('Uploading...') : const Text('Pick Image'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                title: const Text('I confirm the event details are correct.'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || !_agreed ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(widget.event == null ? 'Create Event' : 'Update Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget imageUrlPreview() {
    if (_imageUrl.isNotEmpty) {
      return Image.network(_imageUrl, width: 80, height: 80, fit: BoxFit.cover);
    }
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(Icons.image, size: 32, color: Colors.grey),
    );
  }
}
