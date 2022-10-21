import 'package:chat_app/helpers/user_helper.dart';
import 'package:chat_app/models/message.dart';
import 'package:chat_app/models/user.dart';
import 'package:chat_app/widgets/loader_widget.dart';
import 'package:flutter/material.dart';

class ChatBubbleWidget extends StatefulWidget {
  const ChatBubbleWidget(
      {required this.currentUserId,
      // required this.receiverUser,
      required this.message,
      super.key});
  final Message message;
  final String currentUserId;
  // final User? receiverUser;

  @override
  State<ChatBubbleWidget> createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  User? _userData = User();
  var _isLoading = true;
  @override
  void initState() {
    _getData();
    super.initState();
  }

  Future<void> _getData() async {
    _userData =
        await UsersHelper().getUserDetails(userId: widget.message.senderId);
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUserId == widget.message.senderId;
    return _isLoading
        ? LoaderWidget()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!currentUser)
                Padding(
                  padding: const EdgeInsets.only(left: 70.0),
                  child: Text(_userData!.name!),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: currentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  if (!currentUser)
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.yellow,
                      child: FlutterLogo(
                          // size: 40,
                          ),
                    ),
                  UnconstrainedBox(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 200,
                      margin: EdgeInsets.only(
                        left: currentUser ? 0 : 10,
                        right: currentUser ? 10 : 0,
                        top: 5,
                        bottom: 5,
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.only(
                          topLeft: currentUser
                              ? const Radius.circular(7)
                              : const Radius.circular(0),
                          topRight: currentUser
                              ? const Radius.circular(0)
                              : const Radius.circular(7),
                          bottomRight: currentUser
                              ? const Radius.circular(27)
                              : const Radius.circular(7),
                          bottomLeft: !currentUser
                              ? const Radius.circular(27)
                              : const Radius.circular(7),

                          // bottomLeft: !isMe ? Radius.circular(0) : Radius.circular(12),
                          // bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
                        ),
                      ),
                      child: Text(widget.message.message!),
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}
