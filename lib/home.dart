// home.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'chat_message.dart';
import 'login.dart';
import 'consult_specialist.dart';
import 'sentiment.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _controller = TextEditingController();
  late Box<ChatMessage> chatBox;
  List<ChatMessage> chats = [];
  bool playAudio = true;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool isGenerating = false;
  String? emergencyNumber;
  AudioPlayer audioPlayer = AudioPlayer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    chatBox = Hive.box<ChatMessage>('chatMessages');
    _loadChatHistory();
  }

  void _loadChatHistory() {
    final messages = chatBox.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    setState(() {
      chats = messages;
    });
  }

  Future<void> _saveChatMessage(String role, String content, {String? audio}) async {
    final message = ChatMessage(
      role: role,
      content: content,
      timestamp: DateTime.now(),
      audioBase64: audio,
    );
    await chatBox.add(message);
    setState(() {
      chats.add(message);
    });
  }

  Future<void> _sendRequest(String userPrompt) async {
    if (isGenerating) return;
    setState(() { isGenerating = true; });
    await _saveChatMessage('user', userPrompt);

    var response = await http.post(
      Uri.parse('https://bhav-xd21.onrender.com/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': userPrompt}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      await _saveChatMessage('assistant', data['response'], audio: data['audio']);
      if (playAudio) _playAudio(data['audio']);
      emergencyNumber = data['call'];
      if (emergencyNumber?.isNotEmpty == true) {
        _dialEmergencyNumber(emergencyNumber!);
      }
    }
    setState(() { isGenerating = false; });
  }

  Future<void> _playAudio(String base64Audio) async {
    Uint8List bytes = base64.decode(base64Audio);
    await audioPlayer.stop();
    await audioPlayer.play(BytesSource(bytes));
  }

  Future<void> _dialEmergencyNumber(String number) async {
    final intent = AndroidIntent(
      action: 'android.intent.action.DIAL',
      data: 'tel:$number',
      flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
    );
    await intent.launch();
  }

  void _startListening() async {
    if (await Permission.microphone.request().isGranted) {
      bool available = await _speech.initialize(
        onStatus: (val) => setState(() => _isListening = val == "listening"),
        onError: (val) => setState(() => _isListening = false),
      );
      if (available) {
        _speech.listen(
          localeId: 'bn_BD',
          onResult: (val) {
            if (val.recognizedWords.isNotEmpty) {
              setState(() {
                _controller.text = val.recognizedWords;
              });
            }
          },
        );
      }
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() { _isListening = false; });
  }

  Future<void> _logout() async {
    bool confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Logout", style: TextStyle(color: Colors.red))),
        ],
      ),
    ) ?? false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      }
    }
  }

  void _openSettingsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModal) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Audio Playback:", style: TextStyle(fontWeight: FontWeight.bold)),
                Switch(
                  value: playAudio,
                  onChanged: (val) {
                    setState(() { playAudio = val; });
                    setModal(() {});
                  },
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () { chatBox.clear(); setState(() => chats.clear()); Navigator.pop(ctx); },
              icon: const Icon(Icons.delete), label: const Text("Clear Chat"),
            ),
            ElevatedButton.icon(
              onPressed: () { Navigator.pop(ctx); _scaffoldKey.currentState?.openDrawer(); },
              icon: const Icon(Icons.menu), label: const Text("Menu"),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    bool isUser = msg.role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Icon(Icons.smart_toy, size: 16, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              decoration: BoxDecoration(
                color: isUser ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    msg.content,
                    style: TextStyle(
                      color: isUser ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
                    showCursor: true,
                    cursorColor: Theme.of(context).colorScheme.primary,
                  ),
                  if (!isUser)
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: msg.content));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text('Response copied'), backgroundColor: Theme.of(context).colorScheme.primary),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.content_copy, size: 12, color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text('Tap to copy', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6), fontSize: 10)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(Icons.person, size: 16, color: Theme.of(context).colorScheme.onSecondary),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.asset('assets/logo.png', height: 30)),
          const SizedBox(width: 10),
          const Text('BHAV - AI', style: TextStyle(fontWeight: FontWeight.bold)),
        ]),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.settings), onPressed: _openSettingsPanel),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      drawer: Drawer(
        child: ListView(padding: EdgeInsets.zero, children: [
          DrawerHeader(decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
            child: const Text('Menu', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
          ListTile(
            leading: const Icon(Icons.medical_services),
            title: const Text('Consult a Specialist'),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConsultSpecialistPage())),
          ),
          ListTile(
            leading: const Icon(Icons.sentiment_satisfied),
            title: const Text('Analyze your mood'),
            onTap: () {
              List<String> prompts = chats.map((m) => m.content).toList();
              Navigator.push(context, MaterialPageRoute(builder: (_) => SentimentChartPage(userPrompts: prompts)));
            },
          ),
        ]),
      ),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            itemCount: chats.length + (isGenerating ? 1 : 0),
            itemBuilder: (ctx, idx) {
              if (isGenerating && idx == chats.length) {
                return const Center(child: SpinKitFadingCircle(color: Colors.indigoAccent, size: 50));
              }
              return _buildChatBubble(chats[idx]);
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          ),
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'আপনার প্রশ্ন লিখুন...',
                  hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(_isListening ? Icons.mic_off : Icons.mic, color: _isListening ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary),
            ),
            IconButton(
              onPressed: isGenerating || _controller.text.trim().isEmpty ? null : () {
                _sendRequest(_controller.text.trim());
                _controller.clear();
              },
              icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onPrimary),
              color: Theme.of(context).colorScheme.primary,
            ),
          ]),
        ),
      ]),
    );
  }
}

