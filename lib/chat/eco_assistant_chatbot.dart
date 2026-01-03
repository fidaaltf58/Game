import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

class EcoAssistantChatbot extends StatefulWidget {
  final String? initialServerUrl;
  final Color? primaryColor;
  final String? appTitle;

  const EcoAssistantChatbot({
    Key? key,
    this.initialServerUrl = "http://127.0.0.1:8000",
    this.primaryColor,
    this.appTitle = "🤖 المساعد البيئي",
  }) : super(key: key);

  @override
  State<EcoAssistantChatbot> createState() => _EcoAssistantChatbotState();
}

class _EcoAssistantChatbotState extends State<EcoAssistantChatbot> {
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _serverController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  StreamSubscription<String>? _subscription;
  late String _serverUrl;

  @override
  void initState() {
    super.initState();
    _serverUrl = widget.initialServerUrl ?? "http://127.0.0.1:8000";
    _loadServerUrl();
  }

  /// Charger l'IP depuis SharedPreferences
  Future<void> _loadServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _serverUrl = prefs.getString("server_url") ?? _serverUrl;
      _serverController.text = _serverUrl;
    });
  }

  /// Sauvegarder l'IP dans SharedPreferences
  Future<void> _saveServerUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    // Remove trailing slash if present
    String cleanUrl = url.trim();
    if (cleanUrl.endsWith('/')) {
      cleanUrl = cleanUrl.substring(0, cleanUrl.length - 1);
    }
    await prefs.setString("server_url", cleanUrl);
  }

  /// Helper method to ensure URL doesn't have double slashes
  String _buildUrl(String endpoint) {
    String baseUrl = _serverUrl.trim();
    // Remove trailing slash from base URL
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    // Ensure endpoint starts with /
    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }
    return '$baseUrl$endpoint';
  }

  Future<void> sendMessage() async {
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "content": userMessage});
      _messages.add({"role": "assistant", "content": ""});
      _isLoading = true;
    });

    try {
      final request = http.Request(
        "POST",
        Uri.parse(_buildUrl("/generate")),
      );

      request.headers["Content-Type"] = "application/json";
      request.body = jsonEncode({
        "prompt": userMessage,
        "max_tokens": 2048,
        "stream": true,
      });

      final response = await request.send();

      if (response.statusCode == 200) {
        _subscription = response.stream.transform(utf8.decoder).listen(
              (chunk) {
            setState(() {
              _messages[_messages.length - 1]["content"] =
                  (_messages.last["content"] ?? "") + chunk;
            });
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          },
          onDone: () {
            setState(() {
              _isLoading = false;
            });
          },
          onError: (error) {
            setState(() {
              _messages.last["content"] = "⚠️ خطأ في البث: $error";
              _isLoading = false;
            });
          },
        );
      } else {
        setState(() {
          _messages.last["content"] = "⚠️ خطأ في الاتصال بالخادم ($_serverUrl). رمز الخطأ: ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _messages.last["content"] = "⚠️ فشل الاتصال: $e";
        _isLoading = false;
      });
    }
  }

  void stopResponse() {
    _subscription?.cancel();
    setState(() {
      _isLoading = false;
    });
  }

  void clearMessages() {
    _subscription?.cancel();
    setState(() {
      _messages.clear();
      _isLoading = false;
    });
  }

  void changeServerDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("🔧 تحوير عنوان الخادم ", textAlign: TextAlign.right),
        content: TextField(
          controller: _serverController,
          decoration: const InputDecoration(
            labelText: "عنوان الخادم (http://IP:PORT)",
            hintText: "http://127.0.0.1:8000",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء", textAlign: TextAlign.right),
          ),
          ElevatedButton(
            onPressed: () {
              String newUrl = _serverController.text.trim();
              if (newUrl.endsWith('/')) {
                newUrl = newUrl.substring(0, newUrl.length - 1);
              }
              setState(() {
                _serverUrl = newUrl;
              });
              _saveServerUrl(newUrl);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("✅ تمّ تسجيل عنوان الخادم بنجاح: $_serverUrl", textAlign: TextAlign.right)),
              );
            },
            child: const Text("تسجيل", textAlign: TextAlign.right),
          ),
        ],
      ),
    );
  }

  Color get _primaryColor => widget.primaryColor ?? Colors.green.shade700;

  @override
  void dispose() {
    _subscription?.cancel();
    _controller.dispose();
    _serverController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appTitle!, textAlign: TextAlign.right),
        backgroundColor: _primaryColor,
        actions: [
          IconButton(
            tooltip: "Changer serveur",
            icon: const Icon(Icons.settings_ethernet),
            onPressed: changeServerDialog,
          ),
          IconButton(
            tooltip: "Vider la discussion",
            icon: const Icon(Icons.delete_forever),
            onPressed: clearMessages,
          ),
          IconButton(
            tooltip: "Arrêter la réponse",
            icon: const Icon(Icons.stop_circle),
            onPressed: stopResponse,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["role"] == "user";
                return Align(
                  alignment:
                  isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: isUser ? _primaryColor.withOpacity(0.3) : Colors.blueGrey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      msg["content"]!,
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: "اكتب سؤالك هنا...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (_) => sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.send, color: _primaryColor),
            onPressed: sendMessage,
          ),
        ],
      ),
    );
  }
}