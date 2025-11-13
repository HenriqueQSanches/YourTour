import 'package:flutter/material.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedLanguage = 'Português (Brasil)';

  final List<Map<String, String>> languages = [
    {'code': 'pt', 'name': 'Português (Brasil)', 'flag': '🇧🇷'},
    {'code': 'en', 'name': 'English (US)', 'flag': '🇺🇸'},
    {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
    {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
    {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
    {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
    {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
    {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
    {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Idioma'),
        backgroundColor: const Color(0xFF6A1B9A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.public, color: Color(0xFF6A1B9A), size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Selecione o idioma do aplicativo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6A1B9A),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: languages.length,
                itemBuilder: (context, index) {
                  final language = languages[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    elevation: 1,
                    child: ListTile(
                      leading: Text(
                        language['flag']!,
                        style: const TextStyle(fontSize: 24),
                      ),
                      title: Text(
                        language['name']!,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: _selectedLanguage == language['name']
                          ? const Icon(Icons.check_circle, color: Color(0xFF6A1B9A))
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedLanguage = language['name']!;
                        });
                        _showLanguageChangedDialog(context, language['name']!);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageChangedDialog(BuildContext context, String language) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Idioma Alterado'),
          content: Text('O idioma foi alterado para $language'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}