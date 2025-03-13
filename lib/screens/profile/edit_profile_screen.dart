import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String email;
  final String userId;

  const EditProfileScreen({
    super.key,
    required this.username,
    required this.email,
    required this.userId,
  });

  get picture => null;

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String username;
  late String email;
  late String password;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    username = widget.username;
    email = widget.email;
    password = '';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final userRef = FirebaseFirestore.instance.collection('Account').doc(widget.userId);
      final updates = {
        'username': username,
        'email': email,
      };

      if (_selectedImage != null) {
        final base64Image = await _convertImageToBase64(_selectedImage!);
        updates['picture'] = base64Image;
      }

      if (password.isNotEmpty) {
        updates['password'] = password;
      }

      await userRef.update(updates);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error updating profile. Please try again.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Edit Profile"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: _saveProfile,
          child: const Text(
            "Save",
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 16),
          ),
        ),
      ],
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      height: MediaQuery.of(context).size.height, // Altura completa de la pantalla
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : _getProfileImage(widget.picture),
                    backgroundColor: Colors.grey.shade300,
                    child: _selectedImage == null
                        ? const Icon(Icons.camera_alt, size: 40, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text(
                    "Change Photo",
                    style: TextStyle(color: Color.fromARGB(255, 109, 11, 189)),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: username,
                          decoration: InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Username cannot be empty'
                              : null,
                          onChanged: (value) => username = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          initialValue: email,
                          decoration: InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => value == null || !value.contains('@')
                              ? 'Enter a valid email'
                              : null,
                          onChanged: (value) => email = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "New Password (optional)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          obscureText: true,
                          onChanged: (value) => password = value,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}


  Future<String> _convertImageToBase64(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  ImageProvider<Object>? _getProfileImage(String? base64Image) {
    try {
      final bytes = base64Decode(base64Image!);
      return MemoryImage(bytes);
    } catch (e) {
      return null;
    }
  }
}
