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
  List<Map<String, String>> chatHistory = [];
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
  }

  Future<void> _sendRequest(String userPrompt) async {
    if (isGenerating) return;

    setState(() {
      isGenerating = true;
    });

    var response = await http.post(
      Uri.parse('https://bhav-xd21.onrender.com/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': userPrompt}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        chatHistory.add({'role': 'user', 'content': userPrompt});
        chatHistory.add({'role': 'assistant', 'content': data['response']});
        if (playAudio) _playAudio(data['audio']);
        emergencyNumber = data['call'];
      });

      if (emergencyNumber != null && emergencyNumber!.isNotEmpty) {
        _dialEmergencyNumber(emergencyNumber!);
      }
    }
    setState(() {
      isGenerating = false;
    });
  }

  Future<void> _playAudio(String base64Audio) async {
    Uint8List audioBytes = base64.decode(base64Audio);
    await audioPlayer.stop();
    await audioPlayer.play(BytesSource(audioBytes));
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
    PermissionStatus status = await Permission.microphone.request();
    if (status.isGranted) {
      bool available = await _speech.initialize(
        onStatus: (val) => setState(() {
          _isListening = val == "listening";
        }),
        onError: (val) => setState(() {
          _isListening = false;
        }),
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
      } else {
        print("Speech recognition is not available.");
      }
    } else {
      print("Microphone permission not granted");
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  Future<void> _logout() async {
    bool confirmLogout = await _showLogoutConfirmation();
    if (confirmLogout) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    }
  }

  Future<bool> _showLogoutConfirmation() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Logout Confirmation"),
            content: const Text("Are you sure you want to log out?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Logout", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    _controller.dispose();
    super.dispose();
  }

  /// Widget to display a single chat message.
  Widget _buildChatMessage(Map<String, String> message) {
    final bool isUser = message['role'] == 'user';
    return ListTile(
      title: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF64B5F6) : const Color(0xFF512DA8),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            message['content'] ?? '',
            style: TextStyle(
              color: isUser ? Colors.black : Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// Opens the modal settings panel.
  void _openSettingsPanel() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Transparent background for rounded corners.
      builder: (BuildContext context) {
        // Use StatefulBuilder to allow the modal to update state.
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Audio Playback Toggle
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Audio Playback:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Switch(
                        activeColor: const Color(0xFF8E24AA),
                        value: playAudio,
                        onChanged: (bool value) {
                          setState(() {
                            playAudio = value;
                          });
                          setModalState(() {});
                        },
                      ),
                    ],
                  ),
                  // Clear Chat Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F)),
                    onPressed: () {
                      setState(() {
                        chatHistory.clear();
                      });
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text("Clear Chat",
                        style: TextStyle(color: Colors.white)),
                  ),
                  // Open Menu Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5)),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    icon: const Icon(Icons.menu, color: Colors.white),
                    label: const Text("Menu",
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E88E5),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25.0),
              child: Image.asset(
                'assets/logo.png',
                height: 30,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'BHAV - AI',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.settings, color: Colors.white),
          onPressed: _openSettingsPanel,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFF1E88E5),
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: const Text('Consult a Specialist'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ConsultSpecialistPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.sentiment_satisfied),
              title: const Text('Analyze your mood'),
              onTap: () {
                List<String> userPrompts = chatHistory
                    .where((msg) => msg['role'] == 'user')
                    .map((msg) => msg['content'] ?? '')
                    .toList();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SentimentChartPage(userPrompts: userPrompts),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatHistory.length + (isGenerating ? 1 : 0),
              itemBuilder: (context, index) {
                if (isGenerating && index == chatHistory.length) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SpinKitFadingCircle(
                        color: const Color(0xFF8E24AA),
                        size: 50.0,
                      ),
                    ),
                  );
                }
                final message = chatHistory[index];
                return _buildChatMessage(message);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'আপনার প্রশ্ন লিখুন...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isGenerating
                      ? null
                      : () {
                          if (_controller.text.isNotEmpty) {
                            _sendRequest(_controller.text);
                            _controller.clear();
                          }
                        },
                  child: const Icon(Icons.send, color: Colors.white),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3949AB)),
                  onPressed: _isListening ? _stopListening : _startListening,
                  child: Icon(_isListening ? Icons.mic_off : Icons.mic,
                      color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}