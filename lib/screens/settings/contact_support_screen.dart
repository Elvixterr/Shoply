import 'package:flutter/material.dart';

class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Support'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Need Help?',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'We’re here to assist you. Choose one of the options below to reach out:',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            _buildContactOption(
              'Email Support',
              Icons.email,
              'support@shoply.com',
              'Send us an email with your questions or issues.',
            ),
            const SizedBox(height: 20.0),
            _buildContactOption(
              'Call Us',
              Icons.phone,
              '+1 (123) 456-7890',
              'Reach us directly for immediate assistance.',
            ),
            const SizedBox(height: 20.0),
            _buildContactOption(
              'FAQ',
              Icons.help_outline,
              'Frequently Asked Questions',
              'Find quick answers to common questions.',
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Our support team is available 24/7 to assist you with any inquiries.',
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(
      String title, IconData icon, String subtitle, String description) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.blueAccent, size: 32.0),
      title: Text(title,
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4.0),
          Text(subtitle,
              style: const TextStyle(fontSize: 14.0, color: Colors.black87)),
          const SizedBox(height: 4.0),
          Text(description,
              style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
        ],
      ),
      onTap: () {
        // Lógica para manejar la acción al tocar la opción.
      },
    );
  }
}
