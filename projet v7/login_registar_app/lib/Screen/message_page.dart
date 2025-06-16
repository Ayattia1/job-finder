import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:login_registar_app/config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async'; 
import 'package:flutter/foundation.dart';

class MessagePage extends StatefulWidget {
  final int jobId;
  final int employerId;
  final String employerName;
  final String jobTitle;

  const MessagePage({
    Key? key,
    required this.jobId,
    required this.employerId,
    required this.employerName,
    required this.jobTitle,
  }) : super(key: key);

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<Message> messages = [];
  final TextEditingController _messageController = TextEditingController();
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    fetchMessages();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    fetchMessages(); 
  });
  }

@override
void dispose() {
  _timer?.cancel();
  _messageController.dispose();
  super.dispose();
}

Future<void> fetchMessages() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  final response = await http.get(
    Uri.parse('${Config.baseUrl}/messages?employer_id=${widget.employerId}'),
    headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> jsonMessages = data['messages'];
    final newMessages = jsonMessages.map((m) => Message.fromJson(m)).toList().reversed.toList();

    if (!listEquals(newMessages, messages)) {
      setState(() {
        messages = newMessages;
      });
    }
  }
}


  Future<void> sendMessage() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/messages'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'employer_id': widget.employerId,
        'content': content,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      _messageController.clear();
      final responseData = json.decode(response.body);
      final newMessage = Message.fromJson(responseData['data']);
      setState(() {
        messages.insert(0, newMessage);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.employerName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Poste : ${widget.jobTitle}',
                style: TextStyle(fontSize: 14),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isMe = message.isMine;

                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 4),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue[600] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.content,
                          style: TextStyle(
                              color: isMe ? Colors.white : Colors.black87),
                        ),
                        SizedBox(height: 4),
                        Text(
                          message.timestamp,
                          style: TextStyle(
                              color: isMe ? Colors.white70 : Colors.grey[600],
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Écrire un message...',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              maxLines: null,
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.blue[600],
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final int id;
  final int senderId;
  final String content;
  final String timestamp;
  final bool isMine;

  Message({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    required this.isMine,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      senderId: json['sender_id'],
      content: json['content'],
      timestamp: json['created_at'],
      isMine: json['is_mine'] ?? false,
    );
  }
}
