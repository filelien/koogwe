import 'dart:convert';
import 'package:dio/dio.dart';

// Environment-configured OpenAI proxy settings
const apiKey = String.fromEnvironment('OPENAI_PROXY_API_KEY');
const endpoint = String.fromEnvironment('OPENAI_PROXY_ENDPOINT');

class KoogweChatService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: endpoint,
    headers: {
      'Authorization': 'Bearer $apiKey',
      'Content-Type': 'application/json',
    },
    responseType: ResponseType.json,
    validateStatus: (s) => s != null && s >= 200 && s < 500,
  ));

  Future<String> chat(String message, {String country = 'GF', String language = 'fr', String role = 'passenger'}) async {
    if (endpoint.isEmpty || apiKey.isEmpty) {
      return 'Chat indisponible: configurez OPENAI_PROXY_ENDPOINT et OPENAI_PROXY_API_KEY.';
    }

    try {
      final payload = {
        'model': 'gpt-4o',
        'messages': [
          {
            'role': 'system',
            'content': 'Tu es le chatbot KOOGWE. Réponds brièvement, utilement, en $language. Contexte: pays=$country, role=$role.'
          },
          {'role': 'user', 'content': message}
        ],
      };
      final res = await _dio.post('', data: jsonEncode(payload));
      if (res.statusCode == 200) {
        final content = res.data['choices']?[0]?['message']?['content'];
        if (content is String && content.isNotEmpty) return content;
        return 'Réponse vide.';
      }
      return 'Erreur API (${res.statusCode}): ${res.data}';
    } catch (e) {
      return 'Erreur réseau: $e';
    }
  }
}
