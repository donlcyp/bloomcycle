import 'dart:convert';

import 'package:http/http.dart' as http;

class HealthChatService {
  HealthChatService(this.apiKey);

  final String apiKey;

  static const _endpoint = 'https://api.openai.com/v1/chat/completions';
  static const _model = 'gpt-3.5-turbo';

  Future<String> getHealthReply(String userMessage) async {
    const systemPrompt = '''
You are a health education assistant for a menstrual cycle tracking app.
You ONLY provide general, high-level information about menstrual and reproductive health, lifestyle, and self-care.
You MUST NOT:
- diagnose any condition
- prescribe medications, dosages, or treatments
- guarantee that any symptom is harmless

You MUST:
- encourage users to see a licensed healthcare professional for serious, persistent, or worrying symptoms
- treat anything that sounds like an emergency (severe pain, very heavy bleeding, fainting, chest pain, difficulty breathing, suicidal thoughts) as urgent and instruct the user to seek emergency care or contact local emergency services.

Be concise, kind, and clear. Avoid medical jargon when possible.
''';

    final body = {
      'model': _model,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userMessage},
      ],
      'temperature': 0.4,
      'max_tokens': 350,
    };

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      return 'Im having trouble answering right now. For urgent or serious concerns, please contact a healthcare professional.';
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final choices = data['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      return 'I couldnt generate a response. If youre worried about your health, please talk to a healthcare professional.';
    }

    final content = choices[0]['message']['content']?.toString().trim() ?? '';

    return '$content\n\nRemember: I provide general information only and do not replace a healthcare professional.';
  }
}
