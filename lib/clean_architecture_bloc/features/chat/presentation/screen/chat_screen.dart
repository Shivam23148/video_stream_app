import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntavideofeedapp/clean_architecture_bloc/features/chat/data/models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<ChatModel> chat = [];
  final TextEditingController chatMessage = TextEditingController();

  void addNewMessage(String message, DateTime createdAt) {
    setState(() {
      chat.add(ChatModel(DateTime.now().toString(), message, createdAt));
    });
  }

  String formatTime(DateTime time) {
    return DateFormat('hh:mm a').format(time);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, title: Text("Chat Screen")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          chat.isEmpty
              ? Center(
                  child: Text(
                    "No Chat Initiated",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Expanded(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(
                      context,
                    ).copyWith(overscroll: false),
                    child: ListView.builder(
                      reverse: true,
                      itemCount: chat.length,
                      itemBuilder: (context, index) {
                        final chatMessage = chat[chat.length - 1 - index];
                        return ChatBubble(message: chatMessage);
                      },
                    ),
                  ),
                ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: chatMessage,
                  decoration: InputDecoration(
                    hintText: 'Type a message....',
                    fillColor: Colors.transparent,
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                  ),
                  cursorColor: Colors.black,
                ),
              ),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  addNewMessage(chatMessage.text, DateTime.now());
                  chatMessage.clear();
                },
                icon: Icon(Icons.arrow_forward_outlined),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  ChatBubble({super.key, required this.message});
  final ChatModel message;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.7;
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        child: Text(
          message.message,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(0),
          ),
        ),
      ),
    );
  }
}
