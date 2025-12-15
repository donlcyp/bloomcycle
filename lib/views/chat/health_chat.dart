import 'package:flutter/material.dart';

/// Simple, local-only health tips chatbot UI.
/// NOTE: This is educational only and not medical advice.
class HealthChatPage extends StatefulWidget {
  const HealthChatPage({super.key});

  @override
  State<HealthChatPage> createState() => _HealthChatPageState();
}

class _HealthChatPageState extends State<HealthChatPage> {
  late final List<_ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _messages = [
      _ChatMessage(
        sender: ChatSender.bot,
        text:
            'Hi, I\'m Bloom, your cycle education assistant. I can share general health tips about the menstrual cycle and self-care. I cannot diagnose or replace a doctor. How can I help you today?',
        timestamp: DateTime.now(),
      ),
    ];
  }

  final TextEditingController _controller = TextEditingController();
  bool _sending = false;
  final ScrollController _scrollController = ScrollController();
  bool _showSuggestions = true;

  static const List<String> _suggestedPrompts = <String>[
    'What is a normal menstrual cycle length?',
    'How can I ease period cramps?',
    'What is PMS and how can I manage it?',
    'What are signs of ovulation?',
    'How can I improve my period symptoms?',
    'What should I track in my cycle?',
    'Is irregular bleeding normal?',
    'How does exercise affect my cycle?',
    'What foods help with period symptoms?',
    'When should I see a doctor?',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatMessage(sender: ChatSender.user, text: text));
      _controller.clear();
      _sending = true;
      _showSuggestions = false;
    });

    _scrollToBottom();

    // Simulated safe response. Later you can replace this with a real API call.
    final reply = _generateSafeReply(text);

    await Future<void>.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(sender: ChatSender.bot, text: reply));
      _sending = false;
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
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
    const backgroundColor = Color(0xFFF5E6E8);
    const botBubbleColor = Colors.white;
    const userBubbleColor = Color(0xFFD946A6);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD946A6),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE7F3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_florist,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Bloom',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    'Cycle education assistant (not medical advice)',
                    style: TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Tooltip(
            message: 'Clear conversation',
            child: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _clearConversation,
            ),
          ),
          Tooltip(
            message: 'Emergency: Call 911 or local emergency services',
            child: IconButton(
              icon: const Icon(Icons.emergency),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Emergency Resources'),
                    content: const Text(
                      'If you are experiencing a medical emergency:\n\n'
                      '• Call 911 (or your local emergency number)\n'
                      '• Go to the nearest emergency room\n'
                      '• Contact your healthcare provider immediately\n\n'
                      'For mental health crises:\n'
                      '• National Suicide Prevention Lifeline: 988\n'
                      '• Crisis Text Line: Text HOME to 741741',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_sending && index == _messages.length) {
                  // Typing indicator from Bloom
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: _buildTypingIndicator(context),
                  );
                }

                final msg = _messages[index];
                final isUser = msg.sender == ChatSender.user;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: isUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          if (!isUser) ...[
                            _buildAvatar(isUser: false),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isUser
                                    ? userBubbleColor
                                    : botBubbleColor,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 18),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                msg.text,
                                style: TextStyle(
                                  color: isUser ? Colors.white : Colors.black87,
                                  fontSize: 14,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                          if (isUser) ...[
                            const SizedBox(width: 8),
                            _buildAvatar(isUser: true),
                          ],
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: 4,
                          left: isUser ? 0 : 36,
                          right: isUser ? 36 : 0,
                        ),
                        child: Text(
                          _formatTime(msg.timestamp),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_showSuggestions) _buildSuggestionsBar(context),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
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
                        borderRadius: BorderRadius.all(Radius.circular(24)),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: _sending
                        ? Colors.grey.shade300
                        : const Color(0xFFD946A6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: _sending ? null : _handleSend,
                    icon: Icon(
                      Icons.send,
                      color: _sending ? Colors.grey : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isUser}) {
    if (isUser) {
      return Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFE0F2FE),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: Color(0xFF3B82F6), size: 18),
      );
    }

    return Container(
      width: 28,
      height: 28,
      decoration: const BoxDecoration(
        color: Color(0xFFFCE7F3),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.local_florist,
        color: Color(0xFFD946A6),
        size: 18,
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildAvatar(isUser: false),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(4),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDot(),
              const SizedBox(width: 4),
              _buildDot(delay: 120),
              const SizedBox(width: 4),
              _buildDot(delay: 240),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDot({int delay = 0}) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade500,
        shape: BoxShape.circle,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String timeStr =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

    if (messageDate == today) {
      return 'Today $timeStr';
    } else if (messageDate == yesterday) {
      return 'Yesterday $timeStr';
    } else {
      return '${dateTime.day}/${dateTime.month} $timeStr';
    }
  }

  void _clearConversation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Conversation?'),
        content: const Text(
          'Are you sure you want to clear all messages? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _messages.clear();
                _messages.add(
                  _ChatMessage(
                    sender: ChatSender.bot,
                    text:
                        'Hi, I\'m Bloom, your cycle education assistant. I can share general health tips about the menstrual cycle and self-care. I cannot diagnose or replace a doctor. How can I help you today?',
                    timestamp: DateTime.now(),
                  ),
                );
                _showSuggestions = true;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: const Color(0xFFFDECF4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _suggestedPrompts.map((prompt) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ActionChip(
                backgroundColor: Colors.white,
                label: Text(prompt, style: const TextStyle(fontSize: 12)),
                onPressed: _sending
                    ? null
                    : () {
                        _controller.text = prompt;
                        _handleSend();
                      },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

enum ChatSender { user, bot }

class _ChatMessage {
  _ChatMessage({required this.sender, required this.text, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  final ChatSender sender;
  final String text;
  final DateTime timestamp;
}
