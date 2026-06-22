import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../config/app_theme.dart';
import '../../controllers/assistant_controller.dart';

class AssistantChatScreen extends StatefulWidget {
  const AssistantChatScreen({super.key});

  @override
  State<AssistantChatScreen> createState() => _AssistantChatScreenState();
}

class _AssistantChatScreenState extends State<AssistantChatScreen> {
  final AssistantController controller = Get.find<AssistantController>();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  final List<String> _suggestions = const [
    'ما هو مشروع الطالب أحمد؟',
    'هل توجد مشاريع بعناوين مشابهة لنظام إدارة المكتبة؟',
    'كم عدد المشاريع قيد التنفيذ؟',
    'اعرض إحصائيات النظام',
  ];

  void _send([String? preset]) {
    final text = preset ?? _input.text;
    if (text.trim().isEmpty) return;
    controller.send(text);
    _input.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 120,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppTheme.lightColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
            onPressed: () => Get.back(),
          ),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.smart_toy_outlined,
                    color: AppTheme.primaryColor, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'المساعد الذكي',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppTheme.greyColor),
              tooltip: 'مسح المحادثة',
              onPressed: controller.clear,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.messages.isEmpty) {
                  return _buildEmptyState();
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.messages.length +
                      (controller.isSending.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildBubble(controller.messages[index]);
                  },
                );
              }),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.smart_toy_outlined,
                size: 42, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 16),
          const Text(
            'اسأل المساعد عن الطلاب والمشاريع والفرق',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.onSurface),
          ),
          const SizedBox(height: 8),
          const Text(
            'يمكن للمساعد البحث في بيانات النظام والإجابة على استفساراتك',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppTheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _suggestions
                .map((s) => GestureDetector(
                      onTap: () => _send(s),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border:
                              Border.all(color: AppTheme.outlineVariant),
                        ),
                        child: Text(
                          s,
                          style: TextStyle(
                              fontSize: 12.5, color: AppTheme.primaryColor),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage message) {
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 4 : 16),
            bottomRight: Radius.circular(isUser ? 16 : 4),
          ),
          border: isUser
              ? null
              : Border.all(color: AppTheme.outlineVariant),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            fontSize: 14,
            height: 1.6,
            color: isUser ? AppTheme.onPrimary : AppTheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: AppTheme.primaryColor.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'اكتب سؤالك...',
                  hintStyle: TextStyle(color: AppTheme.greyColor),
                  filled: true,
                  fillColor: AppTheme.lightColor,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Obx(() => GestureDetector(
                  onTap: controller.isSending.value ? null : () => _send(),
                  child: Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: controller.isSending.value
                          ? AppTheme.greyColor
                          : AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
