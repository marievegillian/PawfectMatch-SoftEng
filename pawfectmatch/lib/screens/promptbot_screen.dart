/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/controller/promptbot_control.dart';
// import 'package:pawfectmatch/screens/appointment_screen.dart';

// import 'package:flutter/material.dart';
// import 'promptbot_control.dart';

class PromptBotScreen extends StatefulWidget {
  @override
  _PromptBotScreenState createState() => _PromptBotScreenState();
}

class _PromptBotScreenState extends State<PromptBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  // final List<String> _messages = [];
  // final PromptBotController _controllerBot = PromptBotController();

  void _sendMessage() async {
    final text = _controller.text;
    setState(() {
      _messages.add({"role": "user", "text": text});
      _controller.clear();
    });

    // String botResponse = await _controllerBot.handleUserMessage(text);
    // setState(() {
    //   _messages.add("PromptBot: $botResponse");
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PromptBot', 
          style: const TextStyle(
            color: Colors.white
          )
        ),
        backgroundColor: const Color(0xff011F3F),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // return ListTile(
                //   title: Text(_messages[index]),
                // );
                final message = _messages[index];
                final isUserMessage = message["role"] == "user";
                return Align(
                  alignment:
                      isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.7,
                    ),
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUserMessage ? Colors.blue[200] : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(message["text"]!),
                    ),
                  )
                );
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
                    decoration: InputDecoration(labelText: 'Type a message'),
                    onSubmitted: (value) => _sendMessage(),
                    maxLines:null,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pawfectmatch/controller/promptbot_control.dart';
// import 'promptmessages_model.dart';
import 'package:pawfectmatch/models/models.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PromptBotScreen extends StatefulWidget {
  @override
  _PromptBotScreenState createState() => _PromptBotScreenState();
}

class _PromptBotScreenState extends State<PromptBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final PromptBotController _promptBotController = PromptBotController();
  final List<PromptMessage> _messages = [];
  late String _userID;

  @override
  void initState() {
    super.initState();
    _userID = FirebaseAuth.instance.currentUser!.uid;
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
  try {
    final messages = await _promptBotController.getMessages(_userID);
    setState(() {
      _messages.addAll(messages);
    });
  } catch (e) {
    print('Error fetching messages: $e');
  }
}


  void _sendMessage() async {
    final text = _controller.text;
    if (text.isNotEmpty) {
      setState(() {
        _messages.add(PromptMessage(
          messageContent: text,
          timestamp: Timestamp.now(),
          userID: _userID,
        ));
        _controller.clear();
      });

      await _promptBotController.sendUserMessage(text, _userID);

      // Example bot response handling
      final botReply = 'Let me fetch some data for you.';
      await _promptBotController.sendBotReply(botReply, _userID);
      setState(() {
        _messages.add(PromptMessage(
          messageContent: botReply,
          timestamp: Timestamp.now(),
          userID: '100', // Bot userID
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PromptBot'),
        backgroundColor: const Color(0xff011F3F),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUserMessage = message.userID != '100';
                return Align(
                  alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isUserMessage ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message.messageContent),
                  ),
                );
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
                    decoration: InputDecoration(labelText: 'Type a message'),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
