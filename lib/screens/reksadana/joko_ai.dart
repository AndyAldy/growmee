import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../../models/chat_message.dart';
import '../../services/gemini_service.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/message_input_bar.dart';
import '../../widgets/nav_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiService _geminiService = GeminiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  final Uuid _uuid = const Uuid();

  // --- PERUBAHAN 1: Tambahkan FocusNode ---
  final FocusNode _inputFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      text: 'Halo! Saya Joko, asisten AI Anda. Tanyakan apa saja seputar investasi atau reksa dana.',
      isFromUser: false,
    ));

    // --- PERUBAHAN 2: Tambahkan listener ke FocusNode ---
    _inputFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _inputFocusNode.removeListener(_onFocusChange);
    _inputFocusNode.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  void _onFocusChange() {
    if (_inputFocusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), _scrollDown);
    }
  }

  void _scrollDown() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;

    final userMessageText = _textController.text;
    _textController.clear();

    setState(() {
      _isLoading = true;
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        text: userMessageText,
        isFromUser: true,
      ));
      _scrollDown();
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        text: '...',
        isFromUser: false,
        isTyping: true,
      ));
      _scrollDown();
    });

    try {
      final responseText = await _geminiService.sendMessage(userMessageText);
      setState(() {
        _messages.removeWhere((msg) => msg.isTyping);
        _messages.add(ChatMessage(
          id: _uuid.v4(),
          text: responseText,
          isFromUser: false,
        ));
      });
    } catch (e) {
      setState(() {
        _messages.removeWhere((msg) => msg.isTyping);
        _messages.add(ChatMessage(
          id: _uuid.v4(),
          text: 'Maaf, terjadi kesalahan. Coba lagi nanti.',
          isFromUser: false,
          isError: true,
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollDown();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: const Text(
            'AI Investasi',
            style: TextStyle(color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  return MessageBubble(message: message);
                },
              ),
            ),
            MessageInputBar(
              controller: _textController,
              isLoading: _isLoading,
              onSend: _sendMessage,
              // --- PERUBAHAN 6: Kirim FocusNode ke input bar ---
              focusNode: _inputFocusNode,
            ),
          ],
        ),
        bottomNavigationBar: const NavBar(currentIndex: 2),
      ),
    );
  }
}