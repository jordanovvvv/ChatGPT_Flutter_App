import 'dart:async';

import 'package:flutter/material.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'chatmessage.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  late OpenAI chatGPT;
  @override
  void initState(){
    chatGPT = OpenAI.instance.build(
      token: "API_KEY",
      baseOption: HttpSetup(receiveTimeout: Duration(seconds: 60))
    );
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }




  void _sendMessage() async {
    if(_controller.text.isEmpty) return;
    ChatMessage _message = ChatMessage(
        text: _controller.text,
        sender: "user",
    );

    setState(() {
      _messages.insert(0, _message);
    });

    _controller.clear();

    final request = CompleteText(
        prompt: _message.text, model: TextDavinci3Model());

    final response = await chatGPT.onCompletion(request: request);

    Vx.log(response!.choices[0].text);
    insertNewData(response.choices[0].text);
  }
  void insertNewData(String response){
    ChatMessage botMessage = ChatMessage(text: response, sender: "bot");


    setState(() {
      _messages.insert(0, botMessage);
    });
  }

  Widget _buildTextComposer(){
    return Row(children: [
         Expanded(
          child: TextField(
            controller: _controller,
            onSubmitted: (value) => _sendMessage(),
            decoration: InputDecoration.collapsed(hintText: "Send a message"),
          ),
        ),
      IconButton(
          onPressed: () => _sendMessage(),
          icon: const Icon(Icons.send))
      ],
    ).px16();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("ChatGPT Demo")),
      body: SafeArea(
        child: Column(
          children: [
            Flexible(
                child: ListView.builder(
                  reverse: true,
                    padding: Vx.m8,
                    itemCount: _messages.length,
                    itemBuilder: (context, index){
                      return _messages[index];
      }),
            ),
            Container(
              decoration: BoxDecoration(
                color: context.cardColor
              ),
              child: _buildTextComposer(),
            )
          ],
        ),
      ),
    );
  }
}
