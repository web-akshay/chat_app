import 'package:chat_app/models/message.dart';
import 'package:chat_app/values/collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatHelper {
  Stream<List<Message>> getSingleUserChatStream(
      {required String senderId, required String receiverId}) {
    print('receiverId----->$receiverId');
    // return FirebaseFirestore.instance
    //     .collection(collectionChats)
    //     .where('receiverId', whereIn: [receiverId, senderId])
    //     // .orderBy('createdAt', descending: true)
    return FirebaseFirestore.instance
        .collection(collectionChats)
        .where('receiverId', whereIn: [receiverId, senderId])

        // .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Message.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Stream<List<Message>> getGroupChatStream({required String groupId}) {
    // return FirebaseFirestore.instance
    //     .collection(collectionChats)
    //     .where('receiverId', whereIn: [receiverId, senderId])
    //     // .orderBy('createdAt', descending: true)
    return FirebaseFirestore.instance
        .collection(collectionChats)
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Message.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<String> _createChatRoom({required List<String> users}) async {
    final chatRoomInstance =
        FirebaseFirestore.instance.collection(collectionChatRooms).doc();
    await chatRoomInstance.set({
      'id': chatRoomInstance.id,
      'users': users,
    });
    return chatRoomInstance.id;
  }

  Future<String> getChatRoomId({required List<String> users}) async {
    print(users);
    final chatRoomInstance = await FirebaseFirestore.instance
        .collection(collectionChatRooms)
        .where('users', arrayContains: '')
        .where('users', arrayContains: '00')
        .get()
        .then((value) => value.docs);
    if (chatRoomInstance.isEmpty) {
      print('room created---->');
      // return _createChatRoom(users: users);
    }
    print(chatRoomInstance.length);
    print('not created---->');

    return 'chatRoomInstance';
  }
}
