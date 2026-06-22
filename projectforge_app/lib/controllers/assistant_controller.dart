import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../services/api_service.dart';
import '../config/api_config.dart';

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  ChatMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class AssistantController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isSending = false.obs;

  Future<void> send(String text) async {
    final message = text.trim();
    if (message.isEmpty || isSending.value) return;

    // Snapshot prior turns as history before adding the new user message.
    final history = messages
        .map((m) => m.toJson())
        .toList()
        .take(20)
        .toList(growable: false);

    messages.add(ChatMessage(role: 'user', content: message));
    isSending.value = true;

    try {
      final response = await _apiService.post(
        ApiConfig.assistantChat,
        data: {'message': message, 'history': history},
      );

      if (response.data['success'] == true) {
        final reply = response.data['data']?['reply']?.toString() ??
            'لم أتمكن من توليد إجابة.';
        messages.add(ChatMessage(role: 'assistant', content: reply));
      } else {
        _addError(response.data['message']?.toString());
      }
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final serverMsg = e.response?.data is Map
          ? e.response?.data['message']?.toString()
          : null;
      if (status == 503) {
        _addError(serverMsg ?? 'خدمة المساعد غير مهيّأة (لم يُضبط مفتاح Gemini).');
      } else {
        _addError(serverMsg ?? 'تعذّر الاتصال بالمساعد. حاول مرة أخرى.');
      }
    } catch (_) {
      _addError('حدث خطأ غير متوقع.');
    } finally {
      isSending.value = false;
    }
  }

  void _addError(String? message) {
    messages.add(ChatMessage(
      role: 'assistant',
      content: message ?? 'تعذّر إكمال الطلب.',
    ));
  }

  void clear() => messages.clear();
}
