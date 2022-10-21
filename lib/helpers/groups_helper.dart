import 'package:chat_app/models/group.dart';
import 'package:chat_app/values/collections.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsHelper {
  Stream<List<Group>> getAllGroupsStream() {
    return FirebaseFirestore.instance
        .collection(collectionGroups)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Group.fromJson(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> createGroup({required Group groupData}) async {
    final groupInstance =
        FirebaseFirestore.instance.collection(collectionGroups).doc();
    groupData.id = groupInstance.id;
          groupData.createdAt = DateTime.now().toIso8601String();
    await groupInstance.set(groupData.toJson());
  }
}
