import 'package:flutter/material.dart';

class FaqsScreen extends StatelessWidget {
  const FaqsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildFaqItem(
              'How do I create a shopping list?',
              'To create a shopping list, navigate to the main screen, tap on the "Add List" button, and enter the items you wish to include.',
            ),
            const Divider(),
            _buildFaqItem(
              'Can I compare product prices between stores?',
              'Yes, use the search function to find products and view their prices across different stores to compare and choose the best deal.',
            ),
            const Divider(),
            _buildFaqItem(
              'Is my data secure?',
              'Absolutely. We prioritize user privacy and ensure your data is protected using industry-standard encryption.',
            ),
            const Divider(),
            _buildFaqItem(
              'How can I change the app language?',
              'Navigate to Settings, tap on "Language," and select your preferred language from the list.',
            ),
            const Divider(),
            _buildFaqItem(
              'How do I contact support?',
              'Go to the "Support" section in Settings and select the preferred method (Email, Call, or FAQs).',
            ),
            const Divider(),
            const SizedBox(height: 20.0),
            const Center(
              child: Text(
                'For more questions, visit our website or contact support.',
                style: TextStyle(fontSize: 14.0, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            answer,
            style: const TextStyle(fontSize: 14.0, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
