import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 0)
class ChatMessage extends HiveObject {
  @HiveField(0)
  String role;

  @HiveField(1)
  String content;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  String? audioBase64;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
    this.audioBase64,
  });
}
