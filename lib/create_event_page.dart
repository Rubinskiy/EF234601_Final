import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'services/firestore_service.dart';

class CreateEventPage extends StatefulWidget {
  const CreateEventPage({super.key});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

// page form to create an event
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), //idk
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
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
      String imageUrl = '';
      // TODO: Upload image to storage and get URL if needed
      // will do soon, gonna use tebi.io
      final data = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'date': _selectedDate!.toIso8601String().split('T')[0],
        'time': _selectedTime!.format(context),
        // ion know man im just taking a random image
        'imageUrl': imageUrl.isNotEmpty ? imageUrl : "https://www.fristads.com/images/broken.jpg?fileId=00754ec2-7679-450d-a81b-81c2c96bdea4&croppingId=ec921afa-9940-4fa3-a7a6-268fd649e17c",
        'location': _locationController.text.trim(),
        'organizers': _organizerController.text.trim(),
        'createdBy': userId,
      };
      await FirestoreService().addEvent(data);
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Event')),
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
                decoration: const InputDecoration(labelText: 'Organizers'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _imageFile != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(_imageFile!, width: 80, height: 80, fit: BoxFit.cover),
                        )
                      : Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.image, size: 32, color: Colors.grey),
                        ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload),
                    label: const Text('Pick Image'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: _agreed,
                onChanged: (v) => setState(() => _agreed = v ?? false),
                title: const Text('I confirm the event details are correct'),
                controlAffinity: ListTileControlAffinity.leading,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading || !_agreed ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Create Event'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 