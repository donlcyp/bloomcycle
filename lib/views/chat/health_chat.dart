import 'package:flutter/material.dart';

/// Simple, local-only health tips chatbot UI.
/// NOTE: This is educational only and not medical advice.
class HealthChatPage extends StatefulWidget {
  const HealthChatPage({super.key});

  @override
  State<HealthChatPage> createState() => _HealthChatPageState();
}

class _HealthChatPageState extends State<HealthChatPage> {
  final List<_ChatMessage> _messages = <_ChatMessage>[
    const _ChatMessage(
      sender: ChatSender.bot,
      text:
          'Hi, I\'m Bloom, your cycle education assistant. I can share general health tips about the menstrual cycle and self-care. I cannot diagnose or replace a doctor. How can I help you today?',
    ),
  ];

  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatMessage(sender: ChatSender.user, text: text));
      _controller.clear();
      _sending = true;
    });

    // Simulated safe response. Later you can replace this with a real API call.
    final reply = _generateSafeReply(text);

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(sender: ChatSender.bot, text: reply));
      _sending = false;
    });
  }

  String _generateSafeReply(String userText) {
    final lower = userText.toLowerCase();

    // Very simple pattern-based responses; always non-diagnostic and cautious.
    if (lower.contains('pms') || lower.contains('mood')) {
      return 'Many people notice mood changes before their period. Gentle movement, regular meals, sleep, and stress reduction can help. If mood symptoms are severe or affect your daily life, it\'s important to talk to a healthcare professional.';
    }

    if (lower.contains('cramp') || lower.contains('pain')) {
      return 'Mild to moderate cramps are common during periods. Heat packs, light stretching, and over-the-counter pain relief (if safe for you) may help. If pain is very strong, getting worse, or stops you from doing normal activities, please see a doctor or gynecologist for a proper evaluation.';
    }

    if (lower.contains('heavy') || lower.contains('bleeding')) {
      return 'If you are soaking through a pad or tampon every 1–2 hours, passing large clots, or feeling dizzy or unwell, you should seek medical care urgently. I can only give general information, not medical diagnosis.';
    }

    if (lower.contains('pregnan')) {
      return 'Questions about pregnancy are important, but I cannot tell you if you are pregnant. A home pregnancy test and consultation with a healthcare professional are the safest ways to check. If your period is late and you\'re unsure, please talk to a doctor or clinic.';
    }

    if (lower.contains('fertile') || lower.contains('ovulation')) {
      return 'In a typical 28‑day cycle, ovulation often happens around day 14, and the fertile window spans a few days before and shortly after ovulation. Every body is different, so cycle tracking over time and professional advice give the most accurate guidance.';
    }

    // Default educational response
    return 'I can share general tips about the menstrual cycle, symptoms, and self-care, but I cannot diagnose or provide personalized medical treatment. If you have severe, new, or worrying symptoms, please contact a healthcare professional.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD946A6),
        foregroundColor: Colors.white,
        title: const Text('Health Tips Chat'),
      ),
      backgroundColor: const Color(0xFFF5E6E8),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == ChatSender.user;
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFFD946A6) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: isUser ? Colors.white : Colors.black87,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Ask a general health or cycle question...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sending ? null : _handleSend,
                  icon: Icon(
                    Icons.send,
                    color: _sending ? Colors.grey : const Color(0xFFD946A6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ChatSender { user, bot }

class _ChatMessage {
  final ChatSender sender;
  final String text;

  const _ChatMessage({required this.sender, required this.text});
}
