import 'package:chat_app/helpers/chat_helper.dart';
import 'package:chat_app/helpers/user_helper.dart';
import 'package:chat_app/models/group.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart' as user;
import 'package:chat_app/values/collections.dart';
import 'package:chat_app/widgets/app_bar_widget.dart';
import 'package:chat_app/widgets/chat_bubble_widget.dart';
import 'package:chat_app/widgets/loader_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isInit = true;
  bool _isLoading = true;
  Group? _groupData;
  user.User? _currentUserData;
  TextEditingController newMessageController = TextEditingController();
  @override
  void didChangeDependencies() async {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      _groupData = ModalRoute.of(context)!.settings.arguments as Group;
      print(_groupData!.toJson());
     _currentUserData = await UsersHelper().getCurrentUserData();

      setState(() {
        _isLoading = false;
        _isInit = true;
      });
    }

    super.didChangeDependencies();
  }

  // Future<void> _getCurrentUserData() async {
  //   final currentAuthId = FirebaseAuth.instance.currentUser!.uid;
  //   print('auth id $currentAuthId');
  //   _currentUserData = await FirebaseFirestore.instance
  //       .collection(collectionUsers)
  //       .where('authId', isEqualTo: currentAuthId)
  //       .get()
  //       .then((value) => user.User.fromJson(value.docs.first.data()));
  // }

  Future<void> _sendMessage() async {
    final messageInstance =
        FirebaseFirestore.instance.collection(collectionChats).doc();

    final newMessage = Message(
      id: messageInstance.id,
      message: newMessageController.text.trim(),
      senderId: _currentUserData!.id,
      receiverId: null,
      groupId: _groupData!.id,
      createdAt: DateTime.now().toIso8601String(),
    );

    await messageInstance.set(newMessage.toJson()).then((value) {
      newMessageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: _groupData!.name!,
      ),
      body: _isLoading
          ? const LoaderWidget()
          : Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: ChatHelper()
                        .getGroupChatStream(groupId: _groupData!.id!),
                    builder: (ctx, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const LoaderWidget();
                      }

                      final chatList = snapshot.data;
                      return ListView.builder(
                          reverse: true,
                          itemCount: chatList!.length,
                          itemBuilder: (ctx, index) => ChatBubbleWidget(
                              currentUserId: _currentUserData!.id!,
                              // receiverUser: null,
                              message: chatList[index]));
                    },
                  ),
                ),
                Divider(),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 10),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        child: TextField(
                          controller: newMessageController,
                          textCapitalization: TextCapitalization.sentences,
                          autocorrect: true,
                          enableSuggestions: true,
                          decoration: const InputDecoration(
                              labelText: 'Send a message...'),
                          // onChanged: (value) {
                          //   setState(() {
                          //     _enteredMessage = value;
                          //   });
                          // },
                        ),
                      ),
                      IconButton(
                        color: Theme.of(context).primaryColor,
                        icon: const Icon(
                          Icons.send,
                        ),
                        onPressed: () async {
                          if (newMessageController.text.trim().isNotEmpty) {
                            await _sendMessage();
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
