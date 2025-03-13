import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late String username = 'Loading...';
  late String email = 'Loading...';
  String? profilePictureBase64;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Account')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? 'Unknown User';
          email = userDoc['email'] ?? 'Unknown Email';
          profilePictureBase64 = userDoc['picture']; 
        });
      }
    } catch (e) {
      setState(() {
        username = 'Error';
        email = 'Error';
      });
    }
  }

  ImageProvider<Object>? _getProfileImage() {
    if (profilePictureBase64 == null || profilePictureBase64!.isEmpty) {
      return null; 
    }
    try {
      final bytes = base64Decode(profilePictureBase64!);
      return MemoryImage(bytes);
    } catch (e) {
      return null; 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(0),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              backgroundImage: _getProfileImage(), 
              child: profilePictureBase64 == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null, 
            ),
            title: Text(username), 
            subtitle: Text(email),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: {
                  'username': username,
                  'email': email,
                  'userId': widget.userId,
                  'picture': profilePictureBase64,
                },
              );
            },
          ),
          const SizedBox(height: 20),
          const Divider(),


          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text("NOTIFICATIONS", style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            title: const Text("Send Push-notification"),
            trailing: Switch(
              value: false,
              onChanged: (value) {
              },
            ),
          ),
          const Divider(),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text("SUPPORT", style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            title: const Text("Privacy policy"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(
                  context, '/privacy_policy');
            },
          ),
          ListTile(
            title: const Text("Contact support"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(
                  context, '/contact_support'); 
            },
          ),
          ListTile(
            title: const Text("FAQs"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/faqs'); 
            },
          ),
          ListTile(
            title: const Text("Send feedback"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(
                  context, '/send_feedback'); 
            },
          ),
          const Divider(),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0),
            child: Text("GENERAL", style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            title: const Text("Language"),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("English (US)", style: TextStyle(color: Colors.grey)),
                Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                  context, '/language'); 
            },
          ),
          const Divider(),

          // Botón de Logout
          ListTile(
            title: const Text("Logout"),
            leading: const Icon(Icons.logout, color: Colors.red),
            onTap: () {
              Navigator.pushReplacementNamed(
                  context, '/login'); 
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1, 
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: "Lists",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/listScreen');
          } else if (index == 1) {
          }
        },
      ),
    );
  }
}
