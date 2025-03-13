import 'package:flutter/material.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Language Settings'),
        backgroundColor: const Color.fromARGB(255, 226, 226, 226),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Your Language',
              style: TextStyle(
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Select your preferred language for a personalized experience.',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView(
                children: [
                  _buildLanguageOption(
                      'English (US)', 'en', 'selectedLanguage', context),
                  _buildLanguageOption(
                      'Español (ES)', 'es', 'selectedLanguage', context),
                  _buildLanguageOption(
                      'Français (FR)', 'fr', 'selectedLanguage', context),
                  _buildLanguageOption(
                      'Deutsch (DE)', 'de', 'selectedLanguage', context),
                  _buildLanguageOption(
                      'Italiano (IT)', 'it', 'selectedLanguage', context),
                  _buildLanguageOption(
                      'Português (PT)', 'pt', 'selectedLanguage', context),
                  _buildLanguageOption(
                      '中文 (ZH)', 'zh', 'selectedLanguage', context),
                  _buildLanguageOption(
                      '日本語 (JA)', 'ja', 'selectedLanguage', context),
                  _buildLanguageOption(
                      '한국어 (KO)', 'ko', 'selectedLanguage', context),
                  _buildLanguageOption(
                      'Русский (RU)', 'ru', 'selectedLanguage', context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String language, String code,
      String selectedLanguage, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListTile(
        title: Text(language, style: const TextStyle(fontSize: 18.0)),
        trailing: Radio(
          value: code,
          groupValue: selectedLanguage,
          onChanged: (value) {
            // Lógica para cambiar el idioma
          },
        ),
      ),
    );
  }
}
