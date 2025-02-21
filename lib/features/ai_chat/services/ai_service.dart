import 'package:google_generative_ai/google_generative_ai.dart';

class AIService {
  late final GenerativeModel model;
  late final ChatSession chat;

  AIService() {
    model = GenerativeModel(
        model: 'gemini-pro', apiKey: 'AIzaSyAqG37M3o2J9vKPtmgMlMvuuYJMu5dV8sY');
    chat = model.startChat(history: [
      Content.text(
          'Ты - эксперт по игре Counter-Strike 2.Отвечай кратко и лаконично, не используя лишних слов. Пиши конкретные действия шаг за шагом, например смок кт. Если пишет несвязные вещи, скажи что не понял вопрос.')
    ]);
  }

  Future<String> getChatResponse(String prompt) async {
    try {
      final response = await chat.sendMessage(Content.text(prompt));
      return response.text ?? 'Извините, не удалось получить ответ';
    } catch (e) {
      return 'Ошибка: $e';
    }
  }
}
