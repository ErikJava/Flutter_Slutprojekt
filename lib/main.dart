import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Translation App',
      home: TranslationScreen(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final TextEditingController textEditingController = TextEditingController();
  String translatedText = '';
  final String apiKey = '519a068c-cd27-ab7c-c840-44b11ad9ab25:fx';

  Future<void> translateText() async {
    final String textToTranslate = textEditingController.text;
    const String targetLanguage = 'SV'; // Swedish
    const String sourceLanguage = 'EN'; // English

    const String url =
        'https://api-free.deepl.com/v2/translate'; // Updated endpoint URL
    final Map<String, String> headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final Map<String, dynamic> body = {
      'text': textToTranslate,
      'source_lang': sourceLanguage,
      'target_lang': targetLanguage,
      'auth_key': apiKey,
    };

    final response =
        await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      try {
        // Add this line to print the API response
        print('API Response: ${response.body}');

        final Map<String, dynamic> data = json.decode(response.body);

        // Check if the 'translations' key is present in the JSON response
        if (data.containsKey('translations') &&
            data['translations'].isNotEmpty) {
          setState(() {
            translatedText = data['translations'][0]['text'];
          });
        } else {
          setState(() {
            translatedText = 'Error: No translation data found';
          });
        }
      } catch (e) {
        print('Error decoding JSON: $e');
        setState(() {
          translatedText = 'Error: Unable to translate text';
        });
      }
    } else {
      final Map<String, dynamic> errorData = json.decode(response.body);
      print('DeepL API Error: ${errorData['message']}');
      setState(() {
        translatedText = 'Error: Unable to translate text';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: textEditingController,
                decoration: const InputDecoration(
                  hintText: 'Enter text to translate',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: translateText,
              child: const Text('Translate'),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Translated Text:',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Text(
              translatedText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
