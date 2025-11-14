import 'package:flutter/material.dart';
import '../../services/locale_controller.dart';
import '../../i18n/strings.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String _selectedCode = 'pt';

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
    // Sync com locale atual
    _selectedCode = LocaleController.current.value.languageCode;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).t('lang.title')),
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
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.public, color: Color(0xFF6A1B9A), size: 24),
                    const SizedBox(width: 12),
                    Text(
                      S.of(context).t('lang.select'),
                      style: const TextStyle(
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
                      trailing: _selectedCode == language['code']
                          ? const Icon(Icons.check_circle, color: Color(0xFF6A1B9A))
                          : null,
                      onTap: () {
                        LocaleController.setLocaleCode(language['code']!);
                        setState(() => _selectedCode = language['code']!);
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
          title: Text(S.of(context).t('dialog.language_changed')),
          content: Text(S.of(context).t('dialog.language_changed_to').replaceFirst('{lang}', language)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(S.of(context).t('dialog.ok')),
            ),
          ],
        );
      },
    );
  }
}