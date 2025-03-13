import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';

class ProfileScreen extends StatelessWidget {
  final String username;
  final String email;
  final String userId;

  const ProfileScreen({
    super.key,
    required this.username,
    required this.email,
    required this.userId,
  });

  Future<String?> _fetchProfileImage(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('Account').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        return doc['picture']; // Retornar la imagen en formato Base64
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  ImageProvider<Object>? _getProfileImage(String? base64Image) {
    try {
      final bytes = base64Decode(base64Image!);
      return MemoryImage(bytes); // Decodificar Base64 y mostrar la imagen
    // ignore: empty_catches
    } catch (e) {
          return null;
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text("Profile"),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pushNamed(
              context,
              '/editProfile',
              arguments: {
                'username': username,
                'email': email,
                'userId': userId,
              },
            );
          },
          child: const Text(
            "Edit",
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ],
    ),
    body: FutureBuilder<String?>(
      future: _fetchProfileImage(userId),
      builder: (context, snapshot) {
        final profileImage = snapshot.data;

        return Center( // Centrar todo el contenido en la pantalla
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Ajustar la altura de la columna
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: _getProfileImage(profileImage),
                  backgroundColor: Colors.grey,
                  child: profileImage == null
                      ? const Icon(Icons.person, size: 80, color: Colors.white)
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  username,
                  style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(color: Colors.grey, fontSize: 25),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    ),
  );
}
}
