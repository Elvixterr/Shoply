import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'At Shoply, we value your privacy. Here’s a quick overview of how we handle your data:',
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              'What We Collect',
              Icons.storage,
              [
                'User profile data (e.g., name, email)',
                'Shopping lists and product details',
                'Search and price comparison history',
              ],
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              'How We Use It',
              Icons.insights,
              [
                'To help you manage and organize your shopping lists',
                'To show price comparisons across stores',
                'To suggest cost-saving options',
              ],
            ),
            const SizedBox(height: 20.0),
            _buildSection(
              'Your Choices',
              Icons.lock,
              [
                'Manage data preferences in Settings',
                'Opt-out of non-essential data collection',
              ],
            ),
            const SizedBox(height: 20.0),
            const Divider(),
            const Text(
              'For more information, visit our website or contact support@shoply.com.',
              style: TextStyle(fontSize: 14.0, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<String> points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.blueAccent),
            const SizedBox(width: 8.0),
            Text(
              title,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        ...points.map(
          (point) => Padding(
            padding: const EdgeInsets.only(left: 24.0, bottom: 6.0),
            child: Row(
              children: [
                const Icon(Icons.check, color: Colors.green, size: 16.0),
                const SizedBox(width: 8.0),
                Expanded(
                    child: Text(point, style: const TextStyle(fontSize: 14.0))),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
